using System.Net;
using System.Net.Http.Json;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class NotificationApiTests(PvsApiFactory factory)
{
    private const string Url = "/api/v1/admin/notifications";

    [Fact]
    public async Task SuperAdmin_SendsToTheAllUsersTopic_AndSeesHistory()
    {
        var (superAdmin, _) = await factory.CreateSuperAdminAsync();
        var title = "Scholarship news " + Guid.NewGuid().ToString("N")[..6];

        var sent = await superAdmin.PostAsJsonAsync(Url, new { title = "  " + title + " ", body = "Applications open on 1 November." });
        Assert.Equal(HttpStatusCode.OK, sent.StatusCode);

        var push = factory.PushSender.Sent.Single(s => s.Title == title);
        Assert.Equal("all-test", push.Topic);
        Assert.Equal("Applications open on 1 November.", push.Body);

        var overview = (await superAdmin.GetFromJsonAsync<Envelope<NotificationOverviewDto>>(Url))!.Data!;
        Assert.True(overview.IsConfigured);
        Assert.Contains(overview.History, n => n.Title == title && n.Topic == "all-test");

        // A second click with the same text is not sent twice.
        var again = await superAdmin.PostAsJsonAsync(Url, new { title, body = "Applications open on 1 November." });
        Assert.Equal(HttpStatusCode.Conflict, again.StatusCode);
        Assert.Single(factory.PushSender.Sent, s => s.Title == title);
    }

    [Fact]
    public async Task OnlySuperAdmins_CanSend()
    {
        var (admin, _) = await factory.CreateAdminClientAsync();
        var member = await factory.CreateSignedInClientAsync();
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.PostAsJsonAsync(Url, new { title = "x", body = "y" })).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await member.GetAsync(Url)).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await factory.CreateClient().GetAsync(Url)).StatusCode);
    }

    [Fact]
    public async Task TitleAndBody_AreValidated()
    {
        var (superAdmin, _) = await factory.CreateSuperAdminAsync();
        var response = await superAdmin.PostAsJsonAsync(Url, new { title = "", body = new string('x', 241) });
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var errors = (await response.Content.ReadFromJsonAsync<Envelope<object>>())!.Errors.Select(e => e.Field).ToList();
        Assert.Contains("title", errors);
        Assert.Contains("body", errors);
    }
}
