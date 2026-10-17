/*
================================================================================================================
  Padmashali Vidya Setu (PVS) - database user for the PVS API in a SHARED database (e.g. IQExplore Live)
================================================================================================================
  WHAT IT DOES
    * Creates a contained database user PVS_Api (login + password live in this database only) and a role PVS_AppRole.
    * Gives the role read/write on the PVS_ tables only. PVS_Api gets NO access to IQ Explore tables, cannot
      create or change tables, and cannot read other databases.
    * Safe to run again. Re-run it after each PVS deployment that adds tables, so new tables are granted too.

  BEFORE RUNNING
    1. Run PVS_Deploy_SharedDatabase.sql first (the PVS_ tables must exist).
    2. Replace <STRONG-PASSWORD> below with a long random password (16+ chars, upper/lower case, digits, symbol).
       Keep it out of Git; it goes only into the API's connection string on the server.
    3. Connect to the target DATABASE itself (not master) as the server admin, in SSMS / Azure Data Studio.

  API CONNECTION STRING AFTERWARDS
    Server=tcp:iqexploresql.database.windows.net,1433;Initial Catalog=<database>;User ID=PVS_Api;Password=<password>;
    Encrypt=True;TrustServerCertificate=False;MultipleActiveResultSets=False;Connection Timeout=30;
================================================================================================================
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Password nvarchar(128) = N'<STRONG-PASSWORD>';

IF @Password LIKE N'<%'
    THROW 50001, 'Replace <STRONG-PASSWORD> with a real password before running this script.', 1;
IF DB_NAME() IN (N'master', N'model', N'msdb', N'tempdb')
    THROW 50002, 'Connect to the target database (e.g. IQExploreDB_live), not a system database.', 1;
IF OBJECT_ID(N'dbo.PVS_EFMigrationsHistory', N'U') IS NULL
    THROW 50003, 'PVS is not deployed in this database. Run PVS_Deploy_SharedDatabase.sql first.', 1;

BEGIN TRANSACTION;

-- 1. User (contained: authenticates against this database only)
IF DATABASE_PRINCIPAL_ID(N'PVS_Api') IS NULL
BEGIN
    DECLARE @create nvarchar(max) = N'CREATE USER [PVS_Api] WITH PASSWORD = ' + QUOTENAME(@Password, '''') + N', DEFAULT_SCHEMA = [dbo];';
    EXEC (@create);
    PRINT N'Created user PVS_Api.';
END
ELSE
    PRINT N'User PVS_Api already exists (password unchanged).';

-- 2. Role with access to PVS_ tables only
IF DATABASE_PRINCIPAL_ID(N'PVS_AppRole') IS NULL
    CREATE ROLE [PVS_AppRole];
IF IS_ROLEMEMBER(N'PVS_AppRole', N'PVS_Api') = 0
    ALTER ROLE [PVS_AppRole] ADD MEMBER [PVS_Api];

-- 3. Grants: data tables read/write; the migrations history read-only (the API never changes the schema)
DECLARE @grants nvarchar(max) =
    (SELECT STRING_AGG(CAST(
        CASE WHEN t.name = N'PVS_EFMigrationsHistory'
             THEN N'GRANT SELECT ON ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + N' TO [PVS_AppRole];'
             ELSE N'GRANT SELECT, INSERT, UPDATE, DELETE ON ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + N' TO [PVS_AppRole];'
        END AS nvarchar(max)), NCHAR(10))
     FROM sys.tables t JOIN sys.schemas s ON s.schema_id = t.schema_id
     WHERE t.name LIKE N'PVS[_]%' AND s.name = N'dbo');
EXEC (@grants);

COMMIT;

-- 4. Result: every table PVS_AppRole can use (all must start with PVS_)
SELECT o.name AS TableName, STRING_AGG(p.permission_name, N', ') AS Permissions
FROM sys.database_permissions p
JOIN sys.objects o ON o.object_id = p.major_id
WHERE p.grantee_principal_id = DATABASE_PRINCIPAL_ID(N'PVS_AppRole') AND p.state = 'G'
GROUP BY o.name
ORDER BY o.name;

PRINT N'PVS_Api is ready. Use it in the API connection string (see the header of this script).';
