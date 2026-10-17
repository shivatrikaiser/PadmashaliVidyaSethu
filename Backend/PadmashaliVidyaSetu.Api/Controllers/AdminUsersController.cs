using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Admin;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Admin portal users. Super Admin only.</summary>
[ApiController]
[Authorize(Policy = Policies.ManageAdmins)]
[Route("api/v1/admin/users")]
public sealed class AdminUsersController(IAdminUserService users) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<AdminUserDto>>>> List(CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<AdminUserDto>>.Ok(await users.GetAdminsAsync(ct)));

    [HttpPost]
    public async Task<ActionResult<ApiResponse<AdminUserDto>>> Grant(GrantRoleRequest request, CancellationToken ct) =>
        Ok(ApiResponse<AdminUserDto>.Ok(await users.GrantAsync(request, ct), "Role granted. It applies at their next sign-in."));

    [HttpDelete("{accountId:int}/roles/{roleCode}")]
    public async Task<ActionResult<ApiResponse<object>>> Revoke(int accountId, string roleCode, CancellationToken ct)
    {
        await users.RevokeAsync(accountId, roleCode, ct);
        return Ok(new ApiResponse<object>(true, "Role removed. They have been signed out.", null, []));
    }
}
