using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Endpoints for the web admin portal (Frontend/AdminWeb). Admin or Super Admin role required.</summary>
[ApiController]
[Authorize(Policy = Policies.Admin)]
[Route("api/v1/admin")]
public sealed class AdminController(AppDbContext db, ICurrentUserService currentUser) : ControllerBase
{
    /// <summary>The signed-in administrator. A 403 here means the account has no admin role.</summary>
    [HttpGet("me")]
    public async Task<ActionResult<ApiResponse<AdminMeDto>>> Me(CancellationToken ct)
    {
        var accountId = currentUser.RequireAccountId();
        var mobile = await db.Accounts.Where(a => a.AccountId == accountId).Select(a => a.MobileNumber).SingleAsync(ct);
        var roles = User.FindAll(PvsClaimTypes.Role).Select(c => c.Value).Order().ToList();
        return Ok(ApiResponse<AdminMeDto>.Ok(new AdminMeDto(MobileNumber.Mask(mobile), roles)));
    }
}
