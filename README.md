# Padmashali Vidya Sethu

> Connecting Our Young Padmashalis for a Brighter Future

An education, skills, career and employment platform for Padmashali children and youngsters (age 5+), built for the
**Padmashali Vidyavardhaka Sangha**. Members register with basic details and complete their profile over the years —
School → PUC → College → Higher Education → Employment — so the Sangha can plan scholarships, guidance, training,
mentorship and job programs.

**Status (2026-10-06): Milestone 1 complete** — phone verification, registration, home dashboard with profile
completion, basic profile view. Detailed profile modules (education, interests, career, employment, communication)
and the admin portal are the next phases (see `Docs/ProfileModules.md`).

| Layer | Technology |
|---|---|
| Mobile app | Flutter 3.41 / Dart 3.11, Material 3, Riverpod, go_router, Dio — Android first; iOS/Web ready |
| Admin portal | Angular 21 (web) - `Frontend/AdminWeb` |
| VidyaSethu public website | Angular 21, prerendered static site - `Frontend/VidyaSethuWeb` (separate product site, no backend; lists PVS as an organization) |
| API | ASP.NET Core Web API on .NET 10, EF Core 10, FluentValidation, Serilog, JWT |
| Database | SQL Server / Azure SQL (LocalDB for development) |

## Folder structure

```
PVS/
├── Backend/          ASP.NET Core API (PadmashaliVidyaSetu.slnx)
├── Frontend/         Flutter app (padmashali_vidya_setu/), web admin portal (AdminWeb/),
│                     VidyaSethu public website (VidyaSethuWeb/)
├── Database/         Generated SQL schema + seed, operational scripts
├── Tests/            Backend unit + integration tests (Flutter tests live in the Flutter project)
├── Docs/             Architecture, database, API, flows, security, deployment, master data, UI screenshots
├── Deployment/       Environment notes
├── RunBackend/       Start_Backend_API.bat
└── RunFrontend/      Start_Frontend_App.bat, Start_Admin_Web.bat
```

## Prerequisites

* .NET SDK 10 (`dotnet --list-sdks`)
* SQL Server LocalDB (installed with Visual Studio) — or any SQL Server
* Flutter 3.41+ (`flutter doctor`), Android SDK + an emulator (Android Studio)
* Git

## Run locally

### 1. Backend
```bash
cd Backend/PadmashaliVidyaSetu.Api
dotnet tool restore                       # dotnet-ef (local tool, see /dotnet-tools.json)
# Optional but recommended — keeps you signed in across API restarts:
dotnet user-secrets init
dotnet user-secrets set "Jwt:SigningKey" "<at least 32 random characters>"
dotnet user-secrets set "PhoneVerification:CodeHashingKey" "<another 32+ random characters>"
dotnet run --launch-profile http          # http://localhost:5274  (health: /health)
```
In Development the database `PadmashaliVidyaSetu` is created on LocalDB, migrated and seeded automatically.
Without user-secrets the API uses temporary keys (warning in the log) — fine for a quick try.

**Phone Number Verification Code:** sent by SMS through **SMS Gateway Hub** (DLT template
`Your Phone Number Verification Code for PVS is {#numeric#} Valid for 10 minutes.`, settings in the `SMS` section of
`appsettings.json`). The API key is a secret — never put it in a file in the repo:

```bash
dotnet user-secrets set "SMS:APIKey" "<your SMS Gateway Hub API key>"     # development
# servers: environment variable SMS__APIKey (or Key Vault)
```

In Development no SMS is sent by default (`PhoneVerification:Sender = Development`): the API returns the code and the
app shows it in a "Development mode" box. To send real SMS from your PC, also run
`dotnet user-secrets set "PhoneVerification:Sender" "SmsGatewayHub"`. Staging/Production always use SMS Gateway Hub and
refuse to start if the SMS settings or API key are missing.

### 2. App
```bash
flutter emulators --launch Medium_Phone   # or any AVD with free storage
cd Frontend/padmashali_vidya_setu
flutter run --dart-define-from-file=config/development.json
```
The Android emulator reaches the API at `http://10.0.2.2:5274` automatically. For a physical phone see
`Frontend/padmashali_vidya_setu/config/README.md`.

