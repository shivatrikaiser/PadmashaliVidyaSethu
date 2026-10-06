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

/// <summary>A single "Phone Number Verification Code" issued to a mobile number.</summary>
public class PhoneVerificationChallenge
{
    public Guid ChallengeId { get; set; }
    public string MobileNumber { get; set; } = string.Empty;

    /// <summary>HMAC-SHA256 of the code keyed with a server secret. The code itself is never stored or logged.</summary>
    public string CodeHash { get; set; } = string.Empty;

    public DateTime CreatedDate { get; set; }
    public DateTime ExpiresDate { get; set; }
    public int FailedAttemptCount { get; set; }
    public DateTime? VerifiedDate { get; set; }
    public string? RequestIp { get; set; }
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
