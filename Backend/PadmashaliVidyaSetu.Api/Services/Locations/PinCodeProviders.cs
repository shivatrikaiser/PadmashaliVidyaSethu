using System.Text.Json;
using System.Text.Json.Serialization;

namespace PadmashaliVidyaSetu.Api.Services.Locations;

/// <summary>One post office / locality returned by a PIN-code provider. Names are as the provider spells them.</summary>
public sealed record PostalLocality(string Name, string District, string? Block, string State, string Country);

/// <summary>
/// External PIN-code data source. Replaceable (e.g. with a licensed dataset or an internal table import)
/// without touching the rest of the application.
/// </summary>
public interface IPinCodeProvider
{
    /// <returns>Localities for the PIN; an empty list if the PIN does not exist.</returns>
    /// <exception cref="PinCodeProviderUnavailableException">The provider could not be reached or answered badly.</exception>
    Task<IReadOnlyList<PostalLocality>> LookupAsync(string pinCode, CancellationToken ct);
}

public sealed class PinCodeProviderUnavailableException(string message, Exception? inner = null) : Exception(message, inner);

/// <summary>Public India Post data via api.postalpincode.in. No API key required.</summary>
public sealed class IndiaPostPinCodeProvider(HttpClient http, ILogger<IndiaPostPinCodeProvider> logger) : IPinCodeProvider
{
    public async Task<IReadOnlyList<PostalLocality>> LookupAsync(string pinCode, CancellationToken ct)
    {
        IndiaPostResult[]? results;
        try
        {
            using var response = await http.GetAsync($"pincode/{pinCode}", ct);
            response.EnsureSuccessStatusCode();
            await using var stream = await response.Content.ReadAsStreamAsync(ct);
            results = await JsonSerializer.DeserializeAsync<IndiaPostResult[]>(stream, cancellationToken: ct);
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException && !ct.IsCancellationRequested)
        {
            logger.LogWarning(ex, "India Post PIN lookup failed for {PinCode}", pinCode);
            throw new PinCodeProviderUnavailableException("PIN-code service unavailable.", ex);
        }

        var offices = results?.FirstOrDefault()?.PostOffice;
        if (offices is null) return [];

        return offices
            .Where(o => !string.IsNullOrWhiteSpace(o.Name) && !string.IsNullOrWhiteSpace(o.District) && !string.IsNullOrWhiteSpace(o.State))
            .Select(o => new PostalLocality(
                o.Name!.Trim(),
                o.District!.Trim(),
                string.IsNullOrWhiteSpace(o.Block) || o.Block.Trim().Equals("NA", StringComparison.OrdinalIgnoreCase) ? null : o.Block.Trim(),
                o.State!.Trim(),
                string.IsNullOrWhiteSpace(o.Country) ? "India" : o.Country.Trim()))
            .ToList();
    }

    private sealed class IndiaPostResult
    {
        [JsonPropertyName("Status")] public string? Status { get; set; }
        [JsonPropertyName("PostOffice")] public List<IndiaPostOffice>? PostOffice { get; set; }
    }

    private sealed class IndiaPostOffice
    {
        [JsonPropertyName("Name")] public string? Name { get; set; }
        [JsonPropertyName("District")] public string? District { get; set; }
        [JsonPropertyName("Block")] public string? Block { get; set; }
        [JsonPropertyName("State")] public string? State { get; set; }
        [JsonPropertyName("Country")] public string? Country { get; set; }
    }
}
