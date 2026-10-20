namespace PadmashaliVidyaSetu.Api.Entities.Settings;

/// <summary>
/// The current release of the mobile app, one row per platform. Updated when a new version is published to the
/// store (see <c>Database/seed/04_ReleaseAppVersion.TEMPLATE.sql</c>). The app checks it on every screen and asks
/// for an update when it is older than <see cref="LatestVersion"/>.
/// </summary>
public class AppVersion
{
    public const string Android = "android";
    public const string Ios = "ios";

    /// <summary><see cref="Android"/> or <see cref="Ios"/>.</summary>
    public string Platform { get; set; } = null!;

    /// <summary>Version name as in the app's pubspec, e.g. "1.0.3" (major.minor.patch).</summary>
    public string LatestVersion { get; set; } = null!;

    /// <summary>True: older apps cannot be used until updated. False: they show a dismissible "update available".</summary>
    public bool IsMandatory { get; set; } = true;

    /// <summary>Play Store / App Store page the update button opens; null shows no button.</summary>
    public string? StoreUrl { get; set; }

    public DateTime? ModifiedDate { get; set; }
    public string? ModifiedBy { get; set; }
}
