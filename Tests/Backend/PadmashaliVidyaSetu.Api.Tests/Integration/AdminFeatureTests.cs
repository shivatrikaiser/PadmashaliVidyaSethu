using System.Net;
using System.Net.Http.Json;
using System.Text;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;
using static PadmashaliVidyaSetu.Api.Tests.Infrastructure.RegistrationRequests;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class AdminFeatureTests(PvsApiFactory factory)
{
    private static string UniqueName(string prefix) =>
        prefix + " " + new string(Guid.NewGuid().ToString("N").Where(char.IsLetter).Take(6).ToArray());

    // ---------------------------------------------------------------- Members

    [Fact]
    public async Task Members_SearchFilterDetailAndDeactivate()
    {
        var member = await factory.CreateSignedInClientAsync();
        var name = UniqueName("Zed Searchable");
        var id = await PvsApiFactory.RegisterMemberAsync(member, Student(name));
        var (admin, _) = await factory.CreateAdminClientAsync();

        var found = await admin.GetFromJsonAsync<Envelope<PagedResult<AdminMemberRowDto>>>($"/api/v1/admin/members?search={Uri.EscapeDataString(name)}");
        var row = Assert.Single(found!.Data!.Items);
        Assert.Equal(id, row.RegistrationId);
        Assert.StartsWith("+91", row.MobileNumber);

        var otherTemple = await admin.GetFromJsonAsync<Envelope<PagedResult<AdminMemberRowDto>>>($"/api/v1/admin/members?search={Uri.EscapeDataString(name)}&templeId=2");
        Assert.Empty(otherTemple!.Data!.Items);

        var detail = await admin.GetFromJsonAsync<Envelope<AdminMemberDetailDto>>($"/api/v1/admin/members/{id}");
        Assert.Equal(name, detail!.Data!.Profile.FullName);
        Assert.True(detail.Data.IsActive);
        Assert.NotEmpty(detail.Data.Consents);

        var deactivated = await admin.PutAsJsonAsync($"/api/v1/admin/members/{id}/status", new { isActive = false });
        Assert.Equal(HttpStatusCode.OK, deactivated.StatusCode);
        var activeOnly = await admin.GetFromJsonAsync<Envelope<PagedResult<AdminMemberRowDto>>>($"/api/v1/admin/members?search={Uri.EscapeDataString(name)}");
        Assert.Empty(activeOnly!.Data!.Items);
        var inactive = await admin.GetFromJsonAsync<Envelope<PagedResult<AdminMemberRowDto>>>($"/api/v1/admin/members?search={Uri.EscapeDataString(name)}&isActive=false");
        Assert.Single(inactive!.Data!.Items);
        var inactiveDetail = await admin.GetFromJsonAsync<Envelope<AdminMemberDetailDto>>($"/api/v1/admin/members/{id}");
        Assert.False(inactiveDetail!.Data!.IsActive);

        var mine = await member.GetFromJsonAsync<Envelope<MyAccountDto>>("/api/v1/me");
        Assert.DoesNotContain(mine!.Data!.Members, m => m.RegistrationId == id);
    }

    [Fact]
    public async Task AdminEndpoints_ForMember_Return403()
    {
        var member = await factory.CreateSignedInClientAsync();
        foreach (var url in new[] { "/api/v1/admin/members", "/api/v1/admin/reports/summary", "/api/v1/admin/lists", "/api/v1/admin/other-values", "/api/v1/admin/locations", "/api/v1/admin/users" })
            Assert.Equal(HttpStatusCode.Forbidden, (await member.GetAsync(url)).StatusCode);
    }

    [Fact]
    public async Task Export_ReturnsCsvForExcel()
    {
        var member = await factory.CreateSignedInClientAsync();
        var name = UniqueName("Csv Person");
        var id = await PvsApiFactory.RegisterMemberAsync(member, Student(name));
        var (admin, _) = await factory.CreateAdminClientAsync();

        var response = await admin.GetAsync($"/api/v1/admin/members/export?search={Uri.EscapeDataString(name)}");

        Assert.Equal("text/csv", response.Content.Headers.ContentType!.MediaType);
        var bytes = await response.Content.ReadAsByteArrayAsync();
        Assert.Equal(Encoding.UTF8.GetPreamble(), bytes[..3]);
        var lines = Encoding.UTF8.GetString(bytes[3..]).Split("\r\n", StringSplitOptions.RemoveEmptyEntries);
        Assert.StartsWith("Registration ID,Full Name", lines[0]);
        Assert.StartsWith($"{id},{name},", Assert.Single(lines[1..]));
    }

    // ---------------------------------------------------------------- Reports

    [Fact]
    public async Task Reports_SummaryCountsMembers()
    {
        var member = await factory.CreateSignedInClientAsync();
        await PvsApiFactory.RegisterMemberAsync(member, Student(UniqueName("Report Kid")));
        var (admin, _) = await factory.CreateAdminClientAsync();

        var summary = (await admin.GetFromJsonAsync<Envelope<AdminSummaryDto>>("/api/v1/admin/reports/summary"))!.Data!;

        Assert.True(summary.ActiveMembers >= 1);
        Assert.Equal(12, summary.ByMonth.Count);
        Assert.Equal(6, summary.ByAgeGroup.Count);
        Assert.Equal(summary.ActiveMembers, summary.ByTemple.Sum(t => t.Count));
        Assert.Equal(summary.ActiveMembers, summary.ByOrganisation.Sum(o => o.Count));
        Assert.Equal(5, summary.StudentsByStage.Count);
        Assert.True(summary.StudentsByStage.Single(s => s.Label == "PUC").Count >= 1); // Student() is in PUC 1
        Assert.True(summary.ByMonth[^1].Count >= 1);
    }

    // ---------------------------------------------------------------- Master lists

    [Fact]
    public async Task Lists_AddRenameAndProtectOther()
    {
        var (admin, _) = await factory.CreateAdminClientAsync("SUPER_ADMIN");
        var name = UniqueName("Course");

        var created = await admin.PostAsJsonAsync("/api/v1/admin/lists/courses", new { name });
        var item = (await created.Content.ReadFromJsonAsync<Envelope<AdminListItemDto>>())!.Data!;
        Assert.Equal(LocationSlug(name), item.Code);

        var items = (await admin.GetFromJsonAsync<Envelope<List<AdminListItemDto>>>("/api/v1/admin/lists/courses"))!.Data!;
        Assert.Contains(items, i => i.Id == item.Id);
        Assert.Equal("OTHER", items[^1].Code); // new entries go before "Other"

        Assert.Equal(HttpStatusCode.Conflict, (await admin.PostAsJsonAsync("/api/v1/admin/lists/courses", new { name })).StatusCode);

        var renamed = await admin.PutAsJsonAsync($"/api/v1/admin/lists/courses/{item.Id}", new { name = name + " Renamed", isActive = false });
        var after = (await renamed.Content.ReadFromJsonAsync<Envelope<AdminListItemDto>>())!.Data!;
        Assert.Equal(name + " Renamed", after.Name);
        Assert.False(after.IsActive);

        var other = items.Single(i => i.Code == "OTHER");
        Assert.True(other.IsProtected);
        var deactivateOther = await admin.PutAsJsonAsync($"/api/v1/admin/lists/courses/{other.Id}", new { isActive = false });
        Assert.Equal(HttpStatusCode.UnprocessableEntity, deactivateOther.StatusCode);
    }

    [Fact]
    public async Task Lists_TempleNeedsTwoDigitCode()
    {
        var (admin, _) = await factory.CreateAdminClientAsync("SUPER_ADMIN");
        var response = await admin.PostAsJsonAsync("/api/v1/admin/lists/temples", new { name = "Test Temple, Somewhere", code = "7" });
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Contains(body!.Errors, e => e.Field == "code");
    }

    // ---------------------------------------------------------------- "Other" values

    [Fact]
    public async Task OtherValues_ListedAndMappedToNewEntry()
    {
        var member = await factory.CreateSignedInClientAsync();
        var text = UniqueName("Diploma In");
        var otherId = await factory.WithDbAsync(db => db.EducationLevels.Where(e => e.Code == "OTHER").Select(e => e.Id).SingleAsync());
        var request = Adult(StatusWorking);
        request["highestEducationLevelId"] = otherId;
        request["highestEducationLevelOtherText"] = text;
        var id = await PvsApiFactory.RegisterMemberAsync(member, request);
        var (admin, _) = await factory.CreateAdminClientAsync("SUPER_ADMIN");

        var pending = (await admin.GetFromJsonAsync<Envelope<List<OtherValueDto>>>("/api/v1/admin/other-values"))!.Data!;
        var value = Assert.Single(pending, v => v.Text == text);
        Assert.Equal("education-levels", value.ListType);
        Assert.Equal(1, value.MemberCount);

        var entry = (await (await admin.PostAsJsonAsync("/api/v1/admin/lists/education-levels", new { name = text }))
            .Content.ReadFromJsonAsync<Envelope<AdminListItemDto>>())!.Data!;
        var mapped = await admin.PostAsJsonAsync("/api/v1/admin/other-values/map", new { listType = "education-levels", text, targetId = entry.Id });
        Assert.Equal(1, (await mapped.Content.ReadFromJsonAsync<Envelope<MapOtherValueResultDto>>())!.Data!.UpdatedRows);

        var stored = await factory.WithDbAsync(db => db.Members.Where(m => m.RegistrationId == id)
            .Select(m => new { m.HighestEducationLevelId, m.HighestEducationLevelOtherText }).SingleAsync());
        Assert.Equal(entry.Id, stored.HighestEducationLevelId);
        Assert.Null(stored.HighestEducationLevelOtherText);
        var after = (await admin.GetFromJsonAsync<Envelope<List<OtherValueDto>>>("/api/v1/admin/other-values"))!.Data!;
        Assert.DoesNotContain(after, v => v.Text == text);
    }

    [Fact]
    public async Task ListsAndOtherValues_AreSuperAdminOnly()
    {
        var (admin, _) = await factory.CreateAdminClientAsync();
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.GetAsync("/api/v1/admin/lists")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.GetAsync("/api/v1/admin/lists/courses")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.PostAsJsonAsync("/api/v1/admin/lists/courses", new { name = "Not Allowed" })).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden, (await admin.GetAsync("/api/v1/admin/other-values")).StatusCode);
        Assert.Equal(HttpStatusCode.Forbidden,
            (await admin.PostAsJsonAsync("/api/v1/admin/other-values/map", new { listType = "courses", text = "x", targetId = 1 })).StatusCode);
    }

    [Fact]
    public async Task OtherValues_IncludeDisabilityTexts()
    {
        var member = await factory.CreateSignedInClientAsync();
        var text = UniqueName("Rare Condition");
        var request = Student();
        request["isDisabled"] = true;
        request["disabilityTypeIds"] = new[] { DisabilityOther };
        request["otherDisabilityDescription"] = text;
        await PvsApiFactory.RegisterMemberAsync(member, request);
        var (superAdmin, _) = await factory.CreateAdminClientAsync("SUPER_ADMIN");

        var values = (await superAdmin.GetFromJsonAsync<Envelope<List<OtherValueDto>>>("/api/v1/admin/other-values"))!.Data!;
        Assert.Contains(values, v => v.Text == text && v.ListType == "disability-types");
    }

    // ---------------------------------------------------------------- Admin users

    [Fact]
    public async Task AdminUsers_SuperAdminGrantsAndRevokes()
    {
        var (superAdmin, superMobile) = await factory.CreateAdminClientAsync("SUPER_ADMIN");
        var (admin, _) = await factory.CreateAdminClientAsync();
        var newMobile = PvsApiFactory.NewMobileNumber();

        Assert.Equal(HttpStatusCode.Forbidden, (await admin.GetAsync("/api/v1/admin/users")).StatusCode);

        var granted = await superAdmin.PostAsJsonAsync("/api/v1/admin/users", new { mobileNumber = newMobile, roleCode = "ADMIN" });
        var user = (await granted.Content.ReadFromJsonAsync<Envelope<AdminUserDto>>())!.Data!;
        Assert.Equal("+91" + newMobile, user.MobileNumber);
        Assert.Equal(["ADMIN"], user.Roles);

        var revoked = await superAdmin.DeleteAsync($"/api/v1/admin/users/{user.AccountId}/roles/ADMIN");
        Assert.Equal(HttpStatusCode.OK, revoked.StatusCode);
        var list = (await superAdmin.GetFromJsonAsync<Envelope<List<AdminUserDto>>>("/api/v1/admin/users"))!.Data!;
        Assert.DoesNotContain(list, u => u.AccountId == user.AccountId);

        var me = list.Single(u => u.MobileNumber == "+91" + superMobile);
        var removeSelf = await superAdmin.DeleteAsync($"/api/v1/admin/users/{me.AccountId}/roles/SUPER_ADMIN");
        Assert.Equal(HttpStatusCode.UnprocessableEntity, removeSelf.StatusCode);
    }

    // ---------------------------------------------------------------- Locations

    [Fact]
    public async Task Locations_UserTalukRenamedAndMerged()
    {
        var member = await factory.CreateSignedInClientAsync();
        var talukName = UniqueName("Mytaluk");
        var request = Student();
        request["permanentAddress"] = Address(talukId: null, newTalukName: talukName);
        var id = await PvsApiFactory.RegisterMemberAsync(member, request);
        var (admin, _) = await factory.CreateAdminClientAsync();

        var review = (await admin.GetFromJsonAsync<Envelope<List<LocationReviewItemDto>>>("/api/v1/admin/locations"))!.Data!;
        var taluk = Assert.Single(review, l => l.Kind == "Taluk" && l.Name == talukName);
        Assert.Equal("UserSubmitted", taluk.Source);
        Assert.Equal(2, taluk.AddressCount); // permanent + current (same as permanent)

        var renamed = await admin.PutAsJsonAsync($"/api/v1/admin/locations/taluks/{taluk.Id}", new { name = talukName + " Renamed" });
        Assert.Equal(HttpStatusCode.OK, renamed.StatusCode);

        const int puttur = 3;
        var merged = await admin.PostAsJsonAsync($"/api/v1/admin/locations/taluks/{taluk.Id}/merge", new { targetTalukId = puttur });
        Assert.Equal(HttpStatusCode.OK, merged.StatusCode);

        var taluks = await factory.WithDbAsync(db => db.MemberAddresses.Where(a => a.RegistrationId == id).Select(a => a.TalukId).ToListAsync());
        Assert.All(taluks, t => Assert.Equal(puttur, t));
        var source = await factory.WithDbAsync(db => db.Taluks.SingleAsync(t => t.Id == taluk.Id));
        Assert.False(source.IsActive);
        Assert.Equal(talukName + " Renamed", source.Name);
    }

    private static string LocationSlug(string value) => PadmashaliVidyaSetu.Api.Services.Locations.LocationResolver.Slug(value);
}
