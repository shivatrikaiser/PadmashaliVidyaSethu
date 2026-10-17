using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Admin;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Review of districts / taluks added by PIN lookups or typed by members.</summary>
[ApiController]
[Authorize(Policy = Policies.Admin)]
[Route("api/v1/admin/locations")]
public sealed class AdminLocationsController(ILocationReviewService locations) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<LocationReviewItemDto>>>> Review([FromQuery] bool includeSeed, CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<LocationReviewItemDto>>.Ok(await locations.GetAsync(includeSeed, ct)));

    [HttpPut("districts/{id:int}")]
    public async Task<ActionResult<ApiResponse<object>>> UpdateDistrict(int id, UpdateLocationRequest request, CancellationToken ct)
    {
        await locations.UpdateDistrictAsync(id, request, ct);
        return Ok(new ApiResponse<object>(true, "Saved.", null, []));
    }

    [HttpPut("taluks/{id:int}")]
    public async Task<ActionResult<ApiResponse<object>>> UpdateTaluk(int id, UpdateLocationRequest request, CancellationToken ct)
    {
        await locations.UpdateTalukAsync(id, request, ct);
        return Ok(new ApiResponse<object>(true, "Saved.", null, []));
    }

    /// <summary>Moves every address (and PIN-cache entry) from taluk <paramref name="id"/> to the target, then deactivates it.</summary>
    [HttpPost("taluks/{id:int}/merge")]
    public async Task<ActionResult<ApiResponse<object>>> MergeTaluk(int id, MergeTalukRequest request, CancellationToken ct)
    {
        var moved = await locations.MergeTalukAsync(id, request.TargetTalukId, ct);
        return Ok(new ApiResponse<object>(true, $"Merged. {moved} address(es) moved.", null, []));
    }
}
