using System.Net;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.Services.Verification;

namespace PadmashaliVidyaSetu.Api.Tests.Unit;

public sealed class SmsGatewayHubSenderTests
{
    private static SmsOptions Options() => new()
    {
        APIKey = "test-key",
        SMSURL = "https://www.smsgatewayhub.com/api/mt/SendSMS",
        OTPSenderId = "IQXPLR",
        OTPTemplateId = "1107178125916994770",
        OTPEntityId = "1101698060000095750",
        OTPTemplate = "Your Phone Number Verification Code for PVS is {#numeric#} Valid for 10 minutes.",
    };

    [Fact]
    public void BuildUrl_UsesDltParameters_AndExactTemplateText()
    {
        var url = new Uri(SmsGatewayHubVerificationCodeSender.BuildUrl(Options(), "+919876543210", "0427"));
        var q = QueryHelpers.ParseQuery(url.Query);

        Assert.Equal("https://www.smsgatewayhub.com/api/mt/SendSMS", url.GetLeftPart(UriPartial.Path));
        Assert.Equal("test-key", q["APIKey"]);
        Assert.Equal("IQXPLR", q["senderid"]);
        Assert.Equal("2", q["channel"]);
        Assert.Equal("0", q["DCS"]);
        Assert.Equal("0", q["flashsms"]);
        Assert.Equal("919876543210", q["number"]);
        Assert.Equal("1", q["route"]);
        Assert.Equal("1101698060000095750", q["EntityId"]);
        Assert.Equal("1107178125916994770", q["dlttemplateid"]);
        Assert.Equal("Your Phone Number Verification Code for PVS is 0427 Valid for 10 minutes.", q["text"]);
    }

    [Fact]
    public async Task Send_Succeeds_OnErrorCode000()
    {
        var handler = new StubHandler(HttpStatusCode.OK, """{"ErrorCode":"000","ErrorMessage":"Success","JobId":"20047"}""");
        var sender = Create(handler);

        await sender.SendAsync("+919876543210", "1234", CancellationToken.None);

        Assert.Equal(1, handler.Calls);
        Assert.Contains("text=Your%20Phone%20Number%20Verification%20Code%20for%20PVS%20is%201234", handler.LastUri!.Query);
    }

    [Theory]
    [InlineData(HttpStatusCode.OK, """{"ErrorCode":"013","ErrorMessage":"Invalid template"}""")]
    [InlineData(HttpStatusCode.InternalServerError, "oops")]
    [InlineData(HttpStatusCode.OK, "not json")]
    public async Task Send_Fails_WithUserSafeError(HttpStatusCode status, string body)
    {
        var sender = Create(new StubHandler(status, body));

        var ex = await Assert.ThrowsAsync<ServiceUnavailableException>(() => sender.SendAsync("+919876543210", "1234", CancellationToken.None));

        Assert.DoesNotContain("1234", ex.Message);
        Assert.DoesNotContain("test-key", ex.Message);
    }

    [Fact]
    public void MissingSettings_AreReported()
    {
        var o = Options();
        Assert.Empty(o.MissingSettings());

        o.APIKey = "";
        o.OTPTemplate = "Your code is 1234";
        Assert.Contains("SMS:APIKey", o.MissingSettings());
        Assert.Contains(o.MissingSettings(), m => m.StartsWith("SMS:OTPTemplate"));
    }

    private static SmsGatewayHubVerificationCodeSender Create(StubHandler handler) =>
        new(new HttpClient(handler), Microsoft.Extensions.Options.Options.Create(Options()),
            NullLogger<SmsGatewayHubVerificationCodeSender>.Instance);

    private sealed class StubHandler(HttpStatusCode status, string body) : HttpMessageHandler
    {
        public int Calls { get; private set; }
        public Uri? LastUri { get; private set; }

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            Calls++;
            LastUri = request.RequestUri;
            return Task.FromResult(new HttpResponseMessage(status) { Content = new StringContent(body) });
        }
    }
}
