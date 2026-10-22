/*
================================================================================================================
  Padmashali Vidya Setu (PVS) - deployment into a SHARED database (e.g. IQExplore Live)
  Single self-contained deployment script. Must be updated whenever a new EF migration is added.
  Generated: 2026-10-22 10:41    Migrations: 20261006135106_InitialSchema, 20261009101316_OtherTextColumns, 20261009112325_MemberProfileListChoices, 20261010153650_AppBranding,
              20261020142456_SponsorOrganisationAddress, 20261020153210_AppVersions, 20261020155916_AdminPasswords, 20261022042837_MemberMobileNumber, 20261022044620_PushNotifications, 20261022051124_AndroidPackageName
================================================================================================================
  WHAT IT DOES
    * Creates 48 tables (incl. the migrations history) + their keys, indexes and constraints, and loads the
      PVS master data (temples, genders, classes, locations, ...). Every object name starts with PVS_.
    * Creates objects ONLY - never alters, drops or writes to any existing non-PVS table / object.
    * Safe to run again: already-applied migrations are skipped; new ones (after regeneration) are applied.

  SAFETY
    * Stops before changing anything if: run in a system database, your default schema is not dbo, or PVS_ objects
      exist that this script did not create.
    * Runs in ONE transaction. On any error everything is rolled back and the rest of the script is skipped.
    * Before committing it verifies every PVS table exists and that no other object in the database changed.

  HOW TO RUN  (needs a login with CREATE TABLE permission in dbo, e.g. the server admin or db_owner)
    * SSMS / Azure Data Studio: connect to the target database (check the database drop-down!) and execute.
    * sqlcmd:  sqlcmd -S tcp:<server>.database.windows.net,1433 -d <database> -U <user> -i PVS_Deploy_SharedDatabase.sql
    * NOT the Azure Portal query editor - it does not support GO batch separators.
    Expected result: "PVS deployment SUCCEEDED" at the end of the messages.
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

-------------------------------------------------------------------------------- 2. PVS schema and master data
IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF OBJECT_ID(N'[PVS_EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [PVS_EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PVS_PK_EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Accounts] (
        [AccountId] int NOT NULL IDENTITY,
        [MobileNumber] varchar(16) NOT NULL,
        [MobileVerifiedDate] datetime2(3) NULL,
        [LastLoginDate] datetime2(3) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Accounts_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Accounts_IsActive] DEFAULT CAST(1 AS bit),
        CONSTRAINT [PVS_PK_Accounts] PRIMARY KEY ([AccountId]),
        CONSTRAINT [PVS_CK_Accounts_MobileNumber] CHECK ([MobileNumber] LIKE '+[1-9]%')
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_AchievementTypes] (
        [AchievementTypeId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_AchievementTypes_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_AchievementTypes_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_AchievementTypes] PRIMARY KEY ([AchievementTypeId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_AuditLogs] (
        [AuditLogId] bigint NOT NULL IDENTITY,
        [AccountId] int NULL,
        [Action] varchar(100) NOT NULL,
        [EntityName] varchar(100) NULL,
        [EntityKey] nvarchar(50) NULL,
        [Details] nvarchar(1000) NULL,
        [IpAddress] varchar(45) NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        CONSTRAINT [PVS_PK_AuditLogs] PRIMARY KEY ([AuditLogId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Boards] (
        [BoardId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Boards_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Boards_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Boards] PRIMARY KEY ([BoardId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Branches] (
        [BranchId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Branches_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Branches_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Branches] PRIMARY KEY ([BranchId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_CareerOptions] (
        [CareerOptionId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_CareerOptions_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_CareerOptions_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_CareerOptions] PRIMARY KEY ([CareerOptionId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Classes] (
        [ClassId] int NOT NULL IDENTITY,
        [Stage] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Classes_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Classes_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Classes] PRIMARY KEY ([ClassId]),
        CONSTRAINT [PVS_CK_Classes_Stage] CHECK ([Stage] IN ('PrePrimary', 'Primary', 'HighSchool', 'PreUniversity', 'Vocational', 'UnderGraduate', 'PostGraduate', 'Professional', 'Other'))
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_CommunicationChannels] (
        [CommunicationChannelId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_CommunicationChannels_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_CommunicationChannels_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_CommunicationChannels] PRIMARY KEY ([CommunicationChannelId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_CommunicationTopics] (
        [CommunicationTopicId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_CommunicationTopics_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_CommunicationTopics_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_CommunicationTopics] PRIMARY KEY ([CommunicationTopicId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_CompetitiveExams] (
        [CompetitiveExamId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_CompetitiveExams_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_CompetitiveExams_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_CompetitiveExams] PRIMARY KEY ([CompetitiveExamId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Countries] (
        [CountryId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Countries_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Countries_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Countries] PRIMARY KEY ([CountryId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Courses] (
        [CourseId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Courses_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Courses_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Courses] PRIMARY KEY ([CourseId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_DisabilityTypes] (
        [DisabilityTypeId] int NOT NULL IDENTITY,
        [IsUserSubmitted] bit NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_DisabilityTypes_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_DisabilityTypes_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_DisabilityTypes] PRIMARY KEY ([DisabilityTypeId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_EducationLevels] (
        [EducationLevelId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_EducationLevels_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_EducationLevels_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_EducationLevels] PRIMARY KEY ([EducationLevelId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Genders] (
        [GenderId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Genders_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Genders_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Genders] PRIMARY KEY ([GenderId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Hobbies] (
        [HobbyId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Hobbies_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Hobbies_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Hobbies] PRIMARY KEY ([HobbyId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_InterestAreas] (
        [InterestAreaId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_InterestAreas_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_InterestAreas_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_InterestAreas] PRIMARY KEY ([InterestAreaId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_MemberStatuses] (
        [MemberStatusId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_MemberStatuses_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_MemberStatuses_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_MemberStatuses] PRIMARY KEY ([MemberStatusId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Organisations] (
        [OrganisationId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Organisations_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Organisations_IsActive] DEFAULT CAST(1 AS bit),
        [OrganisationName] nvarchar(150) NOT NULL,
        [OrganisationCode] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Organisations] PRIMARY KEY ([OrganisationId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_PhoneVerificationChallenges] (
        [ChallengeId] uniqueidentifier NOT NULL,
        [MobileNumber] varchar(16) NOT NULL,
        [CodeHash] char(64) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        [ExpiresDate] datetime2(3) NOT NULL,
        [FailedAttemptCount] int NOT NULL,
        [VerifiedDate] datetime2(3) NULL,
        [RequestIp] varchar(45) NULL,
        CONSTRAINT [PVS_PK_PhoneVerificationChallenges] PRIMARY KEY ([ChallengeId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Roles] (
        [RoleId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Roles_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Roles_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Roles] PRIMARY KEY ([RoleId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Skills] (
        [SkillId] int NOT NULL IDENTITY,
        [Category] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Skills_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Skills_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Skills] PRIMARY KEY ([SkillId]),
        CONSTRAINT [PVS_CK_Skills_Category] CHECK ([Category] IN ('Technical', 'General', 'Creative'))
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Sports] (
        [SportId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Sports_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Sports_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Sports] PRIMARY KEY ([SportId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Temples] (
        [TempleId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Temples_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Temples_IsActive] DEFAULT CAST(1 AS bit),
        [TempleName] nvarchar(200) NOT NULL,
        [TempleCode] varchar(2) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Temples] PRIMARY KEY ([TempleId]),
        CONSTRAINT [PVS_CK_Temples_TempleCode] CHECK ([TempleCode] LIKE '[0-9][0-9]')
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Universities] (
        [UniversityId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Universities_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Universities_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Universities] PRIMARY KEY ([UniversityId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_RefreshTokens] (
        [RefreshTokenId] bigint NOT NULL IDENTITY,
        [AccountId] int NOT NULL,
        [TokenHash] char(64) NOT NULL,
        [ExpiresDate] datetime2(3) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        [CreatedByIp] varchar(45) NULL,
        [RevokedDate] datetime2(3) NULL,
        [ReplacedByTokenHash] char(64) NULL,
        CONSTRAINT [PVS_PK_RefreshTokens] PRIMARY KEY ([RefreshTokenId]),
        CONSTRAINT [PVS_FK_RefreshTokens_Accounts_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [PVS_Accounts] ([AccountId]) ON DELETE CASCADE
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_States] (
        [StateId] int NOT NULL IDENTITY,
        [CountryId] int NOT NULL,
        [PostalName] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_States_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_States_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_States] PRIMARY KEY ([StateId]),
        CONSTRAINT [PVS_FK_States_Countries_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [PVS_Countries] ([CountryId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_AccountRoles] (
        [AccountId] int NOT NULL,
        [RoleId] int NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_AccountRoles] PRIMARY KEY ([AccountId], [RoleId]),
        CONSTRAINT [PVS_FK_AccountRoles_Accounts_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [PVS_Accounts] ([AccountId]) ON DELETE CASCADE,
        CONSTRAINT [PVS_FK_AccountRoles_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [PVS_Roles] ([RoleId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Members] (
        [RegistrationId] char(11) NOT NULL,
        [AccountId] int NOT NULL,
        [FullName] nvarchar(150) NOT NULL,
        [FatherName] nvarchar(150) NOT NULL,
        [MotherName] nvarchar(150) NOT NULL,
        [DateOfBirth] date NOT NULL,
        [GenderId] int NOT NULL,
        [TempleId] int NOT NULL,
        [MemberStatusId] int NOT NULL,
        [ClassId] int NULL,
        [HighestEducationLevelId] int NULL,
        [OrganisationId] int NOT NULL,
        [IsCurrentAddressSameAsPermanent] bit NOT NULL,
        [IsDisabled] bit NOT NULL,
        [RegistrationCompletedDate] datetime2(3) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Members_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Members_IsActive] DEFAULT CAST(1 AS bit),
        CONSTRAINT [PVS_PK_Members] PRIMARY KEY ([RegistrationId]),
        CONSTRAINT [PVS_CK_Members_ClassOrHighestEducation] CHECK ([ClassId] IS NULL OR [HighestEducationLevelId] IS NULL),
        CONSTRAINT [PVS_CK_Members_RegistrationId] CHECK ([RegistrationId] LIKE 'PVS-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
        CONSTRAINT [PVS_FK_Members_Accounts_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [PVS_Accounts] ([AccountId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_Members_Classes_ClassId] FOREIGN KEY ([ClassId]) REFERENCES [PVS_Classes] ([ClassId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_Members_EducationLevels_HighestEducationLevelId] FOREIGN KEY ([HighestEducationLevelId]) REFERENCES [PVS_EducationLevels] ([EducationLevelId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_Members_Genders_GenderId] FOREIGN KEY ([GenderId]) REFERENCES [PVS_Genders] ([GenderId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_Members_MemberStatuses_MemberStatusId] FOREIGN KEY ([MemberStatusId]) REFERENCES [PVS_MemberStatuses] ([MemberStatusId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_Members_Organisations_OrganisationId] FOREIGN KEY ([OrganisationId]) REFERENCES [PVS_Organisations] ([OrganisationId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_Members_Temples_TempleId] FOREIGN KEY ([TempleId]) REFERENCES [PVS_Temples] ([TempleId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_TempleRegistrationSequences] (
        [TempleId] int NOT NULL,
        [LastSequenceNumber] int NOT NULL,
        CONSTRAINT [PVS_PK_TempleRegistrationSequences] PRIMARY KEY ([TempleId]),
        CONSTRAINT [PVS_CK_TempleRegistrationSequences_Range] CHECK ([LastSequenceNumber] BETWEEN 0 AND 9999),
        CONSTRAINT [PVS_FK_TempleRegistrationSequences_Temples_TempleId] FOREIGN KEY ([TempleId]) REFERENCES [PVS_Temples] ([TempleId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Districts] (
        [DistrictId] int NOT NULL IDENTITY,
        [StateId] int NOT NULL,
        [PostalName] nvarchar(150) NULL,
        [Source] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Districts_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Districts_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Districts] PRIMARY KEY ([DistrictId]),
        CONSTRAINT [PVS_FK_Districts_States_StateId] FOREIGN KEY ([StateId]) REFERENCES [PVS_States] ([StateId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_ConsentRecords] (
        [ConsentRecordId] bigint NOT NULL IDENTITY,
        [AccountId] int NOT NULL,
        [RegistrationId] char(11) NULL,
        [ConsentType] varchar(40) NOT NULL,
        [PolicyVersion] varchar(20) NOT NULL,
        [IsGranted] bit NOT NULL,
        [RecordedDate] datetime2(3) NOT NULL,
        [IpAddress] varchar(45) NULL,
        CONSTRAINT [PVS_PK_ConsentRecords] PRIMARY KEY ([ConsentRecordId]),
        CONSTRAINT [PVS_FK_ConsentRecords_Accounts_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [PVS_Accounts] ([AccountId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_ConsentRecords_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_MemberDisabilities] (
        [RegistrationId] char(11) NOT NULL,
        [DisabilityTypeId] int NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_MemberDisabilities] PRIMARY KEY ([RegistrationId], [DisabilityTypeId]),
        CONSTRAINT [PVS_FK_MemberDisabilities_DisabilityTypes_DisabilityTypeId] FOREIGN KEY ([DisabilityTypeId]) REFERENCES [PVS_DisabilityTypes] ([DisabilityTypeId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberDisabilities_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Taluks] (
        [TalukId] int NOT NULL IDENTITY,
        [DistrictId] int NOT NULL,
        [PostalName] nvarchar(150) NULL,
        [Source] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Taluks_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Taluks_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Taluks] PRIMARY KEY ([TalukId]),
        CONSTRAINT [PVS_FK_Taluks_Districts_DistrictId] FOREIGN KEY ([DistrictId]) REFERENCES [PVS_Districts] ([DistrictId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_Cities] (
        [CityId] int NOT NULL IDENTITY,
        [PinCode] char(6) NOT NULL,
        [DistrictId] int NOT NULL,
        [TalukId] int NULL,
        [Source] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_Cities_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_Cities_IsActive] DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PVS_PK_Cities] PRIMARY KEY ([CityId]),
        CONSTRAINT [PVS_CK_Cities_PinCode] CHECK ([PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]'),
        CONSTRAINT [PVS_FK_Cities_Districts_DistrictId] FOREIGN KEY ([DistrictId]) REFERENCES [PVS_Districts] ([DistrictId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_Cities_Taluks_TalukId] FOREIGN KEY ([TalukId]) REFERENCES [PVS_Taluks] ([TalukId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE TABLE [PVS_MemberAddresses] (
        [MemberAddressId] int NOT NULL IDENTITY,
        [RegistrationId] char(11) NOT NULL,
        [AddressType] varchar(10) NOT NULL,
        [AddressLine1] nvarchar(200) NOT NULL,
        [AddressLine2] nvarchar(200) NULL,
        [PinCode] char(6) NOT NULL,
        [CityVillageName] nvarchar(150) NOT NULL,
        [CityId] int NULL,
        [TalukId] int NOT NULL,
        [DistrictId] int NOT NULL,
        [StateId] int NOT NULL,
        [CountryId] int NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_MemberAddresses_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_MemberAddresses_IsActive] DEFAULT CAST(1 AS bit),
        CONSTRAINT [PVS_PK_MemberAddresses] PRIMARY KEY ([MemberAddressId]),
        CONSTRAINT [PVS_CK_MemberAddresses_AddressType] CHECK ([AddressType] IN ('Permanent', 'Current')),
        CONSTRAINT [PVS_CK_MemberAddresses_PinCode] CHECK ([PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]'),
        CONSTRAINT [PVS_FK_MemberAddresses_Cities_CityId] FOREIGN KEY ([CityId]) REFERENCES [PVS_Cities] ([CityId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberAddresses_Countries_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [PVS_Countries] ([CountryId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberAddresses_Districts_DistrictId] FOREIGN KEY ([DistrictId]) REFERENCES [PVS_Districts] ([DistrictId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberAddresses_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE,
        CONSTRAINT [PVS_FK_MemberAddresses_States_StateId] FOREIGN KEY ([StateId]) REFERENCES [PVS_States] ([StateId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberAddresses_Taluks_TalukId] FOREIGN KEY ([TalukId]) REFERENCES [PVS_Taluks] ([TalukId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'AchievementTypeId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_AchievementTypes]'))
        SET IDENTITY_INSERT [PVS_AchievementTypes] ON;
    EXEC(N'INSERT INTO [PVS_AchievementTypes] ([AchievementTypeId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''ACADEMIC_RANK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Academic Rank''),
    (2, ''INSTITUTION_RANK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''School/College Rank''),
    (3, ''DISTRICT_RANK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''District Rank''),
    (4, ''STATE_RANK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''State Rank''),
    (5, ''NATIONAL_RANK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''National Rank''),
    (6, ''OLYMPIAD'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Olympiad Achievement''),
    (7, ''SCHOLARSHIP'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Scholarship''),
    (8, ''ACADEMIC_AWARD'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Academic Award''),
    (9, ''RESEARCH'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Research Achievement''),
    (10, ''PUBLICATION'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Paper/Publication''),
    (11, ''COMPETITION'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Competition Achievement''),
    (12, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'AchievementTypeId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_AchievementTypes]'))
        SET IDENTITY_INSERT [PVS_AchievementTypes] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'BoardId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Boards]'))
        SET IDENTITY_INSERT [PVS_Boards] ON;
    EXEC(N'INSERT INTO [PVS_Boards] ([BoardId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''KSEAB'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Karnataka State Board (KSEAB)''),
    (2, ''KA_PU'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Karnataka Pre-University Board''),
    (3, ''CBSE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''CBSE''),
    (4, ''CISCE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''ICSE / ISC (CISCE)''),
    (5, ''NIOS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''NIOS''),
    (6, ''IB'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''International Baccalaureate (IB)''),
    (7, ''CAMBRIDGE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Cambridge (IGCSE / A-Level)''),
    (8, ''OTHER_STATE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Other State Board''),
    (9, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'BoardId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Boards]'))
        SET IDENTITY_INSERT [PVS_Boards] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'BranchId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Branches]'))
        SET IDENTITY_INSERT [PVS_Branches] ON;
    EXEC(N'INSERT INTO [PVS_Branches] ([BranchId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''CSE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Computer Science''),
    (2, ''ISE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Information Science / IT''),
    (3, ''AIDS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Artificial Intelligence & Data Science''),
    (4, ''ECE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Electronics & Communication''),
    (5, ''EEE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Electrical & Electronics''),
    (6, ''MECH'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Mechanical''),
    (7, ''CIVIL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Civil''),
    (8, ''CHEM'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Chemical''),
    (9, ''BIOTECH'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Biotechnology''),
    (10, ''AERO'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Aeronautical''),
    (11, ''PHYSICS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Physics''),
    (12, ''CHEMISTRY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Chemistry''),
    (13, ''MATHS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''Mathematics''),
    (14, ''BIOLOGY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''Biology''),
    (15, ''ACCOUNTING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 150, CAST(1 AS bit), NULL, NULL, N''Accounting & Finance''),
    (16, ''ECONOMICS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 160, CAST(1 AS bit), NULL, NULL, N''Economics''),
    (17, ''MARKETING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 170, CAST(1 AS bit), NULL, NULL, N''Marketing''),
    (18, ''HR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 180, CAST(1 AS bit), NULL, NULL, N''Human Resources''),
    (19, ''ENGLISH'', N''seed'', ''2026-10-06T00:00:00.000Z'', 190, CAST(1 AS bit), NULL, NULL, N''English''),
    (20, ''KANNADA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 200, CAST(1 AS bit), NULL, NULL, N''Kannada''),
    (21, ''HISTORY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 210, CAST(1 AS bit), NULL, NULL, N''History''),
    (22, ''PSYCHOLOGY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 220, CAST(1 AS bit), NULL, NULL, N''Psychology''),
    (23, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 230, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'BranchId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Branches]'))
        SET IDENTITY_INSERT [PVS_Branches] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CareerOptionId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_CareerOptions]'))
        SET IDENTITY_INSERT [PVS_CareerOptions] ON;
    EXEC(N'INSERT INTO [PVS_CareerOptions] ([CareerOptionId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''DOCTOR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Doctor''),
    (2, ''ENGINEER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Engineer''),
    (3, ''CA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''CA''),
    (4, ''LAWYER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Lawyer''),
    (5, ''TEACHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Teacher''),
    (6, ''PROFESSOR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Professor''),
    (7, ''SCIENTIST'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Scientist''),
    (8, ''CIVIL_SERVICES'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Civil Services''),
    (9, ''KPSC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''KPSC''),
    (10, ''BANKING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Banking''),
    (11, ''DEFENCE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Defence''),
    (12, ''POLICE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Police''),
    (13, ''IT_PROFESSIONAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''IT Professional''),
    (14, ''ENTREPRENEUR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''Entrepreneur''),
    (15, ''RESEARCHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 150, CAST(1 AS bit), NULL, NULL, N''Researcher''),
    (16, ''DESIGNER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 160, CAST(1 AS bit), NULL, NULL, N''Designer''),
    (17, ''SPORTS_PROFESSIONAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 170, CAST(1 AS bit), NULL, NULL, N''Sports Professional''),
    (18, ''ARTIST'', N''seed'', ''2026-10-06T00:00:00.000Z'', 180, CAST(1 AS bit), NULL, NULL, N''Artist''),
    (19, ''SKILLED_PROFESSIONAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 190, CAST(1 AS bit), NULL, NULL, N''Skilled Professional''),
    (20, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 200, CAST(1 AS bit), NULL, NULL, N''Other''),
    (21, ''NOT_DECIDED'', N''seed'', ''2026-10-06T00:00:00.000Z'', 210, CAST(1 AS bit), NULL, NULL, N''Not Decided'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CareerOptionId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_CareerOptions]'))
        SET IDENTITY_INSERT [PVS_CareerOptions] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'ClassId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'Stage') AND [object_id] = OBJECT_ID(N'[PVS_Classes]'))
        SET IDENTITY_INSERT [PVS_Classes] ON;
    EXEC(N'INSERT INTO [PVS_Classes] ([ClassId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name], [Stage])
    VALUES (1, ''LKG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''LKG'', ''PrePrimary''),
    (2, ''UKG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''UKG'', ''PrePrimary''),
    (3, ''CLASS_1'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Class 1'', ''Primary''),
    (4, ''CLASS_2'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Class 2'', ''Primary''),
    (5, ''CLASS_3'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Class 3'', ''Primary''),
    (6, ''CLASS_4'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Class 4'', ''Primary''),
    (7, ''CLASS_5'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Class 5'', ''Primary''),
    (8, ''CLASS_6'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Class 6'', ''Primary''),
    (9, ''CLASS_7'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Class 7'', ''Primary''),
    (10, ''CLASS_8'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Class 8'', ''HighSchool''),
    (11, ''CLASS_9'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Class 9'', ''HighSchool''),
    (12, ''CLASS_10'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Class 10'', ''HighSchool''),
    (13, ''PUC_1'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''PUC 1'', ''PreUniversity''),
    (14, ''PUC_2'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''PUC 2'', ''PreUniversity''),
    (15, ''ITI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 150, CAST(1 AS bit), NULL, NULL, N''ITI'', ''Vocational''),
    (16, ''DIPLOMA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 160, CAST(1 AS bit), NULL, NULL, N''Diploma'', ''Vocational''),
    (17, ''UG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 170, CAST(1 AS bit), NULL, NULL, N''Undergraduate'', ''UnderGraduate''),
    (18, ''PG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 180, CAST(1 AS bit), NULL, NULL, N''Postgraduate'', ''PostGraduate''),
    (19, ''PROFESSIONAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 190, CAST(1 AS bit), NULL, NULL, N''Professional Course'', ''Professional''),
    (20, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 200, CAST(1 AS bit), NULL, NULL, N''Other'', ''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'ClassId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'Stage') AND [object_id] = OBJECT_ID(N'[PVS_Classes]'))
        SET IDENTITY_INSERT [PVS_Classes] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CommunicationChannelId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_CommunicationChannels]'))
        SET IDENTITY_INSERT [PVS_CommunicationChannels] ON;
    EXEC(N'INSERT INTO [PVS_CommunicationChannels] ([CommunicationChannelId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''WHATSAPP'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''WhatsApp''),
    (2, ''SMS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''SMS''),
    (3, ''EMAIL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Email''),
    (4, ''APP'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''App Notifications'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CommunicationChannelId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_CommunicationChannels]'))
        SET IDENTITY_INSERT [PVS_CommunicationChannels] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CommunicationTopicId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_CommunicationTopics]'))
        SET IDENTITY_INSERT [PVS_CommunicationTopics] ON;
    EXEC(N'INSERT INTO [PVS_CommunicationTopics] ([CommunicationTopicId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''SCHOLARSHIPS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Scholarships''),
    (2, ''EDUCATION_PROGRAMS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Education Programs''),
    (3, ''CAREER_GUIDANCE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Career Guidance''),
    (4, ''COMPETITIVE_EXAMS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Competitive Exams''),
    (5, ''JOBS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Jobs''),
    (6, ''INTERNSHIPS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Internships''),
    (7, ''TRAINING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Training''),
    (8, ''COMPETITIONS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Competitions''),
    (9, ''PVS_ACTIVITIES'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''PVS Activities''),
    (10, ''COMMUNITY_ANNOUNCEMENTS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Community Announcements'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CommunicationTopicId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_CommunicationTopics]'))
        SET IDENTITY_INSERT [PVS_CommunicationTopics] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CompetitiveExamId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_CompetitiveExams]'))
        SET IDENTITY_INSERT [PVS_CompetitiveExams] ON;
    EXEC(N'INSERT INTO [PVS_CompetitiveExams] ([CompetitiveExamId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''JEE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''JEE''),
    (2, ''NEET'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''NEET''),
    (3, ''KCET'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''KCET''),
    (4, ''CLAT'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''CLAT''),
    (5, ''CA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''CA''),
    (6, ''CMA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''CMA''),
    (7, ''CS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''CS''),
    (8, ''UPSC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''UPSC''),
    (9, ''KPSC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''KPSC''),
    (10, ''SSC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''SSC''),
    (11, ''BANKING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Banking''),
    (12, ''RAILWAYS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Railways''),
    (13, ''DEFENCE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''Defence''),
    (14, ''GATE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''GATE''),
    (15, ''CAT'', N''seed'', ''2026-10-06T00:00:00.000Z'', 150, CAST(1 AS bit), NULL, NULL, N''CAT''),
    (16, ''UGC_NET'', N''seed'', ''2026-10-06T00:00:00.000Z'', 160, CAST(1 AS bit), NULL, NULL, N''UGC NET''),
    (17, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 170, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CompetitiveExamId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_CompetitiveExams]'))
        SET IDENTITY_INSERT [PVS_CompetitiveExams] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CountryId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Countries]'))
        SET IDENTITY_INSERT [PVS_Countries] ON;
    EXEC(N'INSERT INTO [PVS_Countries] ([CountryId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''IN'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''India''),
    (2, ''AE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''United Arab Emirates''),
    (3, ''OM'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Oman''),
    (4, ''QA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Qatar''),
    (5, ''SA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Saudi Arabia''),
    (6, ''KW'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Kuwait''),
    (7, ''BH'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Bahrain''),
    (8, ''US'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''United States''),
    (9, ''GB'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''United Kingdom''),
    (10, ''CA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Canada''),
    (11, ''AU'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Australia''),
    (12, ''SG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Singapore''),
    (13, ''DE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''Germany''),
    (14, ''NZ'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''New Zealand'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CountryId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Countries]'))
        SET IDENTITY_INSERT [PVS_Countries] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourseId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Courses]'))
        SET IDENTITY_INSERT [PVS_Courses] ON;
    EXEC(N'INSERT INTO [PVS_Courses] ([CourseId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''BE_BTECH'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''B.E. / B.Tech''),
    (2, ''MBBS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''MBBS''),
    (3, ''BDS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''BDS''),
    (4, ''BAMS_BHMS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''BAMS / BHMS''),
    (5, ''BSC_NURSING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''B.Sc Nursing''),
    (6, ''BPHARM'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''B.Pharm''),
    (7, ''BSC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''B.Sc''),
    (8, ''BCOM'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''B.Com''),
    (9, ''BA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''B.A.''),
    (10, ''BBA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''BBA''),
    (11, ''BCA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''BCA''),
    (12, ''LLB'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''LLB''),
    (13, ''BED'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''B.Ed''),
    (14, ''ME_MTECH'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''M.E. / M.Tech''),
    (15, ''MSC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 150, CAST(1 AS bit), NULL, NULL, N''M.Sc''),
    (16, ''MCOM'', N''seed'', ''2026-10-06T00:00:00.000Z'', 160, CAST(1 AS bit), NULL, NULL, N''M.Com''),
    (17, ''MA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 170, CAST(1 AS bit), NULL, NULL, N''M.A.''),
    (18, ''MBA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 180, CAST(1 AS bit), NULL, NULL, N''MBA''),
    (19, ''MCA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 190, CAST(1 AS bit), NULL, NULL, N''MCA''),
    (20, ''MD_MS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 200, CAST(1 AS bit), NULL, NULL, N''MD / MS''),
    (21, ''CA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 210, CAST(1 AS bit), NULL, NULL, N''Chartered Accountancy (CA)''),
    (22, ''CS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 220, CAST(1 AS bit), NULL, NULL, N''Company Secretary (CS)''),
    (23, ''CMA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 230, CAST(1 AS bit), NULL, NULL, N''Cost and Management Accountancy (CMA)''),
    (24, ''DIPLOMA_ENGG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 240, CAST(1 AS bit), NULL, NULL, N''Diploma in Engineering''),
    (25, ''ITI_TRADE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 250, CAST(1 AS bit), NULL, NULL, N''ITI Trade''),
    (26, ''PHD'', N''seed'', ''2026-10-06T00:00:00.000Z'', 260, CAST(1 AS bit), NULL, NULL, N''PhD''),
    (27, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 270, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourseId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Courses]'))
        SET IDENTITY_INSERT [PVS_Courses] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'DisabilityTypeId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'IsUserSubmitted', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_DisabilityTypes]'))
        SET IDENTITY_INSERT [PVS_DisabilityTypes] ON;
    EXEC(N'INSERT INTO [PVS_DisabilityTypes] ([DisabilityTypeId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [IsUserSubmitted], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''VISUAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Visual Impairment''),
    (2, ''HEARING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Hearing Impairment''),
    (3, ''SPEECH_LANGUAGE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Speech/Language Impairment''),
    (4, ''PHYSICAL_MOBILITY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Physical/Mobility Impairment''),
    (5, ''INTELLECTUAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Intellectual Disability''),
    (6, ''SPECIFIC_LEARNING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Specific Learning Disability''),
    (7, ''MULTIPLE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Multiple Disabilities''),
    (8, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'DisabilityTypeId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'IsUserSubmitted', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_DisabilityTypes]'))
        SET IDENTITY_INSERT [PVS_DisabilityTypes] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'EducationLevelId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_EducationLevels]'))
        SET IDENTITY_INSERT [PVS_EducationLevels] ON;
    EXEC(N'INSERT INTO [PVS_EducationLevels] ([EducationLevelId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''BELOW_10'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Below Class 10''),
    (2, ''SSLC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Class 10 / SSLC''),
    (3, ''PUC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''PUC / Class 12''),
    (4, ''ITI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''ITI''),
    (5, ''DIPLOMA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Diploma''),
    (6, ''UG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Undergraduate Degree''),
    (7, ''PG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Postgraduate Degree''),
    (8, ''DOCTORATE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Doctorate (PhD)''),
    (9, ''PROFESSIONAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Professional Qualification (CA, CS, etc.)''),
    (10, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'EducationLevelId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_EducationLevels]'))
        SET IDENTITY_INSERT [PVS_EducationLevels] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'GenderId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Genders]'))
        SET IDENTITY_INSERT [PVS_Genders] ON;
    EXEC(N'INSERT INTO [PVS_Genders] ([GenderId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''MALE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Male''),
    (2, ''FEMALE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Female''),
    (3, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Other / Prefer not to say'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'GenderId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Genders]'))
        SET IDENTITY_INSERT [PVS_Genders] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'HobbyId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Hobbies]'))
        SET IDENTITY_INSERT [PVS_Hobbies] ON;
    EXEC(N'INSERT INTO [PVS_Hobbies] ([HobbyId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''READING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Reading''),
    (2, ''MUSIC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Music''),
    (3, ''SINGING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Singing''),
    (4, ''DRAWING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Drawing''),
    (5, ''PHOTOGRAPHY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Photography''),
    (6, ''GARDENING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Gardening''),
    (7, ''WRITING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Writing''),
    (8, ''TRAVELLING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Travelling''),
    (9, ''COOKING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Cooking''),
    (10, ''GAMING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Gaming''),
    (11, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'HobbyId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Hobbies]'))
        SET IDENTITY_INSERT [PVS_Hobbies] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'InterestAreaId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_InterestAreas]'))
        SET IDENTITY_INSERT [PVS_InterestAreas] ON;
    EXEC(N'INSERT INTO [PVS_InterestAreas] ([InterestAreaId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''SCIENCE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Science''),
    (2, ''MATHEMATICS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Mathematics''),
    (3, ''TECHNOLOGY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Technology & Computers''),
    (4, ''MEDICINE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Medicine & Health''),
    (5, ''COMMERCE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Commerce & Business''),
    (6, ''ARTS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Arts & Humanities''),
    (7, ''LANGUAGES'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Languages & Literature''),
    (8, ''LAW'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Law & Public Service''),
    (9, ''SOCIAL_SERVICE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Social Service''),
    (10, ''AGRICULTURE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Agriculture & Environment''),
    (11, ''SPORTS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Sports & Fitness''),
    (12, ''MUSIC_DANCE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Music & Dance''),
    (13, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'InterestAreaId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_InterestAreas]'))
        SET IDENTITY_INSERT [PVS_InterestAreas] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'MemberStatusId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_MemberStatuses]'))
        SET IDENTITY_INSERT [PVS_MemberStatuses] ON;
    EXEC(N'INSERT INTO [PVS_MemberStatuses] ([MemberStatusId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''STUDENT'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Student''),
    (2, ''WORKING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Working''),
    (3, ''UNEMPLOYED'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Unemployed'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'MemberStatusId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_MemberStatuses]'))
        SET IDENTITY_INSERT [PVS_MemberStatuses] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'OrganisationId', N'OrganisationCode', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'OrganisationName') AND [object_id] = OBJECT_ID(N'[PVS_Organisations]'))
        SET IDENTITY_INSERT [PVS_Organisations] ON;
    EXEC(N'INSERT INTO [PVS_Organisations] ([OrganisationId], [OrganisationCode], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [OrganisationName])
    VALUES (1, ''DK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''DK District''),
    (2, ''MUMBAI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Mumbai''),
    (3, ''BANGALORE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Bangalore''),
    (4, ''DUBAI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Dubai''),
    (5, ''SHIMOGA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Shimoga''),
    (6, ''NONE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Not Linked to Any Organisation'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'OrganisationId', N'OrganisationCode', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'OrganisationName') AND [object_id] = OBJECT_ID(N'[PVS_Organisations]'))
        SET IDENTITY_INSERT [PVS_Organisations] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'RoleId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Roles]'))
        SET IDENTITY_INSERT [PVS_Roles] ON;
    EXEC(N'INSERT INTO [PVS_Roles] ([RoleId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''MEMBER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Member''),
    (2, ''ADMIN'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Admin''),
    (3, ''SUPER_ADMIN'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Super Admin''),
    (4, ''DISTRICT_COORDINATOR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''District Coordinator''),
    (5, ''TEMPLE_COORDINATOR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Temple Coordinator''),
    (6, ''EDUCATION_COORDINATOR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Education Coordinator''),
    (7, ''CAREER_COORDINATOR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Career Coordinator''),
    (8, ''EMPLOYMENT_COORDINATOR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Employment Coordinator''),
    (9, ''SCHOLARSHIP_COORDINATOR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Scholarship Coordinator''),
    (10, ''COMMUNICATION_MANAGER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Communication Manager'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'RoleId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Roles]'))
        SET IDENTITY_INSERT [PVS_Roles] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'SkillId', N'Category', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Skills]'))
        SET IDENTITY_INSERT [PVS_Skills] ON;
    EXEC(N'INSERT INTO [PVS_Skills] ([SkillId], [Category], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''Technical'', ''PROGRAMMING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Programming / Coding''),
    (2, ''Technical'', ''WEB_DEV'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Web Development''),
    (3, ''Technical'', ''DATA_ANALYSIS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Data Analysis''),
    (4, ''Technical'', ''MS_OFFICE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''MS Office / Computer Basics''),
    (5, ''Technical'', ''ACCOUNTING_SW'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Accounting Software (Tally, etc.)''),
    (6, ''Technical'', ''ELECTRICAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Electrical Work''),
    (7, ''Technical'', ''MECHANICAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Mechanical / Repair Work''),
    (8, ''Technical'', ''CAD'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''CAD / Design Software''),
    (9, ''General'', ''COMMUNICATION'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Communication''),
    (10, ''General'', ''LEADERSHIP'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Leadership''),
    (11, ''General'', ''TEAMWORK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Teamwork''),
    (12, ''General'', ''PUBLIC_SPEAKING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Public Speaking''),
    (13, ''General'', ''PROBLEM_SOLVING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''Problem Solving''),
    (14, ''General'', ''TIME_MANAGEMENT'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''Time Management''),
    (15, ''General'', ''ENGLISH_SPEAKING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 150, CAST(1 AS bit), NULL, NULL, N''Spoken English''),
    (16, ''Creative'', ''DRAWING_PAINTING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 160, CAST(1 AS bit), NULL, NULL, N''Drawing / Painting''),
    (17, ''Creative'', ''MUSIC'', N''seed'', ''2026-10-06T00:00:00.000Z'', 170, CAST(1 AS bit), NULL, NULL, N''Music (Vocal / Instrument)''),
    (18, ''Creative'', ''DANCE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 180, CAST(1 AS bit), NULL, NULL, N''Dance''),
    (19, ''Creative'', ''CREATIVE_WRITING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 190, CAST(1 AS bit), NULL, NULL, N''Creative Writing''),
    (20, ''Creative'', ''PHOTOGRAPHY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 200, CAST(1 AS bit), NULL, NULL, N''Photography''),
    (21, ''Creative'', ''VIDEO_EDITING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 210, CAST(1 AS bit), NULL, NULL, N''Video Editing''),
    (22, ''Creative'', ''CRAFTS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 220, CAST(1 AS bit), NULL, NULL, N''Arts & Crafts''),
    (23, ''Creative'', ''WEAVING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 230, CAST(1 AS bit), NULL, NULL, N''Weaving / Textile Craft'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'SkillId', N'Category', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Skills]'))
        SET IDENTITY_INSERT [PVS_Skills] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'SportId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Sports]'))
        SET IDENTITY_INSERT [PVS_Sports] ON;
    EXEC(N'INSERT INTO [PVS_Sports] ([SportId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''CRICKET'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Cricket''),
    (2, ''FOOTBALL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Football''),
    (3, ''VOLLEYBALL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Volleyball''),
    (4, ''BADMINTON'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Badminton''),
    (5, ''ATHLETICS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Athletics''),
    (6, ''BASKETBALL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Basketball''),
    (7, ''SWIMMING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Swimming''),
    (8, ''CHESS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Chess''),
    (9, ''KABADDI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Kabaddi''),
    (10, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'SportId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Sports]'))
        SET IDENTITY_INSERT [PVS_Sports] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TempleId', N'TempleCode', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'TempleName') AND [object_id] = OBJECT_ID(N'[PVS_Temples]'))
        SET IDENTITY_INSERT [PVS_Temples] ON;
    EXEC(N'INSERT INTO [PVS_Temples] ([TempleId], [TempleCode], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [TempleName])
    VALUES (1, ''01'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Barkur''),
    (2, ''02'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Mangaluru''),
    (3, ''03'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Kallianapura''),
    (4, ''04'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Salikeri''),
    (5, ''05'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Kinnimulky'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TempleId', N'TempleCode', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'TempleName') AND [object_id] = OBJECT_ID(N'[PVS_Temples]'))
        SET IDENTITY_INSERT [PVS_Temples] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'UniversityId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Universities]'))
        SET IDENTITY_INSERT [PVS_Universities] ON;
    EXEC(N'INSERT INTO [PVS_Universities] ([UniversityId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''VTU'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Visvesvaraya Technological University''),
    (2, ''MANGALORE_UNIV'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Mangalore University''),
    (3, ''RGUHS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Rajiv Gandhi University of Health Sciences''),
    (4, ''BANGALORE_UNIV'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Bangalore University''),
    (5, ''MYSORE_UNIV'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''University of Mysore''),
    (6, ''KUVEMPU_UNIV'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Kuvempu University''),
    (7, ''MAHE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Manipal Academy of Higher Education''),
    (8, ''NITTE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Nitte (Deemed to be University)''),
    (9, ''KSLU'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Karnataka State Law University''),
    (10, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'UniversityId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[PVS_Universities]'))
        SET IDENTITY_INSERT [PVS_Universities] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'StateId', N'Code', N'CountryId', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName') AND [object_id] = OBJECT_ID(N'[PVS_States]'))
        SET IDENTITY_INSERT [PVS_States] ON;
    EXEC(N'INSERT INTO [PVS_States] ([StateId], [Code], [CountryId], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name], [PostalName])
    VALUES (1, ''IN-AP'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Andhra Pradesh'', NULL),
    (2, ''IN-AR'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Arunachal Pradesh'', NULL),
    (3, ''IN-AS'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Assam'', NULL),
    (4, ''IN-BR'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Bihar'', NULL),
    (5, ''IN-CG'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Chhattisgarh'', N''Chattisgarh''),
    (6, ''IN-GA'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Goa'', NULL),
    (7, ''IN-GJ'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Gujarat'', NULL),
    (8, ''IN-HR'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Haryana'', NULL),
    (9, ''IN-HP'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Himachal Pradesh'', NULL),
    (10, ''IN-JH'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Jharkhand'', NULL),
    (11, ''IN-KA'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Karnataka'', NULL),
    (12, ''IN-KL'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Kerala'', NULL),
    (13, ''IN-MP'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''Madhya Pradesh'', NULL),
    (14, ''IN-MH'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''Maharashtra'', NULL),
    (15, ''IN-MN'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 150, CAST(1 AS bit), NULL, NULL, N''Manipur'', NULL),
    (16, ''IN-ML'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 160, CAST(1 AS bit), NULL, NULL, N''Meghalaya'', NULL),
    (17, ''IN-MZ'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 170, CAST(1 AS bit), NULL, NULL, N''Mizoram'', NULL),
    (18, ''IN-NL'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 180, CAST(1 AS bit), NULL, NULL, N''Nagaland'', NULL),
    (19, ''IN-OD'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 190, CAST(1 AS bit), NULL, NULL, N''Odisha'', N''Orissa''),
    (20, ''IN-PB'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 200, CAST(1 AS bit), NULL, NULL, N''Punjab'', NULL),
    (21, ''IN-RJ'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 210, CAST(1 AS bit), NULL, NULL, N''Rajasthan'', NULL),
    (22, ''IN-SK'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 220, CAST(1 AS bit), NULL, NULL, N''Sikkim'', NULL),
    (23, ''IN-TN'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 230, CAST(1 AS bit), NULL, NULL, N''Tamil Nadu'', NULL),
    (24, ''IN-TS'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 240, CAST(1 AS bit), NULL, NULL, N''Telangana'', NULL),
    (25, ''IN-TR'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 250, CAST(1 AS bit), NULL, NULL, N''Tripura'', NULL),
    (26, ''IN-UP'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 260, CAST(1 AS bit), NULL, NULL, N''Uttar Pradesh'', NULL),
    (27, ''IN-UK'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 270, CAST(1 AS bit), NULL, NULL, N''Uttarakhand'', N''Uttaranchal''),
    (28, ''IN-WB'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 280, CAST(1 AS bit), NULL, NULL, N''West Bengal'', NULL),
    (29, ''IN-AN'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 290, CAST(1 AS bit), NULL, NULL, N''Andaman and Nicobar Islands'', NULL),
    (30, ''IN-CH'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 300, CAST(1 AS bit), NULL, NULL, N''Chandigarh'', NULL),
    (31, ''IN-DH'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 310, CAST(1 AS bit), NULL, NULL, N''Dadra and Nagar Haveli and Daman and Diu'', NULL),
    (32, ''IN-DL'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 320, CAST(1 AS bit), NULL, NULL, N''Delhi'', NULL),
    (33, ''IN-JK'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 330, CAST(1 AS bit), NULL, NULL, N''Jammu and Kashmir'', NULL),
    (34, ''IN-LA'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 340, CAST(1 AS bit), NULL, NULL, N''Ladakh'', NULL),
    (35, ''IN-LD'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 350, CAST(1 AS bit), NULL, NULL, N''Lakshadweep'', NULL),
    (36, ''IN-PY'', 1, N''seed'', ''2026-10-06T00:00:00.000Z'', 360, CAST(1 AS bit), NULL, NULL, N''Puducherry'', N''Pondicherry'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'StateId', N'Code', N'CountryId', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName') AND [object_id] = OBJECT_ID(N'[PVS_States]'))
        SET IDENTITY_INSERT [PVS_States] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TempleId', N'LastSequenceNumber') AND [object_id] = OBJECT_ID(N'[PVS_TempleRegistrationSequences]'))
        SET IDENTITY_INSERT [PVS_TempleRegistrationSequences] ON;
    EXEC(N'INSERT INTO [PVS_TempleRegistrationSequences] ([TempleId], [LastSequenceNumber])
    VALUES (1, 0),
    (2, 0),
    (3, 0),
    (4, 0),
    (5, 0)');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TempleId', N'LastSequenceNumber') AND [object_id] = OBJECT_ID(N'[PVS_TempleRegistrationSequences]'))
        SET IDENTITY_INSERT [PVS_TempleRegistrationSequences] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'DistrictId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName', N'Source', N'StateId') AND [object_id] = OBJECT_ID(N'[PVS_Districts]'))
        SET IDENTITY_INSERT [PVS_Districts] ON;
    EXEC(N'INSERT INTO [PVS_Districts] ([DistrictId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name], [PostalName], [Source], [StateId])
    VALUES (1, ''KA-BGK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Bagalkote'', N''Bagalkot'', ''Seed'', 11),
    (2, ''KA-BLR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Ballari'', N''Bellary'', ''Seed'', 11),
    (3, ''KA-BGM'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Belagavi'', N''Belgaum'', ''Seed'', 11),
    (4, ''KA-BRR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Bengaluru Rural'', N''Bangalore Rural'', ''Seed'', 11),
    (5, ''KA-BLU'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Bengaluru Urban'', N''Bangalore'', ''Seed'', 11),
    (6, ''KA-BDR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Bidar'', NULL, ''Seed'', 11),
    (7, ''KA-CMJ'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Chamarajanagar'', N''Chamrajnagar'', ''Seed'', 11),
    (8, ''KA-CBP'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Chikkaballapur'', NULL, ''Seed'', 11),
    (9, ''KA-CKM'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Chikkamagaluru'', N''Chikmagalur'', ''Seed'', 11),
    (10, ''KA-CTA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Chitradurga'', NULL, ''Seed'', 11),
    (11, ''KA-DK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Dakshina Kannada'', NULL, ''Seed'', 11),
    (12, ''KA-DVG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Davanagere'', N''Davangere'', ''Seed'', 11),
    (13, ''KA-DWD'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''Dharwad'', NULL, ''Seed'', 11),
    (14, ''KA-GDG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''Gadag'', NULL, ''Seed'', 11),
    (15, ''KA-HSN'', N''seed'', ''2026-10-06T00:00:00.000Z'', 150, CAST(1 AS bit), NULL, NULL, N''Hassan'', NULL, ''Seed'', 11),
    (16, ''KA-HVR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 160, CAST(1 AS bit), NULL, NULL, N''Haveri'', NULL, ''Seed'', 11),
    (17, ''KA-KLB'', N''seed'', ''2026-10-06T00:00:00.000Z'', 170, CAST(1 AS bit), NULL, NULL, N''Kalaburagi'', N''Gulbarga'', ''Seed'', 11),
    (18, ''KA-KDG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 180, CAST(1 AS bit), NULL, NULL, N''Kodagu'', NULL, ''Seed'', 11),
    (19, ''KA-KLR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 190, CAST(1 AS bit), NULL, NULL, N''Kolar'', NULL, ''Seed'', 11),
    (20, ''KA-KPL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 200, CAST(1 AS bit), NULL, NULL, N''Koppal'', NULL, ''Seed'', 11),
    (21, ''KA-MDY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 210, CAST(1 AS bit), NULL, NULL, N''Mandya'', NULL, ''Seed'', 11),
    (22, ''KA-MYS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 220, CAST(1 AS bit), NULL, NULL, N''Mysuru'', N''Mysore'', ''Seed'', 11),
    (23, ''KA-RCR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 230, CAST(1 AS bit), NULL, NULL, N''Raichur'', NULL, ''Seed'', 11),
    (24, ''KA-RMN'', N''seed'', ''2026-10-06T00:00:00.000Z'', 240, CAST(1 AS bit), NULL, NULL, N''Ramanagara'', N''Ramanagar'', ''Seed'', 11),
    (25, ''KA-SMG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 250, CAST(1 AS bit), NULL, NULL, N''Shivamogga'', N''Shimoga'', ''Seed'', 11),
    (26, ''KA-TMK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 260, CAST(1 AS bit), NULL, NULL, N''Tumakuru'', N''Tumkur'', ''Seed'', 11),
    (27, ''KA-UDP'', N''seed'', ''2026-10-06T00:00:00.000Z'', 270, CAST(1 AS bit), NULL, NULL, N''Udupi'', NULL, ''Seed'', 11),
    (28, ''KA-UK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 280, CAST(1 AS bit), NULL, NULL, N''Uttara Kannada'', NULL, ''Seed'', 11),
    (29, ''KA-VJN'', N''seed'', ''2026-10-06T00:00:00.000Z'', 290, CAST(1 AS bit), NULL, NULL, N''Vijayanagara'', NULL, ''Seed'', 11),
    (30, ''KA-VJP'', N''seed'', ''2026-10-06T00:00:00.000Z'', 300, CAST(1 AS bit), NULL, NULL, N''Vijayapura'', N''Bijapur'', ''Seed'', 11),
    (31, ''KA-YDG'', N''seed'', ''2026-10-06T00:00:00.000Z'', 310, CAST(1 AS bit), NULL, NULL, N''Yadgir'', NULL, ''Seed'', 11)');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'DistrictId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName', N'Source', N'StateId') AND [object_id] = OBJECT_ID(N'[PVS_Districts]'))
        SET IDENTITY_INSERT [PVS_Districts] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TalukId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'DistrictId', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName', N'Source') AND [object_id] = OBJECT_ID(N'[PVS_Taluks]'))
        SET IDENTITY_INSERT [PVS_Taluks] ON;
    EXEC(N'INSERT INTO [PVS_Taluks] ([TalukId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [DistrictId], [IsActive], [ModifiedBy], [ModifiedDate], [Name], [PostalName], [Source])
    VALUES (1, ''KA-DK-MANGALURU'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, 11, CAST(1 AS bit), NULL, NULL, N''Mangaluru'', N''Mangalore'', ''Seed''),
    (2, ''KA-DK-BANTWAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, 11, CAST(1 AS bit), NULL, NULL, N''Bantwal'', NULL, ''Seed''),
    (3, ''KA-DK-PUTTUR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, 11, CAST(1 AS bit), NULL, NULL, N''Puttur'', NULL, ''Seed''),
    (4, ''KA-DK-BELTHANGADY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, 11, CAST(1 AS bit), NULL, NULL, N''Belthangady'', NULL, ''Seed''),
    (5, ''KA-DK-SULLIA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, 11, CAST(1 AS bit), NULL, NULL, N''Sullia'', NULL, ''Seed''),
    (6, ''KA-DK-KADABA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, 11, CAST(1 AS bit), NULL, NULL, N''Kadaba'', NULL, ''Seed''),
    (7, ''KA-DK-MOODBIDRI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, 11, CAST(1 AS bit), NULL, NULL, N''Moodbidri'', N''Mudbidri'', ''Seed''),
    (8, ''KA-DK-ULLAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, 11, CAST(1 AS bit), NULL, NULL, N''Ullal'', NULL, ''Seed''),
    (9, ''KA-DK-MULKI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, 11, CAST(1 AS bit), NULL, NULL, N''Mulki'', NULL, ''Seed''),
    (10, ''KA-UDP-UDUPI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, 27, CAST(1 AS bit), NULL, NULL, N''Udupi'', NULL, ''Seed''),
    (11, ''KA-UDP-KUNDAPURA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, 27, CAST(1 AS bit), NULL, NULL, N''Kundapura'', N''Kundapur'', ''Seed''),
    (12, ''KA-UDP-KARKALA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, 27, CAST(1 AS bit), NULL, NULL, N''Karkala'', NULL, ''Seed''),
    (13, ''KA-UDP-KAPU'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, 27, CAST(1 AS bit), NULL, NULL, N''Kapu'', N''Kaup'', ''Seed''),
    (14, ''KA-UDP-BRAHMAVAR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, 27, CAST(1 AS bit), NULL, NULL, N''Brahmavar'', NULL, ''Seed''),
    (15, ''KA-UDP-BYNDOOR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 150, 27, CAST(1 AS bit), NULL, NULL, N''Byndoor'', NULL, ''Seed''),
    (16, ''KA-UDP-HEBRI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 160, 27, CAST(1 AS bit), NULL, NULL, N''Hebri'', NULL, ''Seed''),
    (17, ''KA-SMG-SHIVAMOGGA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 170, 25, CAST(1 AS bit), NULL, NULL, N''Shivamogga'', N''Shimoga'', ''Seed''),
    (18, ''KA-SMG-BHADRAVATI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 180, 25, CAST(1 AS bit), NULL, NULL, N''Bhadravati'', NULL, ''Seed''),
    (19, ''KA-SMG-SAGAR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 190, 25, CAST(1 AS bit), NULL, NULL, N''Sagar'', N''Sagara'', ''Seed''),
    (20, ''KA-SMG-SHIKARIPURA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 200, 25, CAST(1 AS bit), NULL, NULL, N''Shikaripura'', NULL, ''Seed''),
    (21, ''KA-SMG-SORABA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 210, 25, CAST(1 AS bit), NULL, NULL, N''Soraba'', NULL, ''Seed''),
    (22, ''KA-SMG-THIRTHAHALLI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 220, 25, CAST(1 AS bit), NULL, NULL, N''Thirthahalli'', NULL, ''Seed''),
    (23, ''KA-SMG-HOSANAGARA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 230, 25, CAST(1 AS bit), NULL, NULL, N''Hosanagara'', NULL, ''Seed''),
    (24, ''KA-BLU-BENGALURUNORTH'', N''seed'', ''2026-10-06T00:00:00.000Z'', 240, 5, CAST(1 AS bit), NULL, NULL, N''Bengaluru North'', N''Bangalore North'', ''Seed''),
    (25, ''KA-BLU-BENGALURUSOUTH'', N''seed'', ''2026-10-06T00:00:00.000Z'', 250, 5, CAST(1 AS bit), NULL, NULL, N''Bengaluru South'', N''Bangalore South'', ''Seed''),
    (26, ''KA-BLU-BENGALURUEAST'', N''seed'', ''2026-10-06T00:00:00.000Z'', 260, 5, CAST(1 AS bit), NULL, NULL, N''Bengaluru East'', N''Bangalore East'', ''Seed''),
    (27, ''KA-BLU-ANEKAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 270, 5, CAST(1 AS bit), NULL, NULL, N''Anekal'', NULL, ''Seed''),
    (28, ''KA-BLU-YELAHANKA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 280, 5, CAST(1 AS bit), NULL, NULL, N''Yelahanka'', NULL, ''Seed''),
    (29, ''KA-UK-KARWAR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 290, 28, CAST(1 AS bit), NULL, NULL, N''Karwar'', NULL, ''Seed''),
    (30, ''KA-UK-ANKOLA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 300, 28, CAST(1 AS bit), NULL, NULL, N''Ankola'', NULL, ''Seed''),
    (31, ''KA-UK-KUMTA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 310, 28, CAST(1 AS bit), NULL, NULL, N''Kumta'', NULL, ''Seed''),
    (32, ''KA-UK-HONNAVAR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 320, 28, CAST(1 AS bit), NULL, NULL, N''Honnavar'', NULL, ''Seed''),
    (33, ''KA-UK-BHATKAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 330, 28, CAST(1 AS bit), NULL, NULL, N''Bhatkal'', NULL, ''Seed''),
    (34, ''KA-UK-SIRSI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 340, 28, CAST(1 AS bit), NULL, NULL, N''Sirsi'', NULL, ''Seed''),
    (35, ''KA-UK-SIDDAPUR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 350, 28, CAST(1 AS bit), NULL, NULL, N''Siddapur'', NULL, ''Seed''),
    (36, ''KA-UK-YELLAPUR'', N''seed'', ''2026-10-06T00:00:00.000Z'', 360, 28, CAST(1 AS bit), NULL, NULL, N''Yellapur'', NULL, ''Seed''),
    (37, ''KA-UK-MUNDGOD'', N''seed'', ''2026-10-06T00:00:00.000Z'', 370, 28, CAST(1 AS bit), NULL, NULL, N''Mundgod'', NULL, ''Seed''),
    (38, ''KA-UK-HALIYAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 380, 28, CAST(1 AS bit), NULL, NULL, N''Haliyal'', NULL, ''Seed''),
    (39, ''KA-UK-JOIDA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 390, 28, CAST(1 AS bit), NULL, NULL, N''Joida'', NULL, ''Seed''),
    (40, ''KA-UK-DANDELI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 400, 28, CAST(1 AS bit), NULL, NULL, N''Dandeli'', NULL, ''Seed'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TalukId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'DistrictId', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName', N'Source') AND [object_id] = OBJECT_ID(N'[PVS_Taluks]'))
        SET IDENTITY_INSERT [PVS_Taluks] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_AccountRoles_RoleId] ON [PVS_AccountRoles] ([RoleId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Accounts_MobileNumber] ON [PVS_Accounts] ([MobileNumber]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_AchievementTypes_Code] ON [PVS_AchievementTypes] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_AchievementTypes_IsActive_DisplayOrder] ON [PVS_AchievementTypes] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_AchievementTypes_Name] ON [PVS_AchievementTypes] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_AuditLogs_AccountId_CreatedDate] ON [PVS_AuditLogs] ([AccountId], [CreatedDate]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_AuditLogs_CreatedDate] ON [PVS_AuditLogs] ([CreatedDate]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Boards_Code] ON [PVS_Boards] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Boards_IsActive_DisplayOrder] ON [PVS_Boards] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Boards_Name] ON [PVS_Boards] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Branches_Code] ON [PVS_Branches] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Branches_IsActive_DisplayOrder] ON [PVS_Branches] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Branches_Name] ON [PVS_Branches] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_CareerOptions_Code] ON [PVS_CareerOptions] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_CareerOptions_IsActive_DisplayOrder] ON [PVS_CareerOptions] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_CareerOptions_Name] ON [PVS_CareerOptions] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Cities_Code] ON [PVS_Cities] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Cities_DistrictId] ON [PVS_Cities] ([DistrictId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Cities_IsActive_DisplayOrder] ON [PVS_Cities] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Cities_PinCode_Name] ON [PVS_Cities] ([PinCode], [Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Cities_TalukId] ON [PVS_Cities] ([TalukId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Classes_Code] ON [PVS_Classes] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Classes_IsActive_DisplayOrder] ON [PVS_Classes] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Classes_Name] ON [PVS_Classes] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_CommunicationChannels_Code] ON [PVS_CommunicationChannels] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_CommunicationChannels_IsActive_DisplayOrder] ON [PVS_CommunicationChannels] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_CommunicationChannels_Name] ON [PVS_CommunicationChannels] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_CommunicationTopics_Code] ON [PVS_CommunicationTopics] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_CommunicationTopics_IsActive_DisplayOrder] ON [PVS_CommunicationTopics] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_CommunicationTopics_Name] ON [PVS_CommunicationTopics] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_CompetitiveExams_Code] ON [PVS_CompetitiveExams] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_CompetitiveExams_IsActive_DisplayOrder] ON [PVS_CompetitiveExams] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_CompetitiveExams_Name] ON [PVS_CompetitiveExams] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_ConsentRecords_AccountId_ConsentType] ON [PVS_ConsentRecords] ([AccountId], [ConsentType]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_ConsentRecords_RegistrationId] ON [PVS_ConsentRecords] ([RegistrationId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Countries_Code] ON [PVS_Countries] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Countries_IsActive_DisplayOrder] ON [PVS_Countries] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Countries_Name] ON [PVS_Countries] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Courses_Code] ON [PVS_Courses] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Courses_IsActive_DisplayOrder] ON [PVS_Courses] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Courses_Name] ON [PVS_Courses] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_DisabilityTypes_Code] ON [PVS_DisabilityTypes] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_DisabilityTypes_IsActive_DisplayOrder] ON [PVS_DisabilityTypes] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_DisabilityTypes_Name] ON [PVS_DisabilityTypes] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Districts_Code] ON [PVS_Districts] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Districts_IsActive_DisplayOrder] ON [PVS_Districts] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Districts_StateId_Name] ON [PVS_Districts] ([StateId], [Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_EducationLevels_Code] ON [PVS_EducationLevels] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_EducationLevels_IsActive_DisplayOrder] ON [PVS_EducationLevels] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_EducationLevels_Name] ON [PVS_EducationLevels] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Genders_Code] ON [PVS_Genders] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Genders_IsActive_DisplayOrder] ON [PVS_Genders] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Genders_Name] ON [PVS_Genders] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Hobbies_Code] ON [PVS_Hobbies] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Hobbies_IsActive_DisplayOrder] ON [PVS_Hobbies] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Hobbies_Name] ON [PVS_Hobbies] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_InterestAreas_Code] ON [PVS_InterestAreas] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_InterestAreas_IsActive_DisplayOrder] ON [PVS_InterestAreas] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_InterestAreas_Name] ON [PVS_InterestAreas] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberAddresses_CityId] ON [PVS_MemberAddresses] ([CityId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberAddresses_CountryId] ON [PVS_MemberAddresses] ([CountryId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberAddresses_DistrictId_TalukId] ON [PVS_MemberAddresses] ([DistrictId], [TalukId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberAddresses_PinCode] ON [PVS_MemberAddresses] ([PinCode]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_MemberAddresses_RegistrationId_AddressType] ON [PVS_MemberAddresses] ([RegistrationId], [AddressType]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberAddresses_StateId] ON [PVS_MemberAddresses] ([StateId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberAddresses_TalukId] ON [PVS_MemberAddresses] ([TalukId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberDisabilities_DisabilityTypeId] ON [PVS_MemberDisabilities] ([DisabilityTypeId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Members_AccountId] ON [PVS_Members] ([AccountId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Members_ClassId] ON [PVS_Members] ([ClassId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Members_DateOfBirth] ON [PVS_Members] ([DateOfBirth]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Members_GenderId] ON [PVS_Members] ([GenderId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Members_HighestEducationLevelId] ON [PVS_Members] ([HighestEducationLevelId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Members_MemberStatusId_ClassId] ON [PVS_Members] ([MemberStatusId], [ClassId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Members_OrganisationId] ON [PVS_Members] ([OrganisationId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Members_TempleId] ON [PVS_Members] ([TempleId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_MemberStatuses_Code] ON [PVS_MemberStatuses] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberStatuses_IsActive_DisplayOrder] ON [PVS_MemberStatuses] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_MemberStatuses_Name] ON [PVS_MemberStatuses] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Organisations_IsActive_DisplayOrder] ON [PVS_Organisations] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Organisations_OrganisationCode] ON [PVS_Organisations] ([OrganisationCode]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Organisations_OrganisationName] ON [PVS_Organisations] ([OrganisationName]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_PhoneVerificationChallenges_MobileNumber_CreatedDate] ON [PVS_PhoneVerificationChallenges] ([MobileNumber], [CreatedDate]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_RefreshTokens_AccountId] ON [PVS_RefreshTokens] ([AccountId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_RefreshTokens_TokenHash] ON [PVS_RefreshTokens] ([TokenHash]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Roles_Code] ON [PVS_Roles] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Roles_IsActive_DisplayOrder] ON [PVS_Roles] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Roles_Name] ON [PVS_Roles] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Skills_Category_IsActive_DisplayOrder] ON [PVS_Skills] ([Category], [IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Skills_Code] ON [PVS_Skills] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Skills_IsActive_DisplayOrder] ON [PVS_Skills] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Skills_Name] ON [PVS_Skills] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Sports_Code] ON [PVS_Sports] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Sports_IsActive_DisplayOrder] ON [PVS_Sports] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Sports_Name] ON [PVS_Sports] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_States_Code] ON [PVS_States] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_States_CountryId_Name] ON [PVS_States] ([CountryId], [Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_States_IsActive_DisplayOrder] ON [PVS_States] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Taluks_Code] ON [PVS_Taluks] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Taluks_DistrictId_Name] ON [PVS_Taluks] ([DistrictId], [Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Taluks_IsActive_DisplayOrder] ON [PVS_Taluks] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Temples_IsActive_DisplayOrder] ON [PVS_Temples] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Temples_TempleCode] ON [PVS_Temples] ([TempleCode]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Temples_TempleName] ON [PVS_Temples] ([TempleName]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Universities_Code] ON [PVS_Universities] ([Code]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE INDEX [PVS_IX_Universities_IsActive_DisplayOrder] ON [PVS_Universities] ([IsActive], [DisplayOrder]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    CREATE UNIQUE INDEX [PVS_IX_Universities_Name] ON [PVS_Universities] ([Name]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006135106_InitialSchema'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261006135106_InitialSchema', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009101316_OtherTextColumns'
)
BEGIN
    ALTER TABLE [PVS_Members] ADD [HighestEducationLevelOtherText] nvarchar(150) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009101316_OtherTextColumns'
)
BEGIN
    ALTER TABLE [PVS_MemberDisabilities] ADD [OtherText] nvarchar(150) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009101316_OtherTextColumns'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261009101316_OtherTextColumns', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE TABLE [PVS_AcademicAchievements] (
        [AcademicAchievementId] int NOT NULL IDENTITY,
        [RegistrationId] char(11) NOT NULL,
        [AchievementTypeId] int NOT NULL,
        [AchievementTypeOtherText] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_AcademicAchievements_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_AcademicAchievements_IsActive] DEFAULT CAST(1 AS bit),
        CONSTRAINT [PVS_PK_AcademicAchievements] PRIMARY KEY ([AcademicAchievementId]),
        CONSTRAINT [PVS_FK_AcademicAchievements_AchievementTypes_AchievementTypeId] FOREIGN KEY ([AchievementTypeId]) REFERENCES [PVS_AchievementTypes] ([AchievementTypeId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_AcademicAchievements_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE TABLE [PVS_MemberCareerAspirations] (
        [RegistrationId] char(11) NOT NULL,
        [CareerOptionId] int NOT NULL,
        [OtherText] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_MemberCareerAspirations_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_MemberCareerAspirations] PRIMARY KEY ([RegistrationId], [CareerOptionId]),
        CONSTRAINT [PVS_FK_MemberCareerAspirations_CareerOptions_CareerOptionId] FOREIGN KEY ([CareerOptionId]) REFERENCES [PVS_CareerOptions] ([CareerOptionId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberCareerAspirations_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE TABLE [PVS_MemberCompetitiveExams] (
        [RegistrationId] char(11) NOT NULL,
        [CompetitiveExamId] int NOT NULL,
        [OtherText] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_MemberCompetitiveExams_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_MemberCompetitiveExams] PRIMARY KEY ([RegistrationId], [CompetitiveExamId]),
        CONSTRAINT [PVS_FK_MemberCompetitiveExams_CompetitiveExams_CompetitiveExamId] FOREIGN KEY ([CompetitiveExamId]) REFERENCES [PVS_CompetitiveExams] ([CompetitiveExamId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberCompetitiveExams_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE TABLE [PVS_MemberEducation] (
        [MemberEducationId] int NOT NULL IDENTITY,
        [RegistrationId] char(11) NOT NULL,
        [EducationLevelId] int NOT NULL,
        [EducationLevelOtherText] nvarchar(150) NULL,
        [CourseId] int NULL,
        [CourseOtherText] nvarchar(150) NULL,
        [BranchId] int NULL,
        [BranchOtherText] nvarchar(150) NULL,
        [BoardId] int NULL,
        [BoardOtherText] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_MemberEducation_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL CONSTRAINT [PVS_DF_MemberEducation_IsActive] DEFAULT CAST(1 AS bit),
        CONSTRAINT [PVS_PK_MemberEducation] PRIMARY KEY ([MemberEducationId]),
        CONSTRAINT [PVS_FK_MemberEducation_Boards_BoardId] FOREIGN KEY ([BoardId]) REFERENCES [PVS_Boards] ([BoardId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberEducation_Branches_BranchId] FOREIGN KEY ([BranchId]) REFERENCES [PVS_Branches] ([BranchId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberEducation_Courses_CourseId] FOREIGN KEY ([CourseId]) REFERENCES [PVS_Courses] ([CourseId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberEducation_EducationLevels_EducationLevelId] FOREIGN KEY ([EducationLevelId]) REFERENCES [PVS_EducationLevels] ([EducationLevelId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberEducation_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE TABLE [PVS_MemberHobbies] (
        [RegistrationId] char(11) NOT NULL,
        [HobbyId] int NOT NULL,
        [OtherText] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_MemberHobbies_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_MemberHobbies] PRIMARY KEY ([RegistrationId], [HobbyId]),
        CONSTRAINT [PVS_FK_MemberHobbies_Hobbies_HobbyId] FOREIGN KEY ([HobbyId]) REFERENCES [PVS_Hobbies] ([HobbyId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberHobbies_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE TABLE [PVS_MemberInterestAreas] (
        [RegistrationId] char(11) NOT NULL,
        [InterestAreaId] int NOT NULL,
        [OtherText] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_MemberInterestAreas_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_MemberInterestAreas] PRIMARY KEY ([RegistrationId], [InterestAreaId]),
        CONSTRAINT [PVS_FK_MemberInterestAreas_InterestAreas_InterestAreaId] FOREIGN KEY ([InterestAreaId]) REFERENCES [PVS_InterestAreas] ([InterestAreaId]) ON DELETE NO ACTION,
        CONSTRAINT [PVS_FK_MemberInterestAreas_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE TABLE [PVS_MemberSkills] (
        [RegistrationId] char(11) NOT NULL,
        [SkillId] int NOT NULL,
        [OtherText] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_MemberSkills_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_MemberSkills] PRIMARY KEY ([RegistrationId], [SkillId]),
        CONSTRAINT [PVS_FK_MemberSkills_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE,
        CONSTRAINT [PVS_FK_MemberSkills_Skills_SkillId] FOREIGN KEY ([SkillId]) REFERENCES [PVS_Skills] ([SkillId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE TABLE [PVS_MemberSports] (
        [RegistrationId] char(11) NOT NULL,
        [SportId] int NOT NULL,
        [OtherText] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL CONSTRAINT [PVS_DF_MemberSports_CreatedDate] DEFAULT (SYSUTCDATETIME()),
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_MemberSports] PRIMARY KEY ([RegistrationId], [SportId]),
        CONSTRAINT [PVS_FK_MemberSports_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [PVS_Members] ([RegistrationId]) ON DELETE CASCADE,
        CONSTRAINT [PVS_FK_MemberSports_Sports_SportId] FOREIGN KEY ([SportId]) REFERENCES [PVS_Sports] ([SportId]) ON DELETE NO ACTION
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_AcademicAchievements_AchievementTypeId] ON [PVS_AcademicAchievements] ([AchievementTypeId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_AcademicAchievements_RegistrationId] ON [PVS_AcademicAchievements] ([RegistrationId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberCareerAspirations_CareerOptionId] ON [PVS_MemberCareerAspirations] ([CareerOptionId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberCompetitiveExams_CompetitiveExamId] ON [PVS_MemberCompetitiveExams] ([CompetitiveExamId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberEducation_BoardId] ON [PVS_MemberEducation] ([BoardId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberEducation_BranchId] ON [PVS_MemberEducation] ([BranchId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberEducation_CourseId] ON [PVS_MemberEducation] ([CourseId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberEducation_EducationLevelId] ON [PVS_MemberEducation] ([EducationLevelId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberEducation_RegistrationId] ON [PVS_MemberEducation] ([RegistrationId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberHobbies_HobbyId] ON [PVS_MemberHobbies] ([HobbyId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberInterestAreas_InterestAreaId] ON [PVS_MemberInterestAreas] ([InterestAreaId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberSkills_SkillId] ON [PVS_MemberSkills] ([SkillId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    CREATE INDEX [PVS_IX_MemberSports_SportId] ON [PVS_MemberSports] ([SportId]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261009112325_MemberProfileListChoices'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261009112325_MemberProfileListChoices', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261010153650_AppBranding'
)
BEGIN
    CREATE TABLE [PVS_AppBranding] (
        [AppBrandingId] int NOT NULL,
        [SponsorName] nvarchar(150) NULL,
        [SponsorLogo] varbinary(max) NULL,
        [SponsorLogoContentType] varchar(30) NULL,
        [PoweredBy] nvarchar(150) NULL,
        [ModifiedDate] datetime2(3) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_AppBranding] PRIMARY KEY ([AppBrandingId]),
        CONSTRAINT [PVS_CK_AppBranding_Singleton] CHECK ([AppBrandingId] = 1)
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261010153650_AppBranding'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'AppBrandingId', N'ModifiedBy', N'ModifiedDate', N'PoweredBy', N'SponsorLogo', N'SponsorLogoContentType', N'SponsorName') AND [object_id] = OBJECT_ID(N'[PVS_AppBranding]'))
        SET IDENTITY_INSERT [PVS_AppBranding] ON;
    EXEC(N'INSERT INTO [PVS_AppBranding] ([AppBrandingId], [ModifiedBy], [ModifiedDate], [PoweredBy], [SponsorLogo], [SponsorLogoContentType], [SponsorName])
    VALUES (1, NULL, NULL, N''IQ Explore'', NULL, NULL, NULL)');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'AppBrandingId', N'ModifiedBy', N'ModifiedDate', N'PoweredBy', N'SponsorLogo', N'SponsorLogoContentType', N'SponsorName') AND [object_id] = OBJECT_ID(N'[PVS_AppBranding]'))
        SET IDENTITY_INSERT [PVS_AppBranding] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261010153650_AppBranding'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261010153650_AppBranding', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020142456_SponsorOrganisationAddress'
)
BEGIN
    ALTER TABLE [PVS_AppBranding] ADD [SponsorAddress] nvarchar(300) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020142456_SponsorOrganisationAddress'
)
BEGIN
    ALTER TABLE [PVS_AppBranding] ADD [SponsorOrganisation] nvarchar(150) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020142456_SponsorOrganisationAddress'
)
BEGIN
    EXEC(N'UPDATE [PVS_AppBranding] SET [SponsorAddress] = NULL, [SponsorOrganisation] = NULL
    WHERE [AppBrandingId] = 1;
    SELECT @@ROWCOUNT');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (
    SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020142456_SponsorOrganisationAddress'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261020142456_SponsorOrganisationAddress', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020153210_AppVersions'
)
BEGIN
    CREATE TABLE [PVS_AppVersions] (
        [Platform] varchar(20) NOT NULL,
        [LatestVersion] varchar(20) NOT NULL,
        [IsMandatory] bit NOT NULL,
        [StoreUrl] nvarchar(500) NULL,
        [ModifiedDate] datetime2(3) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_AppVersions] PRIMARY KEY ([Platform]),
        CONSTRAINT [PVS_CK_AppVersions_LatestVersion] CHECK ([LatestVersion] LIKE '[0-9]%.[0-9]%.[0-9]%' AND [LatestVersion] NOT LIKE '%[^0-9.]%'),
        CONSTRAINT [PVS_CK_AppVersions_Platform] CHECK ([Platform] IN ('android', 'ios'))
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020153210_AppVersions'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Platform', N'IsMandatory', N'LatestVersion', N'ModifiedBy', N'ModifiedDate', N'StoreUrl') AND [object_id] = OBJECT_ID(N'[PVS_AppVersions]'))
        SET IDENTITY_INSERT [PVS_AppVersions] ON;
    EXEC(N'INSERT INTO [PVS_AppVersions] ([Platform], [IsMandatory], [LatestVersion], [ModifiedBy], [ModifiedDate], [StoreUrl])
    VALUES (''android'', CAST(1 AS bit), ''1.0.0'', NULL, NULL, N''https://play.google.com/store/apps/details?id=org.padmashalividyasetu.padmashali_vidya_setu''),
    (''ios'', CAST(1 AS bit), ''1.0.0'', NULL, NULL, NULL)');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'Platform', N'IsMandatory', N'LatestVersion', N'ModifiedBy', N'ModifiedDate', N'StoreUrl') AND [object_id] = OBJECT_ID(N'[PVS_AppVersions]'))
        SET IDENTITY_INSERT [PVS_AppVersions] OFF;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020153210_AppVersions'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261020153210_AppVersions', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020155916_AdminPasswords'
)
BEGIN
    ALTER TABLE [PVS_Accounts] ADD [FailedPasswordAttempts] int NOT NULL CONSTRAINT [PVS_DF_Accounts_FailedPasswordAttempts] DEFAULT 0;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020155916_AdminPasswords'
)
BEGIN
    ALTER TABLE [PVS_Accounts] ADD [PasswordHash] varchar(200) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020155916_AdminPasswords'
)
BEGIN
    ALTER TABLE [PVS_Accounts] ADD [PasswordLockedUntil] datetime2(3) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020155916_AdminPasswords'
)
BEGIN
    ALTER TABLE [PVS_Accounts] ADD [PasswordSetDate] datetime2(3) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261020155916_AdminPasswords'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261020155916_AdminPasswords', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022042837_MemberMobileNumber'
)
BEGIN
    ALTER TABLE [PVS_PhoneVerificationChallenges] ADD [AccountId] int NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022042837_MemberMobileNumber'
)
BEGIN
    ALTER TABLE [PVS_PhoneVerificationChallenges] ADD [Purpose] varchar(20) NOT NULL CONSTRAINT [PVS_DF_PhoneVerificationChallenges_Purpose] DEFAULT 'SIGN_IN';
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022042837_MemberMobileNumber'
)
BEGIN
    ALTER TABLE [PVS_Members] ADD [MobileNumber] varchar(16) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022042837_MemberMobileNumber'
)
BEGIN
    ALTER TABLE [PVS_Members] ADD [MobileVerifiedDate] datetime2(3) NULL;
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022042837_MemberMobileNumber'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261022042837_MemberMobileNumber', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022044620_PushNotifications'
)
BEGIN
    CREATE TABLE [PVS_PushNotifications] (
        [PushNotificationId] int NOT NULL IDENTITY,
        [Title] nvarchar(65) NOT NULL,
        [Body] nvarchar(240) NOT NULL,
        [Topic] varchar(100) NOT NULL,
        [FcmMessageId] varchar(200) NULL,
        [SentDate] datetime2(3) NOT NULL,
        [SentBy] nvarchar(100) NULL,
        CONSTRAINT [PVS_PK_PushNotifications] PRIMARY KEY ([PushNotificationId])
    );
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022044620_PushNotifications'
)
BEGIN
    CREATE INDEX [PVS_IX_PushNotifications_SentDate] ON [PVS_PushNotifications] ([SentDate]);
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022044620_PushNotifications'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261022044620_PushNotifications', N'10.0.12');
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022051124_AndroidPackageName'
)
BEGIN
    UPDATE [PVS_AppVersions] SET [StoreUrl] = N'https://play.google.com/store/apps/details?id=com.vidyasethu.pvs' WHERE [Platform] = 'android' AND [StoreUrl] = N'https://play.google.com/store/apps/details?id=org.padmashalividyasetu.padmashali_vidya_setu';
END;
GO

IF @@TRANCOUNT = 0
BEGIN
    RAISERROR(N'PVS deployment STOPPED: an earlier step failed and everything was rolled back. Nothing was changed.', 16, 1);
    SET NOEXEC ON;
END;
IF NOT EXISTS (SELECT * FROM [PVS_EFMigrationsHistory]
    WHERE [MigrationId] = N'20261022051124_AndroidPackageName'
)
BEGIN
    INSERT INTO [PVS_EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261022051124_AndroidPackageName', N'10.0.12');
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