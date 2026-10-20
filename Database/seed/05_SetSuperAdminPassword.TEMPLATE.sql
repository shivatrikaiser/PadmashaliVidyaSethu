/*
  First admin portal password for a Super Admin - run once, after PVS_Update_2026-10-20_AdminPasswords.sql
  (or PVS_Deploy_SharedDatabase.sql). Afterwards that Super Admin sets everyone's passwords, including their own,
  on the portal's Admin users page; this script is only needed again if every Super Admin is locked out.

  * @MobileNumber NULL: uses the existing Super Admin (stops if there are none or several).
  * @MobileNumber set: creates that account if needed and makes it Super Admin ("create if not exists").

  1. Make the password hash on your own computer (the password is typed hidden, never stored or sent anywhere):
         cd Backend\PadmashaliVidyaSetu.Api
         dotnet run --no-launch-profile -- hash-password
     It prints one line starting with AQAAAA... - paste it into @PasswordHash below.
  2. Run this script on the database, then sign in to the admin portal with the mobile number and that password.
*/
SET XACT_ABORT ON;

DECLARE @MobileNumber varchar(16)  = NULL;            -- NULL = the existing Super Admin, or e.g. '+919876543210'
DECLARE @PasswordHash varchar(200) = 'PASTE-HASH-HERE';

IF @PasswordHash NOT LIKE 'AQAAAA%' OR LEN(@PasswordHash) < 60
    THROW 50001, 'Paste the hash printed by "dotnet run --no-launch-profile -- hash-password" into @PasswordHash.', 1;
IF COL_LENGTH(N'dbo.PVS_Accounts', N'PasswordHash') IS NULL
    THROW 50002, 'Run Database/deploy/PVS_Update_2026-10-20_AdminPasswords.sql first.', 1;
IF @MobileNumber IS NOT NULL AND @MobileNumber NOT LIKE '+91[6-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    THROW 50003, 'Mobile number format: +91 followed by the 10-digit number, e.g. +919876543210.', 1;

DECLARE @SuperAdminRoleId int = (SELECT RoleId FROM dbo.PVS_Roles WHERE Code = 'SUPER_ADMIN');
DECLARE @MemberRoleId     int = (SELECT RoleId FROM dbo.PVS_Roles WHERE Code = 'MEMBER');
DECLARE @AccountId int;

BEGIN TRANSACTION;

IF @MobileNumber IS NULL
BEGIN
    IF (SELECT COUNT(*) FROM dbo.PVS_AccountRoles WHERE RoleId = @SuperAdminRoleId) <> 1
        THROW 50004, 'There is no single existing Super Admin. Set @MobileNumber to choose (or create) one.', 1;
    SET @AccountId = (SELECT AccountId FROM dbo.PVS_AccountRoles WHERE RoleId = @SuperAdminRoleId);
END
ELSE
BEGIN
    SET @AccountId = (SELECT AccountId FROM dbo.PVS_Accounts WHERE MobileNumber = @MobileNumber);
    IF @AccountId IS NULL
    BEGIN
        INSERT INTO dbo.PVS_Accounts (MobileNumber, CreatedDate, CreatedBy, IsActive)
        VALUES (@MobileNumber, SYSUTCDATETIME(), N'script:SetSuperAdminPassword', 1);
        SET @AccountId = SCOPE_IDENTITY();
    END;
    IF NOT EXISTS (SELECT 1 FROM dbo.PVS_AccountRoles WHERE AccountId = @AccountId AND RoleId = @MemberRoleId)
        INSERT INTO dbo.PVS_AccountRoles (AccountId, RoleId, CreatedDate, CreatedBy)
        VALUES (@AccountId, @MemberRoleId, SYSUTCDATETIME(), N'script:SetSuperAdminPassword');
    IF NOT EXISTS (SELECT 1 FROM dbo.PVS_AccountRoles WHERE AccountId = @AccountId AND RoleId = @SuperAdminRoleId)
        INSERT INTO dbo.PVS_AccountRoles (AccountId, RoleId, CreatedDate, CreatedBy)
        VALUES (@AccountId, @SuperAdminRoleId, SYSUTCDATETIME(), N'script:SetSuperAdminPassword');
END;

UPDATE dbo.PVS_Accounts
SET PasswordHash = @PasswordHash,
    PasswordSetDate = SYSUTCDATETIME(),
    FailedPasswordAttempts = 0,
    PasswordLockedUntil = NULL,
    IsActive = 1,
    ModifiedDate = SYSUTCDATETIME(),
    ModifiedBy = N'script:SetSuperAdminPassword'
WHERE AccountId = @AccountId;

COMMIT TRANSACTION;

SELECT LEFT(a.MobileNumber, 5) + '*****' + RIGHT(a.MobileNumber, 2) AS SuperAdmin, a.PasswordSetDate
FROM dbo.PVS_Accounts a WHERE a.AccountId = @AccountId;
