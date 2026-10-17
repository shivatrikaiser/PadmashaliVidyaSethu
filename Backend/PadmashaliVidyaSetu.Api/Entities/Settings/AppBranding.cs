namespace PadmashaliVidyaSetu.Api.Entities.Settings;

/// <summary>
/// Sponsor and "Powered by" shown on the app's splash screen. Single row (<see cref="SingletonId"/>), edited by
/// Super Admins in the admin portal.
/// </summary>
public class AppBranding
{
    public const int SingletonId = 1;

    public int AppBrandingId { get; set; } = SingletonId;

    /// <summary>Sponsor name; null hides the sponsor card unless a logo is set.</summary>
    public string? SponsorName { get; set; }

    /// <summary>Optional sponsor logo (PNG / JPEG / WebP).</summary>
    public byte[]? SponsorLogo { get; set; }
    public string? SponsorLogoContentType { get; set; }

    /// <summary>Text after "Powered by :"; null hides the line.</summary>
    public string? PoweredBy { get; set; }

    public DateTime? ModifiedDate { get; set; }
    public string? ModifiedBy { get; set; }
}
