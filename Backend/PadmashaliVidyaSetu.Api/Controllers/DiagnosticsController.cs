using System.Security.Cryptography;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Verification;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Testing aids, available exactly when Swagger is (see <see cref="SwaggerSettings"/>); otherwise 404.</summary>
[ApiController]
[AllowAnonymous]
[Route("api/v1/diagnostics")]
public sealed class DiagnosticsController(
    IConfiguration configuration,
    IHostEnvironment env,
    IOptions<SmsOptions> sms,
    IOptions<WhatsAppOptions> whatsApp,
    IOptions<EmailOptions> email,
    IServiceProvider services,
    ILogger<DiagnosticsController> logger) : ControllerBase
{
    /// <summary>
    /// Sends one real verification SMS through SMS Gateway Hub (whatever PhoneVerification:Sender is) with a generated
    /// 4-digit code in the template's {#var#}, without using the database, and returns SMS Gateway Hub's answer
    /// ("000" = accepted). Costs one SMS credit per call.
    /// </summary>
    [HttpPost("sms-test")]
    [EnableRateLimiting(RateLimitPolicies.Verification)]
    public async Task<ActionResult<ApiResponse<SmsTestResponse>>> SmsTest(RequestVerificationCodeRequest request, CancellationToken ct)
    {
        if (!SwaggerSettings.IsEnabled(configuration, env)) throw new NotFoundException("Not found.");
        // Answered without throwing, so a debugger does not stop on an ordinary test mistake.
        if (!MobileNumber.TryNormalize(request.MobileNumber, out var mobile))
            return BadRequest(ApiResponse.Fail("Please enter a valid mobile number."));
        var missing = sms.Value.MissingSettings().ToList();
        if (missing.Count > 0)
            return UnprocessableEntity(ApiResponse.Fail("SMS settings are incomplete: " + string.Join(", ", missing)));

        var masked = MobileNumber.Mask(mobile);
        logger.LogWarning("Diagnostics: SMS test requested for {Mobile}", masked);

        var code = RandomNumberGenerator.GetInt32(0, 10_000).ToString("D4");
        var result = await services.GetRequiredService<SmsGatewayHubVerificationCodeSender>().TrySendAsync(mobile, code, ct);

        var o = sms.Value;
        var response = new SmsTestResponse(masked, result.Accepted, result.ErrorCode, result.ErrorMessage, result.JobId,
            o.OTPSenderId, o.OTPTemplateId);
        return Ok(new ApiResponse<SmsTestResponse>(result.Accepted,
            result.Accepted ? "SMS accepted by SMS Gateway Hub. Check the phone." : "SMS Gateway Hub did not accept the SMS.",
            response, []));
    }

    /// <summary>
    /// Sends one real verification code as a WhatsApp template message (whatever PhoneVerification:InternationalSender
    /// is) with a generated 4-digit code, without using the database, and returns Meta's answer. Enter the number with
    /// its country code (e.g. +971501234567). Meta charges per message.
    /// </summary>
    [HttpPost("whatsapp-test")]
    [EnableRateLimiting(RateLimitPolicies.Verification)]
    public async Task<ActionResult<ApiResponse<WhatsAppTestResponse>>> WhatsAppTest(RequestVerificationCodeRequest request, CancellationToken ct)
    {
        if (!SwaggerSettings.IsEnabled(configuration, env)) throw new NotFoundException("Not found.");
        if (!MobileNumber.TryNormalize(request.MobileNumber, out var mobile))
            return BadRequest(ApiResponse.Fail("Please enter a valid mobile number with its country code."));
        var missing = whatsApp.Value.MissingSettings().ToList();
        if (missing.Count > 0)
            return UnprocessableEntity(ApiResponse.Fail("WhatsApp settings are incomplete: " + string.Join(", ", missing)));

        var masked = MobileNumber.Mask(mobile);
        logger.LogWarning("Diagnostics: WhatsApp test requested for {Mobile}", masked);

        var code = RandomNumberGenerator.GetInt32(0, 10_000).ToString("D4");
        var result = await services.GetRequiredService<WhatsAppVerificationCodeSender>().TrySendAsync(mobile, code, ct);

        var response = new WhatsAppTestResponse(masked, result.Accepted, result.ErrorCode, result.ErrorMessage, result.MessageId,
            whatsApp.Value.TemplateName);
        return Ok(new ApiResponse<WhatsAppTestResponse>(result.Accepted,
            result.Accepted ? "Message accepted by WhatsApp. Check the phone." : "WhatsApp did not accept the message.",
            response, []));
    }

    /// <summary>
    /// Sends one real verification email through the configured SMTP server (whatever PhoneVerification:EmailSender
    /// is) with a generated 4-digit code, without using the database, and returns the outcome.
    /// </summary>
    [HttpPost("email-test")]
    [EnableRateLimiting(RateLimitPolicies.Verification)]
    public async Task<ActionResult<ApiResponse<object>>> EmailTest(EmailTestRequest request, CancellationToken ct)
    {
        if (!SwaggerSettings.IsEnabled(configuration, env)) throw new NotFoundException("Not found.");
        if (!EmailAddress.TryNormalize(request.Email, out var address))
            return BadRequest(ApiResponse.Fail("Please enter a valid email address."));
        var missing = email.Value.MissingSettings().ToList();
        if (missing.Count > 0)
            return UnprocessableEntity(ApiResponse.Fail("Email settings are incomplete: " + string.Join(", ", missing)));

        logger.LogWarning("Diagnostics: email test requested for {Email}", EmailAddress.Mask(address));
        var code = RandomNumberGenerator.GetInt32(0, 10_000).ToString("D4");
        var (accepted, error) = await services.GetRequiredService<SmtpVerificationEmailSender>().TrySendAsync(address, code, ct);

        return Ok(new ApiResponse<object>(accepted,
            accepted ? "Email accepted by the SMTP server. Check the inbox (and spam folder)." : "The SMTP server did not accept the email.",
            new { MaskedEmail = EmailAddress.Mask(address), Accepted = accepted, Error = error, email.Value.Host, email.Value.FromAddress }, []));
    }
}
