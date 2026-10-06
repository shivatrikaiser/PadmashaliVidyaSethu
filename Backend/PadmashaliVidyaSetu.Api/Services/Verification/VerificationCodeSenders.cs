using PadmashaliVidyaSetu.Api.Common;

namespace PadmashaliVidyaSetu.Api.Services.Verification;

/// <summary>
/// Delivers a Phone Number Verification Code. Implement this for an approved SMS / WhatsApp Business provider
/// (e.g. a DLT-registered Indian SMS gateway) and register it in <c>ServiceCollectionExtensions</c>.
/// Implementations must never log the code.
/// </summary>
public interface IVerificationCodeSender
{
    Task SendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken);
}

/// <summary>
/// Development only: does not send anything. The code reaches the developer through the API response
/// (<c>PhoneVerification:ExposeCodeInResponse</c>), which startup forbids outside Development.
/// </summary>
public sealed class DevelopmentVerificationCodeSender(ILogger<DevelopmentVerificationCodeSender> logger) : IVerificationCodeSender
{
    public Task SendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken)
    {
        logger.LogInformation("Development sender: verification code issued for {Mobile} (not sent)", MobileNumber.Mask(mobileNumberE164));
        return Task.CompletedTask;
    }
}

/// <summary>Fail-closed default until a real provider is configured.</summary>
public sealed class NotConfiguredVerificationCodeSender(ILogger<NotConfiguredVerificationCodeSender> logger) : IVerificationCodeSender
{
    public Task SendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken)
    {
        logger.LogError("No verification code sender is configured (PhoneVerification:Sender). Code not delivered to {Mobile}",
            MobileNumber.Mask(mobileNumberE164));
        throw new ServiceUnavailableException("We could not send the verification code right now. Please try again later.");
    }
}
