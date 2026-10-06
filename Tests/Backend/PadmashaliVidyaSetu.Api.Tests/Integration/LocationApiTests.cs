using System.Net;
using System.Net.Http.Json;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class LocationApiTests(PvsApiFactory factory)
{
    [Fact]
    public async Task PinLookup_LegacyPostalNames_MatchSeededDistrictAndTaluk()
    {
        var client = await factory.CreateSignedInClientAsync();

        var result = await client.GetFromJsonAsync<Envelope<PinCodeLookupResponse>>($"/api/v1/locations/pin-codes/{FakePinCodeProvider.ShimogaPin}");

        Assert.Equal("Shivamogga", result!.Data!.District.Name); // India Post says "Shimoga"
        var suggested = result.Data.Taluks.Single(t => t.Id == result.Data.SuggestedTalukId);
        Assert.Equal("Shivamogga", suggested.Name);
    }

    [Fact]
    public async Task PinLookup_IsCachedLocally()
    {
        var client = await factory.CreateSignedInClientAsync();

        var first = await client.GetFromJsonAsync<Envelope<PinCodeLookupResponse>>($"/api/v1/locations/pin-codes/{FakePinCodeProvider.PutturPin}");
        var second = await client.GetFromJsonAsync<Envelope<PinCodeLookupResponse>>($"/api/v1/locations/pin-codes/{FakePinCodeProvider.PutturPin}");

        Assert.Equal(first!.Data!.Localities.Select(l => l.CityId), second!.Data!.Localities.Select(l => l.CityId));
    }

    [Theory]
    [InlineData("12345")]
    [InlineData("012345")]
    [InlineData("abcdef")]
    public async Task PinLookup_InvalidFormat_Returns400(string pin)
    {
        var client = await factory.CreateSignedInClientAsync();
        var response = await client.GetAsync($"/api/v1/locations/pin-codes/{pin}");
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task PinLookup_Unknown_Returns404()
    {
        var client = await factory.CreateSignedInClientAsync();
        var response = await client.GetAsync($"/api/v1/locations/pin-codes/{FakePinCodeProvider.UnknownPin}");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task PinLookup_ProviderDown_Returns503WithManualSelectionHint()
    {
        var client = await factory.CreateSignedInClientAsync();
        var response = await client.GetAsync($"/api/v1/locations/pin-codes/{FakePinCodeProvider.UnavailablePin}");
        Assert.Equal(HttpStatusCode.ServiceUnavailable, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains("manually", body!.Message);
    }

    [Fact]
    public async Task LocationHierarchy_StatesDistrictsTaluks()
    {
        var client = await factory.CreateSignedInClientAsync();

        var states = (await client.GetFromJsonAsync<Envelope<List<MasterDataItemDto>>>("/api/v1/locations/countries/1/states"))!.Data!;
        var karnataka = states.Single(s => s.Name == "Karnataka");
        var districts = (await client.GetFromJsonAsync<Envelope<List<MasterDataItemDto>>>($"/api/v1/locations/states/{karnataka.Id}/districts"))!.Data!;
        var dk = districts.Single(d => d.Name == "Dakshina Kannada");
        var taluks = (await client.GetFromJsonAsync<Envelope<List<MasterDataItemDto>>>($"/api/v1/locations/districts/{dk.Id}/taluks"))!.Data!;

        Assert.Equal(36, states.Count);
        Assert.Equal(31, districts.Count(d => d.Code.StartsWith("KA-")));
        Assert.Contains(taluks, t => t.Name == "Puttur");
    }

    [Fact]
    public async Task MasterData_UnknownType_Returns404()
    {
        var client = await factory.CreateSignedInClientAsync();
        var response = await client.GetAsync("/api/v1/master-data/not-a-list");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task MasterData_WithoutTypes_ExplainsWhatToSend()
    {
        var client = await factory.CreateSignedInClientAsync();
        var response = await client.GetAsync("/api/v1/master-data");
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains(body!.Errors, e => e.Field == "types" && e.Message.Contains("between 1 and 25"));
    }
}
