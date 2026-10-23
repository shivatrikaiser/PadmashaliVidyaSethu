using System.Net;
using System.Text.Json;
using Microsoft.Extensions.Logging.Abstractions;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.Services.Verification;

namespace PadmashaliVidyaSetu.Api.Tests.Unit;

public sealed class WhatsAppSenderTests
{
    private static WhatsAppOptions Options() => new()
    {
        AccessToken = "test-token",
        PhoneNumberId = "1128909600305977",
        TemplateName = "iqe_validate",
    };

    [Fact]
    public async Task Send_PostsTheTemplateMessage_WithBearerToken()
    {
        var handler = new StubHandler(HttpStatusCode.OK,
            """{"messaging_product":"whatsapp","contacts":[{"input":"971501234567","wa_id":"971501234567"}],"messages":[{"id":"wamid.ABC"}]}""");
        var sender = Create(handler);

        await sender.SendAsync("+971501234567", "0427", CancellationToken.None);

        Assert.Equal(HttpMethod.Post, handler.LastRequest!.Method);
        Assert.Equal("https://graph.facebook.com/v26.0/1128909600305977/messages", handler.LastRequest.RequestUri!.ToString());
        Assert.Equal("Bearer", handler.LastRequest.Headers.Authorization!.Scheme);
        Assert.Equal("test-token", handler.LastRequest.Headers.Authorization.Parameter);

        using var body = JsonDocument.Parse(handler.LastBody!);
        var root = body.RootElement;
        Assert.Equal("whatsapp", root.GetProperty("messaging_product").GetString());
        Assert.Equal("971501234567", root.GetProperty("to").GetString()); // no "+"
        Assert.Equal("template", root.GetProperty("type").GetString());
        var template = root.GetProperty("template");
        Assert.Equal("iqe_validate", template.GetProperty("name").GetString());
        Assert.Equal("en", template.GetProperty("language").GetProperty("code").GetString());
        var component = template.GetProperty("components")[0];
        Assert.Equal("body", component.GetProperty("type").GetString());
        var parameters = component.GetProperty("parameters").EnumerateArray().Select(p => p.GetProperty("text").GetString()).ToList();
        Assert.Equal(["Member", "0427"], parameters);
    }

    [Theory]
    [InlineData(HttpStatusCode.Unauthorized, """{"error":{"message":"Invalid OAuth access token.","type":"OAuthException","code":190}}""")]
    [InlineData(HttpStatusCode.BadRequest, """{"error":{"message":"(#132001) Template name does not exist in the translation","code":132001}}""")]
    [InlineData(HttpStatusCode.OK, """{"messaging_product":"whatsapp","messages":[]}""")]
    [InlineData(HttpStatusCode.BadGateway, "<html>bad gateway</html>")]
    public async Task Send_Fails_WithUserSafeError(HttpStatusCode status, string body)
    {
        var sender = Create(new StubHandler(status, body));

        var ex = await Assert.ThrowsAsync<ServiceUnavailableException>(() => sender.SendAsync("+971501234567", "1234", CancellationToken.None));

        Assert.DoesNotContain("1234", ex.Message);
        Assert.DoesNotContain("test-token", ex.Message);
    }

    [Fact]
    public async Task TrySend_ReportsMetasErrorCode()
    {
        var sender = Create(new StubHandler(HttpStatusCode.Unauthorized, """{"error":{"message":"Invalid OAuth access token.","code":190}}"""));

        var result = await sender.TrySendAsync("+971501234567", "1234", CancellationToken.None);

        Assert.False(result.Accepted);
        Assert.Equal("190", result.ErrorCode);
        Assert.Equal("Invalid OAuth access token.", result.ErrorMessage);
    }

    [Fact]
    public void MissingSettings_AreReported()
    {
        var o = Options();
        Assert.Empty(o.MissingSettings());

        o.AccessToken = "";
        o.PhoneNumberId = " ";
        Assert.Contains("WhatsApp:AccessToken", o.MissingSettings());
        Assert.Contains("WhatsApp:PhoneNumberId", o.MissingSettings());
    }

    [Theory]
    [InlineData("+919876543210", "india")]
    [InlineData("+971501234567", "international")]
    [InlineData("+14155550100", "international")]
    public async Task Routing_SendsIndianNumbersBySms_AndOthersByWhatsApp(string mobile, string expected)
    {
        var india = new RecordingSender();
        var international = new RecordingSender();

        await new RoutingVerificationCodeSender(india, international).SendAsync(mobile, "1234", CancellationToken.None);

        Assert.Equal(expected == "india" ? 1 : 0, india.Calls);
        Assert.Equal(expected == "international" ? 1 : 0, international.Calls);
    }

    private static WhatsAppVerificationCodeSender Create(StubHandler handler) =>
        new(new HttpClient(handler), Microsoft.Extensions.Options.Options.Create(Options()),
            NullLogger<WhatsAppVerificationCodeSender>.Instance);

    private sealed class RecordingSender : IVerificationCodeSender
    {
        public int Calls { get; private set; }

        public Task SendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken)
        {
            Calls++;
            return Task.CompletedTask;
        }
    }

    private sealed class StubHandler(HttpStatusCode status, string body) : HttpMessageHandler
    {
        public HttpRequestMessage? LastRequest { get; private set; }
        public string? LastBody { get; private set; }

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            LastRequest = request;
            LastBody = request.Content is null ? null : await request.Content.ReadAsStringAsync(cancellationToken);
            return new HttpResponseMessage(status) { Content = new StringContent(body) };
        }
    }
}
