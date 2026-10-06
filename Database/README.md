# Database

SQL Server / Azure SQL. The schema is owned by **EF Core migrations** in
`Backend/PadmashaliVidyaSetu.Api/Migrations`; the files here are generated from them or are
operational scripts.

| Path | Purpose |
|------|---------|
| `schema/PadmashaliVidyaSetu_Schema_And_Seed.sql` | Idempotent script of all migrations, including master-data seed. Safe to run repeatedly. Regenerate after every new migration (command below). |
| `seed/01_AddTemples.TEMPLATE.sql` | Add further temples (codes 06+). |
| `scripts/Useful_Queries.sql` | Read-only reporting / review queries. |

Regenerate the schema script:

```bash
cd Backend/PadmashaliVidyaSetu.Api
dotnet ef migrations script --idempotent -o ../../Database/schema/PadmashaliVidyaSetu_Schema_And_Seed.sql
```

Table design, constraints and master-data rules: see `Docs/DatabaseDesign.md` and `Docs/MasterData.md`.
