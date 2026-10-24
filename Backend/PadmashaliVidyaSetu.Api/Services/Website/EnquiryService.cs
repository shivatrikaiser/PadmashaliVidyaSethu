using System.Text;
using Microsoft.Extensions.Options;
using MimeKit;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Logging;
using PadmashaliVidyaSetu.Api.Services.Verification;

namespace PadmashaliVidyaSetu.Api.Services.Website;

/// <summary>
/// Enquiries from the VidyaSethu website's forms (contact page, "For organizations"; every organization uses the same
/// endpoint). Each one is emailed to <see cref="EnquiryOptions.Recipient"/> through the same SMTP account as the email
/// verification codes, with the enquirer as Reply-To. Message bodies are never logged or stored.
/// </summary>
public interface IEnquiryService
{
    Task SubmitAsync(EnquiryRequest request, CancellationToken ct);
}

public sealed class EnquiryService(
    IEnquiryMailer mailer,
    IOptions<EnquiryOptions> options,
    IOptions<EmailOptions> emailOptions,
    IAuditLogger audit,
    Data.AppDbContext db,
    TimeProvider clock,
    ILogger<EnquiryService> logger) : IEnquiryService
{
    public static readonly IReadOnlyDictionary<string, string> Categories = new Dictionary<string, string>
    {
        ["organization"] = "Bringing an organization to VidyaSethu / demo",
        ["general"] = "General question",
        ["partnership"] = "Partnership",
        ["feedback"] = "Feedback",
        ["privacy"] = "Privacy or personal data request",
    };

    public async Task SubmitAsync(EnquiryRequest r, CancellationToken ct)
    {
        var o = options.Value;
        // A person needs a few seconds to fill the form; faster submissions are automated.
        if (r.ElapsedMs < o.MinFillMilliseconds)
            throw new RequestValidationException("message", "Please take a moment to fill in the form, then send it again.");

        var email = EmailAddress.TryNormalize(r.Email, out var e) ? e : null;
        using var message = BuildMessage(emailOptions.Value, o, r, email, clock.GetUtcNow());
        await mailer.SendAsync(message, ct);

        audit.Add(AuditActions.WebsiteEnquiryReceived, "Enquiry", null, $"category={r.Category}; page={r.Page.Tidy()}");
        await db.SaveChangesAsync(ct);
        logger.LogInformation("Website enquiry ({Category}) forwarded to {Recipient}", r.Category, EmailAddress.Mask(o.Recipient));
    }

    /// <summary>Plain-text email (no HTML, so nothing typed into the form can be rendered as markup). Public for tests.</summary>
    public static MimeMessage BuildMessage(EmailOptions sender, EnquiryOptions o, EnquiryRequest r, string? replyTo,
        DateTimeOffset received)
    {
        var category = Categories.GetValueOrDefault(r.Category ?? "", r.Category ?? "");
        var name = r.Name.Tidy();
        var india = received.ToOffset(TimeSpan.FromHours(5.5));

        var body = new StringBuilder()
            .AppendLine($"New enquiry from the VidyaSethu website ({india:dd MMM yyyy, HH:mm} IST)")
            .AppendLine()
            .AppendLine($"About:         {category}")
            .AppendLine($"Name:          {name}")
            .AppendLine($"Organization:  {Field(r.Organization)}")
            .AppendLine($"Email:         {Field(replyTo)}")
            .AppendLine($"Phone:         {Field(r.Phone)}")
            .AppendLine($"Sent from:     {Field(r.Page)}")
            .AppendLine()
            .AppendLine("Message:")
            .AppendLine((r.Message ?? string.Empty).Trim())
            .AppendLine()
            .AppendLine(replyTo is null
                ? "No email address was given - reply by phone."
                : "Reply to this email to answer the enquirer directly.")
            .ToString();

        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(sender.FromName, sender.FromAddress));
        message.To.Add(MailboxAddress.Parse(o.Recipient));
        if (replyTo is not null) message.ReplyTo.Add(new MailboxAddress(name, replyTo));
        message.Subject = $"{o.SubjectPrefix}: {category} - {name}";
        message.Body = new TextPart("plain") { Text = body };
        return message;
    }

    private static string Field(string? value) => string.IsNullOrWhiteSpace(value) ? "-" : value.Tidy();
}

/// <summary>Delivers an enquiry email; the SMTP implementation uses the shared <see cref="EmailOptions"/>.</summary>
public interface IEnquiryMailer
{
    Task SendAsync(MimeMessage message, CancellationToken ct);
}

public sealed class SmtpEnquiryMailer(IOptions<EmailOptions> email, ILogger<SmtpEnquiryMailer> logger) : IEnquiryMailer
{
    public async Task SendAsync(MimeMessage message, CancellationToken ct)
    {
        var error = await SmtpDelivery.TrySendAsync(email.Value, message, ct);
        if (error is null) return;
        logger.LogError("Website enquiry email failed: {Error}", error);
        throw new ServiceUnavailableException("We could not send your enquiry right now. Please try again in a few minutes, or email us.");
    }
}

/// <summary>Development: nothing is sent; the enquiry is only acknowledged (its body is not logged).</summary>
public sealed class DevelopmentEnquiryMailer(ILogger<DevelopmentEnquiryMailer> logger) : IEnquiryMailer
{
    public Task SendAsync(MimeMessage message, CancellationToken ct)
    {
        logger.LogInformation("Development: website enquiry '{Subject}' not emailed", message.Subject);
        return Task.CompletedTask;
    }
}

/// <summary>Fail-closed until SMTP is configured: the website shows an error instead of a false "sent".</summary>
public sealed class NotConfiguredEnquiryMailer(ILogger<NotConfiguredEnquiryMailer> logger) : IEnquiryMailer
{
    public Task SendAsync(MimeMessage message, CancellationToken ct)
    {
        logger.LogError("No email sender is configured (PhoneVerification:EmailSender); website enquiry not delivered");
        throw new ServiceUnavailableException("We could not send your enquiry right now. Please try again later, or email us.");
    }
}
