# padmashali_vidya_setu (Flutter app)

See the repository README for setup. Structure:

```
lib/
  config/        AppConfig (APP_ENV, API_BASE_URL via --dart-define)
  core/          api client + exceptions, secure token storage
  models/        API models, registration draft (conditional rules)
  repositories/  API calls per area
  providers/     Riverpod providers, session
  routing/       go_router + redirect rules
  screens/       auth, registration (wizard + steps), home, profile
  widgets/       shared widgets (dropdowns, code input, cards)
  theme/ utils/ l10n/ (app_en.arb — all UI text)
test/            unit + widget tests (offline, fake repositories)
integration_test/ end-to-end flow against a running API
```
