using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Admin;

namespace PadmashaliVidyaSetu.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Admin)]
[Route("api/v1/admin/reports")]
public sealed class AdminReportsController(IAdminReportService reports) : ControllerBase
{
    [HttpGet("summary")]
    public async Task<ActionResult<ApiResponse<AdminSummaryDto>>> Summary(CancellationToken ct) =>
        Ok(ApiResponse<AdminSummaryDto>.Ok(await reports.GetSummaryAsync(ct)));
}
