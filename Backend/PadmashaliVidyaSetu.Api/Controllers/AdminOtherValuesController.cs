using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Admin;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>"Other" texts typed by members, and mapping them to proper list entries. Super Admin only.</summary>
[ApiController]
[Authorize(Policy = Policies.ManageMasterData)]
[Route("api/v1/admin/other-values")]
public sealed class AdminOtherValuesController(IOtherValueService otherValues) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<OtherValueDto>>>> Pending(CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<OtherValueDto>>.Ok(await otherValues.GetPendingAsync(ct)));

    [HttpPost("map")]
    public async Task<ActionResult<ApiResponse<MapOtherValueResultDto>>> Map(MapOtherValueRequest request, CancellationToken ct) =>
        Ok(ApiResponse<MapOtherValueResultDto>.Ok(await otherValues.MapAsync(request, ct), "Mapped."));
}
