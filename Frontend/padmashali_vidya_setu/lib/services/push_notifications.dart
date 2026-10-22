import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/app_config.dart';

/// Push notifications (Firebase Cloud Messaging) for every app user.
///
/// * Every install subscribes to one topic per environment ([AppConfig.pushTopic]: "all" in production builds), and
///   the admin portal sends one message to that topic - no sign-in or device list needed.
/// * App in the background or closed: Android shows the notification itself, on the [channel] below (set as the
///   default channel in AndroidManifest.xml) with the app's small icon - the app does not need to run.
/// * App open: Firebase does not display anything, so [_showWhileOpen] shows it as a normal notification.
///
/// Needs android/app/google-services.json (and ios/Runner/GoogleService-Info.plist + APNs for iOS). Without it
/// [start] logs and returns: the app works as before, just without push.
abstract final class PushNotifications {
  /// Same id as the server's FirebasePushSender.AndroidChannelId and the manifest's default channel.
  static const channel = AndroidNotificationChannel(
    'pvs_general',
    'Announcements',
    description: 'News and announcements from Padmashali Vidya Sethu',
    importance: Importance.high,
  );

  static final _local = FlutterLocalNotificationsPlugin();
  static bool _started = false;

  static bool get _supported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// Sets everything up; safe to call once at startup (it never throws and never blocks the UI).
  static Future<void> start(AppConfig config) async {
    if (_started || !_supported) return;
    _started = true;
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Push notifications off: Firebase is not configured for this build ($e).');
      return;
    }

    try {
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      final messaging = FirebaseMessaging.instance;
      // Android 13+ and iOS ask the user once; earlier Android versions allow notifications by default.
      final settings = await messaging.requestPermission();
      debugPrint('Push notification permission: ${settings.authorizationStatus.name}');

      // iOS: show alerts while the app is open too (Android: see _showWhileOpen).
      await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
      FirebaseMessaging.onMessage.listen(_showWhileOpen);

      // Every start: idempotent, and repairs a subscription lost after reinstalling or clearing data.
      await messaging.subscribeToTopic(config.pushTopic);
      debugPrint('Push notifications on: subscribed to topic "${config.pushTopic}".');
    } catch (e) {
      // e.g. no network on first start: the next start subscribes again.
      debugPrint('Push notifications: setup incomplete ($e).');
    }
  }

  static Future<void> _showWhileOpen(RemoteMessage message) async {
    final n = message.notification;
    if (n == null || defaultTargetPlatform != TargetPlatform.android) return;
    await _local.show(
      id: message.messageId.hashCode,
      title: n.title,
      body: n.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_notification',
          styleInformation: BigTextStyleInformation(n.body ?? ''),
        ),
      ),
    );
  }
}
