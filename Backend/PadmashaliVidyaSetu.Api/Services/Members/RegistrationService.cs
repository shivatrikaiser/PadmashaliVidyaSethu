using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.Locations;
using PadmashaliVidyaSetu.Api.Entities.MasterData;
using PadmashaliVidyaSetu.Api.Entities.Members;
using PadmashaliVidyaSetu.Api.Logging;
using PadmashaliVidyaSetu.Api.Services.Locations;

namespace PadmashaliVidyaSetu.Api.Services.Members;

public interface IRegistrationService
{
    Task<RegistrationResultDto> RegisterAsync(RegisterMemberRequest request, CancellationToken ct);
}

/// <summary>
/// Creates a member's basic profile. Format/required-field rules live in <c>RegisterMemberRequestValidator</c>;
/// this service enforces the rules that need the database: master values exist and are active, the
/// Current Status ⇄ Class Studying / Highest Education rule, address hierarchy, disability handling, consents and
/// Registration ID allocation.
/// </summary>
public sealed class RegistrationService(
    AppDbContext db,
    IRegistrationIdGenerator registrationIds,
    LocationResolver locations,
    IAuditLogger audit,
    ICurrentUserService currentUser,
    IOptions<RegistrationOptions> options,
    TimeProvider clock,
    ILogger<RegistrationService> logger) : IRegistrationService
{
    private readonly RegistrationOptions _options = options.Value;

    public Task<RegistrationResultDto> RegisterAsync(RegisterMemberRequest request, CancellationToken ct)
    {
        // The execution strategy may re-run the whole unit on a transient SQL failure, so all entity
        // construction happens inside RegisterCoreAsync, starting from a clean change tracker.
        var strategy = db.Database.CreateExecutionStrategy();
        return strategy.ExecuteAsync(() => RegisterCoreAsync(request, ct));
    }

    private async Task<RegistrationResultDto> RegisterCoreAsync(RegisterMemberRequest r, CancellationToken ct)
    {
        db.ChangeTracker.Clear();
        var accountId = currentUser.RequireAccountId();
        var now = clock.GetUtcNow().UtcDateTime;
        var errors = new List<ApiError>();

        await EnsureAccountCanAddMemberAsync(accountId, r, ct);

        var gender = await ActiveAsync(db.Genders, r.GenderId);
        var temple = await ActiveAsync(db.Temples, r.TempleId);
        var status = await ActiveAsync(db.MemberStatuses, r.MemberStatusId);
        var organisation = await ActiveAsync(db.Organisations, r.OrganisationId);
        if (gender is null) errors.Add(new("genderId", "Please select a valid gender."));
        if (temple is null) errors.Add(new("templeId", "Please select a valid temple."));
        if (status is null) errors.Add(new("memberStatusId", "Please select a valid current status."));
        if (organisation is null) errors.Add(new("organisationId", "Please select a valid organisation option."));

        // Rules 1-4: Class Studying only for students; Highest Education only for working / unemployed.
        SchoolClass? schoolClass = null;
        EducationLevel? highestEducation = null;
        string? highestEducationOther = null;
        if (status?.Code == MasterCodes.StatusStudent)
        {
            schoolClass = await ActiveAsync(db.Classes, r.ClassId);
            if (schoolClass is null) errors.Add(new("classId", "Please select the class you are studying in."));
            if (r.HighestEducationLevelId is not null)
                errors.Add(new("highestEducationLevelId", "Highest education is not applicable for students."));
        }
        else if (status is not null)
        {
            highestEducation = await ActiveAsync(db.EducationLevels, r.HighestEducationLevelId);
            if (highestEducation is null) errors.Add(new("highestEducationLevelId", "Please select your highest education."));
            highestEducationOther = OtherText(highestEducation?.Code, r.HighestEducationLevelOtherText,
                "highestEducationLevelOtherText", "Please specify your highest education.", errors);
            if (r.ClassId is not null)
                errors.Add(new("classId", "Class Studying applies only when Current Status is Student."));
        }

        // Guardian consent for minors (age itself is range-checked by the validator).
        var age = AgeCalculator.AgeOn(r.DateOfBirth!.Value, clock.TodayInIndia());
        var isMinor = age < _options.GuardianConsentRequiredBelowAge;
        if (isMinor && !r.GuardianConsent)
            errors.Add(new("guardianConsent", "A parent or guardian must give consent for members under 18."));

        var permanent = await BuildAddressAsync(r.PermanentAddress!, "permanentAddress", AddressTypes.Permanent, errors, ct);
        var current = r.CurrentAddressSameAsPermanent
            ? permanent is null ? null : CopyAddress(permanent, AddressTypes.Current)
            : await BuildAddressAsync(r.CurrentAddress!, "currentAddress", AddressTypes.Current, errors, ct);

        var disabilities = r.IsDisabled
            ? await ResolveDisabilitiesAsync(r.DisabilityTypeIds ?? [], r.OtherDisabilityDescription, errors, ct)
            : [];

        if (errors.Count > 0) throw new RequestValidationException(errors);

        await using var transaction = await db.Database.BeginTransactionAsync(ct);

        var member = new Member
        {
            RegistrationId = await registrationIds.NextAsync(temple!.Id, temple.Code, ct),
            AccountId = accountId,
            FullName = r.FullName.Tidy(),
            FatherName = r.FatherName.Tidy(),
            MotherName = r.MotherName.Tidy(),
            DateOfBirth = r.DateOfBirth.Value,
            GenderId = gender!.Id,
            TempleId = temple.Id,
            MemberStatusId = status!.Id,
            ClassId = schoolClass?.Id,
            HighestEducationLevelId = highestEducation?.Id,
            HighestEducationLevelOtherText = highestEducationOther,
            OrganisationId = organisation!.Id,
            IsCurrentAddressSameAsPermanent = r.CurrentAddressSameAsPermanent,
            IsDisabled = r.IsDisabled,
            RegistrationCompletedDate = now,
        };
        member.Addresses.Add(permanent!);
        member.Addresses.Add(current!);
        foreach (var (typeId, otherText) in disabilities)
        {
            member.Disabilities.Add(new MemberDisability
            {
                DisabilityTypeId = typeId, OtherText = otherText, CreatedDate = now, CreatedBy = currentUser.AuditName,
            });
        }
        db.Members.Add(member);

        AddConsent(accountId, member.RegistrationId, ConsentTypes.PrivacyPolicy, now);
        if (isMinor) AddConsent(accountId, member.RegistrationId, ConsentTypes.GuardianConsent, now);

        audit.Add(AuditActions.MemberRegistered, "Member", member.RegistrationId,
            $"temple={temple.Code}; status={status.Code}");

        await db.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        logger.LogInformation("Member {RegistrationId} registered by account {AccountId}", member.RegistrationId, accountId);
        return new RegistrationResultDto(member.RegistrationId, member.FullName, temple.Name);
    }

    private async Task EnsureAccountCanAddMemberAsync(int accountId, RegisterMemberRequest r, CancellationToken ct)
    {
        var existing = await db.Members.AsNoTracking()
            .Where(m => m.AccountId == accountId && m.IsActive)
            .Select(m => new { m.FullName, m.DateOfBirth })
            .ToListAsync(ct);

        if (existing.Count >= _options.MaxMembersPerAccount)
            throw new BusinessRuleException(
                $"A mobile number can register at most {_options.MaxMembersPerAccount} members.");

        var fullName = r.FullName.Tidy();
        if (existing.Any(m => m.DateOfBirth == r.DateOfBirth &&
                              string.Equals(m.FullName, fullName, StringComparison.OrdinalIgnoreCase)))
            throw new ConflictException("This member is already registered with your mobile number.");
    }

    private static async Task<T?> ActiveAsync<T>(IQueryable<T> set, int? id) where T : MasterDataEntity =>
        id is null ? null : await set.FirstOrDefaultAsync(e => e.Id == id && e.IsActive);

    private async Task<MemberAddress?> BuildAddressAsync(
        AddressRequest a, string prefix, string addressType, List<ApiError> errors, CancellationToken ct)
    {
        var errorCount = errors.Count;

        var country = await ActiveAsync(db.Countries, a.CountryId);
        if (country is null)
        {
            errors.Add(new($"{prefix}.countryId", "Please select a valid country."));
            return null;
        }
        if (country.Code != MasterCodes.CountryIndia)
        {
            errors.Add(new($"{prefix}.countryId", "Only addresses in India are supported at the moment."));
            return null;
        }

        var state = await db.States.FirstOrDefaultAsync(s => s.Id == a.StateId && s.CountryId == country.Id && s.IsActive, ct);
        if (state is null)
        {
            errors.Add(new($"{prefix}.stateId", "Please select a valid state."));
            return null;
        }

        var district = await db.Districts.FirstOrDefaultAsync(d => d.Id == a.DistrictId && d.StateId == state.Id && d.IsActive, ct);
        if (district is null)
        {
            errors.Add(new($"{prefix}.districtId", "Please select a valid district for the selected state."));
            return null;
        }

        Taluk? taluk = null;
        if (a.TalukId is not null)
        {
            taluk = await db.Taluks.FirstOrDefaultAsync(t => t.Id == a.TalukId && t.DistrictId == district.Id && t.IsActive, ct);
            if (taluk is null) errors.Add(new($"{prefix}.talukId", "Please select a valid taluk for the selected district."));
        }
        else
        {
            taluk = await locations.ResolveTalukAsync(district, a.NewTalukName.Tidy(), LocationSources.UserSubmitted, ct);
        }

        City? city = null;
        if (a.CityId is not null)
        {
            city = await db.Cities.FirstOrDefaultAsync(c => c.Id == a.CityId && c.PinCode == a.PinCode, ct);
            if (city is null) errors.Add(new($"{prefix}.cityId", "The selected city/village does not match the PIN code."));
        }

        if (errors.Count > errorCount) return null;

        return new MemberAddress
        {
            AddressType = addressType,
            AddressLine1 = a.AddressLine1.Tidy(),
            AddressLine2 = string.IsNullOrWhiteSpace(a.AddressLine2) ? null : a.AddressLine2.Tidy(),
            PinCode = a.PinCode!.Trim(),
            CityVillageName = a.CityVillageName.Tidy(),
            City = city,
            Taluk = taluk!,
            District = district,
            State = state,
            Country = country,
        };
    }

    private static MemberAddress CopyAddress(MemberAddress source, string addressType) => new()
    {
        AddressType = addressType,
        AddressLine1 = source.AddressLine1,
        AddressLine2 = source.AddressLine2,
        PinCode = source.PinCode,
        CityVillageName = source.CityVillageName,
        City = source.City,
        Taluk = source.Taluk,
        District = source.District,
        State = source.State,
        Country = source.Country,
    };

    /// <summary>
    /// The disability types to link. "Other" is linked like any type, with the member's description as its
    /// <c>OtherText</c> (reviewed and mapped to a proper type by administrators).
    /// </summary>
    private async Task<List<(int TypeId, string? OtherText)>> ResolveDisabilitiesAsync(
        IReadOnlyList<int> ids, string? otherDescription, List<ApiError> errors, CancellationToken ct)
    {
        var distinctIds = ids.Distinct().ToList();
        var types = await db.DisabilityTypes.Where(t => distinctIds.Contains(t.Id) && t.IsActive).ToListAsync(ct);
        if (types.Count != distinctIds.Count)
        {
            errors.Add(new("disabilityTypeIds", "Please select valid disability types."));
            return [];
        }

        var otherText = OtherText(types.Any(t => t.Code == MasterCodes.Other) ? MasterCodes.Other : null, otherDescription,
            "otherDisabilityDescription", "Please specify the type of disability.", errors);
        return types.Select(t => (t.Id, t.Code == MasterCodes.Other ? otherText : null)).ToList();
    }

    /// <summary>
    /// Free text for a list's "Other" choice: required when <paramref name="selectedCode"/> is OTHER, ignored otherwise.
    /// </summary>
    private static string? OtherText(string? selectedCode, string? text, string field, string requiredMessage, List<ApiError> errors)
    {
        if (selectedCode != MasterCodes.Other) return null;
        var tidy = text.Tidy();
        if (tidy.Length == 0) errors.Add(new(field, requiredMessage));
        return tidy.Length == 0 ? null : tidy;
    }

    private void AddConsent(int accountId, string registrationId, string type, DateTime now) =>
        db.ConsentRecords.Add(new ConsentRecord
        {
            AccountId = accountId,
            RegistrationId = registrationId,
            ConsentType = type,
            PolicyVersion = _options.PrivacyPolicyVersion,
            IsGranted = true,
            RecordedDate = now,
            IpAddress = currentUser.IpAddress,
        });
}
