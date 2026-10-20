using System.Net;
using Microsoft.Extensions.Configuration;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class SwaggerTests(PvsApiFactory factory)
{
    [Fact]
    public async Task Development_ServesSwaggerUiWithItsOwnContentSecurityPolicy()
    {
        var response = await factory.CreateClient().GetAsync("/swagger/index.html");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var csp = response.Headers.GetValues("Content-Security-Policy").Single();
        Assert.Contains("script-src 'self'", csp);
        Assert.Contains("frame-ancestors 'none'", csp);
    }

    [Fact]
    public async Task OpenApiDocument_HasBearerSchemeAndNoServerList()
    {
        var json = await factory.CreateClient().GetStringAsync("/openapi/v1.json");

        Assert.Contains("\"Bearer\"", json);
        Assert.Contains("/api/v1/auth/verification-codes", json);
        Assert.DoesNotContain("\"servers\"", json);
    }

    [Fact]
    public async Task OtherEndpoints_KeepTheStrictApiPolicy()
    {
        var response = await factory.CreateClient().GetAsync("/api/v1/app/branding");

        Assert.Equal("default-src 'none'; frame-ancestors 'none'",
            response.Headers.GetValues("Content-Security-Policy").Single());
    }

    [Fact]
    public async Task Disabled_SwaggerAndOpenApiAreNotServed()
    {
        await using var disabled = factory.WithWebHostBuilder(b => b.ConfigureAppConfiguration((_, config) =>
            config.AddInMemoryCollection(new Dictionary<string, string?> { ["Swagger:Enabled"] = "false" })));
        var client = disabled.CreateClient();

        Assert.NotEqual(HttpStatusCode.OK, (await client.GetAsync("/swagger/index.html")).StatusCode);
        Assert.NotEqual(HttpStatusCode.OK, (await client.GetAsync("/openapi/v1.json")).StatusCode);
    }
}
