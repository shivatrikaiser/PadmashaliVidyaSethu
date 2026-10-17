using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Admin;

namespace PadmashaliVidyaSetu.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Admin)]
[Route("api/v1/admin/members")]
public sealed class AdminMembersController(IAdminMemberService members) : ControllerBase
{
    private const string RegistrationIdRoute = "{registrationId:regex(^PVS-\\d{{2}}-\\d{{4}}$)}";

    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedResult<AdminMemberRowDto>>>> Search([FromQuery] MemberSearchQuery query, CancellationToken ct) =>
        Ok(ApiResponse<PagedResult<AdminMemberRowDto>>.Ok(await members.SearchAsync(query, ct)));

    /// <summary>CSV (opens in Excel) of all members matching the filters, up to 50,000 rows.</summary>
    [HttpGet("export")]
    public async Task<IActionResult> Export([FromQuery] MemberSearchQuery query, CancellationToken ct) =>
        File(await members.ExportCsvAsync(query, ct), "text/csv; charset=utf-8", $"pvs-members-{DateTime.UtcNow:yyyyMMdd-HHmm}.csv");

    [HttpGet(RegistrationIdRoute)]
    public async Task<ActionResult<ApiResponse<AdminMemberDetailDto>>> Get(string registrationId, CancellationToken ct) =>
        Ok(ApiResponse<AdminMemberDetailDto>.Ok(await members.GetDetailAsync(registrationId, ct)));

    /// <summary>Deactivate (hidden from the app and reports) or reactivate a member. Nothing is deleted.</summary>
    [HttpPut(RegistrationIdRoute + "/status")]
    public async Task<ActionResult<ApiResponse<object>>> SetStatus(string registrationId, SetActiveRequest request, CancellationToken ct)
    {
        await members.SetActiveAsync(registrationId, request.IsActive, ct);
        return Ok(new ApiResponse<object>(true, request.IsActive ? "Member activated." : "Member deactivated.", null, []));
    }
}
