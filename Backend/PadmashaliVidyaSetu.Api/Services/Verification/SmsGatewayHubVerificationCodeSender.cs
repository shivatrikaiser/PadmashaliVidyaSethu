using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;

namespace PadmashaliVidyaSetu.Api.Services.Verification;

/// <summary>Provider's answer to one send. <see cref="ErrorCode"/> is null when the request itself failed.</summary>
public sealed record SmsSendResult(bool Accepted, string? ErrorCode, string? ErrorMessage, string? JobId);

/// <summary>
/// Sends the Phone Number Verification Code through SMS Gateway Hub (India, DLT-registered template).
/// API: GET {SMSURL}?APIKey&amp;senderid&amp;channel&amp;DCS&amp;flashsms&amp;number&amp;text&amp;route&amp;EntityId&amp;dlttemplateid,
/// success = <c>"ErrorCode": "000"</c>.
///
/// The request URL contains the API key and the code, so it is never logged (the HttpClient's built-in request
/// logging is removed at registration) and errors report only the provider's error code and a masked number.
/// </summary>
public sealed class SmsGatewayHubVerificationCodeSender(
    HttpClient http,
    IOptions<SmsOptions> options,
    ILogger<SmsGatewayHubVerificationCodeSender> logger) : IVerificationCodeSender
{
    private const string SuccessCode = "000";
    private const string FailureMessage = "We could not send the verification code right now. Please try again in a few minutes.";

    public async Task SendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken)
    {
        var result = await TrySendAsync(mobileNumberE164, code, cancellationToken);
        if (!result.Accepted) throw new ServiceUnavailableException(FailureMessage);
    }

    /// <summary>Sends and reports the provider's answer instead of throwing (also used by the SMS test endpoint).</summary>
    public async Task<SmsSendResult> TrySendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken)
    {
        var o = options.Value;
        var masked = MobileNumber.Mask(mobileNumberE164);
        var url = BuildUrl(o, mobileNumberE164, code);

        SmsGatewayHubResponse? result;
        try
        {
            using var response = await http.GetAsync(url, cancellationToken);
            response.EnsureSuccessStatusCode();
            result = await response.Content.ReadFromJsonAsync<SmsGatewayHubResponse>(cancellationToken);
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException && !cancellationToken.IsCancellationRequested)
        {
            // Log the exception type/message only: HttpRequestException messages never include the query string.
            var error = ex.GetType().Name + ": " + ex.Message;
            logger.LogError("SMS Gateway Hub request failed for {Mobile}: {Error}", masked, error);
            return new SmsSendResult(false, null, error, null);
        }

        if (result?.ErrorCode != SuccessCode)
        {
            logger.LogError("SMS Gateway Hub rejected message for {Mobile}: {ErrorCode} {ErrorMessage}",
                masked, result?.ErrorCode, result?.ErrorMessage);
            return new SmsSendResult(false, result?.ErrorCode, result?.ErrorMessage, result?.JobId);
        }

        logger.LogInformation("Verification code SMS accepted for {Mobile} (job {JobId})", masked, result.JobId);
        return new SmsSendResult(true, result.ErrorCode, result.ErrorMessage, result.JobId);
    }

    /// <summary>Builds the provider URL. Public for tests.</summary>
    public static string BuildUrl(SmsOptions o, string mobileNumberE164, string code)
    {
        var parameters = new (string Name, string Value)[]
        {
            ("APIKey", o.APIKey ?? string.Empty),
            ("senderid", o.OTPSenderId),
            ("channel", o.Channel),
            ("DCS", "0"),
            ("flashsms", "0"),
            ("number", mobileNumberE164.TrimStart('+')), // 91XXXXXXXXXX
            ("text", o.MessageText(code)),
            ("route", o.Route),
            ("EntityId", o.OTPEntityId),
            ("dlttemplateid", o.OTPTemplateId),
        };
        var query = string.Join('&', parameters.Select(p => $"{p.Name}={Uri.EscapeDataString(p.Value)}"));
        return $"{o.SMSURL}?{query}";
    }

    private sealed class SmsGatewayHubResponse
    {
        [JsonPropertyName("ErrorCode")] public string? ErrorCode { get; set; }
        [JsonPropertyName("ErrorMessage")] public string? ErrorMessage { get; set; }
        [JsonPropertyName("JobId")] public string? JobId { get; set; }
    }
}
