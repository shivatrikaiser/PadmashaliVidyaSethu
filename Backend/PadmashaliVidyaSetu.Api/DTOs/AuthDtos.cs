namespace PadmashaliVidyaSetu.Api.DTOs;

public sealed record RequestVerificationCodeRequest(string? MobileNumber);

/// <summary>
/// POST /api/v1/enquiries - the VidyaSethu website's enquiry forms (contract: Frontend/VidyaSethuWeb README
/// "Enquiry endpoint"). Email or phone is required; <c>ElapsedMs</c> = time from the form appearing to sending.
/// </summary>
public sealed record EnquiryRequest(
    string? Category,
    string? Name,
    string? Organization,
    string? Email,
    string? Phone,
    string? Message,
    bool Consent,
    string? Locale,
    string? Page,
    int ElapsedMs);

/// <summary>POST /api/v1/diagnostics/email-test.</summary>
public sealed record EmailTestRequest(string? Email);

public sealed record VerificationCodeIssuedResponse(
    Guid ChallengeId,
    string MaskedMobileNumber,
    int CodeLength,
    int ExpiresInSeconds,
    int ResendAfterSeconds,
    /// <summary>Only populated in the Development environment when explicitly enabled.</summary>
    string? DevelopmentCode);

/// <summary>A member's (optional) email address: POST members/email-verifications.</summary>
public sealed record RequestEmailCodeRequest(string? Email);

public sealed record EmailCodeIssuedResponse(
    Guid ChallengeId,
    string MaskedEmail,
    int CodeLength,
    int ExpiresInSeconds,
    int ResendAfterSeconds,
    /// <summary>Only populated in the Development environment when explicitly enabled.</summary>
    string? DevelopmentCode);

/// <summary>A member's email address is verified; pass <c>ChallengeId</c> as <c>EmailVerificationId</c> when registering.</summary>
public sealed record MemberEmailVerifiedResponse(Guid ChallengeId, string MaskedEmail);

public sealed record VerifyCodeRequest(Guid ChallengeId, string? Code);

public sealed record AuthTokensResponse(
    string AccessToken,
    DateTime AccessTokenExpiresAt,
    string RefreshToken,
    DateTime RefreshTokenExpiresAt,
    bool IsNewAccount,
    int RegisteredMemberCount);

public sealed record RefreshTokenRequest(string? RefreshToken);

/// <summary>A member's own mobile number is verified; pass <c>ChallengeId</c> as <c>MobileVerificationId</c> when registering.</summary>
public sealed record MemberMobileVerifiedResponse(Guid ChallengeId, string MaskedMobileNumber);

/// <summary>Admin portal sign-in with the password a Super Admin set.</summary>
public sealed record PasswordSignInRequest(string? MobileNumber, string? Password);

public sealed record AdminMeDto(string MaskedMobileNumber, IReadOnlyList<string> Roles);

/// <summary>Result of POST /api/v1/diagnostics/sms-test: what SMS Gateway Hub answered ("000" = accepted).</summary>
public sealed record SmsTestResponse(
    string MaskedMobileNumber,
    bool Accepted,
    string? ProviderErrorCode,
    string? ProviderMessage,
    string? JobId,
    string SenderId,
    string TemplateId);

/// <summary>Result of POST /api/v1/diagnostics/whatsapp-test: what the WhatsApp Cloud API answered.</summary>
public sealed record WhatsAppTestResponse(
    string MaskedMobileNumber,
    bool Accepted,
    string? ProviderErrorCode,
    string? ProviderMessage,
    string? MessageId,
    string TemplateName);
