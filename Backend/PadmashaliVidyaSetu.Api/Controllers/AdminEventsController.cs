using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Events;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Events with age / gender groups, and the registrations received.</summary>
[ApiController]
[Authorize(Policy = Policies.Admin)]
[Route("api/v1/admin/events")]
public sealed class AdminEventsController(IAdminEventService events) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<AdminEventRowDto>>>> List(CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<AdminEventRowDto>>.Ok(await events.ListAsync(ct)));

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ApiResponse<AdminEventDto>>> Get(int id, CancellationToken ct) =>
        Ok(ApiResponse<AdminEventDto>.Ok(await events.GetAsync(id, ct)));

    [HttpPost]
    public async Task<ActionResult<ApiResponse<AdminEventDto>>> Add(SaveEventRequest request, CancellationToken ct) =>
        Ok(ApiResponse<AdminEventDto>.Ok(await events.SaveAsync(null, request, ct), "Event added."));

    [HttpPut("{id:int}")]
    public async Task<ActionResult<ApiResponse<AdminEventDto>>> Update(int id, SaveEventRequest request, CancellationToken ct) =>
        Ok(ApiResponse<AdminEventDto>.Ok(await events.SaveAsync(id, request, ct), "Event saved."));

    [HttpGet("{id:int}/registrations")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<AdminEventRegistrationDto>>>> Registrations(int id, CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<AdminEventRegistrationDto>>.Ok(await events.RegistrationsAsync(id, ct)));

    /// <summary>CSV (opens in Excel) of the event's registrations, cancelled ones included.</summary>
    [HttpGet("{id:int}/registrations/export")]
    public async Task<IActionResult> Export(int id, CancellationToken ct)
    {
        var (csv, code) = await events.ExportRegistrationsCsvAsync(id, ct);
        return File(csv, "text/csv; charset=utf-8", $"pvs-event-{code.ToLowerInvariant()}-{DateTime.UtcNow:yyyyMMdd-HHmm}.csv");
    }
}
