using FirebaseAdmin.Messaging;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.Settings;
using PadmashaliVidyaSetu.Api.Logging;

namespace PadmashaliVidyaSetu.Api.Services.Notifications;

public interface INotificationService
{
    Task<NotificationOverviewDto> GetOverviewAsync(CancellationToken ct);
    Task<PushNotificationDto> SendToAllAsync(SendNotificationRequest request, CancellationToken ct);
}

/// <summary>
/// Push notifications to every app user: one FCM message to the topic all app installs subscribe to
/// (<see cref="FirebaseOptions.AllUsersTopic"/>), plus a history row and an audit entry.
/// </summary>
public sealed class NotificationService(
    AppDbContext db,
    IPushSender sender,
    IOptions<FirebaseOptions> options,
    ICurrentUserService currentUser,
    IAuditLogger audit,
    TimeProvider clock,
    ILogger<NotificationService> logger) : INotificationService
{
    /// <summary>The same title and text again within this time is treated as an accidental second click.</summary>
    public static readonly TimeSpan DuplicateWindow = TimeSpan.FromMinutes(2);

    private readonly FirebaseOptions _options = options.Value;

    public async Task<NotificationOverviewDto> GetOverviewAsync(CancellationToken ct)
    {
        var history = await db.PushNotifications.AsNoTracking()
            .OrderByDescending(n => n.SentDate)
            .Take(50)
            .Select(n => new PushNotificationDto(n.PushNotificationId, n.Title, n.Body, n.Topic, n.SentDate, n.SentBy))
            .ToListAsync(ct);
        return new NotificationOverviewDto(sender.IsConfigured, _options.AllUsersTopic,
            PushNotification.MaxTitleLength, PushNotification.MaxBodyLength, history);
    }

    public async Task<PushNotificationDto> SendToAllAsync(SendNotificationRequest request, CancellationToken ct)
    {
        var title = request.Title.Tidy();
        var body = (request.Body ?? string.Empty).Trim();
        var errors = new List<ApiError>();
        if (title.Length == 0) errors.Add(new("title", "Enter a title."));
        else if (title.Length > PushNotification.MaxTitleLength)
            errors.Add(new("title", $"At most {PushNotification.MaxTitleLength} characters."));
        if (body.Length == 0) errors.Add(new("body", "Enter the message."));
        else if (body.Length > PushNotification.MaxBodyLength)
            errors.Add(new("body", $"At most {PushNotification.MaxBodyLength} characters."));
        if (errors.Count > 0) throw new RequestValidationException(errors);

        if (!sender.IsConfigured)
            throw new ServiceUnavailableException("Push notifications are not set up yet: the Firebase key is missing on the server.");

        var now = clock.GetUtcNow().UtcDateTime;
        var since = now - DuplicateWindow;
        if (await db.PushNotifications.AnyAsync(n => n.Title == title && n.Body == body && n.SentDate >= since, ct))
            throw new ConflictException("This notification was just sent. Wait a few minutes before sending it again.");

        string messageId;
        try
        {
            messageId = await sender.SendToTopicAsync(_options.AllUsersTopic, title, body, ct);
        }
        catch (FirebaseMessagingException e)
        {
            logger.LogError(e, "FCM send to topic {Topic} failed: {Code}", _options.AllUsersTopic, e.MessagingErrorCode);
            throw new ServiceUnavailableException("Firebase did not accept the notification. Please try again later.");
        }

        var row = new PushNotification
        {
            Title = title, Body = body, Topic = _options.AllUsersTopic, FcmMessageId = messageId,
            SentDate = now, SentBy = currentUser.AuditName,
        };
        db.PushNotifications.Add(row);
        audit.Add(AuditActions.NotificationSent, "PushNotification", null, $"topic '{row.Topic}': {title}");
        await db.SaveChangesAsync(ct);
        logger.LogInformation("Push notification {Id} sent to topic {Topic} ({MessageId})", row.PushNotificationId, row.Topic, messageId);
        return new PushNotificationDto(row.PushNotificationId, row.Title, row.Body, row.Topic, row.SentDate, row.SentBy);
    }
}
