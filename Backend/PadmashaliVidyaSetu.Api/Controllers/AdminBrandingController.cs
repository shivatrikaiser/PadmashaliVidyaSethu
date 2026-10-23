using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Admin;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Splash-screen sponsor and "Powered by". Super Admin only.</summary>
[ApiController]
[Authorize(Policy = Policies.ManageBranding)]
[Route("api/v1/admin/branding")]
public sealed class AdminBrandingController(IBrandingService branding) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<AppBrandingDto>>> Get(CancellationToken ct) =>
        Ok(ApiResponse<AppBrandingDto>.Ok(await branding.GetAsync(ct)));

    [HttpPut]
    public async Task<ActionResult<ApiResponse<AppBrandingDto>>> Update(UpdateBrandingRequest request, CancellationToken ct) =>
        Ok(ApiResponse<AppBrandingDto>.Ok(await branding.UpdateTextAsync(request, ct), "Saved."));

    /// <summary>Upload the sponsor logo (multipart field "file"; PNG, JPEG or WebP, max 300 KB).</summary>
    [HttpPost("sponsor-logo")]
    [RequestSizeLimit(BrandingService.MaxLogoBytes + 64 * 1024)]
    public async Task<ActionResult<ApiResponse<AppBrandingDto>>> UploadLogo(IFormFile? file, CancellationToken ct)
    {
        if (file is null)
            throw new RequestValidationException([new ApiError("sponsorLogo", "Choose an image file.")]);
        if (file.Length > BrandingService.MaxLogoBytes)
            throw new RequestValidationException([new ApiError("sponsorLogo", $"The logo must be at most {BrandingService.MaxLogoBytes / 1024} KB.")]);

        using var buffer = new MemoryStream();
        await file.CopyToAsync(buffer, ct);
        return Ok(ApiResponse<AppBrandingDto>.Ok(await branding.SetSponsorLogoAsync(buffer.ToArray(), ct), "Logo uploaded."));
    }

    [HttpDelete("sponsor-logo")]
    public async Task<ActionResult<ApiResponse<AppBrandingDto>>> RemoveLogo(CancellationToken ct) =>
        Ok(ApiResponse<AppBrandingDto>.Ok(await branding.RemoveSponsorLogoAsync(ct), "Logo removed."));

    /// <summary>All footer sponsors (active and inactive), in display order.</summary>
    [HttpGet("footer-sponsors")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<FooterSponsorAdminDto>>>> FooterSponsors(CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<FooterSponsorAdminDto>>.Ok(await branding.ListFooterSponsorsAsync(ct)));

    [HttpPost("footer-sponsors")]
    public async Task<ActionResult<ApiResponse<FooterSponsorAdminDto>>> AddFooterSponsor(SaveFooterSponsorRequest request, CancellationToken ct) =>
        Ok(ApiResponse<FooterSponsorAdminDto>.Ok(await branding.SaveFooterSponsorAsync(null, request, ct), "Sponsor added."));

    [HttpPut("footer-sponsors/{id:int}")]
    public async Task<ActionResult<ApiResponse<FooterSponsorAdminDto>>> UpdateFooterSponsor(int id, SaveFooterSponsorRequest request,
        CancellationToken ct) =>
        Ok(ApiResponse<FooterSponsorAdminDto>.Ok(await branding.SaveFooterSponsorAsync(id, request, ct), "Sponsor saved."));

    [HttpDelete("footer-sponsors/{id:int}")]
    public async Task<ActionResult<ApiResponse<object>>> DeleteFooterSponsor(int id, CancellationToken ct)
    {
        await branding.DeleteFooterSponsorAsync(id, ct);
        return Ok(ApiResponse<object>.Ok(new { Deleted = true }, "Sponsor removed."));
    }
}
