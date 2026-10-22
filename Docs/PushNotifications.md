# Push notifications (Firebase Cloud Messaging)

A Super Admin sends a notification from the admin portal (**Notifications** page). It reaches every phone with the
app installed - also when the app is closed - within seconds (phones that are off or offline get it when they
reconnect; FCM keeps it up to 4 weeks).

## How it works

| Part | What it does |
|---|---|
| App (`lib/services/push_notifications.dart`) | At every start: initialises Firebase, creates the Android channel `pvs_general` (high importance: heads-up + sound), asks for notification permission (Android 13+, iOS), subscribes to the topic of its build. While the app is open it shows incoming notifications itself; when closed or in the background Android shows them. |
| Topic per environment | Production builds `all`, staging `all-staging`, development `all-dev` (`AppConfig.pushTopic`). The API sends to `Firebase:AllUsersTopic` (same values in `appsettings*.json`), so test messages never reach members. |
| API | `GET/POST /api/v1/admin/notifications` (Super Admin). Sends one FCM message to the topic with the Firebase Admin SDK, keeps a history in `PVS_PushNotifications`, writes an audit entry. The same title and text within 2 minutes is refused (double click). |
| Admin portal | **Notifications** page: title (65), message (240), Android preview, confirmation, history. |

No device list is needed: every install that opened the app once (and allowed notifications) is subscribed.

## One-time setup (Firebase console - https://console.firebase.google.com)

1. **Project**: create one (or use the IQ Explore project) - e.g. "Padmashali Vidya Sethu".
2. **Android app**: Project settings → *Add app* → Android, package name
   `org.padmashalividyasetu.padmashali_vidya_setu`. Download **google-services.json** and put it in
   `Frontend/padmashali_vidya_setu/android/app/`. (It is not a secret; it may be committed.) Rebuild the app - without
   this file the app builds and runs, just without push.
3. **Server key**: Project settings → *Service accounts* → *Generate new private key*. This JSON **is a secret** -
   never commit it (`.gitignore` blocks `*firebase-adminsdk*.json`).
   * Local API: `dotnet user-secrets set "Firebase:CredentialsJson" "<the whole JSON on one line>"`
     (in `Backend/PadmashaliVidyaSetu.Api`), or `Firebase:CredentialsPath` = path to the file outside the repo.
   * Azure App Service → Environment variables: `Firebase__CredentialsJson` = the JSON.
4. **iOS** (later, needs a Mac): add the iOS app in Firebase, download `GoogleService-Info.plist` into
   `ios/Runner/`, upload an APNs authentication key (Apple Developer → Keys) in Firebase → Cloud Messaging, and enable
   *Push Notifications* + *Background Modes → Remote notifications* in Xcode.

## Testing

* Development build on a phone/emulator with Google Play: `flutter run --dart-define-from-file=config/development.json`
  → allow notifications → it subscribes to `all-dev`. Send from the admin portal running against the local API
  (`Firebase:AllUsersTopic` = `all-dev` in Development). Close the app and send again: the notification still appears.
* The Firebase console (*Messaging → New campaign → Notification*, target topic `all-dev`) can also send a test.

## Notes

* Members who refuse the permission (or switch it off in Android settings) do not see notifications; nothing else
  changes for them.
* Some phone makers (Xiaomi, Oppo, Vivo, ...) stop apps aggressively; FCM high-priority notifications still arrive,
  but a member who "force stops" the app receives nothing until they open it again (Android rule).
