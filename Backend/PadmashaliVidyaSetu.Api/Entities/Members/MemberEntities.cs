using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.Locations;
using PadmashaliVidyaSetu.Api.Entities.MasterData;

namespace PadmashaliVidyaSetu.Api.Entities.Members;

/// <summary>
/// Basic profile captured at registration. Detailed education / career / employment data lives in
/// separate per-module tables keyed by <see cref="RegistrationId"/> so the profile can evolve over years.
/// </summary>
public class Member : AuditableEntity
{
    /// <summary>Primary key. Format PVS-TT-NNNN (TT = temple code, NNNN = sequence within temple).</summary>
    public string RegistrationId { get; set; } = string.Empty;

    public int AccountId { get; set; }
    public Account Account { get; set; } = null!;

    public string FullName { get; set; } = string.Empty;
    public string FatherName { get; set; } = string.Empty;
    public string MotherName { get; set; } = string.Empty;

    /// <summary>Authoritative. Age is always derived from this, never stored.</summary>
    public DateOnly DateOfBirth { get; set; }

    public int GenderId { get; set; }
    public Gender Gender { get; set; } = null!;

    public int TempleId { get; set; }
    public Temple Temple { get; set; } = null!;

    public int MemberStatusId { get; set; }
    public MemberStatus MemberStatus { get; set; } = null!;

    /// <summary>Only when status is Student.</summary>
    public int? ClassId { get; set; }
    public SchoolClass? Class { get; set; }

    /// <summary>Only when status is Working or Unemployed.</summary>
    public int? HighestEducationLevelId { get; set; }
    public EducationLevel? HighestEducationLevel { get; set; }

    public int OrganisationId { get; set; }
    public Organisation Organisation { get; set; } = null!;

    public bool IsCurrentAddressSameAsPermanent { get; set; }

    /// <summary>Sensitive. Restricted to the member and authorised roles.</summary>
    public bool IsDisabled { get; set; }

    public DateTime RegistrationCompletedDate { get; set; }

    public ICollection<MemberAddress> Addresses { get; set; } = [];
    public ICollection<MemberDisability> Disabilities { get; set; } = [];
}

public class MemberAddress : AuditableEntity
{
    public int MemberAddressId { get; set; }

    public string RegistrationId { get; set; } = string.Empty;
    public Member Member { get; set; } = null!;

    /// <summary>One of <see cref="AddressTypes"/>.</summary>
    public string AddressType { get; set; } = AddressTypes.Permanent;

    public string AddressLine1 { get; set; } = string.Empty;
    public string? AddressLine2 { get; set; }

    public string PinCode { get; set; } = string.Empty;

    /// <summary>Authoritative display text (user may edit the locality suggested by the PIN lookup).</summary>
    public string CityVillageName { get; set; } = string.Empty;
    public int? CityId { get; set; }
    public City? City { get; set; }

    public int TalukId { get; set; }
    public Taluk Taluk { get; set; } = null!;

    public int DistrictId { get; set; }
    public District District { get; set; } = null!;

    public int StateId { get; set; }
    public State State { get; set; } = null!;

    public int CountryId { get; set; }
    public Country Country { get; set; } = null!;
}

public class MemberDisability
{
    public string RegistrationId { get; set; } = string.Empty;
    public Member Member { get; set; } = null!;

    public int DisabilityTypeId { get; set; }
    public DisabilityType DisabilityType { get; set; } = null!;

    public DateTime CreatedDate { get; set; }
    public string? CreatedBy { get; set; }
}

/// <summary>Per-temple counter used to allocate the NNNN part of Registration IDs.</summary>
public class TempleRegistrationSequence
{
    public int TempleId { get; set; }
    public Temple Temple { get; set; } = null!;
    public int LastSequenceNumber { get; set; }
}

public static class AddressTypes
{
    public const string Permanent = "Permanent";
    public const string Current = "Current";
}
