using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;

namespace PadmashaliVidyaSetu.Api.Services.Verification;

/// <summary>Meta's answer to one send. <see cref="ErrorCode"/> is null when the request itself failed.</summary>
public sealed record WhatsAppSendResult(bool Accepted, string? ErrorCode, string? ErrorMessage, string? MessageId);

/// <summary>
/// Sends the Phone Number Verification Code as a WhatsApp template message (WhatsApp Business Cloud API):
/// POST {GraphApiUrl}/{ApiVersion}/{PhoneNumberId}/messages with a bearer token; success = a message id in
/// <c>messages[0].id</c>. Used for numbers outside India.
///
/// The request carries the access token and the code, so the HttpClient's built-in logging is removed at
/// registration and errors report only Meta's error code / message and a masked number.
/// </summary>
public sealed class WhatsAppVerificationCodeSender(
    HttpClient http,
    IOptions<WhatsAppOptions> options,
    ILogger<WhatsAppVerificationCodeSender> logger) : IVerificationCodeSender
{
    private const string FailureMessage = "We could not send the verification code on WhatsApp right now. Please try again in a few minutes.";

    public async Task SendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken)
    {
        var result = await TrySendAsync(mobileNumberE164, code, cancellationToken);
        if (!result.Accepted) throw new ServiceUnavailableException(FailureMessage);
    }

    /// <summary>Sends and reports Meta's answer instead of throwing (also used by the WhatsApp test endpoint).</summary>
    public async Task<WhatsAppSendResult> TrySendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken)
    {
        var o = options.Value;
        var masked = MobileNumber.Mask(mobileNumberE164);

        using var request = new HttpRequestMessage(HttpMethod.Post, o.MessagesUrl)
        {
            Content = JsonContent.Create(BuildMessage(o, mobileNumberE164, code)),
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", o.AccessToken);

        GraphResponse? result;
        try
        {
            using var response = await http.SendAsync(request, cancellationToken);
            // Errors come back as 4xx with an { "error": { ... } } body, which is read like a success body.
            result = await response.Content.ReadFromJsonAsync<GraphResponse>(cancellationToken);
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException && !cancellationToken.IsCancellationRequested)
        {
            var error = ex.GetType().Name + ": " + ex.Message;
            logger.LogError("WhatsApp request failed for {Mobile}: {Error}", masked, error);
            return new WhatsAppSendResult(false, null, error, null);
        }

        var messageId = result?.Messages?.FirstOrDefault()?.Id;
        if (string.IsNullOrEmpty(messageId))
        {
            var errorCode = result?.Error?.Code?.ToString();
            logger.LogError("WhatsApp rejected message for {Mobile}: {ErrorCode} {ErrorMessage}",
                masked, errorCode, result?.Error?.Message);
            return new WhatsAppSendResult(false, errorCode ?? string.Empty, result?.Error?.Message, null);
        }

        logger.LogInformation("Verification code WhatsApp message accepted for {Mobile} (message {MessageId})", masked, messageId);
        return new WhatsAppSendResult(true, null, null, messageId);
    }

    /// <summary>The Graph API request body. Public for tests.</summary>
    public static object BuildMessage(WhatsAppOptions o, string mobileNumberE164, string code) => new
    {
        messaging_product = "whatsapp",
        to = mobileNumberE164.TrimStart('+'),
        type = "template",
        template = new
        {
            name = o.TemplateName,
            language = new { code = o.TemplateLanguage },
            components = new[]
            {
                new
                {
                    type = "body",
                    parameters = new[]
                    {
                        new { type = "text", text = o.RecipientName },
                        new { type = "text", text = code },
                    },
                },
            },
        },
    };

    private sealed class GraphResponse
    {
        [JsonPropertyName("messages")] public List<GraphMessage>? Messages { get; set; }
        [JsonPropertyName("error")] public GraphError? Error { get; set; }
    }

    private sealed class GraphMessage
    {
        [JsonPropertyName("id")] public string? Id { get; set; }
    }

    private sealed class GraphError
    {
        [JsonPropertyName("code")] public int? Code { get; set; }
        [JsonPropertyName("message")] public string? Message { get; set; }
    }
}

/// <summary>
/// Picks the sender by number: Indian (+91) numbers use <see cref="PhoneVerificationOptions.Sender"/> (SMS),
/// all others <see cref="PhoneVerificationOptions.InternationalSender"/> (WhatsApp).
/// </summary>
public sealed class RoutingVerificationCodeSender(IVerificationCodeSender india, IVerificationCodeSender international)
    : IVerificationCodeSender
{
    public Task SendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken) =>
        (MobileNumber.IsIndian(mobileNumberE164) ? india : international).SendAsync(mobileNumberE164, code, cancellationToken);
}
