using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class BrandingApiTests(PvsApiFactory factory)
{
    /// <summary>Smallest valid PNG header + IHDR start - enough for the type check.</summary>
    private static readonly byte[] Png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52];

    [Fact]
    public async Task Branding_PublicRead_SuperAdminEdit_AdminForbidden()
    {
        var anonymous = factory.CreateClient();
        var (admin, _) = await factory.CreateAdminClientAsync();
        var (superAdmin, _) = await factory.CreateAdminClientAsync("SUPER_ADMIN");

        // Readable before sign-in (splash screen).
        var initial = (await anonymous.GetFromJsonAsync<Envelope<AppBrandingDto>>("/api/v1/app/branding"))!.Data!;
        Assert.False(initial.HasSponsorLogo);

        // Only Super Admins edit.
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.PutAsJsonAsync("/api/v1/admin/branding", new { sponsorName = "X" })).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.GetAsync("/api/v1/admin/branding")).StatusCode);

        try
        {
            var saved = await superAdmin.PutAsJsonAsync("/api/v1/admin/branding", new { sponsorName = "  Sri Laxmi Silks ", poweredBy = "IQ Explore" });
            Assert.Equal(HttpStatusCode.OK, saved.StatusCode);
            var publicView = (await anonymous.GetFromJsonAsync<Envelope<AppBrandingDto>>("/api/v1/app/branding"))!.Data!;
            Assert.Equal("Sri Laxmi Silks", publicView.SponsorName);
            Assert.Equal("IQ Explore", publicView.PoweredBy);

            // Logo: real images only; served publicly with its content type.
            var notImage = await UploadAsync(superAdmin, "not an image"u8.ToArray(), "logo.png");
            Assert.Equal(HttpStatusCode.BadRequest, notImage.StatusCode);
            var uploaded = await UploadAsync(superAdmin, Png, "logo.png");
            Assert.True((await uploaded.Content.ReadFromJsonAsync<Envelope<AppBrandingDto>>())!.Data!.HasSponsorLogo);

            var logo = await anonymous.GetAsync("/api/v1/app/branding/sponsor-logo");
            Assert.Equal("image/png", logo.Content.Headers.ContentType!.MediaType);
            Assert.Equal(Png, await logo.Content.ReadAsByteArrayAsync());

            Assert.Equal(HttpStatusCode.OK, (await superAdmin.DeleteAsync("/api/v1/admin/branding/sponsor-logo")).StatusCode);
            Assert.Equal(HttpStatusCode.NotFound, (await anonymous.GetAsync("/api/v1/app/branding/sponsor-logo")).StatusCode);
        }
        finally
        {
            await superAdmin.PutAsJsonAsync("/api/v1/admin/branding", new { sponsorName = (string?)null, poweredBy = "IQ Explore" });
        }
    }

    private static Task<HttpResponseMessage> UploadAsync(HttpClient client, byte[] bytes, string fileName)
    {
        var content = new MultipartFormDataContent();
        var file = new ByteArrayContent(bytes);
        file.Headers.ContentType = new MediaTypeHeaderValue("image/png");
        content.Add(file, "file", fileName);
        return client.PostAsync("/api/v1/admin/branding/sponsor-logo", content);
    }
}
