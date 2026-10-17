# Database

SQL Server / Azure SQL. The schema is owned by **EF Core migrations** in
`Backend/PadmashaliVidyaSetu.Api/Migrations`; the files here are generated from them or are
operational scripts.

| Path | Purpose |
|------|---------|
| `schema/PadmashaliVidyaSetu_Schema_And_Seed.sql` | Idempotent script of all migrations, including master-data seed. Safe to run repeatedly. Regenerate after every new migration (command below). |
| `deploy/PVS_Deploy_SharedDatabase.sql` | **Production deployment into a database shared with another application (IQExplore Live).** Single file: pre-flight checks, one transaction, post-flight check that no non-PVS object changed. Safe to re-run. Must be updated whenever a new migration is added. Run in SSMS / Azure Data Studio / sqlcmd (not the Azure Portal query editor). |
| `deploy/PVS_CreateApiUser.sql` | Creates the database user `PVS_Api` for the API's connection string, with access to `PVS_` tables only. Run after `PVS_Deploy_SharedDatabase.sql`; re-run after deployments that add tables. |
| `seed/01_AddTemples.TEMPLATE.sql` | Add further temples (codes 06+). |
| `seed/03_GrantAdminRole.TEMPLATE.sql` | Give a mobile number ADMIN / SUPER_ADMIN access to the web admin portal. |
| `scripts/Useful_Queries.sql` | Read-only reporting / review queries. |
| `vidyasethu/VS_Platform_Schema.sql` | **Planned, not in use.** `VS_` tables (VS_Organization, VS_OrganizationHighlight, VS_Enquiry) for a future, *separate* VidyaSethu platform database. Not part of the PVS schema; do not run in the PVS / shared database. |

Regenerate the schema script:

```bash
cd Backend/PadmashaliVidyaSetu.Api
dotnet ef migrations script --idempotent -o ../../Database/schema/PadmashaliVidyaSetu_Schema_And_Seed.sql
```

Table design, constraints and master-data rules: see `Docs/DatabaseDesign.md` and `Docs/MasterData.md`.
