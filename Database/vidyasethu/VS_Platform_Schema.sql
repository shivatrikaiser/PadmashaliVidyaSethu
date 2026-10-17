/*
===============================================================================================================
 VidyaSethu platform - public organization listings and enquiries                            (PLANNED - NOT IN USE)
===============================================================================================================
 Purpose
   Future home of the public organization directory shown on https://vidyasethu.co.in, once a secured
   platform-administration backend replaces the version-controlled file
   Frontend/VidyaSethuWeb/src/app/organizations/organizations.data.ts.
   Columns mirror that file's Organization model one-to-one.

 Where to run it
   * In a SEPARATE VidyaSethu platform database (e.g. "VidyaSethuPlatform") - NOT in the Padmashali Vidya Sethu
     database. VS_Organization is unrelated to any PVS_* table; PVS member data never moves here.
   * Nothing in the repository applies this script and the public website does not read these tables yet.
   * Idempotent: safe to run more than once. Review before running on any shared server.

 Naming
   Every object starts with VS_ (tables, keys, constraints, indexes), like PVS_ in the PVS database.
===============================================================================================================
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

---------------------------------------------------------------------------------------------------------------
-- VS_Organization: one row per organization listed (or prepared for listing) on the public website.
---------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.VS_Organization', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.VS_Organization
    (
        OrganizationId        NVARCHAR(50)   NOT NULL,   -- stable identifier, e.g. 'pvs'
        Slug                  NVARCHAR(100)  NOT NULL,   -- /organizations/{slug}
        DisplayName           NVARCHAR(200)  NOT NULL,
        DisplayNameKn         NVARCHAR(200)  NULL,       -- Kannada (optional; English is the fallback)
        OperatedBy            NVARCHAR(200)  NULL,
        Description           NVARCHAR(1000) NOT NULL,
        DescriptionKn         NVARCHAR(1000) NULL,
        Category              NVARCHAR(40)   NOT NULL,
        Status                NVARCHAR(20)   NOT NULL CONSTRAINT VS_DF_Organization_Status DEFAULT (N'unlisted'),
        DisplayOrder          INT            NOT NULL CONSTRAINT VS_DF_Organization_DisplayOrder DEFAULT (100),
        LogoPath              NVARCHAR(300)  NULL,       -- site-relative, e.g. organizations/{slug}/logo.jpg
        LogoAlt               NVARCHAR(200)  NULL,
        ApplicationUrl        NVARCHAR(500)  NULL,       -- null = portal not available yet
        RegistrationUrl       NVARCHAR(500)  NULL,
        ScholarshipsUrl       NVARCHAR(500)  NULL,
        JobsUrl               NVARCHAR(500)  NULL,
        ShowApplicationLink   BIT            NOT NULL CONSTRAINT VS_DF_Organization_ShowApplicationLink DEFAULT (0),
        ShowRegistrationLink  BIT            NOT NULL CONSTRAINT VS_DF_Organization_ShowRegistrationLink DEFAULT (0),
        ShowScholarshipsLink  BIT            NOT NULL CONSTRAINT VS_DF_Organization_ShowScholarshipsLink DEFAULT (0),
        ShowJobsLink          BIT            NOT NULL CONSTRAINT VS_DF_Organization_ShowJobsLink DEFAULT (0),
        PublicEmail           NVARCHAR(254)  NULL,       -- only details the organization approved for publication
        PublicPhone           NVARCHAR(30)   NULL,
        PublicWebsite         NVARCHAR(500)  NULL,
        PublicAddress         NVARCHAR(500)  NULL,
        UseOwnBranding        BIT            NOT NULL CONSTRAINT VS_DF_Organization_UseOwnBranding DEFAULT (0),
        PrimaryColor          CHAR(7)        NULL,       -- #rrggbb
        AccentColor           CHAR(7)        NULL,
        CreatedDate           DATETIME2(0)   NOT NULL CONSTRAINT VS_DF_Organization_CreatedDate DEFAULT (SYSUTCDATETIME()),
        ModifiedDate          DATETIME2(0)   NULL,

        CONSTRAINT VS_PK_Organization PRIMARY KEY (OrganizationId),
        CONSTRAINT VS_AK_Organization_Slug UNIQUE (Slug),
        CONSTRAINT VS_CK_Organization_Slug CHECK (Slug NOT LIKE N'%[^a-z0-9-]%' AND Slug NOT LIKE N'-%' AND Slug NOT LIKE N'%-'),
        CONSTRAINT VS_CK_Organization_Category CHECK (Category IN
            (N'communityAssociation', N'educationalTrust', N'studentWelfare', N'educationalInstitution', N'other')),
        CONSTRAINT VS_CK_Organization_Status CHECK (Status IN (N'listed', N'unlisted')),
        -- Destinations must be https. The host allow-list is enforced by the application, not here.
        CONSTRAINT VS_CK_Organization_ApplicationUrl CHECK (ApplicationUrl IS NULL OR ApplicationUrl LIKE N'https://%'),
        CONSTRAINT VS_CK_Organization_RegistrationUrl CHECK (RegistrationUrl IS NULL OR RegistrationUrl LIKE N'https://%'),
        CONSTRAINT VS_CK_Organization_ScholarshipsUrl CHECK (ScholarshipsUrl IS NULL OR ScholarshipsUrl LIKE N'https://%'),
        CONSTRAINT VS_CK_Organization_JobsUrl CHECK (JobsUrl IS NULL OR JobsUrl LIKE N'https://%'),
        CONSTRAINT VS_CK_Organization_PublicWebsite CHECK (PublicWebsite IS NULL OR PublicWebsite LIKE N'https://%'),
        CONSTRAINT VS_CK_Organization_PrimaryColor CHECK (PrimaryColor IS NULL OR PrimaryColor LIKE N'#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]'),
        CONSTRAINT VS_CK_Organization_AccentColor CHECK (AccentColor IS NULL OR AccentColor LIKE N'#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]')
    );

    CREATE INDEX VS_IX_Organization_Status_DisplayOrder ON dbo.VS_Organization (Status, DisplayOrder);
END;

---------------------------------------------------------------------------------------------------------------
-- VS_OrganizationHighlight: capabilities shown on an organization's public page.
---------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.VS_OrganizationHighlight', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.VS_OrganizationHighlight
    (
        OrganizationHighlightId INT IDENTITY(1, 1) NOT NULL,
        OrganizationId          NVARCHAR(50)   NOT NULL,
        DisplayOrder            INT            NOT NULL,
        Title                   NVARCHAR(150)  NOT NULL,
        TitleKn                 NVARCHAR(150)  NULL,
        Description             NVARCHAR(500)  NOT NULL,
        DescriptionKn           NVARCHAR(500)  NULL,
        Availability            NVARCHAR(20)   NOT NULL,

        CONSTRAINT VS_PK_OrganizationHighlight PRIMARY KEY (OrganizationHighlightId),
        CONSTRAINT VS_FK_OrganizationHighlight_Organization_OrganizationId
            FOREIGN KEY (OrganizationId) REFERENCES dbo.VS_Organization (OrganizationId) ON DELETE CASCADE,
        CONSTRAINT VS_CK_OrganizationHighlight_Availability CHECK (Availability IN (N'available', N'planned'))
    );

    CREATE INDEX VS_IX_OrganizationHighlight_OrganizationId ON dbo.VS_OrganizationHighlight (OrganizationId, DisplayOrder);
END;

---------------------------------------------------------------------------------------------------------------
-- VS_Enquiry: contact / demo enquiries from the public website (when an enquiry endpoint is built).
-- Personal data: keep only as long as needed (see the website privacy notice) and restrict access.
---------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.VS_Enquiry', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.VS_Enquiry
    (
        EnquiryId         BIGINT IDENTITY(1, 1) NOT NULL,
        Category          NVARCHAR(20)   NOT NULL,
        Name              NVARCHAR(100)  NOT NULL,
        OrganizationName  NVARCHAR(150)  NULL,
        Email             NVARCHAR(254)  NULL,
        Phone             NVARCHAR(20)   NULL,
        Message           NVARCHAR(2000) NOT NULL,
        ConsentGiven      BIT            NOT NULL,
        Locale            NVARCHAR(10)   NOT NULL,
        SourcePage        NVARCHAR(200)  NULL,
        Status            NVARCHAR(20)   NOT NULL CONSTRAINT VS_DF_Enquiry_Status DEFAULT (N'new'),
        ReceivedDate      DATETIME2(0)   NOT NULL CONSTRAINT VS_DF_Enquiry_ReceivedDate DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT VS_PK_Enquiry PRIMARY KEY (EnquiryId),
        CONSTRAINT VS_CK_Enquiry_Category CHECK (Category IN (N'organization', N'general', N'partnership', N'feedback', N'privacy')),
        CONSTRAINT VS_CK_Enquiry_Contact CHECK (Email IS NOT NULL OR Phone IS NOT NULL),
        CONSTRAINT VS_CK_Enquiry_Consent CHECK (ConsentGiven = 1),
        CONSTRAINT VS_CK_Enquiry_Status CHECK (Status IN (N'new', N'inProgress', N'closed', N'spam'))
    );

    CREATE INDEX VS_IX_Enquiry_Status_ReceivedDate ON dbo.VS_Enquiry (Status, ReceivedDate);
END;

---------------------------------------------------------------------------------------------------------------
-- Seed: Padmashali Vidya Sethu (same values as organizations.data.ts). ApplicationUrl stays NULL until the
-- PVS portal is deployed; then set it, e.g. N'https://pvs.vidyasethu.co.in/'.
---------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.VS_Organization WHERE OrganizationId = N'pvs')
BEGIN
    INSERT INTO dbo.VS_Organization
        (OrganizationId, Slug, DisplayName, OperatedBy, Description, Category, Status, DisplayOrder,
         LogoPath, LogoAlt, ShowApplicationLink, UseOwnBranding, PrimaryColor, AccentColor)
    VALUES
        (N'pvs', N'padmashali-vidya-sethu', N'Padmashali Vidya Sethu', N'Padmashali Vidyavardhaka Sangha',
         N'An education, skills, career and employment platform for Padmashali children and young people, run for the Padmashali Vidyavardhaka Sangha.',
         N'communityAssociation', N'listed', 1,
         N'organizations/padmashali-vidya-sethu/logo.jpg', N'Padmashali Vidya Sethu logo', 1, 1, '#1e5aa8', '#e08a1e');

    INSERT INTO dbo.VS_OrganizationHighlight (OrganizationId, DisplayOrder, Title, Description, Availability)
    VALUES
        (N'pvs', 1, N'Student and member registry',
         N'Families register children and young members after verifying their mobile number, and can add more family members later.', N'available'),
        (N'pvs', 2, N'Profile that grows with the member',
         N'A dashboard shows how complete each profile is. Education, skills, career and employment sections are being added in phases.', N'available'),
        (N'pvs', 3, N'Scholarship support',
         N'Member profiles help the Sangha plan scholarship programs. Online scholarship applications are planned for a later release.', N'planned'),
        (N'pvs', 4, N'Jobs and career opportunities',
         N'Career interests and employment details will help the Sangha share relevant job opportunities, guidance and training.', N'planned');
END;

COMMIT TRANSACTION;
PRINT 'VidyaSethu platform schema is up to date.';
