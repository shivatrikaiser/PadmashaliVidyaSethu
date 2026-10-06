using System.Net;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;
using static PadmashaliVidyaSetu.Api.Tests.Infrastructure.RegistrationRequests;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class RegistrationApiTests(PvsApiFactory factory)
{
    /// <summary>Spec §43 / §55: register → verify → details → Student → class → complete → profile → dashboard.</summary>
    [Fact]
    public async Task FullFlow_Student_RegistersAndShowsDashboard()
    {
        var client = await factory.CreateSignedInClientAsync();

        var lists = await client.GetFromJsonAsync<Envelope<Dictionary<string, List<MasterDataItemDto>>>>(
            "/api/v1/master-data?types=temples,genders,member-statuses,classes,organisations,disability-types");
        Assert.Equal(16, lists!.Data!["temples"].Count);
        Assert.Contains(lists.Data["member-statuses"], s => s.Code == "STUDENT");
        Assert.Contains(lists.Data["classes"], c => c.Name == "PUC 1");

        var pin = await client.GetFromJsonAsync<Envelope<PinCodeLookupResponse>>($"/api/v1/locations/pin-codes/{FakePinCodeProvider.PutturPin}");
        Assert.Equal("Dakshina Kannada", pin!.Data!.District.Name);
        Assert.Equal("Karnataka", pin.Data.State.Name);
        Assert.Equal("India", pin.Data.Country.Name);
        Assert.Equal(3, pin.Data.SuggestedTalukId);

        var response = await client.PostAsJsonAsync("/api/v1/members", Student());
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var result = (await response.Content.ReadFromJsonAsync<Envelope<RegistrationResultDto>>())!.Data!;
        Assert.Matches(@"^PVS-01-\d{4}$", result.RegistrationId);

        var me = await client.GetFromJsonAsync<Envelope<MyAccountDto>>("/api/v1/me");
        Assert.Single(me!.Data!.Members);

        var profile = await client.GetFromJsonAsync<Envelope<MemberProfileDto>>($"/api/v1/members/{result.RegistrationId}");
        Assert.Equal("STUDENT", profile!.Data!.MemberStatusCode);
        Assert.Equal("PUC 1", profile.Data.Class!.Name);
        Assert.Null(profile.Data.HighestEducationLevel);
        Assert.Equal(2, profile.Data.Addresses.Count);

        var dashboard = await client.GetFromJsonAsync<Envelope<MemberDashboardDto>>($"/api/v1/members/{result.RegistrationId}/dashboard");
        var sections = dashboard!.Data!.ProfileCompletion.Sections;
        Assert.Equal("Complete", sections.Single(s => s.Key == "basic").Status);
        Assert.Equal("NotApplicable", sections.Single(s => s.Key == "employment").Status);
        Assert.InRange(dashboard.Data.ProfileCompletion.OverallPercent, 1, 99);
    }

    [Theory]
    [InlineData(StatusWorking)]
    [InlineData(StatusUnemployed)]
    public async Task WorkingOrUnemployed_WithClassStudying_IsRejected(int statusId)
    {
        var client = await factory.CreateSignedInClientAsync();
        var request = Adult(statusId);
        request["classId"] = ClassPuc1;
        request["highestEducationLevelId"] = null;

        var response = await client.PostAsJsonAsync("/api/v1/members", request);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains(body!.Errors, e => e.Field == "classId");
    }

    [Theory]
    [InlineData(StatusWorking)]
    [InlineData(StatusUnemployed)]
    public async Task WorkingOrUnemployed_WithHighestEducation_Registers(int statusId)
    {
        var client = await factory.CreateSignedInClientAsync();

        var response = await client.PostAsJsonAsync("/api/v1/members", Adult(statusId));

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var id = (await response.Content.ReadFromJsonAsync<Envelope<RegistrationResultDto>>())!.Data!.RegistrationId;
        var member = await factory.WithDbAsync(db => db.Members.SingleAsync(m => m.RegistrationId == id));
        Assert.Null(member.ClassId);
        Assert.Equal(EducationUndergraduate, member.HighestEducationLevelId);
    }

    [Fact]
    public async Task Student_WithoutClass_IsRejected()
    {
        var client = await factory.CreateSignedInClientAsync();
        var request = Student();
        request["classId"] = null;

        var response = await client.PostAsJsonAsync("/api/v1/members", request);

        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Contains(body!.Errors, e => e.Field == "classId");
    }

    [Fact]
    public async Task DisabledNo_WithDisabilityTypes_IsRejected()
    {
        var client = await factory.CreateSignedInClientAsync();
        var request = Student();
        request["disabilityTypeIds"] = new[] { DisabilityHearing };

        var response = await client.PostAsJsonAsync("/api/v1/members", request);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task DisabledYes_WithoutType_IsRejected()
    {
        var client = await factory.CreateSignedInClientAsync();
        var request = Student();
        request["isDisabled"] = true;

        var response = await client.PostAsJsonAsync("/api/v1/members", request);

        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Contains(body!.Errors, e => e.Field == "disabilityTypeIds");
    }

    [Fact]
    public async Task DisabledYes_Other_AddsNewTypeVisibleToEveryone()
    {
        var client = await factory.CreateSignedInClientAsync();
        var description = "Rare Condition " + Guid.NewGuid().ToString("N")[..6];
        var request = Student();
        request["isDisabled"] = true;
        request["disabilityTypeIds"] = new[] { DisabilityHearing, DisabilityOther };
        request["otherDisabilityDescription"] = description;

        var response = await client.PostAsJsonAsync("/api/v1/members", request);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var id = (await response.Content.ReadFromJsonAsync<Envelope<RegistrationResultDto>>())!.Data!.RegistrationId;

        var otherUser = await factory.CreateSignedInClientAsync();
        var types = await otherUser.GetFromJsonAsync<Envelope<List<MasterDataItemDto>>>("/api/v1/master-data/disability-types");
        var added = Assert.Single(types!.Data!, t => t.Name == description);
        Assert.Equal("OTHER", types.Data[^1].Code); // "Other" stays last

        var linked = await factory.WithDbAsync(db => db.MemberDisabilities.Where(d => d.RegistrationId == id).Select(d => d.DisabilityTypeId).ToListAsync());
        Assert.Equal([DisabilityHearing, added.Id], linked.Order().ToList());
    }

    [Fact]
    public async Task DisabledYes_OtherWithoutDescription_IsRejected()
    {
        var client = await factory.CreateSignedInClientAsync();
        var request = Student();
        request["isDisabled"] = true;
        request["disabilityTypeIds"] = new[] { DisabilityOther };

        var response = await client.PostAsJsonAsync("/api/v1/members", request);

        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains(body!.Errors, e => e.Field == "otherDisabilityDescription");
    }

    [Fact]
    public async Task Minor_WithoutGuardianConsent_IsRejected()
    {
        var client = await factory.CreateSignedInClientAsync();
        var request = Student();
        request["guardianConsent"] = false;

        var response = await client.PostAsJsonAsync("/api/v1/members", request);

        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains(body!.Errors, e => e.Field == "guardianConsent");
    }

    [Fact]
    public async Task YoungerThanFive_IsRejected()
    {
        var client = await factory.CreateSignedInClientAsync();
        var request = Student();
        request["dateOfBirth"] = DateOnly.FromDateTime(DateTime.UtcNow.AddYears(-4)).ToString("yyyy-MM-dd");

        var response = await client.PostAsJsonAsync("/api/v1/members", request);

        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains(body!.Errors, e => e.Field == "dateOfBirth");
    }

    [Fact]
    public async Task CurrentAddressSameAsPermanent_CopiesAddress()
    {
        var client = await factory.CreateSignedInClientAsync();
        var id = await RegisterAsync(client, Student());

        var addresses = await factory.WithDbAsync(db => db.MemberAddresses.Where(a => a.RegistrationId == id).ToListAsync());
        Assert.Equal(2, addresses.Count);
        var permanent = addresses.Single(a => a.AddressType == "Permanent");
        var current = addresses.Single(a => a.AddressType == "Current");
        Assert.Equal(permanent.AddressLine1, current.AddressLine1);
        Assert.Equal(permanent.PinCode, current.PinCode);
        Assert.Equal(permanent.TalukId, current.TalukId);
    }

    [Fact]
    public async Task DifferentCurrentAddress_IsRequiredWhenNotSame()
    {
        var client = await factory.CreateSignedInClientAsync();
        var request = Student();
        request["currentAddressSameAsPermanent"] = false;

        var response = await client.PostAsJsonAsync("/api/v1/members", request);

        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains(body!.Errors, e => e.Field == "currentAddress");
    }

    [Fact]
    public async Task TalukFromAnotherDistrict_IsRejected()
    {
        var client = await factory.CreateSignedInClientAsync();
        var request = Student();
        request["permanentAddress"] = Address(talukId: 17); // Shivamogga taluk with Dakshina Kannada district

        var response = await client.PostAsJsonAsync("/api/v1/members", request);

        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains(body!.Errors, e => e.Field == "permanentAddress.talukId");
    }

    [Fact]
    public async Task NewTalukName_IsAddedToDistrict()
    {
        var client = await factory.CreateSignedInClientAsync();
        var name = "Newtaluk " + new string(Guid.NewGuid().ToString("N").Where(char.IsLetter).Take(5).ToArray());
        var request = Student();
        request["permanentAddress"] = Address(talukId: null, newTalukName: name);

        await RegisterAsync(client, request);

        var taluks = await client.GetFromJsonAsync<Envelope<List<MasterDataItemDto>>>("/api/v1/locations/districts/11/taluks");
        Assert.Contains(taluks!.Data!, t => t.Name == name);
    }

    [Fact]
    public async Task RegistrationIds_AreSequentialWithinTemple_AndIndependentAcrossTemples()
    {
        var client = await factory.CreateSignedInClientAsync();

        var a = await RegisterAsync(client, Student("Member A", templeId: 7));
        var b = await RegisterAsync(client, Student("Member B", templeId: 7));
        var c = await RegisterAsync(client, Student("Member C", templeId: 8));

        Assert.Matches(@"^PVS-07-\d{4}$", a);
        Assert.Equal(int.Parse(a[^4..]) + 1, int.Parse(b[^4..]));
        Assert.StartsWith("PVS-08-", c);
    }

    [Fact]
    public async Task ConcurrentRegistrations_GetUniqueIds()
    {
        var clients = await Task.WhenAll(Enumerable.Range(0, 8).Select(_ => factory.CreateSignedInClientAsync()));

        var ids = await Task.WhenAll(clients.Select((c, i) => RegisterAsync(c, Student($"Parallel {(char)('A' + i)}", templeId: 9))));

        Assert.Equal(ids.Length, ids.Distinct().Count());
    }

    [Fact]
    public async Task DuplicateMemberOnSameAccount_Returns409()
    {
        var client = await factory.CreateSignedInClientAsync();
        await RegisterAsync(client, Student("Same Person"));

        var again = await client.PostAsJsonAsync("/api/v1/members", Student("same  person"));

        Assert.Equal(HttpStatusCode.Conflict, again.StatusCode);
    }

    [Fact]
    public async Task OneAccount_CanRegisterSiblings()
    {
        var client = await factory.CreateSignedInClientAsync();
        await RegisterAsync(client, Student("Sibling One"));
        await RegisterAsync(client, Adult(StatusWorking, "Sibling Two"));

        var me = await client.GetFromJsonAsync<Envelope<MyAccountDto>>("/api/v1/me");
        Assert.Equal(2, me!.Data!.Members.Count);
    }

    [Fact]
    public async Task OtherAccount_CannotReadMember()
    {
        var owner = await factory.CreateSignedInClientAsync();
        var id = await RegisterAsync(owner, Student());
        var stranger = await factory.CreateSignedInClientAsync();

        var profile = await stranger.GetAsync($"/api/v1/members/{id}");
        var dashboard = await stranger.GetAsync($"/api/v1/members/{id}/dashboard");

        Assert.Equal(HttpStatusCode.NotFound, profile.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, dashboard.StatusCode);
    }

    [Fact]
    public async Task Registration_RecordsConsentAndAudit()
    {
        var client = await factory.CreateSignedInClientAsync();
        var id = await RegisterAsync(client, Student());

        var consents = await factory.WithDbAsync(db => db.ConsentRecords.Where(c => c.RegistrationId == id).Select(c => c.ConsentType).ToListAsync());
        var audited = await factory.WithDbAsync(db => db.AuditLogs.AnyAsync(a => a.Action == "Member.Registered" && a.EntityKey == id));

        Assert.Contains("PRIVACY_POLICY", consents);
        Assert.Contains("GUARDIAN_CONSENT", consents);
        Assert.True(audited);
    }

    [Fact]
    public async Task InvalidJson_ReturnsEnvelope()
    {
        var client = await factory.CreateSignedInClientAsync();
        var content = new StringContent("{\"fullName\": 12, \"dateOfBirth\": \"not-a-date\"}", System.Text.Encoding.UTF8, "application/json");

        var response = await client.PostAsync("/api/v1/members", content);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.False(body!.Success);
    }

    private static async Task<string> RegisterAsync(HttpClient client, object request)
    {
        var response = await client.PostAsJsonAsync("/api/v1/members", request);
        Assert.True(response.StatusCode == HttpStatusCode.Created, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<Envelope<RegistrationResultDto>>())!.Data!.RegistrationId;
    }
}
