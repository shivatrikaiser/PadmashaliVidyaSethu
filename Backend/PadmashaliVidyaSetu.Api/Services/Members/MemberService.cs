using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Entities.Members;

namespace PadmashaliVidyaSetu.Api.Services.Members;

public interface IMemberService
{
    Task<MyAccountDto> GetMyAccountAsync(CancellationToken ct);
    Task<MemberProfileDto> GetProfileAsync(string registrationId, CancellationToken ct);
    Task<MemberDashboardDto> GetDashboardAsync(string registrationId, CancellationToken ct);
}

public sealed class MemberService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IProfileCompletionService completion,
    IOptions<RegistrationOptions> registrationOptions,
    TimeProvider clock) : IMemberService
{
    public async Task<MyAccountDto> GetMyAccountAsync(CancellationToken ct)
    {
        var accountId = currentUser.RequireAccountId();
        var mobile = await db.Accounts.Where(a => a.AccountId == accountId).Select(a => a.MobileNumber).SingleAsync(ct);
        var today = clock.TodayInIndia();

        var members = await db.Members.AsNoTracking()
            .Where(m => m.AccountId == accountId && m.IsActive)
            .OrderBy(m => m.RegistrationCompletedDate)
            .Select(m => new
            {
                m.RegistrationId, m.FullName, m.DateOfBirth,
                TempleName = m.Temple.Name, StatusName = m.MemberStatus.Name, StatusCode = m.MemberStatus.Code,
                ClassStage = m.Class != null ? m.Class.Stage : null,
            })
            .ToListAsync(ct);

        var summaries = members.Select(m =>
        {
            var age = AgeCalculator.AgeOn(m.DateOfBirth, today);
            var percent = completion.Calculate(new ProfileFacts(m.RegistrationId, m.StatusCode, m.ClassStage, age)).OverallPercent;
            return new MemberSummaryDto(m.RegistrationId, m.FullName, age, m.TempleName, m.StatusName, percent);
        }).ToList();

        return new MyAccountDto(MobileNumber.Mask(mobile), summaries, registrationOptions.Value.MaxMembersPerAccount);
    }

    public async Task<MemberProfileDto> GetProfileAsync(string registrationId, CancellationToken ct)
    {
        var member = await db.Members.AsNoTracking()
            .Include(m => m.Gender).Include(m => m.Temple).Include(m => m.MemberStatus)
            .Include(m => m.Class).Include(m => m.HighestEducationLevel).Include(m => m.Organisation)
            .Include(m => m.Addresses).ThenInclude(a => a.Taluk)
            .Include(m => m.Addresses).ThenInclude(a => a.District)
            .Include(m => m.Addresses).ThenInclude(a => a.State)
            .Include(m => m.Addresses).ThenInclude(a => a.Country)
            .Include(m => m.Disabilities).ThenInclude(d => d.DisabilityType)
            .AsSplitQuery()
            .SingleOrDefaultAsync(m => m.RegistrationId == registrationId && m.IsActive, ct);

        EnsureCanView(member);
        var canSeeSensitive = member!.AccountId == currentUser.AccountId || currentUser.IsInRole(RoleCodes.SuperAdmin);

        return new MemberProfileDto(
            member.RegistrationId,
            member.FullName,
            member.FatherName,
            member.MotherName,
            member.DateOfBirth,
            AgeCalculator.AgeOn(member.DateOfBirth, clock.TodayInIndia()),
            Ref(member.Gender.Id, member.Gender.Name),
            Ref(member.Temple.Id, member.Temple.Name),
            Ref(member.MemberStatus.Id, member.MemberStatus.Name),
            member.MemberStatus.Code,
            member.Class is null ? null : Ref(member.Class.Id, member.Class.Name),
            member.HighestEducationLevel is null ? null : Ref(member.HighestEducationLevel.Id, member.HighestEducationLevel.Name),
            Ref(member.Organisation.Id, member.Organisation.Name),
            member.IsCurrentAddressSameAsPermanent,
            member.Addresses
                .OrderBy(a => a.AddressType == AddressTypes.Permanent ? 0 : 1)
                .Select(a => new AddressDto(a.AddressType, a.AddressLine1, a.AddressLine2, a.PinCode, a.CityVillageName,
                    Ref(a.Taluk.Id, a.Taluk.Name), Ref(a.District.Id, a.District.Name),
                    Ref(a.State.Id, a.State.Name), Ref(a.Country.Id, a.Country.Name)))
                .ToList(),
            canSeeSensitive && member.IsDisabled,
            canSeeSensitive
                ? member.Disabilities.Select(d => Ref(d.DisabilityType.Id, d.DisabilityType.Name)).ToList()
                : [],
            member.RegistrationCompletedDate);
    }

    public async Task<MemberDashboardDto> GetDashboardAsync(string registrationId, CancellationToken ct)
    {
        var m = await db.Members.AsNoTracking()
            .Where(x => x.RegistrationId == registrationId && x.IsActive)
            .Select(x => new
            {
                x.AccountId, x.RegistrationId, x.FullName, x.DateOfBirth, StatusCode = x.MemberStatus.Code,
                ClassStage = x.Class != null ? x.Class.Stage : null,
            })
            .SingleOrDefaultAsync(ct);

        if (m is null) throw new NotFoundException("Member not found.");
        if (m.AccountId != currentUser.AccountId && !currentUser.IsInRole(RoleCodes.Admin) && !currentUser.IsInRole(RoleCodes.SuperAdmin))
            throw new NotFoundException("Member not found.");

        var age = AgeCalculator.AgeOn(m.DateOfBirth, clock.TodayInIndia());
        var profile = completion.Calculate(new ProfileFacts(m.RegistrationId, m.StatusCode, m.ClassStage, age));
        return new MemberDashboardDto(m.RegistrationId, m.FullName, age, m.StatusCode, profile);
    }

    /// <summary>
    /// Members can only see profiles registered under their own mobile number. Admin access to other profiles is
    /// part of the admin portal phase. "Not found" is returned instead of "forbidden" so IDs cannot be probed.
    /// </summary>
    private void EnsureCanView(Member? member)
    {
        if (member is null) throw new NotFoundException("Member not found.");
        var isOwner = member.AccountId == currentUser.AccountId;
        var isAdmin = currentUser.IsInRole(RoleCodes.Admin) || currentUser.IsInRole(RoleCodes.SuperAdmin);
        if (!isOwner && !isAdmin) throw new NotFoundException("Member not found.");
    }

    private static LookupRefDto Ref(int id, string name) => new(id, name);
}
