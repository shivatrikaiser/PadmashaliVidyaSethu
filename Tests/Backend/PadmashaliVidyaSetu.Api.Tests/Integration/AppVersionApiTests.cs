using System.Net;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class AppVersionApiTests(PvsApiFactory factory)
{
    [Fact]
    public async Task Version_PublicPerPlatform_NotCached()
    {
        var client = factory.CreateClient();

        var response = await client.GetAsync("/api/v1/app/version?platform=Android");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.True(response.Headers.CacheControl?.NoStore);
        var android = (await response.Content.ReadFromJsonAsync<Envelope<AppVersionDto>>())!.Data!;
        Assert.Equal("android", android.Platform);
        Assert.Equal("1.0.0", android.LatestVersion);
        Assert.True(android.IsMandatory);
        Assert.StartsWith("https://play.google.com/", android.StoreUrl);

        Assert.Equal(HttpStatusCode.OK, (await client.GetAsync("/api/v1/app/version?platform=ios")).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.GetAsync("/api/v1/app/version?platform=windows")).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await client.GetAsync("/api/v1/app/version")).StatusCode);
    }

    [Fact]
    public async Task Version_RejectsMalformedVersionInDatabase()
    {
        // The app compares versions numerically; the table only accepts major.minor.patch digits.
        await Assert.ThrowsAnyAsync<DbUpdateException>(() => factory.WithDbAsync(async db =>
        {
            var row = await db.AppVersions.SingleAsync(v => v.Platform == "ios");
            row.LatestVersion = "1.0-beta";
            return await db.SaveChangesAsync();
        }));
    }
}
