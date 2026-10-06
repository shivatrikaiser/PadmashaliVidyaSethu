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
   | `PhoneVerification__Sender` | `SmsGatewayHub` (default in appsettings.json) |
   | `Cors__AllowedOrigins__0` | Only if a web client is deployed |

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
* Confirm the application id (`org.padmashalividyasetu.padmashali_vidya_setu`) and app icon before first release —
  they cannot change after publishing.

## Environments
`Deployment/{development,staging,production}` hold environment notes. Configuration files:
`appsettings.{Environment}.json` (non-secret only) and Flutter `config/{env}.json`.
