/*
  Replace the temple list with the Sangha's 16 temples ("Our Sixteen Temples").
  TempleName = "<Temple name>, <Place>" (the two lines of the PDF). TempleCode 01-16 = PDF numbering.
*/
SET XACT_ABORT ON;
BEGIN TRANSACTION;

-------------------------------------------------------------------------------- 1. Truncate PVS_Temples
-- TRUNCATE TABLE is not allowed on a table referenced by foreign keys, so DELETE + reseed is used instead.
IF EXISTS (SELECT 1 FROM dbo.PVS_Members)
    THROW 50001, 'Members are already registered against these temples - temples cannot be truncated.', 1;

DELETE FROM dbo.PVS_TempleRegistrationSequences;
DELETE FROM dbo.PVS_Temples;
DBCC CHECKIDENT (N'dbo.PVS_Temples', RESEED, 0) WITH NO_INFOMSGS;

-------------------------------------------------------------------------------- 2. Insert the 16 temples
SET IDENTITY_INSERT dbo.PVS_Temples ON;

INSERT INTO dbo.PVS_Temples (TempleId, TempleCode, TempleName, DisplayOrder, IsActive, CreatedDate, CreatedBy) VALUES
    ( 1, '01', N'Sree Brahmalinga Veerabhadra Durgaparameshwara Temple, Barkur',         10, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    ( 2, '02', N'Shree Veerabhadra Mahamayee Temple, Mangalore',                         20, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    ( 3, '03', N'Shree Adishakthi Veerabhadra Brahmalinga Temple, Kalyanpur',            30, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    ( 4, '04', N'Shree Veerbhadra Durgaparameshwari Temple, Surathkal',                  40, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    ( 5, '05', N'Sree Brahmalinga Veerabhadra Durgaparameshwari Temple, Salikere',       50, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    ( 6, '06', N'Sree Adhishakthi Veerabhadra Temple, Karkala',                          60, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    ( 7, '07', N'Sree Veerabhadra Mahanayee Temple, Haleyangadi',                        70, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    ( 8, '08', N'Sree Veerabhadra Temple, Kinnimulky',                                   80, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    ( 9, '09', N'Shree Veerabhadra Mahamayee Temple, Mulky',                             90, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    (10, '10', N'Panambur Sree Veerabhadra Swamy Mahamayee Temple, Siddakatte',         100, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    (11, '11', N'Shree Adishakthi Veerabhadra Temple, Kaup',                            110, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    (12, '12', N'Shree Veerabhadra Mahamayee Temple, Bangramanjeshwara',                120, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    (13, '13', N'Shree Veerabhadra Durgaparameshwari Temple, Ullala',                   130, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    (14, '14', N'Sree Veerabhadra Mahamayee Temple, Hosadurga',                         140, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    (15, '15', N'Shree Adishkthi Veerabhadra Temple, Yermal',                           150, 1, SYSUTCDATETIME(), N'script:ReplaceTemples'),
    (16, '16', N'Shree Veerabhadra Temple, Padubidri',                                  160, 1, SYSUTCDATETIME(), N'script:ReplaceTemples');

SET IDENTITY_INSERT dbo.PVS_Temples OFF;

-- Registration number counters (PVS-<TempleCode>-NNNN) start at 0 for every temple.
INSERT INTO dbo.PVS_TempleRegistrationSequences (TempleId, LastSequenceNumber)
SELECT TempleId, 0 FROM dbo.PVS_Temples;

COMMIT;

SELECT TempleId, TempleCode, TempleName FROM dbo.PVS_Temples ORDER BY TempleCode;
