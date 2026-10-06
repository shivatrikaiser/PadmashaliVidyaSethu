/*
  Add further Padmashali temples (the first five - Barkur, Mangaluru, Kallianapura, Salikeri,
  Kinnimulky - are seeded by the application as codes 01-05).

  - TempleName: up to 200 characters, include the place name.
  - TempleCode: next unused 2-digit code (06, 07, ...). It becomes part of every Registration ID
    (PVS-<TempleCode>-NNNN) and must NEVER change afterwards.
  - Fill in the rows, remove "TEMPLATE" from the file name, run once per environment.
*/
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @New TABLE (TempleCode varchar(2) PRIMARY KEY, TempleName nvarchar(200) NOT NULL, DisplayOrder int NOT NULL);
INSERT INTO @New (TempleCode, TempleName, DisplayOrder) VALUES
    ('06', N'<Temple name, Place>', 60);
--  ('07', N'<Temple name, Place>', 70);

IF EXISTS (SELECT 1 FROM @New WHERE TempleName LIKE N'<%')
    THROW 50001, 'Fill in every temple name before running this script.', 1;
IF EXISTS (SELECT 1 FROM @New n JOIN dbo.Temples t ON t.TempleCode = n.TempleCode OR t.TempleName = n.TempleName)
    THROW 50002, 'A temple with this code or name already exists.', 1;

INSERT INTO dbo.Temples (TempleName, TempleCode, DisplayOrder, IsActive, CreatedDate, CreatedBy)
SELECT TempleName, TempleCode, DisplayOrder, 1, SYSUTCDATETIME(), 'script:AddTemples' FROM @New;

-- Registration counters start at 0 (the API also creates them on first use).
INSERT INTO dbo.TempleRegistrationSequences (TempleId, LastSequenceNumber)
SELECT t.TempleId, 0 FROM dbo.Temples t JOIN @New n ON n.TempleCode = t.TempleCode;

COMMIT;
