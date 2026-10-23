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
            var saved = await superAdmin.PutAsJsonAsync("/api/v1/admin/branding", new
            {
                sponsorName = "  Sri Laxmi Silks ",
                sponsorOrganisation = " Laxmi  Textiles Pvt Ltd ",
                // Lines kept (each tidied, blank ones dropped), Windows line endings accepted.
                sponsorAddress = " 12, Car Street \r\n\r\n Udupi  576101 ",
                poweredBy = "IQ Explore",
            });
            Assert.Equal(HttpStatusCode.OK, saved.StatusCode);
            var publicView = (await anonymous.GetFromJsonAsync<Envelope<AppBrandingDto>>("/api/v1/app/branding"))!.Data!;
            Assert.Equal("Sri Laxmi Silks", publicView.SponsorName);
            Assert.Equal("Laxmi Textiles Pvt Ltd", publicView.SponsorOrganisation);
            Assert.Equal("12, Car Street\nUdupi 576101", publicView.SponsorAddress);
            Assert.Equal("IQ Explore", publicView.PoweredBy);

            var tooManyLines = await superAdmin.PutAsJsonAsync("/api/v1/admin/branding", new { sponsorAddress = "1\n2\n3\n4\n5" });
            Assert.Equal(HttpStatusCode.BadRequest, tooManyLines.StatusCode);

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

    [Fact]
    public async Task FooterSponsors_SuperAdminManages_AppSeesActiveOnesInOrder()
    {
        var anonymous = factory.CreateClient();
        var (admin, _) = await factory.CreateAdminClientAsync();
        var (superAdmin, _) = await factory.CreateAdminClientAsync("SUPER_ADMIN");
        const string url = "/api/v1/admin/branding/footer-sponsors";

        Assert.Equal(HttpStatusCode.Forbidden, (await admin.GetAsync(url)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await superAdmin.PostAsJsonAsync(url, new { name = " ", displayOrder = 1, isActive = true })).StatusCode);

        var tag = Guid.NewGuid().ToString("N")[..6];
        async Task<FooterSponsorAdminDto> AddAsync(string name, int order, bool active)
        {
            var response = await superAdmin.PostAsJsonAsync(url,
                new { name = $"{name} {tag}", designation = "Managing Director", companyName = " Sri  Laxmi Silks ", displayOrder = order, isActive = active });
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
            return (await response.Content.ReadFromJsonAsync<Envelope<FooterSponsorAdminDto>>())!.Data!;
        }
        var second = await AddAsync("Ravi", 20, active: true);
        var first = await AddAsync("Asha", 10, active: true);
        var hidden = await AddAsync("Hidden", 5, active: false);

        try
        {
            var shown = (await anonymous.GetFromJsonAsync<Envelope<AppBrandingDto>>("/api/v1/app/branding"))!.Data!
                .FooterSponsors!.Where(s => s.Name.EndsWith(tag)).ToList();
            Assert.Equal([$"Asha {tag}", $"Ravi {tag}"], shown.Select(s => s.Name));
            Assert.Equal("Managing Director", shown[0].Designation);
            Assert.Equal("Sri Laxmi Silks", shown[0].CompanyName);

            // Switching one inactive hides it; the admin list keeps it.
            var update = await superAdmin.PutAsJsonAsync($"{url}/{second.Id}",
                new { name = second.Name, displayOrder = 20, isActive = false });
            Assert.Equal(HttpStatusCode.OK, update.StatusCode);
            var after = (await anonymous.GetFromJsonAsync<Envelope<AppBrandingDto>>("/api/v1/app/branding"))!.Data!.FooterSponsors!;
            Assert.DoesNotContain(after, s => s.Name == second.Name);
            var all = (await superAdmin.GetFromJsonAsync<Envelope<List<FooterSponsorAdminDto>>>(url))!.Data!;
            Assert.Contains(all, s => s.Id == second.Id && !s.IsActive);
            Assert.Contains(all, s => s.Id == hidden.Id);

            Assert.Equal(HttpStatusCode.NotFound, (await superAdmin.PutAsJsonAsync($"{url}/999999", new { name = "X", isActive = true })).StatusCode);
        }
        finally
        {
            foreach (var s in new[] { first, second, hidden }) await superAdmin.DeleteAsync($"{url}/{s.Id}");
        }
        var removed = (await superAdmin.GetFromJsonAsync<Envelope<List<FooterSponsorAdminDto>>>(url))!.Data!;
        Assert.DoesNotContain(removed, s => s.Name.EndsWith(tag));
    }

    [Fact]
    public async Task PoweredByUrl_DefaultsToIqExploreOnGooglePlay_AndMustBeHttps()
    {
        var anonymous = factory.CreateClient();
        var (superAdmin, _) = await factory.CreateAdminClientAsync("SUPER_ADMIN");
        var before = (await anonymous.GetFromJsonAsync<Envelope<AppBrandingDto>>("/api/v1/app/branding"))!.Data!;

        try
        {
            var invalid = await superAdmin.PutAsJsonAsync("/api/v1/admin/branding", new { poweredBy = "IQ Explore", poweredByUrl = "http://example.com" });
            Assert.Equal(HttpStatusCode.BadRequest, invalid.StatusCode);

            const string play = "https://play.google.com/store/apps/details?id=com.iqexplore.app";
            (await superAdmin.PutAsJsonAsync("/api/v1/admin/branding", new { poweredBy = "IQ Explore", poweredByUrl = play })).EnsureSuccessStatusCode();
            Assert.Equal(play, (await anonymous.GetFromJsonAsync<Envelope<AppBrandingDto>>("/api/v1/app/branding"))!.Data!.PoweredByUrl);
        }
        finally
        {
            await superAdmin.PutAsJsonAsync("/api/v1/admin/branding", new
            {
                before.SponsorName, before.SponsorOrganisation, before.SponsorAddress, before.PoweredBy, before.PoweredByUrl,
            });
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
