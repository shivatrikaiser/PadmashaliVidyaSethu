using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Events;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Event registrations (sports, drawing, quiz, ...) for a member of the signed-in account.</summary>
[ApiController]
[Authorize(Policy = Policies.Member)]
[Route("api/v1/members/{registrationId:regex(^PVS-\\d{{2}}-\\d{{4}}$)}/events")]
public sealed class EventsController(IEventService events) : ControllerBase
{
    /// <summary>Events the member can register for (or is registered for), with the groups that fit their age and gender.</summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MemberEventDto>>>> List(string registrationId, CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<MemberEventDto>>.Ok(await events.ListForMemberAsync(registrationId, ct)));

    /// <summary>Registers the member (or changes their groups); returns the event registration number.</summary>
    [HttpPut("{eventId:int}/registration")]
    public async Task<ActionResult<ApiResponse<EventRegistrationResultDto>>> Register(string registrationId, int eventId,
        EventRegistrationRequest request, CancellationToken ct) =>
        Ok(ApiResponse<EventRegistrationResultDto>.Ok(await events.RegisterAsync(registrationId, eventId, request, ct),
            "Registration successful."));

    [HttpDelete("{eventId:int}/registration")]
    public async Task<ActionResult<ApiResponse<object>>> Cancel(string registrationId, int eventId, CancellationToken ct)
    {
        await events.CancelAsync(registrationId, eventId, ct);
        return Ok(ApiResponse<object>.Ok(new { Cancelled = true }, "Registration cancelled."));
    }
}
