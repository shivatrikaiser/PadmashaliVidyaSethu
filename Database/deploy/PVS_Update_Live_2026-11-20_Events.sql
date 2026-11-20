/*
================================================================================================================
  Padmashali Vidya Setu (PVS) - UPDATE for IQExplore Live, 20 Nov 2026 - EVENT REGISTRATIONS
  Brings Live from migration 20261023123334_FooterSponsors (applied 23 Oct 2026 by PVS_Update_Live_2026-10-23_Part2.sql)
  to 20261120090151_EventRegistrations. Tested on IQExploreDB_dev_02.
================================================================================================================
  WHAT IT CHANGES (PVS objects only - nothing outside PVS_ objects is created, altered or written)
    20261120090151_EventRegistrations - events members register for in the app (sports, drawing, quiz, ...):
      new table PVS_Events                   event (code, title, description, venue, event date, "age as on" date,
                                             registration open / close dates, groups per member, published)
      new table PVS_EventGroups              its age groups (min / max age, optional gender, optional places)
      new table PVS_EventRegistrations       one per member and event, with the event registration number
                                             (e.g. SPORTS26-0001)
      new table PVS_EventRegistrationGroups  the groups each registration chose
    + permissions on the 4 new tables for the API role PVS_AppRole. Existing tables and data are not changed.

  SAFETY
    * Stops before changing anything unless PVS is deployed here with 20261023123334_FooterSponsors applied.
    * ONE transaction: on any error everything is rolled back.
    * Before committing: checks every change above is in place and that no non-PVS object changed.
    * Safe to run again: steps already applied are skipped.

  HOW TO RUN  (login with CREATE TABLE permission in dbo, e.g. the server admin)
    * SSMS / Azure Data Studio: connect to IQExploreDB_Live (check the database drop-down!) and execute.
    * NOT the Azure Portal query editor - it does not support GO batch separators.
    Expected result: "PVS deployment SUCCEEDED: 53 PVS tables; migrations: ..." at the end of the messages.
    Then publish the new API, then the admin portal and the app.
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

-- This update needs PVS deployed up to 20261023123334_FooterSponsors; otherwise use PVS_Deploy_SharedDatabase.sql.
IF OBJECT_ID(N'dbo.PVS_EFMigrationsHistory', N'U') IS NULL
BEGIN
    RAISERROR(N'PVS deployment STOPPED: PVS is not deployed in this database. Use Database/deploy/PVS_Deploy_SharedDatabase.sql instead. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END
ELSE IF NOT EXISTS (SELECT 1 FROM dbo.PVS_EFMigrationsHistory WHERE MigrationId = N'20261023123334_FooterSponsors')
BEGIN
    RAISERROR(N'PVS deployment STOPPED: migration 20261023123334_FooterSponsors is not applied here. Nothing was changed.', 16, 1);
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

-------------------------------------------------------------------------------- 2. Changes since 20261023123334_FooterSponsors
IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE TABLE [PVS_Events] (
        [EventId] int NOT NULL IDENTITY,
        [Code] varchar(12) NOT NULL,
        [Title] nvarchar(150) NOT NULL,
        [Description] nvarchar(2000) NULL,
        [Venue] nvarchar(300) NULL,
        [EventDate] date NOT NULL,
        [AgeAsOnDate] date NOT NULL,
        [RegistrationOpensDate] date NOT NULL,
        [RegistrationClosesDate] date NOT NULL,
        [MaxGroupsPerMember] int NOT NULL,
        [IsPublished] bit NOT NULL,
        [LastRegistrationNumber] int NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Events_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Events_IsActive] DEFAULT CAST(1 AS bit),
        CONSTRAINT [PVS_PK_Events] PRIMARY KEY ([EventId]),
        CONSTRAINT [PVS_CK_Events_Code] CHECK (LEN([Code]) >= 2 AND [Code] NOT LIKE '%[^A-Z0-9]%'),
        CONSTRAINT [PVS_CK_Events_LastRegistrationNumber] CHECK ([LastRegistrationNumber] BETWEEN 0 AND 9999),
        CONSTRAINT [PVS_CK_Events_MaxGroupsPerMember] CHECK ([MaxGroupsPerMember] BETWEEN 1 AND 50),
        CONSTRAINT [PVS_CK_Events_RegistrationDates] CHECK ([RegistrationOpensDate] <= [RegistrationClosesDate])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE TABLE [PVS_EventGroups] (
        [EventGroupId] int NOT NULL IDENTITY,
        [EventId] int NOT NULL,
        [Name] nvarchar(100) NOT NULL,
        [MinAge] int NOT NULL,
        [MaxAge] int NOT NULL,
        [GenderId] int NULL,
        [Capacity] int NULL,
        [DisplayOrder] int NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_EventGroups_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_EventGroups_IsActive] DEFAULT CAST(1 AS bit),
        CONSTRAINT [PVS_PK_EventGroups] PRIMARY KEY ([EventGroupId]),
        CONSTRAINT [PVS_CK_EventGroups_Ages] CHECK ([MinAge] >= 0 AND [MaxAge] <= 120 AND [MinAge] <= [MaxAge]),
        CONSTRAINT [PVS_CK_EventGroups_Capacity] CHECK ([Capacity] IS NULL OR [Capacity] >= 1),
        CONSTRAINT [PVS_FK_EventGroups_Events_EventId] FOREIGN KEY ([EventId]) REFERENCES [PVS_Events] ([EventId]) ON DELETE CASCADE,
        CONSTRAINT [PVS_FK_EventGroups_Genders_GenderId] FOREIGN KEY ([GenderId]) REFERENCES [PVS_Genders] ([GenderId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE TABLE [PVS_EventRegistrations] (
        [EventRegistrationId] int NOT NULL IDENTITY,
        [EventId] int NOT NULL,
        [RegistrationId] char(11) NOT NULL,
        [RegistrationNumber] varchar(17) NOT NULL,
        [AgeOnAgeAsOnDate] int NOT NULL,
        [RegisteredDate] datetime2(3) NOT NULL,
        [CancelledDate] datetime2(3) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_EventRegistrations_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_EventRegistrations_IsActive] DEFAULT CAST(1 AS bit),
        CONSTRAINT [PVS_PK_EventRegistrations] PRIMARY KEY ([EventRegistrationId]),
        CONSTRAINT [PVS_FK_EventRegistrations_Events_EventId] FOREIGN KEY ([EventId]) REFERENCES [PVS_Events] ([EventId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_EventRegistrations_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE TABLE [PVS_EventRegistrationGroups] (
        [EventRegistrationId] int NOT NULL,
        [EventGroupId] int NOT NULL,
        CONSTRAINT [PVS_PK_EventRegistrationGroups] PRIMARY KEY ([EventRegistrationId], [EventGroupId]),
        CONSTRAINT [PVS_FK_EventRegistrationGroups_EventGroups_EventGroupId] FOREIGN KEY ([EventGroupId]) REFERENCES [PVS_EventGroups] ([EventGroupId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_EventRegistrationGroups_EventRegistrations_EventRegistrationId] FOREIGN KEY ([EventRegistrationId]) REFERENCES [PVS_EventRegistrations] ([EventRegistrationId]) ON DELETE CASCADE
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE INDEX [PVS_IX_EventGroups_EventId_DisplayOrder] ON [PVS_EventGroups] ([EventId], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE INDEX [PVS_IX_EventGroups_GenderId] ON [PVS_EventGroups] ([GenderId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE INDEX [PVS_IX_EventRegistrationGroups_EventGroupId] ON [PVS_EventRegistrationGroups] ([EventGroupId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_EventRegistrations_EventId_RegistrationId] ON [PVS_EventRegistrations] ([EventId], [RegistrationId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE INDEX [PVS_IX_EventRegistrations_RegistrationId] ON [PVS_EventRegistrations] ([RegistrationId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_EventRegistrations_RegistrationNumber] ON [PVS_EventRegistrations] ([RegistrationNumber]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Events_Code] ON [PVS_Events] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    CREATE INDEX [PVS_IX_Events_IsActive_IsPublished_RegistrationClosesDate] ON [PVS_Events] ([IsActive], [IsPublished], [RegistrationClosesDate]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261120090151_EventRegistrations'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261120090151_EventRegistrations', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
-- Let the API (role PVS_AppRole, see PVS_CreateApiUser.sql) use the new tables.
IF DATABASE_PRINCIPAL_ID(N'PVS_AppRole') IS NOT NULL
BEGIN
    GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[PVS_EventGroups] TO [PVS_AppRole];
    GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[PVS_EventRegistrationGroups] TO [PVS_AppRole];
    GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[PVS_EventRegistrations] TO [PVS_AppRole];
    GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[PVS_Events] TO [PVS_AppRole];
END
ELSE
    PRINT N'Note: role PVS_AppRole not found - run PVS_CreateApiUser.sql after this script.';
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF OBJECT_ID(N'dbo.PVS_Events', N'U') IS NULL
   OR OBJECT_ID(N'dbo.PVS_EventGroups', N'U') IS NULL
   OR OBJECT_ID(N'dbo.PVS_EventRegistrations', N'U') IS NULL
   OR OBJECT_ID(N'dbo.PVS_EventRegistrationGroups', N'U') IS NULL
   OR NOT EXISTS (SELECT 1 FROM dbo.PVS_EFMigrationsHistory WHERE MigrationId = N'20261120090151_EventRegistrations')
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
    (N'PVS_EventGroups'),
    (N'PVS_EventRegistrationGroups'),
    (N'PVS_EventRegistrations'),
    (N'PVS_Events'),
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