using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.Settings;
using PadmashaliVidyaSetu.Api.Logging;

namespace PadmashaliVidyaSetu.Api.Services.Admin;

public interface IBrandingService
{
    Task<AppBrandingDto> GetAsync(CancellationToken ct);
    Task<(byte[] Bytes, string ContentType, string Version)?> GetSponsorLogoAsync(CancellationToken ct);
    Task<AppBrandingDto> UpdateTextAsync(UpdateBrandingRequest request, CancellationToken ct);
    Task<AppBrandingDto> SetSponsorLogoAsync(byte[] bytes, CancellationToken ct);
    Task<AppBrandingDto> RemoveSponsorLogoAsync(CancellationToken ct);
}

/// <summary>Sponsor / "Powered by" for the splash screen (single settings row).</summary>
public sealed class BrandingService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IAuditLogger audit,
    TimeProvider clock) : IBrandingService
{
    public const int MaxLogoBytes = 300 * 1024;
    public const int MaxTextLength = 150;

    public async Task<AppBrandingDto> GetAsync(CancellationToken ct) =>
        ToDto(await db.AppBranding.AsNoTracking()
            .Select(b => new AppBranding
            {
                SponsorName = b.SponsorName, PoweredBy = b.PoweredBy, ModifiedDate = b.ModifiedDate,
                SponsorLogoContentType = b.SponsorLogoContentType,
            })
            .SingleAsync(ct));

    public async Task<(byte[] Bytes, string ContentType, string Version)?> GetSponsorLogoAsync(CancellationToken ct)
    {
        var logo = await db.AppBranding.AsNoTracking()
            .Select(b => new { b.SponsorLogo, b.SponsorLogoContentType, b.ModifiedDate })
            .SingleAsync(ct);
        return logo.SponsorLogo is null || logo.SponsorLogoContentType is null
            ? null
            : (logo.SponsorLogo, logo.SponsorLogoContentType, Version(logo.ModifiedDate));
    }

    public async Task<AppBrandingDto> UpdateTextAsync(UpdateBrandingRequest request, CancellationToken ct)
    {
        var sponsor = ValidText(request.SponsorName, "sponsorName");
        var poweredBy = ValidText(request.PoweredBy, "poweredBy");
        var branding = await db.AppBranding.SingleAsync(ct);
        branding.SponsorName = sponsor;
        branding.PoweredBy = poweredBy;
        return await SaveAsync(branding, $"sponsor '{sponsor}', powered by '{poweredBy}'", ct);
    }

    public async Task<AppBrandingDto> SetSponsorLogoAsync(byte[] bytes, CancellationToken ct)
    {
        if (bytes.Length == 0) throw Invalid("Choose an image file.");
        if (bytes.Length > MaxLogoBytes) throw Invalid($"The logo must be at most {MaxLogoBytes / 1024} KB.");
        var contentType = ImageType(bytes) ?? throw Invalid("The logo must be a PNG, JPEG or WebP image.");

        var branding = await db.AppBranding.SingleAsync(ct);
        branding.SponsorLogo = bytes;
        branding.SponsorLogoContentType = contentType;
        return await SaveAsync(branding, $"sponsor logo set ({bytes.Length / 1024} KB)", ct);
    }

    public async Task<AppBrandingDto> RemoveSponsorLogoAsync(CancellationToken ct)
    {
        var branding = await db.AppBranding.SingleAsync(ct);
        branding.SponsorLogo = null;
        branding.SponsorLogoContentType = null;
        return await SaveAsync(branding, "sponsor logo removed", ct);
    }

    private async Task<AppBrandingDto> SaveAsync(AppBranding branding, string details, CancellationToken ct)
    {
        branding.ModifiedDate = clock.GetUtcNow().UtcDateTime;
        branding.ModifiedBy = currentUser.AuditName;
        audit.Add(AuditActions.BrandingUpdated, "AppBranding", null, details);
        await db.SaveChangesAsync(ct);
        return ToDto(branding);
    }

    private static AppBrandingDto ToDto(AppBranding b) => new(
        b.SponsorName, b.PoweredBy, b.SponsorLogoContentType is not null,
        b.SponsorLogoContentType is null ? null : Version(b.ModifiedDate), b.ModifiedDate);

    /// <summary>Changes whenever the settings change, so apps can cache the logo URL safely.</summary>
    private static string Version(DateTime? modified) => (modified?.Ticks ?? 0).ToString("x");

    private static string? ValidText(string? value, string field)
    {
        var text = value.Tidy();
        if (text.Length > MaxTextLength)
            throw new RequestValidationException([new ApiError(field, $"At most {MaxTextLength} characters.")]);
        return text.Length == 0 ? null : text;
    }

    /// <summary>Recognises the file by its first bytes (never trusts the uploaded file name or type).</summary>
    private static string? ImageType(byte[] b) =>
        b is [0x89, 0x50, 0x4E, 0x47, ..] ? "image/png"
        : b is [0xFF, 0xD8, 0xFF, ..] ? "image/jpeg"
        : b.Length > 12 && b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F' && b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P' ? "image/webp"
        : null;

    private static RequestValidationException Invalid(string message) => new([new ApiError("sponsorLogo", message)]);
}
