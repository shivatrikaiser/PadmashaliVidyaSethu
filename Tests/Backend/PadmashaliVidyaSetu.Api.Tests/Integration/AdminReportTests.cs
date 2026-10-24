using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

/// <summary>Deleted-accounts report and the Organisation filter of the member list.</summary>
[Collection(ApiCollection.Name)]
public sealed class AdminReportTests(PvsApiFactory factory)
{
    private const string Report = "/api/v1/admin/reports/deleted-accounts";

    [Fact]
    public async Task DeletedAccounts_ListsTheAccountWithItsMembers_ForAdminsOnly()
    {
        var mobile = PvsApiFactory.NewMobileNumber();
        var user = factory.CreateClient();
        var tokens = await PvsApiFactory.SignInAsync(user, mobile);
        user.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        var name = "Deleted Report " + new string(Guid.NewGuid().ToString("N").Where(char.IsLetter).Take(5).ToArray());
        var registrationId = await PvsApiFactory.RegisterMemberAsync(user, RegistrationRequests.Student(name));
        (await user.PostAsync("/api/v1/me/deletion", null)).EnsureSuccessStatusCode();

        // Members cannot see the report.
        var member = await factory.CreateSignedInClientAsync();
        Assert.Equal(HttpStatusCode.Forbidden, (await member.GetAsync(Report)).StatusCode);

        var (admin, _) = await factory.CreateAdminClientAsync();
        var rows = (await admin.GetFromJsonAsync<Envelope<List<DeletedAccountDto>>>(Report))!.Data!;
        var row = Assert.Single(rows, r => r.MobileNumber == "+91" + mobile);
        Assert.Equal(registrationId, Assert.Single(row.Members).RegistrationId);
        Assert.Equal(name, row.Members[0].FullName);
        Assert.True(row.DeletedDate >= row.CreatedDate);

        // Search by name or number; a date range in the future finds nothing.
        var byName = (await admin.GetFromJsonAsync<Envelope<List<DeletedAccountDto>>>($"{Report}?search={Uri.EscapeDataString(name)}"))!.Data!;
        Assert.Single(byName);
        var byNumber = (await admin.GetFromJsonAsync<Envelope<List<DeletedAccountDto>>>($"{Report}?search={mobile[^6..]}"))!.Data!;
        Assert.Contains(byNumber, r => r.MobileNumber == "+91" + mobile);
        var future = (await admin.GetFromJsonAsync<Envelope<List<DeletedAccountDto>>>($"{Report}?from=2099-01-01"))!.Data!;
        Assert.Empty(future);

        // Excel export: one row per member.
        var csv = await admin.GetAsync($"{Report}/export?search={Uri.EscapeDataString(name)}");
        Assert.Equal("text/csv", csv.Content.Headers.ContentType!.MediaType);
        var text = Encoding.UTF8.GetString(await csv.Content.ReadAsByteArrayAsync());
        Assert.Contains(registrationId, text);
        Assert.Contains("+91" + mobile, text);
    }

    [Fact]
    public async Task MemberList_FiltersByOrganisation()
    {
        var client = await factory.CreateSignedInClientAsync();
        var name = "Org Filter " + new string(Guid.NewGuid().ToString("N").Where(char.IsLetter).Take(5).ToArray());
        var request = RegistrationRequests.Student(name);
        request["organisationId"] = 2; // Mumbai
        var registrationId = await PvsApiFactory.RegisterMemberAsync(client, request);
        var (admin, _) = await factory.CreateAdminClientAsync();

        async Task<List<AdminMemberRowDto>> FindAsync(int organisationId) =>
            (await admin.GetFromJsonAsync<Envelope<PagedResult<AdminMemberRowDto>>>(
                $"/api/v1/admin/members?search={Uri.EscapeDataString(name)}&organisationId={organisationId}"))!.Data!.Items.ToList();

        Assert.Contains(await FindAsync(2), m => m.RegistrationId == registrationId);
        Assert.Empty(await FindAsync(1));

        var csv = await admin.GetStringAsync($"/api/v1/admin/members/export?search={Uri.EscapeDataString(name)}&organisationId=1");
        Assert.DoesNotContain(registrationId, csv);
    }
}
