using System.ComponentModel.DataAnnotations;

namespace PadmashaliVidyaSetu.Api.Configuration;

public class JwtOptions
{
    public const string Section = "Jwt";

    [Required] public string Issuer { get; set; } = "PadmashaliVidyaSetu";
    [Required] public string Audience { get; set; } = "PadmashaliVidyaSetu.Mobile";

    /// <summary>
    /// HMAC-SHA256 signing key, at least 32 bytes. Supplied through user-secrets (development) or
    /// environment variable <c>Jwt__SigningKey</c> / a secret store (staging, production). Never committed.
    /// </summary>
    public string? SigningKey { get; set; }

    [Range(5, 240)] public int AccessTokenMinutes { get; set; } = 30;
    [Range(1, 180)] public int RefreshTokenDays { get; set; } = 30;
}

public class PhoneVerificationOptions
{
    public const string Section = "PhoneVerification";

    /// <summary>The product requirement is a 4-digit code. Not configurable on purpose.</summary>
    public const int CodeLength = 4;

    /// <summary>Must match the validity stated in the DLT SMS template ("Valid for 10 minutes").</summary>
    [Range(60, 1800)] public int CodeLifetimeSeconds { get; set; } = 600;
    [Range(0, 600)] public int ResendCooldownSeconds { get; set; } = 30;
    [Range(1, 50)] public int MaxCodesPerHourPerNumber { get; set; } = 5;
    [Range(1, 10)] public int MaxFailedAttemptsPerCode { get; set; } = 5;

    /// <summary>
    /// Secret used to HMAC verification codes before storage. Same handling as the JWT key.
    /// </summary>
    public string? CodeHashingKey { get; set; }

    /// <summary>
    /// Development only: return the issued code in the API response so the app can be exercised without an
    /// SMS provider. Startup refuses to run with this enabled outside the Development environment.
    /// </summary>
    public bool ExposeCodeInResponse { get; set; }

    /// <summary>Which <c>IVerificationCodeSender</c> to use: "SmsGatewayHub", "Development" or "NotConfigured".</summary>
    public string Sender { get; set; } = VerificationSenders.NotConfigured;
}

public static class VerificationSenders
{
    public const string SmsGatewayHub = nameof(SmsGatewayHub);
    public const string Development = nameof(Development);
    public const string NotConfigured = nameof(NotConfigured);
}

/// <summary>
/// SMS Gateway Hub (DLT) settings. Property names match the "SMS" configuration section.
/// <see cref="APIKey"/> is a secret: user-secrets in development, environment variable <c>SMS__APIKey</c> /
/// Key Vault elsewhere. Never commit it.
/// </summary>
public class SmsOptions
{
    public const string Section = "SMS";
    public const string CodePlaceholder = "{#numeric#}";

    public string? APIKey { get; set; }
    public string SMSURL { get; set; } = "https://www.smsgatewayhub.com/api/mt/SendSMS";
    public string OTPSenderId { get; set; } = string.Empty;
    public string OTPTemplateId { get; set; } = string.Empty;
    public string OTPEntityId { get; set; } = string.Empty;

    /// <summary>DLT-approved text. <see cref="CodePlaceholder"/> is replaced by the code; the rest must match exactly.</summary>
    public string OTPTemplate { get; set; } = string.Empty;

    /// <summary>Route id from the SMS Gateway Hub panel.</summary>
    public string Route { get; set; } = "1";

    /// <summary>2 = transactional.</summary>
    public string Channel { get; set; } = "2";

    [Range(2, 60)] public int TimeoutSeconds { get; set; } = 15;

    public IEnumerable<string> MissingSettings()
    {
        if (string.IsNullOrWhiteSpace(APIKey)) yield return "SMS:APIKey";
        if (!Uri.TryCreate(SMSURL, UriKind.Absolute, out var url) || url.Scheme != Uri.UriSchemeHttps) yield return "SMS:SMSURL (https)";
        if (string.IsNullOrWhiteSpace(OTPSenderId)) yield return "SMS:OTPSenderId";
        if (string.IsNullOrWhiteSpace(OTPTemplateId)) yield return "SMS:OTPTemplateId";
        if (string.IsNullOrWhiteSpace(OTPEntityId)) yield return "SMS:OTPEntityId";
        if (!OTPTemplate.Contains(CodePlaceholder, StringComparison.Ordinal)) yield return $"SMS:OTPTemplate (must contain {CodePlaceholder})";
    }
}

public class RegistrationOptions
{
    public const string Section = "Registration";

    [Range(1, 30)] public int MinimumAge { get; set; } = 5;
    [Range(30, 120)] public int MaximumAge { get; set; } = 100;
    [Range(1, 50)] public int MaxMembersPerAccount { get; set; } = 10;

    /// <summary>Members younger than this need a parent/guardian consent record.</summary>
    [Range(1, 21)] public int GuardianConsentRequiredBelowAge { get; set; } = 18;

    [Required] public string PrivacyPolicyVersion { get; set; } = "2026.10-draft";
}

public class PinCodeLookupOptions
{
    public const string Section = "PinCodeLookup";

    [Required, Url] public string BaseUrl { get; set; } = "https://api.postalpincode.in/";
    [Range(2, 60)] public int TimeoutSeconds { get; set; } = 10;
}

public class CorsSettings
{
    public const string Section = "Cors";
    public string[] AllowedOrigins { get; set; } = [];
}

public class DatabaseOptions
{
    public const string Section = "Database";

    /// <summary>Apply EF migrations (incl. master-data seed) at startup. Development convenience only.</summary>
    public bool ApplyMigrationsOnStartup { get; set; }
}
