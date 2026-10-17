namespace PadmashaliVidyaSetu.Api.Entities.Compliance;

/// <summary>Immutable record of a consent decision. Never updated - a change of mind is a new row.</summary>
public class ConsentRecord
{
    public long ConsentRecordId { get; set; }
    public int AccountId { get; set; }
    public string? RegistrationId { get; set; }

    /// <summary>One of <see cref="ConsentTypes"/>.</summary>
    public string ConsentType { get; set; } = string.Empty;

    public string PolicyVersion { get; set; } = string.Empty;
    public bool IsGranted { get; set; }
    public DateTime RecordedDate { get; set; }
    public string? IpAddress { get; set; }
}

/// <summary>
/// Append-only audit trail of security-relevant and data-changing actions.
/// <see cref="Details"/> must never contain verification codes, tokens or sensitive personal data.
/// </summary>
public class AuditLog
{
    public long AuditLogId { get; set; }
    public int? AccountId { get; set; }
    public string Action { get; set; } = string.Empty;
    public string? EntityName { get; set; }
    public string? EntityKey { get; set; }
    public string? Details { get; set; }
    public string? IpAddress { get; set; }
    public DateTime CreatedDate { get; set; }
}

public static class ConsentTypes
{
    public const string PrivacyPolicy = "PRIVACY_POLICY";
    public const string GuardianConsent = "GUARDIAN_CONSENT";
}

public static class AuditActions
{
    public const string VerificationCodeRequested = "Auth.VerificationCodeRequested";
    public const string VerificationSucceeded = "Auth.VerificationSucceeded";
    public const string VerificationFailed = "Auth.VerificationFailed";
    public const string AccountCreated = "Auth.AccountCreated";
    public const string TokenRefreshed = "Auth.TokenRefreshed";
    public const string RefreshTokenReuseDetected = "Auth.RefreshTokenReuseDetected";
    public const string LoggedOut = "Auth.LoggedOut";
    public const string MemberRegistered = "Member.Registered";
    public const string MemberActivated = "Admin.MemberActivated";
    public const string MemberDeactivated = "Admin.MemberDeactivated";
    public const string MembersExported = "Admin.MembersExported";
    public const string ListItemCreated = "Admin.ListItemCreated";
    public const string ListItemUpdated = "Admin.ListItemUpdated";
    public const string OtherValueMapped = "Admin.OtherValueMapped";
    public const string RoleGranted = "Admin.RoleGranted";
    public const string RoleRevoked = "Admin.RoleRevoked";
    public const string LocationUpdated = "Admin.LocationUpdated";
    public const string TalukMerged = "Admin.TalukMerged";
    public const string BrandingUpdated = "Admin.BrandingUpdated";
}
