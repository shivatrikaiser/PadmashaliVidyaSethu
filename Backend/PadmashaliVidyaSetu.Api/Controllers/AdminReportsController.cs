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

    /// <summary>Accounts deleted by their users in the app (kept for the records), newest first, with their members.</summary>
    [HttpGet("deleted-accounts")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<DeletedAccountDto>>>> DeletedAccounts(
        [FromQuery] DeletedAccountsQuery query, CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<DeletedAccountDto>>.Ok(await reports.GetDeletedAccountsAsync(query, ct)));

    /// <summary>The deleted-accounts report as CSV (opens in Excel), one row per member.</summary>
    [HttpGet("deleted-accounts/export")]
    public async Task<IActionResult> ExportDeletedAccounts([FromQuery] DeletedAccountsQuery query, CancellationToken ct) =>
        File(await reports.ExportDeletedAccountsCsvAsync(query, ct), "text/csv; charset=utf-8",
            $"pvs-deleted-accounts-{DateTime.UtcNow:yyyyMMdd-HHmm}.csv");
}
