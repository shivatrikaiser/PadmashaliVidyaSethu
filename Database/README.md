# Database

SQL Server / Azure SQL. The schema is owned by **EF Core migrations** in
`Backend/PadmashaliVidyaSetu.Api/Migrations`; the files here are generated from them or are
operational scripts.

| Path | Purpose |
|------|---------|
| `schema/PadmashaliVidyaSetu_Schema_And_Seed.sql` | Idempotent script of all migrations, including master-data seed. Safe to run repeatedly. Regenerate after every new migration (command below). |
| `deploy/PVS_Deploy_SharedDatabase.sql` | **Production deployment into a database shared with another application (IQExplore Live).** Single file: pre-flight checks, one transaction, post-flight check that no non-PVS object changed. Safe to re-run. Must be updated whenever a new migration is added. Run in SSMS / Azure Data Studio / sqlcmd (not the Azure Portal query editor). |
| `deploy/PVS_Update_2026-10-20.sql` | Update for IQExplore Live from migration `AppBranding` to `AppVersions` (sponsor organisation/address, app versions table + its API permissions). Same safety checks as the full deploy script; refuses to run on any other starting state. |
| `deploy/PVS_Update_Live_2026-10-22.sql` | Update for IQExplore Live from `AdminPasswords` to `AndroidPackageName`: member's own mobile number, push-notification history (+ API permissions), Play Store link for `com.vidyasethu.pvs`. |
| `deploy/PVS_Update_Live_2026-10-23.sql` | Update for IQExplore Live from `AndroidPackageName` to `MemberEmail`: addresses outside India (`PVS_MemberAddresses` Taluk/District/PIN nullable, PIN code → postal code `varchar(10)`, country-aware check constraint) and a member's optional, separately verified email (`PVS_Members.Email` / `EmailVerifiedDate`; email codes in `PVS_PhoneVerificationChallenges`, whose `MobileNumber` becomes nullable). Run after `PVS_Update_Live_2026-10-22.sql`. |
| `deploy/PVS_Update_Live_2026-10-23_Part2.sql` | Update for IQExplore Live from `MemberEmail` to `FooterSponsors`: `PVS_Accounts.DeletedDate` ("Delete my account": data kept, number blocked), new table `PVS_FooterSponsors` (+ API permissions; current sponsor copied in) and `PVS_AppBranding.PoweredByUrl` (IQ Explore on Google Play). Run after `PVS_Update_Live_2026-10-23.sql`. |
| `deploy/PVS_Update_2026-10-20_AdminPasswords.sql` | Update for IQExplore Live from `AppVersions` to `AdminPasswords` (admin portal password columns on `PVS_Accounts`). |
| `deploy/PVS_CreateApiUser.sql` | Creates the database user `PVS_Api` for the API's connection string, with access to `PVS_` tables only. Run after `PVS_Deploy_SharedDatabase.sql`; re-run after deployments that add tables. |
| `seed/01_AddTemples.TEMPLATE.sql` | Add further temples (codes 06+). |
| `seed/03_GrantAdminRole.TEMPLATE.sql` | Give a mobile number ADMIN / SUPER_ADMIN access to the web admin portal. |
| `seed/04_ReleaseAppVersion.TEMPLATE.sql` | After a new app build is live in the store: set the latest app version (older apps ask members to update). |
| `seed/05_SetSuperAdminPassword.TEMPLATE.sql` | First admin portal password for a Super Admin (creates the Super Admin if a number is given and none exists). Hash made locally with `dotnet run --no-launch-profile -- hash-password`. |
| `scripts/Useful_Queries.sql` | Read-only reporting / review queries. |
| `vidyasethu/VS_Platform_Schema.sql` | **Planned, not in use.** `VS_` tables (VS_Organization, VS_OrganizationHighlight, VS_Enquiry) for a future, *separate* VidyaSethu platform database. Not part of the PVS schema; do not run in the PVS / shared database. |

Regenerate the schema script:

```bash
cd Backend/PadmashaliVidyaSetu.Api
dotnet ef migrations script --idempotent -o ../../Database/schema/PadmashaliVidyaSetu_Schema_And_Seed.sql
```

Table design, constraints and master-data rules: see `Docs/DatabaseDesign.md` and `Docs/MasterData.md`.
