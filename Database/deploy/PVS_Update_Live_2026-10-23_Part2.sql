/*
================================================================================================================
  Padmashali Vidya Setu (PVS) - UPDATE for IQExplore Live, 23 Oct 2026 (part 2)
  Brings Live from migration 20261023110803_MemberEmail (applied on Live 23 Oct 2026 by PVS_Update_Live_2026-10-23.sql)
  to 20261023123334_FooterSponsors. Tested on IQExploreDB_dev_02.
================================================================================================================
  WHAT IT CHANGES (PVS objects only - nothing outside PVS_ objects is created, altered or written)
    1. 20261023114125_AccountDeletion - "Delete my account" in the app (Google Play requirement):
         PVS_Accounts  + DeletedDate datetime2(3) NULL. Deleting keeps all data (account marked deleted, members
         inactive); the number can no longer sign in or register again. Existing accounts are unchanged.
    2. 20261023123334_FooterSponsors - footer sponsors and the "Technology Powered by" link:
         new table PVS_FooterSponsors (name, designation, company, display order, active) + its permissions for the
         API role PVS_AppRole; the current sponsor (name + organisation) is copied in as the first entry.
         PVS_AppBranding + PoweredByUrl nvarchar(500) NULL, set to the IQ Explore app on Google Play.

  SAFETY
    * Stops before changing anything unless PVS is deployed here with 20261023110803_MemberEmail applied.
    * ONE transaction: on any error everything is rolled back.
    * Before committing: checks every change above is in place and that no non-PVS object changed.
    * Safe to run again: steps already applied are skipped.

  HOW TO RUN  (login with ALTER/CREATE TABLE permission in dbo, e.g. the server admin)
    * SSMS / Azure Data Studio: connect to IQExploreDB_Live (check the database drop-down!) and execute.
    * NOT the Azure Portal query editor - it does not support GO batch separators.
    Expected result: "PVS deployment SUCCEEDED: 49 PVS tables; migrations: ..." at the end of the messages.
    Then publish the new API, admin portal and app.
================================================================================================================
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
SET NOEXEC OFF;
GO

-------------------------------------------------------------------------------- 1. Pre-flight checks
PRINT N'PVS deployment - server ' + @@SERVERNAME + N', database ' + DB_NAME() + N', user ' + SUSER_SNAME();

IF DB_NAME() IN (N'master', N'model', N'msdb', N'tempdb')
BEGIN
    DECLARE @database sysname = DB_NAME();
    RAISERROR(N'PVS deployment STOPPED: connected to the system database %s. Connect to the target database.', 16, 1, @database);
    SET NOEXEC ON;
END;
GO

IF SCHEMA_NAME() <> N'dbo'
BEGIN
    DECLARE @schema sysname = SCHEMA_NAME();
    RAISERROR(N'PVS deployment STOPPED: your default schema is %s; PVS objects must be created in dbo. Use a login whose default schema is dbo.', 16, 1, @schema);
    SET NOEXEC ON;
END;
GO

-- This update needs PVS deployed up to 20261023110803_MemberEmail; otherwise use PVS_Deploy_SharedDatabase.sql.
IF OBJECT_ID(N'dbo.PVS_EFMigrationsHistory', N'U') IS NULL
BEGIN
    RAISERROR(N'PVS deployment STOPPED: PVS is not deployed in this database. Use Database/deploy/PVS_Deploy_SharedDatabase.sql instead. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END
ELSE IF NOT EXISTS (SELECT 1 FROM dbo.PVS_EFMigrationsHistory WHERE MigrationId = N'20261023110803_MemberEmail')
BEGIN
    RAISERROR(N'PVS deployment STOPPED: migration 20261023110803_MemberEmail is not applied here. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
GO

IF OBJECT_ID(N'dbo.PVS_EFMigrationsHistory', N'U') IS NULL
BEGIN
    -- First deployment: there must be no PVS_ object at all (in any schema), so nothing can clash.
    IF EXISTS (SELECT 1 FROM sys.objects WHERE is_ms_shipped = 0 AND name LIKE N'PVS[_]%')
    BEGIN
        SELECT SCHEMA_NAME(schema_id) AS SchemaName, name AS ExistingObject, type_desc AS ObjectType
        FROM sys.objects WHERE is_ms_shipped = 0 AND name LIKE N'PVS[_]%' ORDER BY name;
        RAISERROR(N'PVS deployment STOPPED: objects named PVS_* already exist (see results) but PVS was never deployed here. Nothing was changed.', 16, 1);
        SET NOEXEC ON;
    END
    ELSE
        PRINT N'Mode: first deployment.';
END
ELSE
BEGIN
    DECLARE @applied nvarchar(max) = (SELECT STRING_AGG(MigrationId, N', ') FROM dbo.PVS_EFMigrationsHistory);
    PRINT N'Mode: upgrade - already applied: ' + ISNULL(@applied, N'(none)');
END;
GO

-- Fingerprint of every non-PVS object, compared again before COMMIT.
IF OBJECT_ID(N'tempdb..#PvsOtherObjects') IS NOT NULL DROP TABLE #PvsOtherObjects;
SELECT COUNT(*) AS ObjectCount,
       CHECKSUM_AGG(CHECKSUM(o.object_id, o.name, o.type, o.modify_date)) AS Signature,
       (SELECT COUNT(*) FROM sys.indexes i JOIN sys.objects t ON t.object_id = i.object_id
        WHERE t.is_ms_shipped = 0 AND t.name NOT LIKE N'PVS[_]%') AS IndexCount
INTO #PvsOtherObjects
FROM sys.objects o
WHERE o.is_ms_shipped = 0 AND o.name NOT LIKE N'PVS[_]%';
GO

BEGIN TRANSACTION;
GO

-------------------------------------------------------------------------------- 2. Changes since 20261023110803_MemberEmail
IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023114125_AccountDeletion'
)
BEGIN
    ALTER TABLE [PVS_Accounts] ADD [DeletedDate] datetime2(3) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023114125_AccountDeletion'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261023114125_AccountDeletion', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023123334_FooterSponsors'
)
BEGIN
    ALTER TABLE [PVS_AppBranding] ADD [PoweredByUrl] nvarchar(500) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023123334_FooterSponsors'
)
BEGIN
    CREATE TABLE [PVS_FooterSponsors] (
        [FooterSponsorId] int NOT NULL IDENTITY,
        [Name] nvarchar(150) NOT NULL,
        [Designation] nvarchar(150) NULL,
        [CompanyName] nvarchar(150) NULL,
        [DisplayOrder] int NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_FooterSponsors_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_FooterSponsors_IsActive] DEFAULT CAST(1 AS bit),
        CONSTRAINT [PVS_PK_FooterSponsors] PRIMARY KEY ([FooterSponsorId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023123334_FooterSponsors'
)
BEGIN
    EXEC(N'UPDATE [PVS_AppBranding] SET [PoweredByUrl] = N''https://play.google.com/store/apps/details?id=com.iqexplore.app''
    WHERE [AppBrandingId] = 1;
    SELECT @@ROWCOUNT');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023123334_FooterSponsors'
)
BEGIN
    CREATE INDEX [PVS_IX_FooterSponsors_IsActive_DisplayOrder] ON [PVS_FooterSponsors] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023123334_FooterSponsors'
)
BEGIN
    INSERT INTO [PVS_FooterSponsors] ([Name], [CompanyName], [DisplayOrder], [CreatedBy]) SELECT [SponsorName], [SponsorOrganisation], 0, N'migration' FROM [PVS_AppBranding] WHERE [AppBrandingId] = 1 AND NULLIF(LTRIM(RTRIM([SponsorName])), N'') IS NOT NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023123334_FooterSponsors'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261023123334_FooterSponsors', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
-- Let the API (role PVS_AppRole, see PVS_CreateApiUser.sql) use the new table.
IF DATABASE_PRINCIPAL_ID(N'PVS_AppRole') IS NOT NULL
    GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[PVS_FooterSponsors] TO [PVS_AppRole];
ELSE
    PRINT N'Note: role PVS_AppRole not found - run PVS_CreateApiUser.sql after this script.';
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF COL_LENGTH(N'dbo.PVS_Accounts', N'DeletedDate') IS NULL
   OR OBJECT_ID(N'dbo.PVS_FooterSponsors', N'U') IS NULL
   OR COL_LENGTH(N'dbo.PVS_AppBranding', N'PoweredByUrl') IS NULL
   OR NOT EXISTS (SELECT 1 FROM dbo.PVS_EFMigrationsHistory WHERE MigrationId = N'20261023114125_AccountDeletion')
   OR NOT EXISTS (SELECT 1 FROM dbo.PVS_EFMigrationsHistory WHERE MigrationId = N'20261023123334_FooterSponsors')
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR(N'PVS deployment ROLLED BACK: not every change is in place. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
GO

-------------------------------------------------------------------------------- 3. Post-flight checks, then COMMIT
IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
DECLARE @expected TABLE (TableName sysname PRIMARY KEY);
INSERT INTO @expected (TableName) VALUES
    (N'PVS_AcademicAchievements'),
    (N'PVS_AccountRoles'),
    (N'PVS_Accounts'),
    (N'PVS_AchievementTypes'),
    (N'PVS_AppBranding'),
    (N'PVS_AppVersions'),
    (N'PVS_AuditLogs'),
    (N'PVS_Boards'),
    (N'PVS_Branches'),
    (N'PVS_CareerOptions'),
    (N'PVS_Cities'),
    (N'PVS_Classes'),
    (N'PVS_CommunicationChannels'),
    (N'PVS_CommunicationTopics'),
    (N'PVS_CompetitiveExams'),
    (N'PVS_ConsentRecords'),
    (N'PVS_Countries'),
    (N'PVS_Courses'),
    (N'PVS_DisabilityTypes'),
    (N'PVS_Districts'),
    (N'PVS_EFMigrationsHistory'),
    (N'PVS_EducationLevels'),
    (N'PVS_Genders'),
    (N'PVS_FooterSponsors'),
    (N'PVS_Hobbies'),
    (N'PVS_InterestAreas'),
    (N'PVS_MemberAddresses'),
    (N'PVS_MemberCareerAspirations'),
    (N'PVS_MemberCompetitiveExams'),
    (N'PVS_MemberDisabilities'),
    (N'PVS_MemberEducation'),
    (N'PVS_MemberHobbies'),
    (N'PVS_MemberInterestAreas'),
    (N'PVS_MemberSkills'),
    (N'PVS_MemberSports'),
    (N'PVS_MemberStatuses'),
    (N'PVS_Members'),
    (N'PVS_Organisations'),
    (N'PVS_PhoneVerificationChallenges'),
    (N'PVS_PushNotifications'),
    (N'PVS_RefreshTokens'),
    (N'PVS_Roles'),
    (N'PVS_Skills'),
    (N'PVS_Sports'),
    (N'PVS_States'),
    (N'PVS_Taluks'),
    (N'PVS_TempleRegistrationSequences'),
    (N'PVS_Temples'),
    (N'PVS_Universities');

DECLARE @missing nvarchar(max) =
    (SELECT STRING_AGG(e.TableName, N', ') FROM @expected e WHERE OBJECT_ID(N'dbo.' + e.TableName, N'U') IS NULL);

DECLARE @othersChanged bit = CASE WHEN EXISTS (
    SELECT 1 FROM #PvsOtherObjects b
    CROSS APPLY (
        SELECT COUNT(*) AS ObjectCount,
               CHECKSUM_AGG(CHECKSUM(o.object_id, o.name, o.type, o.modify_date)) AS Signature,
               (SELECT COUNT(*) FROM sys.indexes i JOIN sys.objects t ON t.object_id = i.object_id
                WHERE t.is_ms_shipped = 0 AND t.name NOT LIKE N'PVS[_]%') AS IndexCount
        FROM sys.objects o WHERE o.is_ms_shipped = 0 AND o.name NOT LIKE N'PVS[_]%') a
    WHERE a.ObjectCount <> b.ObjectCount OR ISNULL(a.Signature, 0) <> ISNULL(b.Signature, 0) OR a.IndexCount <> b.IndexCount)
    THEN 1 ELSE 0 END;

IF @missing IS NOT NULL OR @othersChanged = 1
BEGIN
    ROLLBACK TRANSACTION;
    IF @missing IS NOT NULL
        RAISERROR(N'PVS deployment ROLLED BACK: missing tables %s. Nothing was changed.', 16, 1, @missing);
    ELSE
        RAISERROR(N'PVS deployment ROLLED BACK: a non-PVS object changed during deployment. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    DECLARE @tables int = (SELECT COUNT(*) FROM sys.tables WHERE name LIKE N'PVS[_]%');
    DECLARE @migrations nvarchar(max) = (SELECT STRING_AGG(MigrationId, N', ') FROM dbo.PVS_EFMigrationsHistory);
    PRINT N'PVS deployment SUCCEEDED: ' + CAST(@tables AS nvarchar(10)) + N' PVS tables; migrations: ' + @migrations
        + N'. No other objects were changed.';
END;
GO

-------------------------------------------------------------------------------- 4. Clean-up (always runs)
SET NOEXEC OFF;
GO
IF @@TRANCOUNT > 0
BEGIN
    ROLLBACK TRANSACTION;
    PRINT N'PVS deployment ROLLED BACK: the script did not finish cleanly. Nothing was changed.';
END;
IF OBJECT_ID(N'tempdb..#PvsOtherObjects') IS NOT NULL DROP TABLE #PvsOtherObjects;
GO