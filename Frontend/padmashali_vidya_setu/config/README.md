# Flutter environment configuration

Pass one of these files at build/run time:

```bash
flutter run --dart-define-from-file=config/development.json
flutter build appbundle --release --dart-define-from-file=config/production.json
```

| Key            | Meaning                                                                 |
|----------------|-------------------------------------------------------------------------|
| `APP_ENV`      | `development`, `staging` or `production`                               |
| `API_BASE_URL` | PVS API root. Omit in development to use `http://10.0.2.2:5274` on the Android emulator and `http://localhost:5274` elsewhere. |

`development.device.json` is a template for a physical phone on the same Wi-Fi as the
development PC — replace the IP with the PC's LAN address (and allow it in
`android/app/src/debug/res/xml/network_security_config.xml`).

The staging / production URLs are placeholders until hosting is decided.
**Never put secrets or API keys here** — anything compiled into the app can be extracted.
