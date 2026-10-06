using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Auth;

namespace PadmashaliVidyaSetu.Api.Controllers;

[ApiController]
[Route("api/v1/auth")]
public sealed class AuthController(IAuthService auth) : ControllerBase
{
    /// <summary>Sends a 4-digit Phone Number Verification Code to the mobile number.</summary>
    [HttpPost("verification-codes")]
    [AllowAnonymous]
    [EnableRateLimiting(RateLimitPolicies.Verification)]
    public async Task<ActionResult<ApiResponse<VerificationCodeIssuedResponse>>> RequestCode(
        RequestVerificationCodeRequest request, CancellationToken ct)
    {
        var result = await auth.RequestVerificationCodeAsync(request.MobileNumber!, ct);
        return Ok(ApiResponse<VerificationCodeIssuedResponse>.Ok(result, "Verification code sent."));
    }

    /// <summary>Verifies the code; signs in (creating the account on first use) and returns tokens.</summary>
    [HttpPost("verification-codes/verify")]
    [AllowAnonymous]
    [EnableRateLimiting(RateLimitPolicies.Verification)]
    public async Task<ActionResult<ApiResponse<AuthTokensResponse>>> Verify(VerifyCodeRequest request, CancellationToken ct)
    {
        var result = await auth.VerifyCodeAsync(request.ChallengeId, request.Code!, ct);
        return Ok(ApiResponse<AuthTokensResponse>.Ok(result, "Phone number verified."));
    }

    [HttpPost("token/refresh")]
    [AllowAnonymous]
    [EnableRateLimiting(RateLimitPolicies.Auth)]
    public async Task<ActionResult<ApiResponse<AuthTokensResponse>>> Refresh(RefreshTokenRequest request, CancellationToken ct)
    {
        var result = await auth.RefreshAsync(request.RefreshToken!, ct);
        return Ok(ApiResponse<AuthTokensResponse>.Ok(result));
    }

    [HttpPost("logout")]
    public async Task<ActionResult<ApiResponse<object>>> Logout(RefreshTokenRequest request, CancellationToken ct)
    {
        await auth.LogoutAsync(request.RefreshToken!, ct);
        return Ok(new ApiResponse<object>(true, "Signed out.", null, []));
    }
}
