namespace PadmashaliVidyaSetu.Api.Entities.Settings;

/// <summary>A push notification a Super Admin sent from the admin portal (history; the message itself goes via FCM).</summary>
public class PushNotification
{
    public const int MaxTitleLength = 65;
    public const int MaxBodyLength = 240;

    public int PushNotificationId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;

    /// <summary>The FCM topic it went to ("all" in production).</summary>
    public string Topic { get; set; } = string.Empty;

    /// <summary>Message id returned by Firebase.</summary>
    public string? FcmMessageId { get; set; }

    public DateTime SentDate { get; set; }
    public string? SentBy { get; set; }
}
