using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Notifications;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>Push notifications to all app users. Super Admin only.</summary>
[ApiController]
[Authorize(Policy = Policies.SendNotifications)]
[Route("api/v1/admin/notifications")]
public sealed class AdminNotificationsController(INotificationService notifications) : ControllerBase
{
    /// <summary>Whether sending is set up, the limits, and the last 50 notifications sent.</summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<NotificationOverviewDto>>> Get(CancellationToken ct) =>
        Ok(ApiResponse<NotificationOverviewDto>.Ok(await notifications.GetOverviewAsync(ct)));

    /// <summary>Sends a push notification to every app user.</summary>
    [HttpPost]
    public async Task<ActionResult<ApiResponse<PushNotificationDto>>> Send(SendNotificationRequest request, CancellationToken ct) =>
        Ok(ApiResponse<PushNotificationDto>.Ok(await notifications.SendToAllAsync(request, ct), "Notification sent to all app users."));
}
