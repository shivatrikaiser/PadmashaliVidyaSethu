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

    [Range(60, 1800)] public int CodeLifetimeSeconds { get; set; } = 300;
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

    /// <summary>Which <c>IVerificationCodeSender</c> to use: "Development" or "NotConfigured" (until a real provider is added).</summary>
    public string Sender { get; set; } = "NotConfigured";
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
