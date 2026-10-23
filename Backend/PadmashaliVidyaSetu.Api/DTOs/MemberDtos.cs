namespace PadmashaliVidyaSetu.Api.DTOs;

/// <summary>
/// An address. In India: PIN code, City / Village, Taluk, District and State from the lists (PIN-code lookup).
/// Outside India: the postal code (optional), City / Town and State / Province - <c>StateId</c> from that country's
/// states, or <c>NewStateName</c> when it is not listed; District, Taluk and City are not used.
/// </summary>
public sealed record AddressRequest(
    string? AddressLine1,
    string? AddressLine2,
    string? PinCode,
    string? CityVillageName,
    int? CityId,
    int? TalukId,
    /// <summary>Used when the member's taluk is not in the list; it is added to the master for everyone.</summary>
    string? NewTalukName,
    int? DistrictId,
    int? StateId,
    int? CountryId,
    /// <summary>Outside India only: the state / province when it is not in the country's list; it is added to the master.</summary>
    string? NewStateName = null);

public sealed record RegisterMemberRequest(
    string? FullName,
    string? FatherName,
    string? MotherName,
    DateOnly? DateOfBirth,
    int? GenderId,
    int? TempleId,
    int? MemberStatusId,
    int? ClassId,
    int? HighestEducationLevelId,
    string? HighestEducationLevelOtherText,
    int? OrganisationId,
    AddressRequest? PermanentAddress,
    bool CurrentAddressSameAsPermanent,
    AddressRequest? CurrentAddress,
    bool IsDisabled,
    IReadOnlyList<int>? DisabilityTypeIds,
    string? OtherDisabilityDescription,
    bool AcceptPrivacyPolicy,
    bool GuardianConsent,
    /// <summary>Optional: the member's own mobile number. Unless it is the signed-in number, it must be verified first
    /// (POST members/mobile-verifications, then .../verify) and <c>MobileVerificationId</c> set to that challenge.</summary>
    string? MobileNumber = null,
    Guid? MobileVerificationId = null,
    /// <summary>Optional: the member's email address, verified first (POST members/email-verifications, then .../verify)
    /// with <c>EmailVerificationId</c> set to that challenge.</summary>
    string? Email = null,
    Guid? EmailVerificationId = null);

public sealed record RegistrationResultDto(string RegistrationId, string FullName, string TempleName);

public sealed record LookupRefDto(int Id, string Name);

public sealed record AddressDto(
    string AddressType,
    string AddressLine1,
    string? AddressLine2,
    string? PinCode,
    string CityVillageName,
    /// <summary>Null for an address outside India (also District).</summary>
    LookupRefDto? Taluk,
    LookupRefDto? District,
    LookupRefDto State,
    LookupRefDto Country);

public sealed record MemberProfileDto(
    string RegistrationId,
    string FullName,
    string FatherName,
    string MotherName,
    DateOnly DateOfBirth,
    int Age,
    LookupRefDto Gender,
    LookupRefDto Temple,
    LookupRefDto MemberStatus,
    string MemberStatusCode,
    LookupRefDto? Class,
    LookupRefDto? HighestEducationLevel,
    LookupRefDto Organisation,
    bool CurrentAddressSameAsPermanent,
    IReadOnlyList<AddressDto> Addresses,
    bool IsDisabled,
    IReadOnlyList<LookupRefDto> DisabilityTypes,
    DateTime RegistrationCompletedDate,
    /// <summary>The member's own verified mobile number, if any.</summary>
    string? MobileNumber = null,
    /// <summary>The member's verified email address, if any.</summary>
    string? Email = null);

public sealed record MemberSummaryDto(
    string RegistrationId,
    string FullName,
    int Age,
    string TempleName,
    string MemberStatusName,
    int ProfileCompletionPercent);

public sealed record MyAccountDto(string MaskedMobileNumber, IReadOnlyList<MemberSummaryDto> Members, int MaxMembersPerAccount);

public sealed record ProfileSectionDto(
    string Key,
    string Title,
    /// <summary>Complete, InProgress, NotStarted, NotApplicable.</summary>
    string Status,
    int Percent,
    /// <summary>False while the module is still being built (shown as "Coming soon").</summary>
    bool IsAvailable);

public sealed record ProfileCompletionDto(string RegistrationId, int OverallPercent, IReadOnlyList<ProfileSectionDto> Sections);

public sealed record MemberDashboardDto(
    string RegistrationId,
    string FullName,
    int Age,
    string MemberStatusCode,
    ProfileCompletionDto ProfileCompletion);
