using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Verification;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class DiagnosticsApiTests(PvsApiFactory factory)
{
    private const string Url = "/api/v1/diagnostics/sms-test";

    [Fact]
    public async Task SmsTest_IsNotFound_WhenSwaggerIsOff()
    {
        await using var app = Configure(new() { ["Swagger:Enabled"] = "false" });

        var response = await Send(app.CreateClient());

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task SmsTest_IsListedInSwagger()
    {
        Assert.Contains(Url, await factory.CreateClient().GetStringAsync("/openapi/v1.json"));
    }

    [Fact]
    public async Task SmsTest_WithoutApiKey_SaysWhichSettingIsMissing()
    {
        // Explicitly empty: the test host runs as Development and would otherwise pick up a real key from user-secrets.
        await using var app = Configure(new() { ["SMS:APIKey"] = "" });

        var response = await Send(app.CreateClient());
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();

        Assert.Equal(HttpStatusCode.UnprocessableEntity, response.StatusCode);
        Assert.Contains("SMS:APIKey", body!.Message);
    }

    [Fact]
    public async Task SmsTest_SendsThroughSmsGatewayHub_EvenWhenTheSignInSenderIsDevelopment()
    {
        var handler = new StubHandler("""{"ErrorCode":"000","ErrorMessage":"Done","JobId":"job-2"}""");
        await using var app = Configure(new() { ["SMS:APIKey"] = "test-sms-key" }, handler); // Sender stays Development

        var response = await Send(app.CreateClient());

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal(1, handler.Calls);
    }

    [Fact]
    public async Task SmsTest_RejectsAnInvalidMobileNumber()
    {
        var response = await factory.CreateClient().PostAsJsonAsync(Url, new { mobileNumber = "12345" });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Theory]
    [InlineData("000", true)]
    [InlineData("006", false)]
    public async Task SmsTest_SendsAGeneratedCode_AndReturnsTheProviderAnswer(string errorCode, bool accepted)
    {
        var handler = new StubHandler($$"""{"ErrorCode":"{{errorCode}}","ErrorMessage":"Provider says {{errorCode}}","JobId":"job-1"}""");
        await using var app = Configure(new()
        {
            ["PhoneVerification:Sender"] = "SmsGatewayHub",
            ["PhoneVerification:ExposeCodeInResponse"] = "false",
            ["SMS:APIKey"] = "test-sms-key",
            ["SMS:OTPTemplate"] = "Your code is {#var#} now",
        }, handler);

        var response = await Send(app.CreateClient());
        var body = await response.Content.ReadFromJsonAsync<Envelope<SmsTestResponse>>();

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal(accepted, body!.Success);
        Assert.Equal(accepted, body.Data!.Accepted);
        Assert.Equal(errorCode, body.Data.ProviderErrorCode);
        Assert.Equal(1, handler.Calls);
        Assert.Matches(@"text=Your%20code%20is%20\d{4}%20now", handler.LastUri!.Query);
    }

    private WebApplicationFactory<Program> Configure(Dictionary<string, string?> settings, StubHandler? handler = null) =>
        factory.WithWebHostBuilder(b =>
        {
            b.ConfigureAppConfiguration((_, config) => config.AddInMemoryCollection(settings));
            if (handler is not null)
                b.ConfigureServices(s => s.AddHttpClient<SmsGatewayHubVerificationCodeSender>()
                    .ConfigurePrimaryHttpMessageHandler(() => handler));
        });

    private static Task<HttpResponseMessage> Send(HttpClient client) =>
        client.PostAsJsonAsync(Url, new { mobileNumber = PvsApiFactory.NewMobileNumber() });

    private sealed class StubHandler(string body) : HttpMessageHandler
    {
        public int Calls { get; private set; }
        public Uri? LastUri { get; private set; }

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            Calls++;
            LastUri = request.RequestUri;
            return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK) { Content = new StringContent(body) });
        }
    }
}
