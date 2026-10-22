namespace PadmashaliVidyaSetu.Api.DTOs;

public sealed record RequestVerificationCodeRequest(string? MobileNumber);

public sealed record VerificationCodeIssuedResponse(
    Guid ChallengeId,
    string MaskedMobileNumber,
    int CodeLength,
    int ExpiresInSeconds,
    int ResendAfterSeconds,
    /// <summary>Only populated in the Development environment when explicitly enabled.</summary>
    string? DevelopmentCode);

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
