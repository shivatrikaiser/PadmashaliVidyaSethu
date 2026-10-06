using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Locations;
using PadmashaliVidyaSetu.Api.Entities.MasterData;

namespace PadmashaliVidyaSetu.Api.Services.Locations;

public interface IPinCodeLookupService
{
    Task<PinCodeLookupResponse> LookupAsync(string pinCode, CancellationToken ct);
}

/// <summary>
/// PIN code → City / District / State / Country (+ Taluk suggestion).
/// Served from the local <c>Cities</c> table when the PIN has been seen before; otherwise fetched from the
/// configured <see cref="IPinCodeProvider"/> and stored, so each PIN is fetched from outside at most once.
/// </summary>
public sealed partial class PinCodeLookupService(
    AppDbContext db,
    IPinCodeProvider provider,
    LocationResolver resolver,
    ILogger<PinCodeLookupService> logger) : IPinCodeLookupService
{
    [GeneratedRegex(@"^[1-9]\d{5}$")]
    public static partial Regex PinCodePattern();

    public async Task<PinCodeLookupResponse> LookupAsync(string pinCode, CancellationToken ct)
    {
        pinCode = pinCode.Trim();
        if (!PinCodePattern().IsMatch(pinCode))
            throw new RequestValidationException("pinCode", "Please enter a valid 6-digit PIN code.");

        if (!await db.Cities.AnyAsync(c => c.PinCode == pinCode, ct))
        {
            await LearnFromProviderAsync(pinCode, ct);
        }

        return await BuildResponseAsync(pinCode, ct)
               ?? throw new NotFoundException("We could not find this PIN code. Please check it, or select the district manually.");
    }

    private async Task LearnFromProviderAsync(string pinCode, CancellationToken ct)
    {
        IReadOnlyList<PostalLocality> localities;
        try
        {
            localities = await provider.LookupAsync(pinCode, ct);
        }
        catch (PinCodeProviderUnavailableException)
        {
            throw new ServiceUnavailableException(
                "PIN code details could not be fetched right now. Please select the state, district and taluk manually.");
        }

        if (localities.Count == 0) return;

        var countries = await db.Countries.ToListAsync(ct);
        foreach (var locality in localities)
        {
            var country = countries.FirstOrDefault(c =>
                              LocationResolver.Normalize(c.Name) == LocationResolver.Normalize(locality.Country))
                          ?? countries.Single(c => c.Code == MasterCodes.CountryIndia);
            var state = await resolver.ResolveStateAsync(country, locality.State, ct);
            var district = await resolver.ResolveDistrictAsync(state, locality.District, LocationSources.PinLookup, ct);
            var taluk = locality.Block is null
                ? null
                : await resolver.ResolveTalukAsync(district, locality.Block, LocationSources.PinLookup, ct);

            var exists = db.Cities.Local.Any(c => c.PinCode == pinCode &&
                                                  string.Equals(c.Name, locality.Name, StringComparison.OrdinalIgnoreCase));
            if (exists) continue;

            db.Cities.Add(new City
            {
                PinCode = pinCode,
                Name = locality.Name,
                Code = await LocationResolver.UniqueCodeAsync(db.Cities, $"{pinCode}-{LocationResolver.Slug(locality.Name)}", ct),
                District = district,
                Taluk = taluk,
                Source = LocationSources.PinLookup,
                DisplayOrder = 0,
            });
        }

        try
        {
            await db.SaveChangesAsync(ct);
            logger.LogInformation("Learned {Count} localities for PIN {PinCode}", localities.Count, pinCode);
        }
        catch (DbUpdateException ex)
        {
            // Most likely a concurrent lookup of the same PIN stored it first. Fall back to whatever is stored.
            logger.LogWarning(ex, "Could not store localities for PIN {PinCode}; using stored data", pinCode);
            db.ChangeTracker.Clear();
        }
    }

    private async Task<PinCodeLookupResponse?> BuildResponseAsync(string pinCode, CancellationToken ct)
    {
        var cities = await db.Cities.AsNoTracking()
            .Where(c => c.PinCode == pinCode && c.IsActive)
            .Include(c => c.District).ThenInclude(d => d.State).ThenInclude(s => s.Country)
            .OrderBy(c => c.DisplayOrder).ThenBy(c => c.Name)
            .ToListAsync(ct);
        if (cities.Count == 0) return null;

        // A PIN occasionally spans districts; use the district most of its localities belong to.
        var districtId = cities.GroupBy(c => c.DistrictId).OrderByDescending(g => g.Count()).First().Key;
        var inDistrict = cities.Where(c => c.DistrictId == districtId).ToList();
        var district = inDistrict[0].District;

        var taluks = await db.Taluks.AsNoTracking()
            .Where(t => t.DistrictId == districtId && t.IsActive)
            .OrderBy(t => t.DisplayOrder).ThenBy(t => t.Name)
            .Select(t => new MasterDataItemDto(t.Id, t.Name, t.Code))
            .ToListAsync(ct);

        var suggestedTalukId = inDistrict
            .Where(c => c.TalukId is not null)
            .GroupBy(c => c.TalukId)
            .OrderByDescending(g => g.Count())
            .Select(g => g.Key)
            .FirstOrDefault();

        return new PinCodeLookupResponse(
            pinCode,
            new MasterDataItemDto(district.State.Country.Id, district.State.Country.Name, district.State.Country.Code),
            new MasterDataItemDto(district.State.Id, district.State.Name, district.State.Code),
            new MasterDataItemDto(district.Id, district.Name, district.Code),
            inDistrict.Select(c => new LocalityDto(c.Id, c.Name, c.TalukId)).ToList(),
            taluks,
            suggestedTalukId);
    }
}
