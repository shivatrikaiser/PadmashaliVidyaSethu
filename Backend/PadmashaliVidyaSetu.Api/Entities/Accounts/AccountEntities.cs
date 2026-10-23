using PadmashaliVidyaSetu.Api.Entities.Common;

namespace PadmashaliVidyaSetu.Api.Entities.Accounts;

/// <summary>
/// A login identity: one verified mobile number. An account can hold several member profiles
/// (for example a parent registering two children who have no phone of their own).
/// </summary>
public class Account : AuditableEntity
{
    public int AccountId { get; set; }

    /// <summary>E.164 format, e.g. +919876543210.</summary>
    public string MobileNumber { get; set; } = string.Empty;

    public DateTime? MobileVerifiedDate { get; set; }
    public DateTime? LastLoginDate { get; set; }

    /// <summary>
    /// Set when the user deleted their account in the app. Nothing is removed - the account and its members are kept
    /// (inactive) for the records - but the number can never sign in or register again.
    /// </summary>
    public DateTime? DeletedDate { get; set; }

    public bool IsDeleted => DeletedDate is not null;

    /// <summary>
    /// Admin portal password (ASP.NET Core Identity PBKDF2 hash), set by a Super Admin on the Admin users page.
    /// Only accounts with an admin role can sign in with it; null = no password sign-in.
    /// </summary>
    public string? PasswordHash { get; set; }
    public DateTime? PasswordSetDate { get; set; }

    /// <summary>Consecutive wrong passwords; reset by a successful sign-in or a new password.</summary>
    public int FailedPasswordAttempts { get; set; }
    public DateTime? PasswordLockedUntil { get; set; }

    public ICollection<AccountRole> AccountRoles { get; set; } = [];
}

/// <summary>Role master. Designed so coordinator roles can be activated without schema changes.</summary>
public class Role : MasterDataEntity;

public class AccountRole
{
    public int AccountId { get; set; }
    public Account Account { get; set; } = null!;
    public int RoleId { get; set; }
    public Role Role { get; set; } = null!;
    public DateTime CreatedDate { get; set; }
    public string? CreatedBy { get; set; }
}

public class RefreshToken
{
    public long RefreshTokenId { get; set; }
    public int AccountId { get; set; }
    public Account Account { get; set; } = null!;

    /// <summary>SHA-256 of the token. The raw token is never stored.</summary>
    public string TokenHash { get; set; } = string.Empty;

    public DateTime ExpiresDate { get; set; }
    public DateTime CreatedDate { get; set; }
    public string? CreatedByIp { get; set; }
    public DateTime? RevokedDate { get; set; }
    public string? ReplacedByTokenHash { get; set; }

    public bool IsActiveAt(DateTime utcNow) => RevokedDate is null && ExpiresDate > utcNow;
}

/// <summary>
/// A single verification code, issued to a mobile number ("Phone Number Verification Code") or - for
/// <see cref="VerificationPurposes.MemberEmail"/> - to an email address. Exactly one of the two is set.
/// </summary>
public class PhoneVerificationChallenge
{
    public Guid ChallengeId { get; set; }
    public string? MobileNumber { get; set; }

    /// <summary>The email address the code was sent to (lower case); only for <see cref="VerificationPurposes.MemberEmail"/>.</summary>
    public string? Email { get; set; }

    /// <summary><see cref="VerificationPurposes.SignIn"/> or <see cref="VerificationPurposes.MemberMobile"/>.</summary>
    public string Purpose { get; set; } = VerificationPurposes.SignIn;

    /// <summary>The signed-in account that asked for a <see cref="VerificationPurposes.MemberMobile"/> code; null for sign-in.</summary>
    public int? AccountId { get; set; }

    /// <summary>HMAC-SHA256 of the code keyed with a server secret. The code itself is never stored or logged.</summary>
    public string CodeHash { get; set; } = string.Empty;

    public DateTime CreatedDate { get; set; }
    public DateTime ExpiresDate { get; set; }
    public int FailedAttemptCount { get; set; }
    public DateTime? VerifiedDate { get; set; }
    public string? RequestIp { get; set; }
}

public static class VerificationPurposes
{
    /// <summary>Signs in (creating the account on first use).</summary>
    public const string SignIn = "SIGN_IN";

    /// <summary>Proves a family member's own mobile number at registration; never signs in.</summary>
    public const string MemberMobile = "MEMBER_MOBILE";

    /// <summary>Proves a member's (optional) email address at registration, with its own code sent to that address.</summary>
    public const string MemberEmail = "MEMBER_EMAIL";

    /// <summary>How long a verified member-number (or member-email) code may be used to register it.</summary>
    public static readonly TimeSpan MemberMobileProofLifetime = TimeSpan.FromHours(1);
}

public static class RoleCodes
{
    public const string Member = "MEMBER";
    public const string Admin = "ADMIN";
    public const string SuperAdmin = "SUPER_ADMIN";
    public const string DistrictCoordinator = "DISTRICT_COORDINATOR";
    public const string TempleCoordinator = "TEMPLE_COORDINATOR";
    public const string EducationCoordinator = "EDUCATION_COORDINATOR";
    public const string CareerCoordinator = "CAREER_COORDINATOR";
    public const string EmploymentCoordinator = "EMPLOYMENT_COORDINATOR";
    public const string ScholarshipCoordinator = "SCHOLARSHIP_COORDINATOR";
    public const string CommunicationManager = "COMMUNICATION_MANAGER";
}