Or just double-click `RunBackend/Start_Backend_API.bat` then `RunFrontend/Start_Frontend_App.bat`.

### 3. Admin portal (web)
With the API running, double-click `RunFrontend/Start_Admin_Web.bat` (opens http://localhost:4200). Sign-in needs a
mobile number with the ADMIN or SUPER_ADMIN role - grant it with `Database/seed/03_GrantAdminRole.TEMPLATE.sql`.
Details: `Frontend/AdminWeb/README.md`.

### 4. VidyaSethu public website
The product website for https://vidyasethu.co.in - independent of the PVS API, app and database. Double-click
`RunFrontend/Start_VidyaSethu_Web.bat` (opens http://localhost:4300). Build, tests, the PVS link configuration and
Azure deployment: `Frontend/VidyaSethuWeb/README.md`.

## Tests

```bash
# Backend: 103 unit + integration tests (integration tests use a throw-away LocalDB database)
dotnet test Backend/PadmashaliVidyaSetu.slnx

# Flutter: unit + widget tests (offline)
cd Frontend/padmashali_vidya_setu && flutter test

# End-to-end on an emulator against the running API (registration → home)
flutter test integration_test -d emulator-5554

# Same, saving screenshots to Docs/ui/screenshots
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/registration_flow_test.dart \
  -d emulator-5554 --dart-define=SCREENSHOTS=true
```

## Database

* Schema = EF Core migrations (`Backend/PadmashaliVidyaSetu.Api/Migrations`).
  New migration: `dotnet ef migrations add <Name> --output-dir Migrations` (from the API folder).
* Apply manually: `dotnet ef database update`.
* Idempotent SQL for DBAs: `Database/schema/PadmashaliVidyaSetu_Schema_And_Seed.sql` (regenerate after migrations).
* Temples seeded: Barkur, Mangaluru, Kallianapura, Salikeri, Kinnimulky (codes 01–05). Add more with `Database/seed/01_AddTemples.TEMPLATE.sql`.

## Build

```bash
dotnet publish Backend/PadmashaliVidyaSetu.Api -c Release -o publish
cd Frontend/padmashali_vidya_setu && flutter build appbundle --release --dart-define-from-file=config/production.json
```
See `Docs/Deployment.md` (release signing, secrets, hosting).

## Configuration

| Where | What |
|---|---|
| `appsettings.json` | Defaults (no secrets) |
| `appsettings.Development.json` | LocalDB, auto-migrate, development verification code, relaxed rate limit |
| `appsettings.Staging/Production.json` | Non-secret overrides; secrets via environment variables / Key Vault |
| Flutter `config/*.json` | `APP_ENV`, `API_BASE_URL` (no secrets — app packages can be decompiled) |

## Troubleshooting

| Problem | Fix |
|---|---|
| App shows "Unable to reach the server" | API running? Emulator must use `10.0.2.2`, not `localhost`. Phone: use the PC's LAN IP and allow it in the debug network security config. |
| `INSTALL_FAILED_INSUFFICIENT_STORAGE` | The emulator is full — use another AVD or wipe it in Device Manager. |
| Code not received by SMS | API log shows `SMS Gateway Hub rejected message … <ErrorCode>`: check API key, sender id, DLT template/entity ids, route, and that the template text in `SMS:OTPTemplate` matches the DLT-approved text exactly. |
| "Too many requests" when testing | Per-IP / per-number limits. Wait, or raise `RateLimiting:*` in `appsettings.Development.json`. |
| Signed out after restarting the API | Set the user-secrets above (otherwise keys are regenerated each start). |
| Windows desktop build: "requires symlink support" | Enable Windows Developer Mode (only needed for `-d windows`). |
| LocalDB not running | `SqlLocalDB start MSSQLLocalDB` |
| PIN code not found / service down | Choose State, District and Taluk manually; the form never blocks on the PIN service. |

## Documentation
`Docs/Architecture.md` · `Docs/DatabaseDesign.md` · `Docs/ApiSpecification.md` · `Docs/RegistrationFlow.md` ·
`Docs/ProfileModules.md` · `Docs/Security.md` · `Docs/Deployment.md` · `Docs/MasterData.md` · `Docs/ui/screenshots/`
