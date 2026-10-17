using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Admin;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Public app content shown before sign-in (splash screen).</summary>
[ApiController]
[AllowAnonymous]
[Route("api/v1/app")]
public sealed class AppController(IBrandingService branding) : ControllerBase
{
    /// <summary>Sponsor and "Powered by" for the splash screen.</summary>
    [HttpGet("branding")]
    public async Task<ActionResult<ApiResponse<AppBrandingDto>>> Branding(CancellationToken ct) =>
        Ok(ApiResponse<AppBrandingDto>.Ok(await branding.GetAsync(ct)));

    /// <summary>The sponsor logo image. Cacheable: the URL carries <c>?v=</c> the logo version.</summary>
    [HttpGet("branding/sponsor-logo")]
    public async Task<IActionResult> SponsorLogo(CancellationToken ct)
    {
        var logo = await branding.GetSponsorLogoAsync(ct);
        if (logo is null) return NotFound();
        Response.Headers.CacheControl = "public, max-age=86400";
        return File(logo.Value.Bytes, logo.Value.ContentType, lastModified: null,
            entityTag: new Microsoft.Net.Http.Headers.EntityTagHeaderValue($"\"{logo.Value.Version}\""));
    }
}
