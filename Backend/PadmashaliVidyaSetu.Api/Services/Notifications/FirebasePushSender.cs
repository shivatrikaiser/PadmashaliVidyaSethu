using System.ComponentModel.DataAnnotations;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Options;

namespace PadmashaliVidyaSetu.Api.Services.Notifications;

/// <summary>
/// Firebase Cloud Messaging (push notifications). The service-account key is a secret: supply it through
/// user-secrets / an App Service setting (<c>Firebase__CredentialsJson</c>, the whole JSON on one line) or a file path
/// (<c>Firebase__CredentialsPath</c>). Without either, sending is switched off (the admin page says so).
/// </summary>
public class FirebaseOptions
{
    public const string Section = "Firebase";

    /// <summary>Contents of the Firebase service-account JSON key (Project settings → Service accounts).</summary>
    public string? CredentialsJson { get; set; }

    /// <summary>Alternative to <see cref="CredentialsJson"/>: path to the key file (outside the repository).</summary>
    public string? CredentialsPath { get; set; }

    /// <summary>
    /// The topic every app install subscribes to. Must match the app's build: "all" for production builds,
    /// "all-dev" for development builds - so test notifications never reach real members.
    /// </summary>
    [Required, RegularExpression("^[a-zA-Z0-9-_.~%]{1,100}$")]
    public string AllUsersTopic { get; set; } = "all";

    public bool IsConfigured => !string.IsNullOrWhiteSpace(CredentialsJson) || !string.IsNullOrWhiteSpace(CredentialsPath);
}

public interface IPushSender
{
    bool IsConfigured { get; }

    /// <summary>Sends a notification to every device subscribed to <paramref name="topic"/>; returns the FCM message id.</summary>
    Task<string> SendToTopicAsync(string topic, string title, string body, CancellationToken ct);
}

/// <summary>Sends through the Firebase Admin SDK. Android: high priority on the app's "pvs_general" channel, so the
/// notification pops up even when the app is closed; iOS: alert with sound.</summary>
public sealed class FirebasePushSender(IOptions<FirebaseOptions> options) : IPushSender
{
    /// <summary>Must match the channel the app creates (lib/services/push_notifications.dart).</summary>
    public const string AndroidChannelId = "pvs_general";

    private readonly FirebaseOptions _options = options.Value;
    private readonly Lazy<FirebaseMessaging> _messaging = new(() => CreateMessaging(options.Value));

    public bool IsConfigured => _options.IsConfigured;

    public async Task<string> SendToTopicAsync(string topic, string title, string body, CancellationToken ct)
    {
        var message = new Message
        {
            Topic = topic,
            Notification = new Notification { Title = title, Body = body },
            Data = new Dictionary<string, string> { ["type"] = "broadcast" },
            Android = new AndroidConfig
            {
                Priority = Priority.High,
                Notification = new AndroidNotification
                {
                    ChannelId = AndroidChannelId,
                    DefaultSound = true,
                    Priority = NotificationPriority.HIGH,
                    Icon = "ic_stat_notification",
                },
            },
            Apns = new ApnsConfig
            {
                Headers = new Dictionary<string, string> { ["apns-priority"] = "10" },
                Aps = new Aps { Sound = "default" },
            },
        };
        return await _messaging.Value.SendAsync(message, ct);
    }

    private static FirebaseMessaging CreateMessaging(FirebaseOptions o)
    {
        var credential = !string.IsNullOrWhiteSpace(o.CredentialsJson)
            ? CredentialFactory.FromJson<ServiceAccountCredential>(o.CredentialsJson).ToGoogleCredential()
            : CredentialFactory.FromFile<ServiceAccountCredential>(o.CredentialsPath!).ToGoogleCredential();
        // A named app, so nothing else in the process can replace or reuse it.
        var app = FirebaseApp.GetInstance("pvs") ?? FirebaseApp.Create(new AppOptions { Credential = credential }, "pvs");
        return FirebaseMessaging.GetMessaging(app);
    }
}
