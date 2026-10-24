using System.Text;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.Members;
using PadmashaliVidyaSetu.Api.Logging;
using PadmashaliVidyaSetu.Api.Services.Members;

namespace PadmashaliVidyaSetu.Api.Services.Admin;

public interface IAdminMemberService
{
    Task<PagedResult<AdminMemberRowDto>> SearchAsync(MemberSearchQuery query, CancellationToken ct);
    Task<byte[]> ExportCsvAsync(MemberSearchQuery query, CancellationToken ct);
    Task<AdminMemberDetailDto> GetDetailAsync(string registrationId, CancellationToken ct);
    Task SetActiveAsync(string registrationId, bool isActive, CancellationToken ct);
}

public sealed class AdminMemberService(
    AppDbContext db,
    IMemberService members,
    ICurrentUserService currentUser,
    IAuditLogger audit,
    TimeProvider clock) : IAdminMemberService
{
    public const int MaxPageSize = 100;
    public const int MaxExportRows = 50_000;

    public async Task<PagedResult<AdminMemberRowDto>> SearchAsync(MemberSearchQuery query, CancellationToken ct)
    {
        var page = Math.Max(1, query.Page);
        var pageSize = Math.Clamp(query.PageSize, 1, MaxPageSize);
        var filtered = Filter(query);

        var total = await filtered.CountAsync(ct);
        var rows = await Rows(filtered.OrderByDescending(m => m.RegistrationCompletedDate).ThenBy(m => m.RegistrationId)
            .Skip((page - 1) * pageSize).Take(pageSize)).ToListAsync(ct);

        var today = clock.TodayInIndia();
        return new PagedResult<AdminMemberRowDto>(rows.Select(r => r.ToDto(today)).ToList(), total, page, pageSize);
    }

    public async Task<byte[]> ExportCsvAsync(MemberSearchQuery query, CancellationToken ct)
    {
        var rows = await Filter(query)
            .OrderBy(m => m.RegistrationId)
            .Take(MaxExportRows)
            .Select(m => new
            {
                m.RegistrationId, m.FullName, m.FatherName, m.MotherName, m.DateOfBirth,
                Gender = m.Gender.Name, Temple = m.Temple.Name, Status = m.MemberStatus.Name,
                Class = m.Class != null ? m.Class.Name : null,
                Education = m.HighestEducationLevel != null ? m.HighestEducationLevel.Name : null,
                m.HighestEducationLevelOtherText,
                Organisation = m.Organisation.Name,
                Mobile = m.Account.MobileNumber,
                m.Email,
                Address = m.Addresses.Where(a => a.AddressType == AddressTypes.Permanent)
                    .Select(a => new
                    {
                        a.AddressLine1, a.AddressLine2, a.CityVillageName, a.PinCode,
                        Taluk = a.Taluk != null ? a.Taluk.Name : null,
                        District = a.District != null ? a.District.Name : null,
                        State = a.State.Name, Country = a.Country.Name,
                    })
                    .FirstOrDefault(),
                m.IsActive, m.RegistrationCompletedDate,
            })
            .ToListAsync(ct);

        var today = clock.TodayInIndia();
        var csv = new StringBuilder();
        csv.AppendLine(string.Join(',', "Registration ID", "Full Name", "Father Name", "Mother Name", "Date of Birth", "Age",
            "Gender", "Temple", "Current Status", "Class Studying", "Highest Education", "Organisation", "Mobile", "Email",
            "Address Line 1", "Address Line 2", "City / Village", "PIN Code", "Taluk", "District", "State",
            "Country", "Active", "Registered (UTC)"));
        foreach (var r in rows)
        {
            var education = r.HighestEducationLevelOtherText is null ? r.Education : $"{r.Education}: {r.HighestEducationLevelOtherText}";
            csv.AppendLine(string.Join(',', new object?[]
            {
                r.RegistrationId, r.FullName, r.FatherName, r.MotherName, r.DateOfBirth.ToString("yyyy-MM-dd"),
                AgeCalculator.AgeOn(r.DateOfBirth, today), r.Gender, r.Temple, r.Status, r.Class, education,
                r.Organisation, r.Mobile, r.Email, r.Address?.AddressLine1, r.Address?.AddressLine2, r.Address?.CityVillageName,
                r.Address?.PinCode, r.Address?.Taluk, r.Address?.District, r.Address?.State,
                r.Address?.Country, r.IsActive ? "Yes" : "No", r.RegistrationCompletedDate.ToString("yyyy-MM-dd HH:mm"),
            }.Select(CsvField)));
        }

        audit.Add(AuditActions.MembersExported, "Member", null, $"{rows.Count} rows");
        await db.SaveChangesAsync(ct);

        // UTF-8 with BOM so Excel shows Kannada names correctly.
        return [.. Encoding.UTF8.GetPreamble(), .. Encoding.UTF8.GetBytes(csv.ToString())];
    }

    public async Task<AdminMemberDetailDto> GetDetailAsync(string registrationId, CancellationToken ct)
    {
        var profile = await members.GetProfileAsync(registrationId, ct);
        var extra = await db.Members.AsNoTracking()
            .Where(m => m.RegistrationId == registrationId)
            .Select(m => new { m.Account.MobileNumber, m.IsActive })
            .SingleAsync(ct);
        var consents = await db.ConsentRecords.AsNoTracking()
            .Where(c => c.RegistrationId == registrationId)
            .OrderBy(c => c.RecordedDate)
            .Select(c => new ConsentDto(c.ConsentType, c.PolicyVersion, c.IsGranted, c.RecordedDate))
            .ToListAsync(ct);

        return new AdminMemberDetailDto(profile, extra.MobileNumber, extra.IsActive,
            currentUser.IsInRole(RoleCodes.SuperAdmin), consents);
    }

    public async Task SetActiveAsync(string registrationId, bool isActive, CancellationToken ct)
    {
        var member = await db.Members.SingleOrDefaultAsync(m => m.RegistrationId == registrationId, ct)
                     ?? throw new NotFoundException("Member not found.");
        if (member.IsActive == isActive) return;

        member.IsActive = isActive;
        audit.Add(isActive ? AuditActions.MemberActivated : AuditActions.MemberDeactivated, "Member", registrationId);
        await db.SaveChangesAsync(ct);
    }

    private IQueryable<Member> Filter(MemberSearchQuery q)
    {
        var query = db.Members.AsNoTracking();
        if (q.IsActive is { } active) query = query.Where(m => m.IsActive == active);
        if (q.TempleId is { } templeId) query = query.Where(m => m.TempleId == templeId);
        if (q.MemberStatusId is { } statusId) query = query.Where(m => m.MemberStatusId == statusId);
        if (q.ClassId is { } classId) query = query.Where(m => m.ClassId == classId);
        if (q.OrganisationId is { } organisationId) query = query.Where(m => m.OrganisationId == organisationId);
        if (q.DistrictId is { } districtId)
            query = query.Where(m => m.Addresses.Any(a => a.AddressType == AddressTypes.Permanent && a.DistrictId == districtId));

        // Age on today's date: age >= From  <=>  born on or before today - From years.
        var today = clock.TodayInIndia();
        if (q.AgeFrom is { } from) query = query.Where(m => m.DateOfBirth <= today.AddYears(-from));
        if (q.AgeTo is { } to) query = query.Where(m => m.DateOfBirth > today.AddYears(-(to + 1)));

        var search = q.Search.Tidy();
        if (search.Length > 0)
        {
            var digits = new string(search.Where(char.IsDigit).ToArray());
            query = query.Where(m =>
                m.RegistrationId.Contains(search)
                || m.FullName.Contains(search)
                || m.FatherName.Contains(search)
                || m.MotherName.Contains(search)
                || (digits.Length >= 4 && m.Account.MobileNumber.Contains(digits)));
        }
        return query;
    }

    private static IQueryable<MemberRow> Rows(IQueryable<Member> query) =>
        query.Select(m => new MemberRow(
            m.RegistrationId, m.FullName, m.DateOfBirth, m.Gender.Name, m.Temple.Name, m.MemberStatus.Name,
            m.Class != null ? m.Class.Name : m.HighestEducationLevel != null ? m.HighestEducationLevel.Name : null,
            m.Addresses.Where(a => a.AddressType == AddressTypes.Permanent).Select(a => a.District != null ? a.District.Name : a.Country.Name).FirstOrDefault(),
            m.Addresses.Where(a => a.AddressType == AddressTypes.Permanent).Select(a => a.Taluk != null ? a.Taluk.Name : null).FirstOrDefault(),
            m.Account.MobileNumber, m.IsActive, m.RegistrationCompletedDate));

    private sealed record MemberRow(
        string RegistrationId, string FullName, DateOnly DateOfBirth, string Gender, string Temple, string Status,
        string? ClassOrEducation, string? District, string? Taluk, string Mobile, bool IsActive, DateTime Registered)
    {
        public AdminMemberRowDto ToDto(DateOnly today) => new(RegistrationId, FullName, AgeCalculator.AgeOn(DateOfBirth, today),
            Gender, Temple, Status, ClassOrEducation, District, Taluk, Mobile, IsActive, Registered);
    }

    /// <summary>
    /// CSV field, quoted when needed. A leading = or @ (or + / - not followed by a digit, so "+91..." stays a phone
    /// number) is prefixed with ' so Excel never runs member-typed text as a formula.
    /// </summary>
    /// <summary>One CSV value, quoted when needed; also guards against spreadsheet formula injection.</summary>
    internal static string CsvField(object? value)
    {
        var text = value?.ToString() ?? string.Empty;
        var formulaLike = text.Length > 0 && (text[0] is '=' or '@'
            || (text[0] is '+' or '-' && !(text.Length > 1 && char.IsDigit(text[1]))));
        if (formulaLike) text = "'" + text;
        return text.IndexOfAny([',', '"', '\n', '\r']) >= 0 ? $"\"{text.Replace("\"", "\"\"")}\"" : text;
    }
}
