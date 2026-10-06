using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.Locations;

namespace PadmashaliVidyaSetu.Api.Services.Locations;

/// <summary>
/// Matches free-text location names (from the PIN-code provider or from a member) to master rows, creating a row
/// when no match exists. Matching ignores case, spacing and punctuation and also checks the legacy/postal spelling,
/// so "Shimoga" resolves to the seeded "Shivamogga" district.
/// New rows are added to the change tracker; the caller saves.
/// </summary>
public sealed class LocationResolver(AppDbContext db)
{
    private const int AutoDisplayOrder = 1000;

    public static string Normalize(string value) =>
        new(value.Replace("&", "and", StringComparison.Ordinal).ToLowerInvariant().Where(char.IsLetterOrDigit).ToArray());

    public async Task<State> ResolveStateAsync(Country country, string name, CancellationToken ct)
    {
        var candidates = await db.States.Where(s => s.CountryId == country.Id).ToListAsync(ct);
        var match = FindMatch(candidates, name, s => s.PostalName);
        if (match is not null) return match;

        var created = new State
        {
            CountryId = country.Id,
            Name = name,
            PostalName = name,
            Code = await UniqueCodeAsync(db.States, $"{country.Code}-{Slug(name)}", ct),
            DisplayOrder = AutoDisplayOrder,
        };
        db.States.Add(created);
        return created;
    }

    public async Task<District> ResolveDistrictAsync(State state, string name, string source, CancellationToken ct)
    {
        var candidates = state.Id == 0
            ? []
            : await db.Districts.Where(d => d.StateId == state.Id).ToListAsync(ct);
        candidates.AddRange(db.Districts.Local.Where(d => d.State == state && d.Id == 0));
        var match = FindMatch(candidates, name, d => d.PostalName);
        if (match is not null) return match;

        var created = new District
        {
            State = state,
            Name = name,
            PostalName = name,
            Source = source,
            Code = await UniqueCodeAsync(db.Districts, $"{state.Code}-{Slug(name)}", ct),
            DisplayOrder = AutoDisplayOrder,
        };
        db.Districts.Add(created);
        return created;
    }

    public async Task<Taluk> ResolveTalukAsync(District district, string name, string source, CancellationToken ct)
    {
        var candidates = district.Id == 0
            ? []
            : await db.Taluks.Where(t => t.DistrictId == district.Id).ToListAsync(ct);
        candidates.AddRange(db.Taluks.Local.Where(t => t.District == district && t.Id == 0));
        var match = FindMatch(candidates, name, t => t.PostalName);
        if (match is not null) return match;

        var created = new Taluk
        {
            District = district,
            Name = name,
            PostalName = source == LocationSources.PinLookup ? name : null,
            Source = source,
            Code = await UniqueCodeAsync(db.Taluks, $"{district.Code}-{Slug(name)}", ct),
            DisplayOrder = AutoDisplayOrder,
        };
        db.Taluks.Add(created);
        return created;
    }

    private static T? FindMatch<T>(IEnumerable<T> candidates, string name, Func<T, string?> postalName) where T : MasterDataEntity
    {
        var key = Normalize(name);
        return candidates.FirstOrDefault(c => Normalize(c.Name) == key)
               ?? candidates.FirstOrDefault(c => postalName(c) is { } p && Normalize(p) == key);
    }

    public static string Slug(string value)
    {
        var slug = new string(value.ToUpperInvariant().Select(ch => char.IsLetterOrDigit(ch) ? ch : '-').ToArray());
        while (slug.Contains("--", StringComparison.Ordinal)) slug = slug.Replace("--", "-", StringComparison.Ordinal);
        return slug.Trim('-');
    }

    /// <summary>Returns <paramref name="baseCode"/> (truncated to fit) or a numbered variant not yet used.</summary>
    public static async Task<string> UniqueCodeAsync<T>(DbSet<T> set, string baseCode, CancellationToken ct) where T : MasterDataEntity
    {
        const int maxLength = 56; // leaves room for a "-NNN" suffix within the 60-char column
        var code = baseCode.Length > maxLength ? baseCode[..maxLength].TrimEnd('-') : baseCode;
        var candidate = code;
        for (var i = 2; await set.AnyAsync(e => e.Code == candidate, ct) || set.Local.Any(e => e.Code == candidate); i++)
        {
            candidate = $"{code}-{i}";
        }
        return candidate;
    }
}
