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
    Task<IReadOnlyList<FooterSponsorAdminDto>> ListFooterSponsorsAsync(CancellationToken ct);
    Task<FooterSponsorAdminDto> SaveFooterSponsorAsync(int? id, SaveFooterSponsorRequest request, CancellationToken ct);
    Task DeleteFooterSponsorAsync(int id, CancellationToken ct);
}

/// <summary>Sponsor (name, organisation, address) / "Powered by" for the app (single settings row).</summary>
public sealed class BrandingService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IAuditLogger audit,
    TimeProvider clock) : IBrandingService
{
    public const int MaxLogoBytes = 300 * 1024;
    public const int MaxTextLength = 150;
    public const int MaxAddressLength = 300;
    public const int MaxAddressLines = 4;

    public const int MaxUrlLength = 500;

    public async Task<AppBrandingDto> GetAsync(CancellationToken ct) =>
        ToDto(await db.AppBranding.AsNoTracking()
            .Select(b => new AppBranding
            {
                SponsorName = b.SponsorName, SponsorOrganisation = b.SponsorOrganisation, SponsorAddress = b.SponsorAddress,
                PoweredBy = b.PoweredBy, PoweredByUrl = b.PoweredByUrl, ModifiedDate = b.ModifiedDate,
                SponsorLogoContentType = b.SponsorLogoContentType,
            })
            .SingleAsync(ct), await ActiveFooterSponsorsAsync(ct));

    private async Task<IReadOnlyList<FooterSponsorDto>> ActiveFooterSponsorsAsync(CancellationToken ct) =>
        await db.FooterSponsors.AsNoTracking()
            .Where(s => s.IsActive)
            .OrderBy(s => s.DisplayOrder).ThenBy(s => s.FooterSponsorId)
            .Select(s => new FooterSponsorDto(s.Name, s.Designation, s.CompanyName))
            .ToListAsync(ct);

    public async Task<IReadOnlyList<FooterSponsorAdminDto>> ListFooterSponsorsAsync(CancellationToken ct) =>
        await db.FooterSponsors.AsNoTracking()
            .OrderBy(s => s.DisplayOrder).ThenBy(s => s.FooterSponsorId)
            .Select(s => new FooterSponsorAdminDto(s.FooterSponsorId, s.Name, s.Designation, s.CompanyName, s.DisplayOrder,
                s.IsActive, s.ModifiedDate ?? s.CreatedDate))
            .ToListAsync(ct);

    /// <summary>Adds (<paramref name="id"/> null) or updates a footer sponsor.</summary>
    public async Task<FooterSponsorAdminDto> SaveFooterSponsorAsync(int? id, SaveFooterSponsorRequest request, CancellationToken ct)
    {
        var name = ValidText(request.Name, "name")
                   ?? throw new RequestValidationException([new ApiError("name", "Enter the sponsor's name.")]);
        var designation = ValidText(request.Designation, "designation");
        var company = ValidText(request.CompanyName, "companyName");
        if (request.DisplayOrder is < 0 or > 9999)
            throw new RequestValidationException([new ApiError("displayOrder", "Use a number from 0 to 9999.")]);

        FooterSponsor sponsor;
        if (id is null)
        {
            sponsor = new FooterSponsor();
            db.FooterSponsors.Add(sponsor);
        }
        else
        {
            sponsor = await db.FooterSponsors.SingleOrDefaultAsync(s => s.FooterSponsorId == id, ct)
                      ?? throw new NotFoundException("This sponsor no longer exists.");
        }
        sponsor.Name = name;
        sponsor.Designation = designation;
        sponsor.CompanyName = company;
        sponsor.DisplayOrder = request.DisplayOrder;
        sponsor.IsActive = request.IsActive;

        audit.Add(AuditActions.BrandingUpdated, "FooterSponsor", id?.ToString(),
            $"{(id is null ? "added" : "updated")} footer sponsor '{name}' ({(request.IsActive ? "active" : "inactive")})");
        await db.SaveChangesAsync(ct);
        return new FooterSponsorAdminDto(sponsor.FooterSponsorId, sponsor.Name, sponsor.Designation, sponsor.CompanyName,
            sponsor.DisplayOrder, sponsor.IsActive, sponsor.ModifiedDate ?? sponsor.CreatedDate);
    }

    public async Task DeleteFooterSponsorAsync(int id, CancellationToken ct)
    {
        var sponsor = await db.FooterSponsors.SingleOrDefaultAsync(s => s.FooterSponsorId == id, ct)
                      ?? throw new NotFoundException("This sponsor no longer exists.");
        db.FooterSponsors.Remove(sponsor);
        audit.Add(AuditActions.BrandingUpdated, "FooterSponsor", id.ToString(), $"removed footer sponsor '{sponsor.Name}'");
        await db.SaveChangesAsync(ct);
    }

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
        var organisation = ValidText(request.SponsorOrganisation, "sponsorOrganisation");
        var address = ValidAddress(request.SponsorAddress);
        var poweredBy = ValidText(request.PoweredBy, "poweredBy");
        var poweredByUrl = ValidUrl(request.PoweredByUrl, "poweredByUrl");
        var branding = await db.AppBranding.SingleAsync(ct);
        branding.SponsorName = sponsor;
        branding.SponsorOrganisation = organisation;
        branding.SponsorAddress = address;
        branding.PoweredBy = poweredBy;
        branding.PoweredByUrl = poweredByUrl;
        return await SaveAsync(branding, $"sponsor '{sponsor}', organisation '{organisation}', powered by '{poweredBy}' ({poweredByUrl})", ct);
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
        return ToDto(branding, await ActiveFooterSponsorsAsync(ct));
    }

    private static AppBrandingDto ToDto(AppBranding b, IReadOnlyList<FooterSponsorDto> footerSponsors) => new(
        b.SponsorName, b.SponsorOrganisation, b.SponsorAddress, b.PoweredBy, b.SponsorLogoContentType is not null,
        b.SponsorLogoContentType is null ? null : Version(b.ModifiedDate), b.ModifiedDate, b.PoweredByUrl, footerSponsors);

    /// <summary>An https link (or nothing).</summary>
    private static string? ValidUrl(string? value, string field)
    {
        var text = (value ?? string.Empty).Trim();
        if (text.Length == 0) return null;
        if (text.Length > MaxUrlLength || !Uri.TryCreate(text, UriKind.Absolute, out var url) || url.Scheme != Uri.UriSchemeHttps)
            throw new RequestValidationException([new ApiError(field, "Enter a full https:// link, e.g. the app's Google Play page.")]);
        return text;
    }

    /// <summary>Changes whenever the settings change, so apps can cache the logo URL safely.</summary>
    private static string Version(DateTime? modified) => (modified?.Ticks ?? 0).ToString("x");

    private static string? ValidText(string? value, string field)
    {
        var text = value.Tidy();
        if (text.Length > MaxTextLength)
            throw new RequestValidationException([new ApiError(field, $"At most {MaxTextLength} characters.")]);
        return text.Length == 0 ? null : text;
    }

    /// <summary>Each line tidied, blank lines dropped; at most <see cref="MaxAddressLines"/> lines.</summary>
    private static string? ValidAddress(string? value)
    {
        var lines = (value ?? string.Empty).Split('\n').Select(l => l.Tidy()).Where(l => l.Length > 0).ToList();
        var address = string.Join('\n', lines);
        if (lines.Count > MaxAddressLines)
            throw new RequestValidationException([new ApiError("sponsorAddress", $"At most {MaxAddressLines} lines.")]);
        if (address.Length > MaxAddressLength)
            throw new RequestValidationException([new ApiError("sponsorAddress", $"At most {MaxAddressLength} characters.")]);
        return address.Length == 0 ? null : address;
    }

    /// <summary>Recognises the file by its first bytes (never trusts the uploaded file name or type).</summary>
    private static string? ImageType(byte[] b) =>
        b is [0x89, 0x50, 0x4E, 0x47, ..] ? "image/png"
        : b is [0xFF, 0xD8, 0xFF, ..] ? "image/jpeg"
        : b.Length > 12 && b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F' && b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P' ? "image/webp"
        : null;

    private static RequestValidationException Invalid(string message) => new([new ApiError("sponsorLogo", message)]);
}
