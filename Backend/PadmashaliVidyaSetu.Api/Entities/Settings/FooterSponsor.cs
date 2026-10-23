using PadmashaliVidyaSetu.Api.Entities.Common;

namespace PadmashaliVidyaSetu.Api.Entities.Settings;

/// <summary>
/// One sponsor credited in the app's footer ("Sponsored by:" stays fixed, the active sponsors scroll beside it, in
/// <see cref="DisplayOrder"/>). Managed by Super Admins on the admin portal's branding page; inactive rows are kept
/// but not shown.
/// </summary>
public class FooterSponsor : AuditableEntity
{
    public int FooterSponsorId { get; set; }

    public string Name { get; set; } = string.Empty;

    /// <summary>E.g. "Managing Director"; optional.</summary>
    public string? Designation { get; set; }

    /// <summary>E.g. "Sri Laxmi Silks"; optional.</summary>
    public string? CompanyName { get; set; }

    /// <summary>Lower first.</summary>
    public int DisplayOrder { get; set; }
}
