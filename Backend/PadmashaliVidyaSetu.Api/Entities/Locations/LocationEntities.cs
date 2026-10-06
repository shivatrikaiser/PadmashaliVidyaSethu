using PadmashaliVidyaSetu.Api.Entities.Common;

namespace PadmashaliVidyaSetu.Api.Entities.Locations;

/// <summary>Code = ISO 3166-1 alpha-2.</summary>
public class Country : MasterDataEntity
{
    public ICollection<State> States { get; set; } = [];
}

public class State : MasterDataEntity
{
    public int CountryId { get; set; }
    public Country Country { get; set; } = null!;

    /// <summary>Name as returned by the postal PIN-code service, when it differs from <see cref="MasterDataEntity.Name"/>.</summary>
    public string? PostalName { get; set; }

    public ICollection<District> Districts { get; set; } = [];
}

public class District : MasterDataEntity
{
    public int StateId { get; set; }
    public State State { get; set; } = null!;

    /// <summary>Legacy/postal spelling, e.g. "Shimoga" for Shivamogga. Used to match PIN-code lookups.</summary>
    public string? PostalName { get; set; }

    /// <summary>Seed, PinLookup or Admin.</summary>
    public string Source { get; set; } = LocationSources.Seed;

    public ICollection<Taluk> Taluks { get; set; } = [];
}

public class Taluk : MasterDataEntity
{
    public int DistrictId { get; set; }
    public District District { get; set; } = null!;

    public string? PostalName { get; set; }
    public string Source { get; set; } = LocationSources.Seed;
}

/// <summary>
/// City / village / locality, keyed by PIN code. Rows are learned from the PIN-code service and
/// then served locally, so this table doubles as the PIN-code cache.
/// </summary>
public class City : MasterDataEntity
{
    public string PinCode { get; set; } = string.Empty;

    public int DistrictId { get; set; }
    public District District { get; set; } = null!;

    public int? TalukId { get; set; }
    public Taluk? Taluk { get; set; }

    public string Source { get; set; } = LocationSources.PinLookup;
}

public static class LocationSources
{
    public const string Seed = "Seed";
    public const string PinLookup = "PinLookup";
    public const string UserSubmitted = "UserSubmitted";
    public const string Admin = "Admin";
}
