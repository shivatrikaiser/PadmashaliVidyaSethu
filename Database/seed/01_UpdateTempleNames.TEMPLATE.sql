/*
  Replace the 16 placeholder temple names with the official names supplied by the
  Padmashali Vidyavardhaka Sangha. Run once against each environment.

  - TempleCode (01..16) MUST NOT change once members are registered: it is embedded in
    Registration IDs (PVS-<TempleCode>-<NNNN>).
  - DisplayOrder controls the dropdown order.
  - Fill in the names below, then remove "TEMPLATE" from the file name.
*/
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @Names TABLE (TempleCode varchar(2) PRIMARY KEY, TempleName nvarchar(150) NOT NULL, DisplayOrder int NOT NULL);
INSERT INTO @Names (TempleCode, TempleName, DisplayOrder) VALUES
    ('01', N'<Temple 1 official name>', 10),
    ('02', N'<Temple 2 official name>', 20),
    ('03', N'<Temple 3 official name>', 30),
    ('04', N'<Temple 4 official name>', 40),
    ('05', N'<Temple 5 official name>', 50),
    ('06', N'<Temple 6 official name>', 60),
    ('07', N'<Temple 7 official name>', 70),
    ('08', N'<Temple 8 official name>', 80),
    ('09', N'<Temple 9 official name>', 90),
    ('10', N'<Temple 10 official name>', 100),
    ('11', N'<Temple 11 official name>', 110),
    ('12', N'<Temple 12 official name>', 120),
    ('13', N'<Temple 13 official name>', 130),
    ('14', N'<Temple 14 official name>', 140),
    ('15', N'<Temple 15 official name>', 150),
    ('16', N'<Temple 16 official name>', 160);

IF EXISTS (SELECT 1 FROM @Names WHERE TempleName LIKE N'<%')
    THROW 50001, 'Fill in every temple name before running this script.', 1;

UPDATE t
   SET t.TempleName = n.TempleName,
       t.DisplayOrder = n.DisplayOrder,
       t.ModifiedDate = SYSUTCDATETIME(),
       t.ModifiedBy = 'script:UpdateTempleNames'
  FROM dbo.Temples t
  JOIN @Names n ON n.TempleCode = t.TempleCode;

COMMIT;
