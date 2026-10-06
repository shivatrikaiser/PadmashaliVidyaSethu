IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Accounts] (
        [AccountId] int NOT NULL IDENTITY,
        [MobileNumber] varchar(16) NOT NULL,
        [MobileVerifiedDate] datetime2(3) NULL,
        [LastLoginDate] datetime2(3) NULL,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        CONSTRAINT [PK_Accounts] PRIMARY KEY ([AccountId]),
        CONSTRAINT [CK_Accounts_MobileNumber] CHECK ([MobileNumber] LIKE '+[1-9]%')
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [AchievementTypes] (
        [AchievementTypeId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_AchievementTypes] PRIMARY KEY ([AchievementTypeId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [AuditLogs] (
        [AuditLogId] bigint NOT NULL IDENTITY,
        [AccountId] int NULL,
        [Action] varchar(100) NOT NULL,
        [EntityName] varchar(100) NULL,
        [EntityKey] nvarchar(50) NULL,
        [Details] nvarchar(1000) NULL,
        [IpAddress] varchar(45) NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        CONSTRAINT [PK_AuditLogs] PRIMARY KEY ([AuditLogId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Boards] (
        [BoardId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Boards] PRIMARY KEY ([BoardId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Branches] (
        [BranchId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Branches] PRIMARY KEY ([BranchId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [CareerOptions] (
        [CareerOptionId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_CareerOptions] PRIMARY KEY ([CareerOptionId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Classes] (
        [ClassId] int NOT NULL IDENTITY,
        [Stage] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Classes] PRIMARY KEY ([ClassId]),
        CONSTRAINT [CK_Classes_Stage] CHECK ([Stage] IN ('PrePrimary', 'Primary', 'HighSchool', 'PreUniversity', 'Vocational', 'UnderGraduate', 'PostGraduate', 'Professional', 'Other'))
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [CommunicationChannels] (
        [CommunicationChannelId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_CommunicationChannels] PRIMARY KEY ([CommunicationChannelId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [CommunicationTopics] (
        [CommunicationTopicId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_CommunicationTopics] PRIMARY KEY ([CommunicationTopicId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [CompetitiveExams] (
        [CompetitiveExamId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_CompetitiveExams] PRIMARY KEY ([CompetitiveExamId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Countries] (
        [CountryId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Countries] PRIMARY KEY ([CountryId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Courses] (
        [CourseId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Courses] PRIMARY KEY ([CourseId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [DisabilityTypes] (
        [DisabilityTypeId] int NOT NULL IDENTITY,
        [IsUserSubmitted] bit NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_DisabilityTypes] PRIMARY KEY ([DisabilityTypeId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [EducationLevels] (
        [EducationLevelId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_EducationLevels] PRIMARY KEY ([EducationLevelId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Genders] (
        [GenderId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Genders] PRIMARY KEY ([GenderId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Hobbies] (
        [HobbyId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Hobbies] PRIMARY KEY ([HobbyId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [InterestAreas] (
        [InterestAreaId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_InterestAreas] PRIMARY KEY ([InterestAreaId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [MemberStatuses] (
        [MemberStatusId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_MemberStatuses] PRIMARY KEY ([MemberStatusId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Organisations] (
        [OrganisationId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [OrganisationName] nvarchar(150) NOT NULL,
        [OrganisationCode] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Organisations] PRIMARY KEY ([OrganisationId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [PhoneVerificationChallenges] (
        [ChallengeId] uniqueidentifier NOT NULL,
        [MobileNumber] varchar(16) NOT NULL,
        [CodeHash] char(64) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        [ExpiresDate] datetime2(3) NOT NULL,
        [FailedAttemptCount] int NOT NULL,
        [VerifiedDate] datetime2(3) NULL,
        [RequestIp] varchar(45) NULL,
        CONSTRAINT [PK_PhoneVerificationChallenges] PRIMARY KEY ([ChallengeId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Roles] (
        [RoleId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Roles] PRIMARY KEY ([RoleId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Skills] (
        [SkillId] int NOT NULL IDENTITY,
        [Category] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Skills] PRIMARY KEY ([SkillId]),
        CONSTRAINT [CK_Skills_Category] CHECK ([Category] IN ('Technical', 'General', 'Creative'))
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Sports] (
        [SportId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Sports] PRIMARY KEY ([SportId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Temples] (
        [TempleId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [TempleName] nvarchar(150) NOT NULL,
        [TempleCode] varchar(2) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Temples] PRIMARY KEY ([TempleId]),
        CONSTRAINT [CK_Temples_TempleCode] CHECK ([TempleCode] LIKE '[0-9][0-9]')
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Universities] (
        [UniversityId] int NOT NULL IDENTITY,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Universities] PRIMARY KEY ([UniversityId])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [RefreshTokens] (
        [RefreshTokenId] bigint NOT NULL IDENTITY,
        [AccountId] int NOT NULL,
        [TokenHash] char(64) NOT NULL,
        [ExpiresDate] datetime2(3) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        [CreatedByIp] varchar(45) NULL,
        [RevokedDate] datetime2(3) NULL,
        [ReplacedByTokenHash] char(64) NULL,
        CONSTRAINT [PK_RefreshTokens] PRIMARY KEY ([RefreshTokenId]),
        CONSTRAINT [FK_RefreshTokens_Accounts_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [Accounts] ([AccountId]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [States] (
        [StateId] int NOT NULL IDENTITY,
        [CountryId] int NOT NULL,
        [PostalName] nvarchar(150) NULL,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_States] PRIMARY KEY ([StateId]),
        CONSTRAINT [FK_States_Countries_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [Countries] ([CountryId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [AccountRoles] (
        [AccountId] int NOT NULL,
        [RoleId] int NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PK_AccountRoles] PRIMARY KEY ([AccountId], [RoleId]),
        CONSTRAINT [FK_AccountRoles_Accounts_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [Accounts] ([AccountId]) ON DELETE CASCADE,
        CONSTRAINT [FK_AccountRoles_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Roles] ([RoleId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Members] (
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
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        CONSTRAINT [PK_Members] PRIMARY KEY ([RegistrationId]),
        CONSTRAINT [CK_Members_ClassOrHighestEducation] CHECK ([ClassId] IS NULL OR [HighestEducationLevelId] IS NULL),
        CONSTRAINT [CK_Members_RegistrationId] CHECK ([RegistrationId] LIKE 'PVS-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
        CONSTRAINT [FK_Members_Accounts_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [Accounts] ([AccountId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Members_Classes_ClassId] FOREIGN KEY ([ClassId]) REFERENCES [Classes] ([ClassId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Members_EducationLevels_HighestEducationLevelId] FOREIGN KEY ([HighestEducationLevelId]) REFERENCES [EducationLevels] ([EducationLevelId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Members_Genders_GenderId] FOREIGN KEY ([GenderId]) REFERENCES [Genders] ([GenderId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Members_MemberStatuses_MemberStatusId] FOREIGN KEY ([MemberStatusId]) REFERENCES [MemberStatuses] ([MemberStatusId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Members_Organisations_OrganisationId] FOREIGN KEY ([OrganisationId]) REFERENCES [Organisations] ([OrganisationId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Members_Temples_TempleId] FOREIGN KEY ([TempleId]) REFERENCES [Temples] ([TempleId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [TempleRegistrationSequences] (
        [TempleId] int NOT NULL,
        [LastSequenceNumber] int NOT NULL,
        CONSTRAINT [PK_TempleRegistrationSequences] PRIMARY KEY ([TempleId]),
        CONSTRAINT [CK_TempleRegistrationSequences_Range] CHECK ([LastSequenceNumber] BETWEEN 0 AND 9999),
        CONSTRAINT [FK_TempleRegistrationSequences_Temples_TempleId] FOREIGN KEY ([TempleId]) REFERENCES [Temples] ([TempleId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Districts] (
        [DistrictId] int NOT NULL IDENTITY,
        [StateId] int NOT NULL,
        [PostalName] nvarchar(150) NULL,
        [Source] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Districts] PRIMARY KEY ([DistrictId]),
        CONSTRAINT [FK_Districts_States_StateId] FOREIGN KEY ([StateId]) REFERENCES [States] ([StateId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [ConsentRecords] (
        [ConsentRecordId] bigint NOT NULL IDENTITY,
        [AccountId] int NOT NULL,
        [RegistrationId] char(11) NULL,
        [ConsentType] varchar(40) NOT NULL,
        [PolicyVersion] varchar(20) NOT NULL,
        [IsGranted] bit NOT NULL,
        [RecordedDate] datetime2(3) NOT NULL,
        [IpAddress] varchar(45) NULL,
        CONSTRAINT [PK_ConsentRecords] PRIMARY KEY ([ConsentRecordId]),
        CONSTRAINT [FK_ConsentRecords_Accounts_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [Accounts] ([AccountId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_ConsentRecords_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [Members] ([RegistrationId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [MemberDisabilities] (
        [RegistrationId] char(11) NOT NULL,
        [DisabilityTypeId] int NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL,
        [CreatedBy] nvarchar(100) NULL,
        CONSTRAINT [PK_MemberDisabilities] PRIMARY KEY ([RegistrationId], [DisabilityTypeId]),
        CONSTRAINT [FK_MemberDisabilities_DisabilityTypes_DisabilityTypeId] FOREIGN KEY ([DisabilityTypeId]) REFERENCES [DisabilityTypes] ([DisabilityTypeId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_MemberDisabilities_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [Members] ([RegistrationId]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Taluks] (
        [TalukId] int NOT NULL IDENTITY,
        [DistrictId] int NOT NULL,
        [PostalName] nvarchar(150) NULL,
        [Source] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Taluks] PRIMARY KEY ([TalukId]),
        CONSTRAINT [FK_Taluks_Districts_DistrictId] FOREIGN KEY ([DistrictId]) REFERENCES [Districts] ([DistrictId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [Cities] (
        [CityId] int NOT NULL IDENTITY,
        [PinCode] char(6) NOT NULL,
        [DistrictId] int NOT NULL,
        [TalukId] int NULL,
        [Source] varchar(20) NOT NULL,
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        [Name] nvarchar(150) NOT NULL,
        [Code] varchar(60) NOT NULL,
        [DisplayOrder] int NOT NULL,
        CONSTRAINT [PK_Cities] PRIMARY KEY ([CityId]),
        CONSTRAINT [CK_Cities_PinCode] CHECK ([PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]'),
        CONSTRAINT [FK_Cities_Districts_DistrictId] FOREIGN KEY ([DistrictId]) REFERENCES [Districts] ([DistrictId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Cities_Taluks_TalukId] FOREIGN KEY ([TalukId]) REFERENCES [Taluks] ([TalukId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE TABLE [MemberAddresses] (
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
        [CreatedDate] datetime2(3) NOT NULL DEFAULT (SYSUTCDATETIME()),
        [ModifiedDate] datetime2(3) NULL,
        [CreatedBy] nvarchar(100) NULL,
        [ModifiedBy] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT CAST(1 AS bit),
        CONSTRAINT [PK_MemberAddresses] PRIMARY KEY ([MemberAddressId]),
        CONSTRAINT [CK_MemberAddresses_AddressType] CHECK ([AddressType] IN ('Permanent', 'Current')),
        CONSTRAINT [CK_MemberAddresses_PinCode] CHECK ([PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]'),
        CONSTRAINT [FK_MemberAddresses_Cities_CityId] FOREIGN KEY ([CityId]) REFERENCES [Cities] ([CityId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_MemberAddresses_Countries_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [Countries] ([CountryId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_MemberAddresses_Districts_DistrictId] FOREIGN KEY ([DistrictId]) REFERENCES [Districts] ([DistrictId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_MemberAddresses_Members_RegistrationId] FOREIGN KEY ([RegistrationId]) REFERENCES [Members] ([RegistrationId]) ON DELETE CASCADE,
        CONSTRAINT [FK_MemberAddresses_States_StateId] FOREIGN KEY ([StateId]) REFERENCES [States] ([StateId]) ON DELETE NO ACTION,
        CONSTRAINT [FK_MemberAddresses_Taluks_TalukId] FOREIGN KEY ([TalukId]) REFERENCES [Taluks] ([TalukId]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'AchievementTypeId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[AchievementTypes]'))
        SET IDENTITY_INSERT [AchievementTypes] ON;
    EXEC(N'INSERT INTO [AchievementTypes] ([AchievementTypeId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'AchievementTypeId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[AchievementTypes]'))
        SET IDENTITY_INSERT [AchievementTypes] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'BoardId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Boards]'))
        SET IDENTITY_INSERT [Boards] ON;
    EXEC(N'INSERT INTO [Boards] ([BoardId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''KSEAB'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Karnataka State Board (KSEAB)''),
    (2, ''KA_PU'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Karnataka Pre-University Board''),
    (3, ''CBSE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''CBSE''),
    (4, ''CISCE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''ICSE / ISC (CISCE)''),
    (5, ''NIOS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''NIOS''),
    (6, ''IB'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''International Baccalaureate (IB)''),
    (7, ''CAMBRIDGE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Cambridge (IGCSE / A-Level)''),
    (8, ''OTHER_STATE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Other State Board''),
    (9, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'BoardId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Boards]'))
        SET IDENTITY_INSERT [Boards] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'BranchId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Branches]'))
        SET IDENTITY_INSERT [Branches] ON;
    EXEC(N'INSERT INTO [Branches] ([BranchId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'BranchId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Branches]'))
        SET IDENTITY_INSERT [Branches] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CareerOptionId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[CareerOptions]'))
        SET IDENTITY_INSERT [CareerOptions] ON;
    EXEC(N'INSERT INTO [CareerOptions] ([CareerOptionId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CareerOptionId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[CareerOptions]'))
        SET IDENTITY_INSERT [CareerOptions] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'ClassId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'Stage') AND [object_id] = OBJECT_ID(N'[Classes]'))
        SET IDENTITY_INSERT [Classes] ON;
    EXEC(N'INSERT INTO [Classes] ([ClassId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name], [Stage])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'ClassId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'Stage') AND [object_id] = OBJECT_ID(N'[Classes]'))
        SET IDENTITY_INSERT [Classes] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CommunicationChannelId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[CommunicationChannels]'))
        SET IDENTITY_INSERT [CommunicationChannels] ON;
    EXEC(N'INSERT INTO [CommunicationChannels] ([CommunicationChannelId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''WHATSAPP'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''WhatsApp''),
    (2, ''SMS'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''SMS''),
    (3, ''EMAIL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Email''),
    (4, ''APP'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''App Notifications'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CommunicationChannelId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[CommunicationChannels]'))
        SET IDENTITY_INSERT [CommunicationChannels] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CommunicationTopicId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[CommunicationTopics]'))
        SET IDENTITY_INSERT [CommunicationTopics] ON;
    EXEC(N'INSERT INTO [CommunicationTopics] ([CommunicationTopicId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CommunicationTopicId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[CommunicationTopics]'))
        SET IDENTITY_INSERT [CommunicationTopics] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CompetitiveExamId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[CompetitiveExams]'))
        SET IDENTITY_INSERT [CompetitiveExams] ON;
    EXEC(N'INSERT INTO [CompetitiveExams] ([CompetitiveExamId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CompetitiveExamId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[CompetitiveExams]'))
        SET IDENTITY_INSERT [CompetitiveExams] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CountryId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Countries]'))
        SET IDENTITY_INSERT [Countries] ON;
    EXEC(N'INSERT INTO [Countries] ([CountryId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CountryId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Countries]'))
        SET IDENTITY_INSERT [Countries] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourseId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Courses]'))
        SET IDENTITY_INSERT [Courses] ON;
    EXEC(N'INSERT INTO [Courses] ([CourseId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'CourseId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Courses]'))
        SET IDENTITY_INSERT [Courses] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'DisabilityTypeId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'IsUserSubmitted', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[DisabilityTypes]'))
        SET IDENTITY_INSERT [DisabilityTypes] ON;
    EXEC(N'INSERT INTO [DisabilityTypes] ([DisabilityTypeId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [IsUserSubmitted], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''VISUAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Visual Impairment''),
    (2, ''HEARING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Hearing Impairment''),
    (3, ''SPEECH_LANGUAGE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Speech/Language Impairment''),
    (4, ''PHYSICAL_MOBILITY'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Physical/Mobility Impairment''),
    (5, ''INTELLECTUAL'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Intellectual Disability''),
    (6, ''SPECIFIC_LEARNING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Specific Learning Disability''),
    (7, ''MULTIPLE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Multiple Disabilities''),
    (8, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), CAST(0 AS bit), NULL, NULL, N''Other'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'DisabilityTypeId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'IsUserSubmitted', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[DisabilityTypes]'))
        SET IDENTITY_INSERT [DisabilityTypes] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'EducationLevelId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[EducationLevels]'))
        SET IDENTITY_INSERT [EducationLevels] ON;
    EXEC(N'INSERT INTO [EducationLevels] ([EducationLevelId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'EducationLevelId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[EducationLevels]'))
        SET IDENTITY_INSERT [EducationLevels] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'GenderId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Genders]'))
        SET IDENTITY_INSERT [Genders] ON;
    EXEC(N'INSERT INTO [Genders] ([GenderId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''MALE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Male''),
    (2, ''FEMALE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Female''),
    (3, ''OTHER'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Other / Prefer not to say'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'GenderId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Genders]'))
        SET IDENTITY_INSERT [Genders] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'HobbyId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Hobbies]'))
        SET IDENTITY_INSERT [Hobbies] ON;
    EXEC(N'INSERT INTO [Hobbies] ([HobbyId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'HobbyId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Hobbies]'))
        SET IDENTITY_INSERT [Hobbies] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'InterestAreaId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[InterestAreas]'))
        SET IDENTITY_INSERT [InterestAreas] ON;
    EXEC(N'INSERT INTO [InterestAreas] ([InterestAreaId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'InterestAreaId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[InterestAreas]'))
        SET IDENTITY_INSERT [InterestAreas] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'MemberStatusId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[MemberStatuses]'))
        SET IDENTITY_INSERT [MemberStatuses] ON;
    EXEC(N'INSERT INTO [MemberStatuses] ([MemberStatusId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
    VALUES (1, ''STUDENT'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Student''),
    (2, ''WORKING'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Working''),
    (3, ''UNEMPLOYED'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Unemployed'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'MemberStatusId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[MemberStatuses]'))
        SET IDENTITY_INSERT [MemberStatuses] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'OrganisationId', N'OrganisationCode', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'OrganisationName') AND [object_id] = OBJECT_ID(N'[Organisations]'))
        SET IDENTITY_INSERT [Organisations] ON;
    EXEC(N'INSERT INTO [Organisations] ([OrganisationId], [OrganisationCode], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [OrganisationName])
    VALUES (1, ''DK'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''DK District''),
    (2, ''MUMBAI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Mumbai''),
    (3, ''BANGALORE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Bangalore''),
    (4, ''DUBAI'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Dubai''),
    (5, ''SHIMOGA'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Shimoga''),
    (6, ''NONE'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Not Linked to Any Organisation'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'OrganisationId', N'OrganisationCode', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'OrganisationName') AND [object_id] = OBJECT_ID(N'[Organisations]'))
        SET IDENTITY_INSERT [Organisations] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'RoleId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Roles]'))
        SET IDENTITY_INSERT [Roles] ON;
    EXEC(N'INSERT INTO [Roles] ([RoleId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'RoleId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Roles]'))
        SET IDENTITY_INSERT [Roles] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'SkillId', N'Category', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Skills]'))
        SET IDENTITY_INSERT [Skills] ON;
    EXEC(N'INSERT INTO [Skills] ([SkillId], [Category], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'SkillId', N'Category', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Skills]'))
        SET IDENTITY_INSERT [Skills] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'SportId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Sports]'))
        SET IDENTITY_INSERT [Sports] ON;
    EXEC(N'INSERT INTO [Sports] ([SportId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'SportId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Sports]'))
        SET IDENTITY_INSERT [Sports] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TempleId', N'TempleCode', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'TempleName') AND [object_id] = OBJECT_ID(N'[Temples]'))
        SET IDENTITY_INSERT [Temples] ON;
    EXEC(N'INSERT INTO [Temples] ([TempleId], [TempleCode], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [TempleName])
    VALUES (1, ''01'', N''seed'', ''2026-10-06T00:00:00.000Z'', 10, CAST(1 AS bit), NULL, NULL, N''Temple 01 (Placeholder - update name)''),
    (2, ''02'', N''seed'', ''2026-10-06T00:00:00.000Z'', 20, CAST(1 AS bit), NULL, NULL, N''Temple 02 (Placeholder - update name)''),
    (3, ''03'', N''seed'', ''2026-10-06T00:00:00.000Z'', 30, CAST(1 AS bit), NULL, NULL, N''Temple 03 (Placeholder - update name)''),
    (4, ''04'', N''seed'', ''2026-10-06T00:00:00.000Z'', 40, CAST(1 AS bit), NULL, NULL, N''Temple 04 (Placeholder - update name)''),
    (5, ''05'', N''seed'', ''2026-10-06T00:00:00.000Z'', 50, CAST(1 AS bit), NULL, NULL, N''Temple 05 (Placeholder - update name)''),
    (6, ''06'', N''seed'', ''2026-10-06T00:00:00.000Z'', 60, CAST(1 AS bit), NULL, NULL, N''Temple 06 (Placeholder - update name)''),
    (7, ''07'', N''seed'', ''2026-10-06T00:00:00.000Z'', 70, CAST(1 AS bit), NULL, NULL, N''Temple 07 (Placeholder - update name)''),
    (8, ''08'', N''seed'', ''2026-10-06T00:00:00.000Z'', 80, CAST(1 AS bit), NULL, NULL, N''Temple 08 (Placeholder - update name)''),
    (9, ''09'', N''seed'', ''2026-10-06T00:00:00.000Z'', 90, CAST(1 AS bit), NULL, NULL, N''Temple 09 (Placeholder - update name)''),
    (10, ''10'', N''seed'', ''2026-10-06T00:00:00.000Z'', 100, CAST(1 AS bit), NULL, NULL, N''Temple 10 (Placeholder - update name)''),
    (11, ''11'', N''seed'', ''2026-10-06T00:00:00.000Z'', 110, CAST(1 AS bit), NULL, NULL, N''Temple 11 (Placeholder - update name)''),
    (12, ''12'', N''seed'', ''2026-10-06T00:00:00.000Z'', 120, CAST(1 AS bit), NULL, NULL, N''Temple 12 (Placeholder - update name)''),
    (13, ''13'', N''seed'', ''2026-10-06T00:00:00.000Z'', 130, CAST(1 AS bit), NULL, NULL, N''Temple 13 (Placeholder - update name)''),
    (14, ''14'', N''seed'', ''2026-10-06T00:00:00.000Z'', 140, CAST(1 AS bit), NULL, NULL, N''Temple 14 (Placeholder - update name)''),
    (15, ''15'', N''seed'', ''2026-10-06T00:00:00.000Z'', 150, CAST(1 AS bit), NULL, NULL, N''Temple 15 (Placeholder - update name)''),
    (16, ''16'', N''seed'', ''2026-10-06T00:00:00.000Z'', 160, CAST(1 AS bit), NULL, NULL, N''Temple 16 (Placeholder - update name)'')');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TempleId', N'TempleCode', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'TempleName') AND [object_id] = OBJECT_ID(N'[Temples]'))
        SET IDENTITY_INSERT [Temples] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'UniversityId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Universities]'))
        SET IDENTITY_INSERT [Universities] ON;
    EXEC(N'INSERT INTO [Universities] ([UniversityId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'UniversityId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name') AND [object_id] = OBJECT_ID(N'[Universities]'))
        SET IDENTITY_INSERT [Universities] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'StateId', N'Code', N'CountryId', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName') AND [object_id] = OBJECT_ID(N'[States]'))
        SET IDENTITY_INSERT [States] ON;
    EXEC(N'INSERT INTO [States] ([StateId], [Code], [CountryId], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name], [PostalName])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'StateId', N'Code', N'CountryId', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName') AND [object_id] = OBJECT_ID(N'[States]'))
        SET IDENTITY_INSERT [States] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TempleId', N'LastSequenceNumber') AND [object_id] = OBJECT_ID(N'[TempleRegistrationSequences]'))
        SET IDENTITY_INSERT [TempleRegistrationSequences] ON;
    EXEC(N'INSERT INTO [TempleRegistrationSequences] ([TempleId], [LastSequenceNumber])
    VALUES (1, 0),
    (2, 0),
    (3, 0),
    (4, 0),
    (5, 0),
    (6, 0),
    (7, 0),
    (8, 0),
    (9, 0),
    (10, 0),
    (11, 0),
    (12, 0),
    (13, 0),
    (14, 0),
    (15, 0),
    (16, 0)');
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TempleId', N'LastSequenceNumber') AND [object_id] = OBJECT_ID(N'[TempleRegistrationSequences]'))
        SET IDENTITY_INSERT [TempleRegistrationSequences] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'DistrictId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName', N'Source', N'StateId') AND [object_id] = OBJECT_ID(N'[Districts]'))
        SET IDENTITY_INSERT [Districts] ON;
    EXEC(N'INSERT INTO [Districts] ([DistrictId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [IsActive], [ModifiedBy], [ModifiedDate], [Name], [PostalName], [Source], [StateId])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'DistrictId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName', N'Source', N'StateId') AND [object_id] = OBJECT_ID(N'[Districts]'))
        SET IDENTITY_INSERT [Districts] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TalukId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'DistrictId', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName', N'Source') AND [object_id] = OBJECT_ID(N'[Taluks]'))
        SET IDENTITY_INSERT [Taluks] ON;
    EXEC(N'INSERT INTO [Taluks] ([TalukId], [Code], [CreatedBy], [CreatedDate], [DisplayOrder], [DistrictId], [IsActive], [ModifiedBy], [ModifiedDate], [Name], [PostalName], [Source])
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
    IF EXISTS (SELECT * FROM [sys].[identity_columns] WHERE [name] IN (N'TalukId', N'Code', N'CreatedBy', N'CreatedDate', N'DisplayOrder', N'DistrictId', N'IsActive', N'ModifiedBy', N'ModifiedDate', N'Name', N'PostalName', N'Source') AND [object_id] = OBJECT_ID(N'[Taluks]'))
        SET IDENTITY_INSERT [Taluks] OFF;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_AccountRoles_RoleId] ON [AccountRoles] ([RoleId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Accounts_MobileNumber] ON [Accounts] ([MobileNumber]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_AchievementTypes_Code] ON [AchievementTypes] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_AchievementTypes_IsActive_DisplayOrder] ON [AchievementTypes] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_AchievementTypes_Name] ON [AchievementTypes] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_AuditLogs_AccountId_CreatedDate] ON [AuditLogs] ([AccountId], [CreatedDate]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_AuditLogs_CreatedDate] ON [AuditLogs] ([CreatedDate]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Boards_Code] ON [Boards] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Boards_IsActive_DisplayOrder] ON [Boards] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Boards_Name] ON [Boards] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Branches_Code] ON [Branches] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Branches_IsActive_DisplayOrder] ON [Branches] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Branches_Name] ON [Branches] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CareerOptions_Code] ON [CareerOptions] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_CareerOptions_IsActive_DisplayOrder] ON [CareerOptions] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CareerOptions_Name] ON [CareerOptions] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Cities_Code] ON [Cities] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Cities_DistrictId] ON [Cities] ([DistrictId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Cities_IsActive_DisplayOrder] ON [Cities] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Cities_PinCode_Name] ON [Cities] ([PinCode], [Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Cities_TalukId] ON [Cities] ([TalukId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Classes_Code] ON [Classes] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Classes_IsActive_DisplayOrder] ON [Classes] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Classes_Name] ON [Classes] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CommunicationChannels_Code] ON [CommunicationChannels] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_CommunicationChannels_IsActive_DisplayOrder] ON [CommunicationChannels] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CommunicationChannels_Name] ON [CommunicationChannels] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CommunicationTopics_Code] ON [CommunicationTopics] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_CommunicationTopics_IsActive_DisplayOrder] ON [CommunicationTopics] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CommunicationTopics_Name] ON [CommunicationTopics] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CompetitiveExams_Code] ON [CompetitiveExams] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_CompetitiveExams_IsActive_DisplayOrder] ON [CompetitiveExams] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_CompetitiveExams_Name] ON [CompetitiveExams] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_ConsentRecords_AccountId_ConsentType] ON [ConsentRecords] ([AccountId], [ConsentType]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_ConsentRecords_RegistrationId] ON [ConsentRecords] ([RegistrationId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Countries_Code] ON [Countries] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Countries_IsActive_DisplayOrder] ON [Countries] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Countries_Name] ON [Countries] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Courses_Code] ON [Courses] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Courses_IsActive_DisplayOrder] ON [Courses] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Courses_Name] ON [Courses] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_DisabilityTypes_Code] ON [DisabilityTypes] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_DisabilityTypes_IsActive_DisplayOrder] ON [DisabilityTypes] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_DisabilityTypes_Name] ON [DisabilityTypes] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Districts_Code] ON [Districts] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Districts_IsActive_DisplayOrder] ON [Districts] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Districts_StateId_Name] ON [Districts] ([StateId], [Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_EducationLevels_Code] ON [EducationLevels] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_EducationLevels_IsActive_DisplayOrder] ON [EducationLevels] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_EducationLevels_Name] ON [EducationLevels] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Genders_Code] ON [Genders] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Genders_IsActive_DisplayOrder] ON [Genders] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Genders_Name] ON [Genders] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Hobbies_Code] ON [Hobbies] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Hobbies_IsActive_DisplayOrder] ON [Hobbies] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Hobbies_Name] ON [Hobbies] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_InterestAreas_Code] ON [InterestAreas] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_InterestAreas_IsActive_DisplayOrder] ON [InterestAreas] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_InterestAreas_Name] ON [InterestAreas] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_MemberAddresses_CityId] ON [MemberAddresses] ([CityId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_MemberAddresses_CountryId] ON [MemberAddresses] ([CountryId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_MemberAddresses_DistrictId_TalukId] ON [MemberAddresses] ([DistrictId], [TalukId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_MemberAddresses_PinCode] ON [MemberAddresses] ([PinCode]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_MemberAddresses_RegistrationId_AddressType] ON [MemberAddresses] ([RegistrationId], [AddressType]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_MemberAddresses_StateId] ON [MemberAddresses] ([StateId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_MemberAddresses_TalukId] ON [MemberAddresses] ([TalukId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_MemberDisabilities_DisabilityTypeId] ON [MemberDisabilities] ([DisabilityTypeId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Members_AccountId] ON [Members] ([AccountId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Members_ClassId] ON [Members] ([ClassId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Members_DateOfBirth] ON [Members] ([DateOfBirth]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Members_GenderId] ON [Members] ([GenderId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Members_HighestEducationLevelId] ON [Members] ([HighestEducationLevelId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Members_MemberStatusId_ClassId] ON [Members] ([MemberStatusId], [ClassId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Members_OrganisationId] ON [Members] ([OrganisationId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Members_TempleId] ON [Members] ([TempleId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_MemberStatuses_Code] ON [MemberStatuses] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_MemberStatuses_IsActive_DisplayOrder] ON [MemberStatuses] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_MemberStatuses_Name] ON [MemberStatuses] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Organisations_IsActive_DisplayOrder] ON [Organisations] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Organisations_OrganisationCode] ON [Organisations] ([OrganisationCode]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Organisations_OrganisationName] ON [Organisations] ([OrganisationName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_PhoneVerificationChallenges_MobileNumber_CreatedDate] ON [PhoneVerificationChallenges] ([MobileNumber], [CreatedDate]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_RefreshTokens_AccountId] ON [RefreshTokens] ([AccountId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_RefreshTokens_TokenHash] ON [RefreshTokens] ([TokenHash]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Roles_Code] ON [Roles] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Roles_IsActive_DisplayOrder] ON [Roles] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Roles_Name] ON [Roles] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Skills_Category_IsActive_DisplayOrder] ON [Skills] ([Category], [IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Skills_Code] ON [Skills] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Skills_IsActive_DisplayOrder] ON [Skills] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Skills_Name] ON [Skills] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Sports_Code] ON [Sports] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Sports_IsActive_DisplayOrder] ON [Sports] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Sports_Name] ON [Sports] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_States_Code] ON [States] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_States_CountryId_Name] ON [States] ([CountryId], [Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_States_IsActive_DisplayOrder] ON [States] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Taluks_Code] ON [Taluks] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Taluks_DistrictId_Name] ON [Taluks] ([DistrictId], [Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Taluks_IsActive_DisplayOrder] ON [Taluks] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Temples_IsActive_DisplayOrder] ON [Temples] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Temples_TempleCode] ON [Temples] ([TempleCode]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Temples_TempleName] ON [Temples] ([TempleName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Universities_Code] ON [Universities] ([Code]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE INDEX [IX_Universities_IsActive_DisplayOrder] ON [Universities] ([IsActive], [DisplayOrder]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    CREATE UNIQUE INDEX [IX_Universities_Name] ON [Universities] ([Name]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006083334_InitialFoundation'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261006083334_InitialFoundation', N'10.0.12');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 6;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 7;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 8;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 9;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 10;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 11;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 12;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 13;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 14;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 15;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [TempleRegistrationSequences]
    WHERE [TempleId] = 16;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 6;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 7;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 8;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 9;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 10;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 11;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 12;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 13;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 14;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 15;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'DELETE FROM [Temples]
    WHERE [TempleId] = 16;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    DROP INDEX [IX_Temples_TempleName] ON [Temples];
    DECLARE @var nvarchar(max);
    SELECT @var = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Temples]') AND [c].[name] = N'TempleName');
    IF @var IS NOT NULL EXEC(N'ALTER TABLE [Temples] DROP CONSTRAINT ' + @var + ';');
    ALTER TABLE [Temples] ALTER COLUMN [TempleName] nvarchar(200) NOT NULL;
    CREATE UNIQUE INDEX [IX_Temples_TempleName] ON [Temples] ([TempleName]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'UPDATE [Temples] SET [TempleName] = N''Barkur''
    WHERE [TempleId] = 1;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'UPDATE [Temples] SET [TempleName] = N''Mangaluru''
    WHERE [TempleId] = 2;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'UPDATE [Temples] SET [TempleName] = N''Kallianapura''
    WHERE [TempleId] = 3;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'UPDATE [Temples] SET [TempleName] = N''Salikeri''
    WHERE [TempleId] = 4;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    EXEC(N'UPDATE [Temples] SET [TempleName] = N''Kinnimulky''
    WHERE [TempleId] = 5;
    SELECT @@ROWCOUNT');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20261006114313_TemplesAndSmsVerification'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20261006114313_TemplesAndSmsVerification', N'10.0.12');
END;

COMMIT;
GO

