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
