using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;
using PadmashaliVidyaSetu.Api.Common;

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
    /// <summary>
    /// Refresh token lifetime. Every refresh issues a new token with a fresh lifetime, so members stay signed in
    /// for as long as they open the app at least once in this period (3650 days: effectively never signed out).
    /// </summary>
    [Range(1, 3650)] public int RefreshTokenDays { get; set; } = 3650;
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

    /// <summary>Sender for Indian (+91) numbers: "SmsGatewayHub", "Development" or "NotConfigured".</summary>
    public string Sender { get; set; } = VerificationSenders.NotConfigured;

    /// <summary>Sender for numbers outside India (not +91): "WhatsApp", "Development" or "NotConfigured".</summary>
    public string InternationalSender { get; set; } = VerificationSenders.NotConfigured;

    /// <summary>
    /// Store-review sign-in (e.g. for Google Play): this one number signs in with a fixed code and nothing is ever
    /// sent to it. Sign-in only - not for a member's own number. Leave the number empty to switch it off.
    /// </summary>
    public TestLoginOptions TestLogin { get; set; } = new();

    /// <summary>Sender for email verification codes (a member's optional email address): "Smtp", "Development" or "NotConfigured".</summary>
    public string EmailSender { get; set; } = VerificationSenders.NotConfigured;
}

public class TestLoginOptions
{
    /// <summary>Any format <c>MobileNumber.TryNormalize</c> accepts, e.g. "917795276699". Empty = no test login.</summary>
    public string? MobileNumber { get; set; }

    /// <summary>The fixed 4-digit code for that number.</summary>
    public string? Code { get; set; }

    /// <summary>The number in E.164 form, or null when the test login is off or the number is invalid.</summary>
    public string? NormalizedMobile =>
        Common.MobileNumber.TryNormalize(MobileNumber, out var e164) ? e164 : null;

    public bool IsEnabled => !string.IsNullOrWhiteSpace(MobileNumber);

    /// <summary>Startup check: when enabled, the number must be valid and the code exactly 4 digits.</summary>
    public bool IsValid => !IsEnabled
        || (NormalizedMobile is not null && Code is { Length: PhoneVerificationOptions.CodeLength } && Code.All(char.IsAsciiDigit));
}

public static class VerificationSenders
{
    public const string SmsGatewayHub = nameof(SmsGatewayHub);
    public const string WhatsApp = nameof(WhatsApp);
    public const string Smtp = nameof(Smtp);
    public const string Development = nameof(Development);
    public const string NotConfigured = nameof(NotConfigured);
}

/// <summary>
/// WhatsApp Business Cloud API (Meta Graph API) settings for verification codes to numbers outside India.
/// The code is sent with an approved authentication template whose body has two text parameters: the recipient's
/// name ({{1}}) and the code ({{2}}). <see cref="AccessToken"/> is a secret: user-secrets in development, environment
/// variable <c>WhatsApp__AccessToken</c> / Key Vault elsewhere. Never commit it.
/// </summary>
public class WhatsAppOptions
{
    public const string Section = "WhatsApp";

    public string? AccessToken { get; set; }
    public string GraphApiUrl { get; set; } = "https://graph.facebook.com";
    public string ApiVersion { get; set; } = "v26.0";

    /// <summary>WhatsApp Business phone number id (Meta app → WhatsApp → API Setup), not the phone number itself.</summary>
    public string PhoneNumberId { get; set; } = string.Empty;

    public string TemplateName { get; set; } = string.Empty;
    public string TemplateLanguage { get; set; } = "en";

    /// <summary>Text for the template's name parameter ({{1}}): the number is not linked to a person when the code is sent.</summary>
    public string RecipientName { get; set; } = "Member";

    [Range(2, 60)] public int TimeoutSeconds { get; set; } = 15;

    public string MessagesUrl => $"{GraphApiUrl.TrimEnd('/')}/{ApiVersion}/{PhoneNumberId}/messages";

    public IEnumerable<string> MissingSettings()
    {
        if (string.IsNullOrWhiteSpace(AccessToken)) yield return "WhatsApp:AccessToken";
        if (!Uri.TryCreate(GraphApiUrl, UriKind.Absolute, out var url) || url.Scheme != Uri.UriSchemeHttps) yield return "WhatsApp:GraphApiUrl (https)";
        if (string.IsNullOrWhiteSpace(ApiVersion)) yield return "WhatsApp:ApiVersion";
        if (string.IsNullOrWhiteSpace(PhoneNumberId)) yield return "WhatsApp:PhoneNumberId";
        if (string.IsNullOrWhiteSpace(TemplateName)) yield return "WhatsApp:TemplateName";
        if (string.IsNullOrWhiteSpace(TemplateLanguage)) yield return "WhatsApp:TemplateLanguage";
        if (string.IsNullOrWhiteSpace(RecipientName)) yield return "WhatsApp:RecipientName";
    }
}

