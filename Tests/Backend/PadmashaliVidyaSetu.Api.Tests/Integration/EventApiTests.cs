using System.Net;
using System.Net.Http.Json;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class EventApiTests(PvsApiFactory factory)
{
    private const string AdminUrl = "/api/v1/admin/events";
    private const int Male = 1;
    private const int Female = 2;

    private static readonly DateOnly Today = DateOnly.FromDateTime(DateTime.UtcNow.AddHours(5.5));

    private static string NewCode() => "T" + Guid.NewGuid().ToString("N")[..7].ToUpperInvariant();

    private static Dictionary<string, object?> Event(string code, params object[] groups) => new()
    {
        ["code"] = code.ToLowerInvariant(), // stored upper case
        ["title"] = "  Sports  Day 2026 ",
        ["description"] = "Running, long jump\r\n\r\n\r\nand relay.",
        ["venue"] = "Temple grounds, Barkur",
        ["eventDate"] = Today.AddDays(20).ToString("yyyy-MM-dd"),
        ["ageAsOnDate"] = Today.AddDays(10).ToString("yyyy-MM-dd"),
        ["registrationOpensDate"] = Today.AddDays(-1).ToString("yyyy-MM-dd"),
        ["registrationClosesDate"] = Today.AddDays(5).ToString("yyyy-MM-dd"),
        ["maxGroupsPerMember"] = 2,
        ["isPublished"] = true,
        ["isActive"] = true,
        ["groups"] = groups,
    };

    private static object Group(string name, int min, int max, int? genderId = null, int? capacity = null, int? id = null) =>
        new { id, name, minAge = min, maxAge = max, genderId, capacity };

    private static int GroupId(AdminEventDto e, string name) => e.Groups.Single(g => g.Name == name).Id;

    private static async Task<T> DataAsync<T>(HttpResponseMessage response)
    {
        Assert.True(response.IsSuccessStatusCode, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<Envelope<T>>())!.Data!;
    }

    private static Task<HttpResponseMessage> RegisterAsync(HttpClient client, string member, int eventId, params int[] groupIds) =>
        client.PutAsJsonAsync($"/api/v1/members/{member}/events/{eventId}/registration", new { groupIds });

    private static async Task<MemberEventDto?> FindAsync(HttpClient client, string member, int eventId) =>
        (await client.GetFromJsonAsync<Envelope<List<MemberEventDto>>>($"/api/v1/members/{member}/events"))!.Data!
            .SingleOrDefault(e => e.EventId == eventId);

    [Fact]
    public async Task Members_SeeTheirAgeGroups_RegisterWithinLimits_AndGetOneNumberPerEvent()
    {
        var (admin, _) = await factory.CreateAdminClientAsync();
        var code = NewCode();
        var ev = await DataAsync<AdminEventDto>(await admin.PostAsJsonAsync(AdminUrl, Event(code,
            Group("Girls 10-15", 10, 15, Female),
            Group("Boys 10-15", 10, 15, Male),
            Group("Adults 18-40", 18, 40),
            Group("Open (one place)", 0, 120, capacity: 1))));
        Assert.Equal(code, ev.Code);
        Assert.Equal("Sports Day 2026", ev.Title);
        Assert.Equal("Running, long jump\n\nand relay.", ev.Description);
        Assert.Equal(["Girls 10-15", "Boys 10-15", "Adults 18-40", "Open (one place)"], ev.Groups.Select(g => g.Name));

        // One family: a girl born 2012-08-15 (14 on the "age as on" date) and an adult born 1998.
        var family = await factory.CreateSignedInClientAsync();
        var girl = await PvsApiFactory.RegisterMemberAsync(family, RegistrationRequests.Student("Sumana Shettigar"));
        var adult = await PvsApiFactory.RegisterMemberAsync(family, RegistrationRequests.Adult(RegistrationRequests.StatusWorking));

        var seen = (await FindAsync(family, girl, ev.Id))!;
        Assert.Equal(14, seen.Age);
        Assert.True(seen.IsRegistrationOpen);
        Assert.Equal(["Girls 10-15", "Open (one place)"], seen.Groups.Select(g => g.Name));
        Assert.Null(seen.Registration);

        // Only groups that fit, and at most the event's limit.
        Assert.Equal(HttpStatusCode.BadRequest, (await RegisterAsync(family, girl, ev.Id, GroupId(ev, "Boys 10-15"))).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await RegisterAsync(family, girl, ev.Id)).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await RegisterAsync(family, adult, ev.Id,
            GroupId(ev, "Adults 18-40"), GroupId(ev, "Open (one place)"), GroupId(ev, "Girls 10-15"))).StatusCode);

        var registered = await DataAsync<EventRegistrationResultDto>(await RegisterAsync(family, girl, ev.Id,
            GroupId(ev, "Girls 10-15"), GroupId(ev, "Open (one place)")));
        Assert.Equal($"{code}-0001", registered.RegistrationNumber);
        Assert.Equal("Sumana Shettigar", registered.MemberName);
        Assert.Equal(["Girls 10-15", "Open (one place)"], registered.Groups);

        // The open group is now full for others.
        var full = await RegisterAsync(family, adult, ev.Id, GroupId(ev, "Open (one place)"));
        Assert.Equal(HttpStatusCode.UnprocessableEntity, full.StatusCode);
        Assert.True((await FindAsync(family, adult, ev.Id))!.Groups.Single(g => g.Name == "Open (one place)").IsFull);
        var adultNumber = (await DataAsync<EventRegistrationResultDto>(await RegisterAsync(family, adult, ev.Id,
            GroupId(ev, "Adults 18-40")))).RegistrationNumber;
        Assert.Equal($"{code}-0002", adultNumber);

        // Changing groups keeps the number and frees the place.
        var changed = await DataAsync<EventRegistrationResultDto>(await RegisterAsync(family, girl, ev.Id, GroupId(ev, "Girls 10-15")));
        Assert.Equal($"{code}-0001", changed.RegistrationNumber);
        Assert.Equal(HttpStatusCode.OK, (await RegisterAsync(family, adult, ev.Id,
            GroupId(ev, "Adults 18-40"), GroupId(ev, "Open (one place)"))).StatusCode);

        var mine = (await FindAsync(family, girl, ev.Id))!.Registration!;
        Assert.Equal($"{code}-0001", mine.RegistrationNumber);
        Assert.Equal(["Girls 10-15"], mine.GroupNames);

        // Cancel, then register again: same number.
        Assert.Equal(HttpStatusCode.OK, (await family.DeleteAsync($"/api/v1/members/{girl}/events/{ev.Id}/registration")).StatusCode);
        Assert.Null((await FindAsync(family, girl, ev.Id))!.Registration);
        Assert.Equal(HttpStatusCode.NotFound, (await family.DeleteAsync($"/api/v1/members/{girl}/events/{ev.Id}/registration")).StatusCode);
        var again = await DataAsync<EventRegistrationResultDto>(await RegisterAsync(family, girl, ev.Id, GroupId(ev, "Girls 10-15")));
        Assert.Equal($"{code}-0001", again.RegistrationNumber);

        // Another account cannot see or register this family's members.
        var stranger = await factory.CreateSignedInClientAsync();
        Assert.Equal(HttpStatusCode.NotFound, (await stranger.GetAsync($"/api/v1/members/{girl}/events")).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await RegisterAsync(stranger, girl, ev.Id, GroupId(ev, "Girls 10-15"))).StatusCode);

        // Admin: counts, list and CSV.
        var detail = await DataAsync<AdminEventDto>(await admin.GetAsync($"{AdminUrl}/{ev.Id}"));
        Assert.Equal(2, detail.RegistrationCount);
        Assert.Equal(1, detail.Groups.Single(g => g.Name == "Girls 10-15").RegistrationCount);
        Assert.Equal(1, detail.Groups.Single(g => g.Name == "Open (one place)").RegistrationCount);
        var registrations = await DataAsync<List<AdminEventRegistrationDto>>(await admin.GetAsync($"{AdminUrl}/{ev.Id}/registrations"));
        Assert.Equal([$"{code}-0001", $"{code}-0002"], registrations.Select(r => r.RegistrationNumber));
        Assert.Equal(["Adults 18-40", "Open (one place)"], registrations[1].Groups);
        var csv = await admin.GetStringAsync($"{AdminUrl}/{ev.Id}/registrations/export");
        Assert.Contains($"{code}-0001,{girl},Sumana Shettigar,Female,14,Girls 10-15", csv);

        var rows = await DataAsync<List<AdminEventRowDto>>(await admin.GetAsync(AdminUrl));
        Assert.Equal(2, rows.Single(r => r.Id == ev.Id).RegistrationCount);
    }

    [Fact]
    public async Task Admin_CannotRemoveGroupsInUse_OrChangeTheCodeAfterRegistrations()
    {
        var (admin, _) = await factory.CreateAdminClientAsync();
        var code = NewCode();
        var ev = await DataAsync<AdminEventDto>(await admin.PostAsJsonAsync(AdminUrl, Event(code,
            Group("Juniors", 5, 17), Group("Seniors", 18, 99))));
        var family = await factory.CreateSignedInClientAsync();
        var girl = await PvsApiFactory.RegisterMemberAsync(family, RegistrationRequests.Student());
        Assert.Equal(HttpStatusCode.OK, (await RegisterAsync(family, girl, ev.Id, GroupId(ev, "Juniors"))).StatusCode);

        // Juniors is in use: cannot be removed. Seniors is free: removed. A new group is added.
        var withoutJuniors = Event(code, Group("Seniors", 18, 99, id: GroupId(ev, "Seniors")));
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await admin.PutAsJsonAsync($"{AdminUrl}/{ev.Id}", withoutJuniors)).StatusCode);

        var edited = await DataAsync<AdminEventDto>(await admin.PutAsJsonAsync($"{AdminUrl}/{ev.Id}", Event(code,
            Group("Under 18", 5, 17, id: GroupId(ev, "Juniors")), Group("Parents", 25, 70))));
        Assert.Equal(["Under 18", "Parents"], edited.Groups.Select(g => g.Name));
        Assert.Equal(GroupId(ev, "Juniors"), GroupId(edited, "Under 18"));

        var renamed = Event(NewCode(), Group("Under 18", 5, 17, id: GroupId(ev, "Juniors")));
        var refused = await admin.PutAsJsonAsync($"{AdminUrl}/{ev.Id}", renamed);
        Assert.Equal(HttpStatusCode.BadRequest, refused.StatusCode);
        Assert.Contains("code", await refused.Content.ReadAsStringAsync());

        // Codes are unique.
        Assert.Equal(HttpStatusCode.BadRequest, (await admin.PostAsJsonAsync(AdminUrl, Event(code, Group("A", 1, 2)))).StatusCode);
    }

    [Fact]
    public async Task Validation_Drafts_AndRegistrationDates()
    {
        var (admin, _) = await factory.CreateAdminClientAsync();

        var bad = Event("A B", Group("X", 10, 5, genderId: 999, capacity: 0));
        bad["registrationClosesDate"] = Today.AddDays(30).ToString("yyyy-MM-dd"); // after the event
        var response = await admin.PostAsJsonAsync(AdminUrl, bad);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var fields = (await response.Content.ReadFromJsonAsync<Envelope<object>>())!.Errors.Select(e => e.Field).ToHashSet();
        Assert.Superset(new HashSet<string?> { "code", "registrationClosesDate", "groups[0].maxAge", "groups[0].genderId", "groups[0].capacity" }, fields);

        var noGroups = await admin.PostAsJsonAsync(AdminUrl, Event(NewCode()));
        Assert.Equal(HttpStatusCode.BadRequest, noGroups.StatusCode);

        // A draft is not shown in the app; nor is an event whose registration has not opened yet registrable.
        var draftBody = Event(NewCode(), Group("All", 0, 120));
        draftBody["isPublished"] = false;
        var draft = await DataAsync<AdminEventDto>(await admin.PostAsJsonAsync(AdminUrl, draftBody));
        var laterBody = Event(NewCode(), Group("All", 0, 120));
        laterBody["registrationOpensDate"] = Today.AddDays(2).ToString("yyyy-MM-dd");
        var later = await DataAsync<AdminEventDto>(await admin.PostAsJsonAsync(AdminUrl, laterBody));

        var family = await factory.CreateSignedInClientAsync();
        var girl = await PvsApiFactory.RegisterMemberAsync(family, RegistrationRequests.Student());
        Assert.Null(await FindAsync(family, girl, draft.Id));
        Assert.Equal(HttpStatusCode.NotFound, (await RegisterAsync(family, girl, draft.Id, draft.Groups[0].Id)).StatusCode);

        var upcoming = (await FindAsync(family, girl, later.Id))!;
        Assert.False(upcoming.IsRegistrationOpen);
        Assert.Equal(HttpStatusCode.UnprocessableEntity, (await RegisterAsync(family, girl, later.Id, later.Groups[0].Id)).StatusCode);

        // Members cannot use the admin endpoints.
        Assert.Equal(HttpStatusCode.Forbidden, (await family.GetAsync(AdminUrl)).StatusCode);
    }
}
