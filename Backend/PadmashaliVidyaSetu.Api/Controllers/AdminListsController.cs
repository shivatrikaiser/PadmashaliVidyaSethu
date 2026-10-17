using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Admin;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Configurable lists (temples, courses, skills, ...), including inactive entries. Super Admin only.</summary>
[ApiController]
[Authorize(Policy = Policies.ManageMasterData)]
[Route("api/v1/admin/lists")]
public sealed class AdminListsController(IAdminListService lists) : ControllerBase
{
    [HttpGet]
    public ActionResult<ApiResponse<IReadOnlyList<AdminListTypeDto>>> Types() =>
        Ok(ApiResponse<IReadOnlyList<AdminListTypeDto>>.Ok(lists.ListTypes));

    [HttpGet("{type}")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<AdminListItemDto>>>> Items(string type, CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<AdminListItemDto>>.Ok(await lists.GetItemsAsync(type, ct)));

    [HttpPost("{type}")]
    public async Task<ActionResult<ApiResponse<AdminListItemDto>>> Create(string type, CreateListItemRequest request, CancellationToken ct) =>
        Ok(ApiResponse<AdminListItemDto>.Ok(await lists.CreateAsync(type, request, ct), "Added."));

    [HttpPut("{type}/{id:int}")]
    public async Task<ActionResult<ApiResponse<AdminListItemDto>>> Update(string type, int id, UpdateListItemRequest request, CancellationToken ct) =>
        Ok(ApiResponse<AdminListItemDto>.Ok(await lists.UpdateAsync(type, id, request, ct), "Saved."));
}
