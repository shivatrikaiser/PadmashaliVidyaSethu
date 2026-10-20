namespace PadmashaliVidyaSetu.Api.Entities.Settings;

/// <summary>
/// Sponsor and "Powered by" shown on the app's splash and welcome screens and in its footer. Single row
/// (<see cref="SingletonId"/>), edited by Super Admins in the admin portal.
/// </summary>
public class AppBranding
{
    public const int SingletonId = 1;

    public int AppBrandingId { get; set; } = SingletonId;

    /// <summary>Sponsor name; null hides the sponsor card unless a logo is set.</summary>
    public string? SponsorName { get; set; }

    /// <summary>Sponsor's organisation (shown under the name on the welcome screen); null hides the line.</summary>
    public string? SponsorOrganisation { get; set; }

    /// <summary>Sponsor's address, up to <c>BrandingService.MaxAddressLines</c> lines separated by a line feed; null hides it.</summary>
    public string? SponsorAddress { get; set; }

    /// <summary>Optional sponsor logo (PNG / JPEG / WebP).</summary>
    public byte[]? SponsorLogo { get; set; }
    public string? SponsorLogoContentType { get; set; }

    /// <summary>Text after "Powered by :"; null hides the line.</summary>
    public string? PoweredBy { get; set; }

    public DateTime? ModifiedDate { get; set; }
    public string? ModifiedBy { get; set; }
}
