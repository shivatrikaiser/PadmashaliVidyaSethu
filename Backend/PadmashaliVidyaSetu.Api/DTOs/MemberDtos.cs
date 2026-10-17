namespace PadmashaliVidyaSetu.Api.DTOs;

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
    int? CountryId);

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
    bool GuardianConsent);

public sealed record RegistrationResultDto(string RegistrationId, string FullName, string TempleName);

public sealed record LookupRefDto(int Id, string Name);

public sealed record AddressDto(
    string AddressType,
    string AddressLine1,
    string? AddressLine2,
    string PinCode,
    string CityVillageName,
    LookupRefDto Taluk,
    LookupRefDto District,
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
    DateTime RegistrationCompletedDate);

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