/// <summary>
/// SMS Gateway Hub (DLT) settings. Property names match the "SMS" configuration section.
/// <see cref="APIKey"/> is a secret: user-secrets in development, environment variable <c>SMS__APIKey</c> /
/// Key Vault elsewhere. Never commit it.
/// </summary>
public class SmsOptions
{
    public const string Section = "SMS";

    // The code goes into the template's DLT variable, whatever its name: {#var#}, {#num#}, {#numeric#}, ...
    private static readonly Regex CodeVariable = new(@"\{#[A-Za-z]+#\}", RegexOptions.CultureInvariant);

    public string? APIKey { get; set; }
    public string SMSURL { get; set; } = "https://www.smsgatewayhub.com/api/mt/SendSMS";
    public string OTPSenderId { get; set; } = string.Empty;
    public string OTPTemplateId { get; set; } = string.Empty;
    public string OTPEntityId { get; set; } = string.Empty;

    /// <summary>
    /// DLT-approved text, copied as registered (e.g. "... is {#var#} Valid for 10 minutes"). Its first {#...#}
    /// variable is replaced by the code; the rest must match the registered template exactly.
    /// </summary>
    public string OTPTemplate { get; set; } = string.Empty;

    /// <summary>The SMS text for <paramref name="code"/>.</summary>
    public string MessageText(string code) => CodeVariable.Replace(OTPTemplate, code, 1);

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
        if (!CodeVariable.IsMatch(OTPTemplate)) yield return "SMS:OTPTemplate (must contain a DLT variable such as {#var#})";
    }
}

/// <summary>
/// SMTP settings for email verification codes. <see cref="Password"/> is a secret: user-secrets in
/// development, environment variable <c>Email__Password</c> / Key Vault elsewhere. Never commit it.
/// </summary>
public class EmailOptions
{
    public const string Section = "Email";

    public string Host { get; set; } = string.Empty;
    [Range(1, 65535)] public int Port { get; set; } = 587;

    /// <summary>"StartTls" (port 587), "SslOnConnect" (port 465) or "Auto".</summary>
    public string Security { get; set; } = "StartTls";

    /// <summary>SMTP login; leave empty for a relay that needs none.</summary>
    public string? UserName { get; set; }
    public string? Password { get; set; }

    public string FromAddress { get; set; } = string.Empty;
    public string FromName { get; set; } = "Vidya Sethu";
    public string Subject { get; set; } = "Your Vidya Sethu email verification code";

    [Range(2, 60)] public int TimeoutSeconds { get; set; } = 15;

    private static readonly string[] SecurityModes = ["StartTls", "SslOnConnect", "Auto"];

    public IEnumerable<string> MissingSettings()
    {
        if (string.IsNullOrWhiteSpace(Host)) yield return "Email:Host";
        if (!EmailAddress.TryNormalize(FromAddress, out _)) yield return "Email:FromAddress";
        if (!SecurityModes.Contains(Security, StringComparer.OrdinalIgnoreCase)) yield return "Email:Security (StartTls, SslOnConnect or Auto)";
        if (!string.IsNullOrWhiteSpace(UserName) && string.IsNullOrEmpty(Password)) yield return "Email:Password";
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

    /// <summary>
    /// Also allow any http://localhost:&lt;port&gt; origin - for development only (`flutter run -d chrome` and
    /// `ng serve` use changing ports). Never enable outside Development.
    /// </summary>
    public bool AllowAnyLocalhostOrigin { get; set; }
}

public class DatabaseOptions
{
    public const string Section = "Database";

    /// <summary>Apply EF migrations (incl. master-data seed) at startup. Development convenience only.</summary>
    public bool ApplyMigrationsOnStartup { get; set; }
}

public class SwaggerSettings
{
    public const string Section = "Swagger";
    public const string UiPath = "/swagger";

    /// <summary>
    /// Serve the OpenAPI document (/openapi/v1.json) and Swagger UI (/swagger) for testing the API.
    /// Not set = on in Development only. Elsewhere set Swagger__Enabled=true while testing and remove it afterwards:
    /// it publishes the list of endpoints (calls still need a signed-in token).
    /// </summary>
    public bool? Enabled { get; set; }

    public static bool IsEnabled(IConfiguration configuration, IHostEnvironment env) =>
        configuration.GetSection(Section).Get<SwaggerSettings>()?.Enabled ?? env.IsDevelopment();
}
