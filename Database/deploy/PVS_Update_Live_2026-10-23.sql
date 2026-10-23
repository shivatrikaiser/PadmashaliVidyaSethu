/*
================================================================================================================
  Padmashali Vidya Setu (PVS) - UPDATE for IQExplore Live, 23 Oct 2026
  Brings Live from migration 20261022051124_AndroidPackageName (run PVS_Update_Live_2026-10-22.sql first if Live is not there yet)
  to 20261023110803_MemberEmail. Tested on IQExploreDB_dev_02.
================================================================================================================
  WHAT IT CHANGES (PVS objects only - nothing outside PVS_ objects is created, altered or written)
    1. 20261023100540_AddressOutsideIndia - members can register an address outside India:
         PVS_MemberAddresses  TalukId    int NOT NULL     -> int NULL
                              DistrictId int NOT NULL     -> int NULL
                              PinCode    char(6) NOT NULL -> varchar(10) NULL (postal code abroad; index re-created)
         Check constraint PVS_CK_MemberAddresses_PinCode is replaced by PVS_CK_MemberAddresses_CountryRules:
           India (CountryId 1): 6-digit PIN code, District and Taluk still required - exactly as before.
           Other countries:     no District, Taluk or PIN-code place; postal code optional.
         Existing addresses (all in India) are unchanged and satisfy the new constraint.
    2. 20261023110803_MemberEmail - a member's optional email address, verified with its own code:
         PVS_Members                      + Email varchar(254) NULL, EmailVerifiedDate datetime2(3) NULL
         PVS_PhoneVerificationChallenges  + Email varchar(254) NULL (+ index Email, CreatedDate);
                                          MobileNumber NOT NULL -> NULL (an email code has no number);
                                          check constraint PVS_CK_PhoneVerificationChallenges_Target: exactly one
                                          of MobileNumber / Email. Existing codes all have a number - unchanged.
    No new tables, so the API permissions (PVS_AppRole) do not change.

  SAFETY
    * Stops before changing anything unless PVS is deployed here with 20261022051124_AndroidPackageName applied.
    * ONE transaction: on any error everything is rolled back.
    * Before committing: checks every change above is in place and that no non-PVS object changed.
    * Safe to run again: steps already applied are skipped.

  HOW TO RUN  (login with ALTER TABLE permission in dbo, e.g. the server admin)
    * SSMS / Azure Data Studio: connect to IQExploreDB_Live (check the database drop-down!) and execute.
    * NOT the Azure Portal query editor - it does not support GO batch separators.
    Expected result: "PVS deployment SUCCEEDED: 48 PVS tables; migrations: ..." at the end of the messages.
    Then publish the new API, admin portal and app (the API must be updated together with this script).
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

-- This update needs PVS deployed up to 20261022051124_AndroidPackageName; otherwise use PVS_Deploy_SharedDatabase.sql.
IF OBJECT_ID(N'dbo.PVS_EFMigrationsHistory', N'U') IS NULL
BEGIN
    RAISERROR(N'PVS deployment STOPPED: PVS is not deployed in this database. Use Database/deploy/PVS_Deploy_SharedDatabase.sql instead. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END
ELSE IF NOT EXISTS (SELECT 1 FROM dbo.PVS_EFMigrationsHistory WHERE MigrationId = N'20261022051124_AndroidPackageName')
BEGIN
    RAISERROR(N'PVS deployment STOPPED: migration 20261022051124_AndroidPackageName is not applied here. Nothing was changed.', 16, 1);
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

-------------------------------------------------------------------------------- 2. Changes since 20261022051124_AndroidPackageName
IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023100540_AddressOutsideIndia'
)
BEGIN
    ALTER TABLE [PVS_MemberAddresses] DROP CONSTRAINT [PVS_CK_MemberAddresses_PinCode];
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023100540_AddressOutsideIndia'
)
BEGIN
    DECLARE @var nvarchar(max);
    SELECT @var = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PVS_MemberAddresses]') AND [c].[name] = N'TalukId');
    IF @var IS NOT NULL EXEC(N'ALTER TABLE [PVS_MemberAddresses] DROP CONSTRAINT ' + @var + ';');
    ALTER TABLE [PVS_MemberAddresses] ALTER COLUMN [TalukId] int NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023100540_AddressOutsideIndia'
)
BEGIN
    DROP INDEX [PVS_IX_MemberAddresses_PinCode] ON [PVS_MemberAddresses];
    DECLARE @var1 nvarchar(max);
    SELECT @var1 = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PVS_MemberAddresses]') AND [c].[name] = N'PinCode');
    IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [PVS_MemberAddresses] DROP CONSTRAINT ' + @var1 + ';');
    ALTER TABLE [PVS_MemberAddresses] ALTER COLUMN [PinCode] varchar(10) NULL;
    CREATE INDEX [PVS_IX_MemberAddresses_PinCode] ON [PVS_MemberAddresses] ([PinCode]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023100540_AddressOutsideIndia'
)
BEGIN
    DECLARE @var2 nvarchar(max);
    SELECT @var2 = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PVS_MemberAddresses]') AND [c].[name] = N'DistrictId');
    IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [PVS_MemberAddresses] DROP CONSTRAINT ' + @var2 + ';');
    ALTER TABLE [PVS_MemberAddresses] ALTER COLUMN [DistrictId] int NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023100540_AddressOutsideIndia'
)
BEGIN
    EXEC(N'ALTER TABLE [PVS_MemberAddresses] ADD CONSTRAINT [PVS_CK_MemberAddresses_CountryRules] CHECK (([CountryId] = 1 AND [PinCode] LIKE ''[1-9][0-9][0-9][0-9][0-9][0-9]'' AND [DistrictId] IS NOT NULL AND [TalukId] IS NOT NULL) OR ([CountryId] <> 1 AND [DistrictId] IS NULL AND [TalukId] IS NULL AND [CityId] IS NULL))');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023100540_AddressOutsideIndia'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261023100540_AddressOutsideIndia', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023110803_MemberEmail'
)
BEGIN
    DECLARE @var3 nvarchar(max);
    SELECT @var3 = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[PVS_PhoneVerificationChallenges]') AND [c].[name] = N'MobileNumber');
    IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [PVS_PhoneVerificationChallenges] DROP CONSTRAINT ' + @var3 + ';');
    ALTER TABLE [PVS_PhoneVerificationChallenges] ALTER COLUMN [MobileNumber] varchar(16) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023110803_MemberEmail'
)
BEGIN
    ALTER TABLE [PVS_PhoneVerificationChallenges] ADD [Email] varchar(254) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023110803_MemberEmail'
)
BEGIN
    ALTER TABLE [PVS_Members] ADD [Email] varchar(254) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023110803_MemberEmail'
)
BEGIN
    ALTER TABLE [PVS_Members] ADD [EmailVerifiedDate] datetime2(3) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023110803_MemberEmail'
)
BEGIN
    CREATE INDEX [PVS_IX_PhoneVerificationChallenges_Email_CreatedDate] ON [PVS_PhoneVerificationChallenges] ([Email], [CreatedDate]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023110803_MemberEmail'
)
BEGIN
    EXEC(N'ALTER TABLE [PVS_PhoneVerificationChallenges] ADD CONSTRAINT [PVS_CK_PhoneVerificationChallenges_Target] CHECK (([MobileNumber] IS NOT NULL AND [Email] IS NULL) OR ([MobileNumber] IS NULL AND [Email] IS NOT NULL))');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261023110803_MemberEmail'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261023110803_MemberEmail', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF COLUMNPROPERTY(OBJECT_ID(N'dbo.PVS_MemberAddresses'), N'TalukId', 'AllowsNull') <> 1
   OR COLUMNPROPERTY(OBJECT_ID(N'dbo.PVS_MemberAddresses'), N'DistrictId', 'AllowsNull') <> 1
   OR COLUMNPROPERTY(OBJECT_ID(N'dbo.PVS_MemberAddresses'), N'PinCode', 'AllowsNull') <> 1
   OR COL_LENGTH(N'dbo.PVS_MemberAddresses', N'PinCode') <> 10
   OR OBJECT_ID(N'dbo.PVS_CK_MemberAddresses_CountryRules', N'C') IS NULL
   OR OBJECT_ID(N'dbo.PVS_CK_MemberAddresses_PinCode', N'C') IS NOT NULL
   OR NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.PVS_MemberAddresses') AND name = N'PVS_IX_MemberAddresses_PinCode')
   OR COL_LENGTH(N'dbo.PVS_Members', N'Email') IS NULL
   OR COL_LENGTH(N'dbo.PVS_Members', N'EmailVerifiedDate') IS NULL
   OR COL_LENGTH(N'dbo.PVS_PhoneVerificationChallenges', N'Email') IS NULL
   OR COLUMNPROPERTY(OBJECT_ID(N'dbo.PVS_PhoneVerificationChallenges'), N'MobileNumber', 'AllowsNull') <> 1
   OR OBJECT_ID(N'dbo.PVS_CK_PhoneVerificationChallenges_Target', N'C') IS NULL
   OR NOT EXISTS (SELECT 1 FROM dbo.PVS_EFMigrationsHistory WHERE MigrationId = N'20261023100540_AddressOutsideIndia')
   OR NOT EXISTS (SELECT 1 FROM dbo.PVS_EFMigrationsHistory WHERE MigrationId = N'20261023110803_MemberEmail')
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