using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class CorsTests(PvsApiFactory factory)
{
    [Theory]
    [InlineData("http://localhost:56062", true)]   // flutter run -d chrome (random port)
    [InlineData("http://localhost:4200", true)]    // ng serve
    [InlineData("http://127.0.0.1:61234", true)]
    [InlineData("https://example.com", false)]
    [InlineData("http://localhost.evil.com:8080", false)]
    public async Task Development_AllowsAnyLocalhostOriginOnly(string origin, bool allowed)
    {
        using var request = new HttpRequestMessage(HttpMethod.Options, "/api/v1/auth/verification-codes");
        request.Headers.Add("Origin", origin);
        request.Headers.Add("Access-Control-Request-Method", "POST");
        request.Headers.Add("Access-Control-Request-Headers", "content-type");

        var response = await factory.CreateClient().SendAsync(request);

        response.Headers.TryGetValues("Access-Control-Allow-Origin", out var values);
        Assert.Equal(allowed, values?.Single() == origin);
    }
}
