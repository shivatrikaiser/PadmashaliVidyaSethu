using System.Net;
using System.Net.Http.Json;
using MimeKit;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Website;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

/// <summary>POST /api/v1/enquiries - the VidyaSethu website's enquiry forms.</summary>
[Collection(ApiCollection.Name)]
public sealed class EnquiryApiTests(PvsApiFactory factory)
{
    private const string Url = "/api/v1/enquiries";

    private static Dictionary<string, object?> Valid(string message) => new()
    {
        ["category"] = "organization",
        ["name"] = "  Asha  Rao ",
        ["organization"] = "Sri Vidya Trust",
        ["email"] = "Asha.Rao@Example.com",
        ["phone"] = null,
        ["message"] = message,
        ["consent"] = true,
        ["locale"] = "en",
        ["page"] = "/for-organizations",
        ["elapsedMs"] = 8423,
    };

    [Fact]
    public async Task ValidEnquiry_IsEmailedToSupport_WithTheEnquirerAsReplyTo()
    {
        var text = "We would like a demo for our trust " + Guid.NewGuid().ToString("N");

        var response = await factory.CreateClient().PostAsJsonAsync(Url, Valid(text));

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var mail = Assert.Single(factory.EnquiryMailer.Sent, m => m.TextBody.Contains(text));
        Assert.Equal("support@iqexplore.com", mail.To.Mailboxes.Single().Address);
        Assert.Equal("asha.rao@example.com", mail.ReplyTo.Mailboxes.Single().Address);
        Assert.Equal("VidyaSethu enquiry: Bringing an organization to VidyaSethu / demo - Asha Rao", mail.Subject);
        Assert.Contains("Organization:  Sri Vidya Trust", mail.TextBody);
        Assert.Contains("Sent from:     /for-organizations", mail.TextBody);
        Assert.Null(mail.HtmlBody); // plain text only: nothing typed in the form is rendered as markup
    }

    [Fact]
    public async Task PhoneOnly_IsAccepted_WithoutReplyTo()
    {
        var text = "Please call me back about scholarships " + Guid.NewGuid().ToString("N");
        var body = Valid(text);
        body["email"] = null;
        body["phone"] = "+91 77952 76699";

        (await factory.CreateClient().PostAsJsonAsync(Url, body)).EnsureSuccessStatusCode();

        var mail = Assert.Single(factory.EnquiryMailer.Sent, m => m.TextBody.Contains(text));
        Assert.Empty(mail.ReplyTo);
        Assert.Contains("reply by phone", mail.TextBody);
    }

    [Theory]
    [InlineData("category", "spam", "category")]
    [InlineData("name", "A", "name")]
    [InlineData("message", "too short", "message")]
    [InlineData("email", "not-an-email", "email")]
    [InlineData("consent", false, "consent")]
    [InlineData("elapsedMs", 500, "message")] // filled faster than a person can
    public async Task InvalidEnquiry_IsRejected_AndNothingIsSent(string field, object value, string errorField)
    {
        var before = factory.EnquiryMailer.Sent.Count;
        var body = Valid("A message that is long enough to pass.");
        body[field] = value;

        var response = await factory.CreateClient().PostAsJsonAsync(Url, body);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var envelope = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains(envelope!.Errors, e => string.Equals(e.Field, errorField, StringComparison.OrdinalIgnoreCase));
        Assert.Equal(before, factory.EnquiryMailer.Sent.Count);
    }

    [Fact]
    public async Task NoEmailAndNoPhone_IsRejected()
    {
        var body = Valid("A message that is long enough to pass.");
        body["email"] = null;

        var response = await factory.CreateClient().PostAsJsonAsync(Url, body);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public void Message_IsPlainText_FromTheSharedEmailAccount()
    {
        var sender = new EmailOptions { FromAddress = "noreply@vidyasethu.co.in", FromName = "Vidya Sethu" };
        var request = new EnquiryRequest("feedback", "Ravi", null, null, "7795276699", "<b>Great</b> work, thank you!", true,
            "en", "/contact", 9000);

        using var message = EnquiryService.BuildMessage(sender, new EnquiryOptions(), request, null,
            new DateTimeOffset(2026, 10, 24, 6, 0, 0, TimeSpan.Zero));

        Assert.Equal("noreply@vidyasethu.co.in", message.From.Mailboxes.Single().Address);
        Assert.IsType<TextPart>(message.Body);
        Assert.Contains("<b>Great</b> work", message.TextBody); // shown as typed, never as HTML
        Assert.Contains("24 Oct 2026, 11:30 IST", message.TextBody);
    }
}
