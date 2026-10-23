using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;

namespace PadmashaliVidyaSetu.Api.Services.Verification;

/// <summary>
/// Delivers an email verification code (a member's optional email address, verified with its own code).
/// Implementations must never log the code.
/// </summary>
public interface IVerificationEmailSender
{
    Task SendAsync(string email, string code, CancellationToken cancellationToken);
}

/// <summary>Sends the code through an SMTP server (MailKit). The SMTP conversation is never logged.</summary>
public sealed class SmtpVerificationEmailSender(
    IOptions<EmailOptions> options,
    IOptions<PhoneVerificationOptions> verification,
    ILogger<SmtpVerificationEmailSender> logger) : IVerificationEmailSender
{
    private const string FailureMessage = "We could not send the verification code by email right now. Please try again in a few minutes.";

    public async Task SendAsync(string email, string code, CancellationToken cancellationToken)
    {
        var result = await TrySendAsync(email, code, cancellationToken);
        if (!result.Accepted) throw new ServiceUnavailableException(FailureMessage);
    }

    /// <summary>Sends and reports the outcome instead of throwing (also used by the email test endpoint).</summary>
    public async Task<(bool Accepted, string? Error)> TrySendAsync(string email, string code, CancellationToken cancellationToken)
    {
        var o = options.Value;
        var masked = EmailAddress.Mask(email);
        try
        {
            using var message = BuildMessage(o, email, code, verification.Value.CodeLifetimeSeconds);
            using var client = new SmtpClient { Timeout = o.TimeoutSeconds * 1000 };
            await client.ConnectAsync(o.Host, o.Port, SecureSocket(o.Security), cancellationToken);
            if (!string.IsNullOrWhiteSpace(o.UserName)) await client.AuthenticateAsync(o.UserName, o.Password ?? string.Empty, cancellationToken);
            await client.SendAsync(message, cancellationToken);
            await client.DisconnectAsync(true, cancellationToken);
        }
        catch (Exception ex) when (ex is not OperationCanceledException || !cancellationToken.IsCancellationRequested)
        {
            // MailKit messages name the server's reply (e.g. "5.7.8 Authentication failed"), never the message body.
            var error = ex.GetType().Name + ": " + ex.Message;
            logger.LogError("Verification email failed for {Email}: {Error}", masked, error);
            return (false, error);
        }

        logger.LogInformation("Verification code email accepted by the SMTP server for {Email}", masked);
        return (true, null);
    }

    /// <summary>The email (plain text and HTML). Public for tests.</summary>
    public static MimeMessage BuildMessage(EmailOptions o, string email, string code, int lifetimeSeconds)
    {
        var minutes = Math.Max(1, lifetimeSeconds / 60);
        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(o.FromName, o.FromAddress));
        message.To.Add(MailboxAddress.Parse(email));
        message.Subject = o.Subject;
        message.Body = new BodyBuilder
        {
            TextBody =
                $"Your Email Verification Code for Vidya Sethu is {code}. It is valid for {minutes} minutes.\n\n" +
                "Enter it in the Vidya Sethu app to confirm this email address. If you did not ask for it, you can ignore this email.",
            HtmlBody =
                $"<p>Your Email Verification Code for Vidya Sethu is</p><p style=\"font-size:24px;font-weight:bold;letter-spacing:4px\">{code}</p>" +
                $"<p>It is valid for {minutes} minutes. Enter it in the Vidya Sethu app to confirm this email address.</p>" +
                "<p style=\"color:#666\">If you did not ask for it, you can ignore this email.</p>",
        }.ToMessageBody();
        return message;
    }

    private static SecureSocketOptions SecureSocket(string security) => security.ToLowerInvariant() switch
    {
        "sslonconnect" => SecureSocketOptions.SslOnConnect,
        "auto" => SecureSocketOptions.Auto,
        _ => SecureSocketOptions.StartTls,
    };
}

/// <summary>Development only: does not send anything (the code is in the API response, as for SMS).</summary>
public sealed class DevelopmentVerificationEmailSender(ILogger<DevelopmentVerificationEmailSender> logger) : IVerificationEmailSender
{
    public Task SendAsync(string email, string code, CancellationToken cancellationToken)
    {
        logger.LogInformation("Development sender: verification email for {Email} (not sent)", EmailAddress.Mask(email));
        return Task.CompletedTask;
    }
}

/// <summary>Fail-closed default until SMTP is configured.</summary>
public sealed class NotConfiguredVerificationEmailSender(ILogger<NotConfiguredVerificationEmailSender> logger) : IVerificationEmailSender
{
    public Task SendAsync(string email, string code, CancellationToken cancellationToken)
    {
        logger.LogError("No verification email sender is configured (PhoneVerification:EmailSender). Code not emailed to {Email}",
            EmailAddress.Mask(email));
        throw new ServiceUnavailableException("We could not send the verification code by email right now. Please try again later.");
    }
}
