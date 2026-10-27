# Deployment

Hosting has not been chosen yet. This is the recommended path on Azure (any SQL Server + .NET host works).

## Backend
1. **Database** — Azure SQL (S0+). Apply `Database/schema/PadmashaliVidyaSetu_Schema_And_Seed.sql`
   (idempotent) with a deployment identity, or run `dotnet ef database update` from CI.
   Keep `Database:ApplyMigrationsOnStartup=false` outside Development.
2. **API** — Azure App Service (Linux, .NET 10) or a container:
   `dotnet publish Backend/PadmashaliVidyaSetu.Api -c Release -o publish`.
3. **Settings** (App Service configuration / Key Vault references — never in files):

   | Setting | Notes |
   |---|---|
   | `ASPNETCORE_ENVIRONMENT` | `Staging` / `Production` |
   | `ConnectionStrings__DefaultConnection` | Prefer Managed Identity (`Authentication=Active Directory Default`) |
   | `Jwt__SigningKey` | ≥ 32 random bytes |
   | `PhoneVerification__CodeHashingKey` | ≥ 32 random bytes, different from the JWT key |
   | `SMS__APIKey` | SMS Gateway Hub API key (other `SMS` settings are in appsettings.json) |
   | `PhoneVerification__Sender` | `SmsGatewayHub` (default in appsettings.json) - Indian (+91) numbers |
   | `WhatsApp__AccessToken` | WhatsApp Cloud API access token (permanent System User token); other `WhatsApp` settings (phone number id, template `iqe_validate`) are in appsettings.json |
   | `PhoneVerification__InternationalSender` | `WhatsApp` (default in appsettings.json) - numbers outside India |
   | `Email__Host`, `Email__UserName`, `Email__FromAddress` | SMTP server for email verification codes (a member's optional email address); `Email__Port` 587 / `Email__Security` StartTls by default |
   | `Email__Password` | SMTP password (secret) |
   | `PhoneVerification__EmailSender` | `Smtp` (default in appsettings.json) |
   | `PhoneVerification__TestLogin__MobileNumber` / `__Code` | Store-review sign-in (Google Play): `917795276699` / `9876` in appsettings.json. That number signs in with the fixed code and is never sent anything; "Delete account" closes its members but does not block it. Set the number empty to switch it off |
   | `Cors__AllowedOrigins__0` | `https://pvs-admin.vidyasethu.co.in` (admin portal) |
   | `Cors__AllowedOrigins__1` | `https://pvs.vidyasethu.co.in` (member web app) |
   | `Cors__AllowedOrigins__N` (next free number; `__3` in production) | `https://vidyasethu.co.in` (website: enquiry forms) |
   | `Enquiries__Recipient` | Optional - who receives website enquiries (default `support@iqexplore.com`); sent through the `Email` SMTP settings |
   | `Swagger__Enabled` | `true` only while testing - serves `/swagger`, `/openapi/v1.json` and the SMS / WhatsApp / email tests (`POST /api/v1/diagnostics/sms-test`, `.../whatsapp-test`, `.../email-test`); remove afterwards |

4. HTTPS only; HSTS is enabled automatically outside Development. If behind a proxy/Front Door, configure
   forwarded headers so rate limiting sees client IPs.
5. Monitoring: send Serilog to Application Insights / Log Analytics; alert on 5xx and on
   `Auth.RefreshTokenReuseDetected`.

## Mobile app
```bash
cd Frontend/padmashali_vidya_setu
flutter build appbundle --release --dart-define-from-file=config/production.json
```
* Set the real API URL in `config/production.json`.
* Create an upload keystore (kept outside the repo) and `android/key.properties`; configure release signing in
  `android/app/build.gradle.kts` (currently uses the debug key — **must change before Play Store**).
* Confirm the application id (`com.vidyasethu.pvs`) and app icon before first release —
  they cannot change after publishing.

## Environments
`Deployment/{development,staging,production}` hold environment notes. Configuration files:
`appsettings.{Environment}.json` (non-secret only) and Flutter `config/{env}.json`.

## Addresses

| Address | What |
|---|---|
| `https://pvs.vidyasethu.co.in` | PVS member app, Flutter web build - see "Member web app" below |
| `https://pvs-admin.vidyasethu.co.in` | Admin portal (`Frontend/AdminWeb`) - see `Frontend/AdminWeb/README.md` "Deployment" |
| `https://vidyasethu.co.in` | VidyaSethu website; `/pvs` redirects to the member app |
| `https://api.pvs.vidyasethu.co.in` | PVS API (custom domain on the API App Service: CNAME `api.pvs` + TXT `asuid.api.pvs`) |

## Admin portal
Azure App Service Web App (one zip, Windows or Linux) built with `npm run build` in `Frontend/AdminWeb`. Its
production build calls `https://api.pvs.vidyasethu.co.in`, and the API must list `https://pvs-admin.vidyasethu.co.in` in
`Cors__AllowedOrigins__0`.

## VidyaSethu public website
Deployed separately as an Azure App Service Web App (one zip, Windows or Linux; static files, no database) - see
`Frontend/VidyaSethuWeb/README.md`. Its "Open Padmashali Vidya Sethu" destination
(`organizationLinks.pvs.application` in `src/environments/environment.ts`) is the member app
`https://pvs.vidyasethu.co.in/`, not the admin portal.

## Member web app
`https://pvs.vidyasethu.co.in`, its own Azure App Service Web App (Windows, IIS), published by FTP.

1. **Build** (base href `/`):
   ```powershell
   cd Frontend\padmashali_vidya_setu
   flutter build web --release --no-web-resources-cdn --dart-define-from-file=config/production.json
   ```
   Output: `build\web`. It includes `web\web.config` (IIS): app files as they are, every other address served
   `index.html` (Flutter routes), CSP (WebAssembly, the API, Google's font CDN), security headers, caching.
2. **Web App** (once): Publish **Code**, OS **Windows**, any stack (static files only), plan **Basic B1** or higher
   (custom domain with HTTPS). Configuration: HTTPS Only **On**, minimum TLS 1.2, FTP state **FTPS only**; do not set
   `WEBSITE_RUN_FROM_PACKAGE` (it makes `wwwroot` read-only, so FTP uploads are ignored).
3. **Upload** (FTP credentials: Web App → Deployment Center → FTPS credentials): the **contents** of `build\web`
   (subfolders included) to `/site/wwwroot`, overwriting. `/site/wwwroot/index.html` and `/site/wwwroot/web.config`
   must sit side by side.
4. **Custom domain** (Web App → Custom domains → Add, *App Service Managed Certificate*), at the DNS provider:
   **CNAME** `pvs` → `<web-app>.azurewebsites.net`, **TXT** `asuid.pvs` → the verification ID shown in the dialog.
   Remove `pvs.vidyasethu.co.in` from the admin portal's Web App first (it moved to `pvs-admin.vidyasethu.co.in`).
5. **API:** `Cors__AllowedOrigins__1` = `https://pvs.vidyasethu.co.in` (see the settings table above).
6. **Check:** `https://pvs.vidyasethu.co.in/` loads the app, a refresh on a screen (e.g. `/register`) still works,
   `https://vidyasethu.co.in/pvs` redirects there, and sign-in reaches the API.
