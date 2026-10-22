namespace PadmashaliVidyaSetu.Api.DTOs;

// ---------------------------------------------------------------- Common

public sealed record PagedResult<T>(IReadOnlyList<T> Items, int TotalCount, int Page, int PageSize);

public sealed record CountItem(string Label, int Count);

// ---------------------------------------------------------------- Members

/// <summary>Filters of the admin member list and export. Age is calculated on today's date in India.</summary>
public sealed record MemberSearchQuery(
    string? Search = null,
    int? TempleId = null,
    int? MemberStatusId = null,
    int? ClassId = null,
    int? DistrictId = null,
    int? AgeFrom = null,
    int? AgeTo = null,
    bool? IsActive = true,
    int Page = 1,
    int PageSize = 25);

public sealed record AdminMemberRowDto(
    string RegistrationId,
    string FullName,
    int Age,
    string Gender,
    string Temple,
    string MemberStatus,
    string? ClassOrEducation,
    string? District,
    string? Taluk,
    string MobileNumber,
    bool IsActive,
    DateTime RegistrationCompletedDate);

public sealed record ConsentDto(string ConsentType, string PolicyVersion, bool IsGranted, DateTime RecordedDate);

public sealed record AdminMemberDetailDto(
    MemberProfileDto Profile,
    string MobileNumber,
    bool IsActive,
    bool CanSeeSensitiveData,
    IReadOnlyList<ConsentDto> Consents);

public sealed record SetActiveRequest(bool IsActive);

// ---------------------------------------------------------------- Reports

public sealed record AdminSummaryDto(
    int ActiveMembers,
    int InactiveMembers,
    int Accounts,
    int RegisteredLast30Days,
    IReadOnlyList<CountItem> ByTemple,
    IReadOnlyList<CountItem> ByStatus,
    IReadOnlyList<CountItem> ByGender,
    IReadOnlyList<CountItem> ByOrganisation,
    /// <summary>Students only, grouped into five school stages (pre-primary ... college and other).</summary>
    IReadOnlyList<CountItem> StudentsByStage,
    IReadOnlyList<CountItem> ByAgeGroup,
    IReadOnlyList<CountItem> ByDistrict,
    IReadOnlyList<CountItem> ByMonth);

// ---------------------------------------------------------------- Master lists

public sealed record AdminListTypeDto(string Type, string Label);

public sealed record AdminListItemDto(int Id, string Name, string Code, int DisplayOrder, bool IsActive, bool IsProtected);

/// <summary>Code is required for temples only (2 digits, part of Registration IDs); other lists generate it.</summary>
public sealed record CreateListItemRequest(string? Name, string? Code, int? DisplayOrder);

public sealed record UpdateListItemRequest(string? Name, int? DisplayOrder, bool? IsActive);

// ---------------------------------------------------------------- "Other" values

public sealed record OtherValueDto(string ListType, string ListLabel, string Text, int MemberCount);

/// <summary>Moves every member who typed <see cref="Text"/> for "Other" to the list entry <see cref="TargetId"/>.</summary>
public sealed record MapOtherValueRequest(string? ListType, string? Text, int TargetId);

public sealed record MapOtherValueResultDto(int UpdatedRows);

// ---------------------------------------------------------------- Admin users

public sealed record AdminUserDto(
    int AccountId,
    string MobileNumber,
    IReadOnlyList<string> Roles,
    DateTime? LastLoginDate,
    bool HasPassword,
    DateTime? PasswordSetDate);

/// <summary><c>Password</c> is optional: set it here or later with <see cref="SetPasswordRequest"/>.</summary>
public sealed record GrantRoleRequest(string? MobileNumber, string? RoleCode, string? Password = null);

/// <summary>A Super Admin sets (or replaces) an admin's portal password.</summary>
public sealed record SetPasswordRequest(string? Password);

// ---------------------------------------------------------------- Splash branding

/// <summary>Sponsor (name, organisation, address) / "Powered by" for the app's splash, welcome screen and footer. The logo is served separately (see AppController).</summary>
public sealed record AppBrandingDto(
    string? SponsorName,
    string? SponsorOrganisation,
    /// <summary>Up to four lines separated by a line feed.</summary>
    string? SponsorAddress,
    string? PoweredBy,
    bool HasSponsorLogo,
    /// <summary>Changes with every edit; appended to the logo URL so caches refresh.</summary>
    string? SponsorLogoVersion,
    DateTime? ModifiedDate);

public sealed record UpdateBrandingRequest(string? SponsorName, string? PoweredBy, string? SponsorOrganisation = null, string? SponsorAddress = null);

// ---------------------------------------------------------------- App version

/// <summary>The current release for a platform. Apps older than <c>LatestVersion</c> ask the member to update.</summary>
public sealed record AppVersionDto(string Platform, string LatestVersion, bool IsMandatory, string? StoreUrl);

// ---------------------------------------------------------------- Push notifications

public sealed record SendNotificationRequest(string? Title, string? Body);

public sealed record PushNotificationDto(int Id, string Title, string Body, string Topic, DateTime SentDate, string? SentBy);

/// <summary><c>IsConfigured</c> false: the Firebase key is not set on the server, so nothing can be sent yet.</summary>
public sealed record NotificationOverviewDto(
    bool IsConfigured,
    string Topic,
    int MaxTitleLength,
    int MaxBodyLength,
    IReadOnlyList<PushNotificationDto> History);

// ---------------------------------------------------------------- Locations review

public sealed record LocationReviewItemDto(
    string Kind,
    int Id,
    string Name,
    int ParentId,
    string ParentName,
    string Source,
    bool IsActive,
    int AddressCount,
    DateTime CreatedDate);

public sealed record UpdateLocationRequest(string? Name, bool? IsActive);

public sealed record MergeTalukRequest(int TargetTalukId);
