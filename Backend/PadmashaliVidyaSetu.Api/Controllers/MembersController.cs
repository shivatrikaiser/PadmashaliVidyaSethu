using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Auth;
using PadmashaliVidyaSetu.Api.Services.Members;

namespace PadmashaliVidyaSetu.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Member)]
[Route("api/v1")]
public sealed class MembersController(IRegistrationService registration, IMemberService members, IAuthService auth) : ControllerBase
{
    private const string RegistrationIdRoute = "{registrationId:regex(^PVS-\\d{{2}}-\\d{{4}}$)}";

    /// <summary>The signed-in account and the members registered under its mobile number.</summary>
    [HttpGet("me")]
    public async Task<ActionResult<ApiResponse<MyAccountDto>>> Me(CancellationToken ct) =>
        Ok(ApiResponse<MyAccountDto>.Ok(await members.GetMyAccountAsync(ct)));

    /// <summary>Sends a verification code to a member's own (optional) mobile number while registering them.</summary>
    [HttpPost("members/mobile-verifications")]
    [EnableRateLimiting(RateLimitPolicies.Verification)]
    public async Task<ActionResult<ApiResponse<VerificationCodeIssuedResponse>>> RequestMobileCode(
        RequestVerificationCodeRequest request, CancellationToken ct) =>
        Ok(ApiResponse<VerificationCodeIssuedResponse>.Ok(await auth.RequestMemberMobileCodeAsync(request.MobileNumber!, ct),
            "Verification code sent."));

    /// <summary>Verifies that code; pass the returned challenge id as <c>mobileVerificationId</c> when registering.</summary>
    [HttpPost("members/mobile-verifications/verify")]
    [EnableRateLimiting(RateLimitPolicies.Verification)]
    public async Task<ActionResult<ApiResponse<MemberMobileVerifiedResponse>>> VerifyMobileCode(
        VerifyCodeRequest request, CancellationToken ct) =>
        Ok(ApiResponse<MemberMobileVerifiedResponse>.Ok(await auth.VerifyMemberMobileCodeAsync(request.ChallengeId, request.Code!, ct),
            "Mobile number verified."));

    /// <summary>Registers a member (basic profile) under the signed-in mobile number.</summary>
    [HttpPost("members")]
    public async Task<ActionResult<ApiResponse<RegistrationResultDto>>> Register(RegisterMemberRequest request, CancellationToken ct)
    {
        var result = await registration.RegisterAsync(request, ct);
        return CreatedAtAction(nameof(GetProfile), new { registrationId = result.RegistrationId },
            ApiResponse<RegistrationResultDto>.Ok(result, "Registration successful."));
    }

    [HttpGet("members/" + RegistrationIdRoute)]
    public async Task<ActionResult<ApiResponse<MemberProfileDto>>> GetProfile(string registrationId, CancellationToken ct) =>
        Ok(ApiResponse<MemberProfileDto>.Ok(await members.GetProfileAsync(registrationId, ct)));

    [HttpGet("members/" + RegistrationIdRoute + "/dashboard")]
    public async Task<ActionResult<ApiResponse<MemberDashboardDto>>> GetDashboard(string registrationId, CancellationToken ct) =>
        Ok(ApiResponse<MemberDashboardDto>.Ok(await members.GetDashboardAsync(registrationId, ct)));
}
