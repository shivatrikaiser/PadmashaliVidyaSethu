/*
  Give a mobile number access to the web admin portal (Frontend/AdminWeb).

  1. The person signs in once (mobile app or admin portal) so their account exists.
     The admin portal then says "This mobile number does not have admin access" - expected.
  2. Put their number and the role below, remove "TEMPLATE" from the file name, run it.
     Roles: ADMIN (admin portal) or SUPER_ADMIN (admin portal + sensitive data such as disability details).
  3. They sign in to the admin portal again.
*/
SET XACT_ABORT ON;

DECLARE @MobileNumber varchar(16) = '+91XXXXXXXXXX';   -- e.g. '+919876543210'
DECLARE @RoleCode     varchar(60) = 'ADMIN';           -- ADMIN or SUPER_ADMIN

DECLARE @AccountId int = (SELECT AccountId FROM dbo.PVS_Accounts WHERE MobileNumber = @MobileNumber);
DECLARE @RoleId    int = (SELECT RoleId FROM dbo.PVS_Roles WHERE Code = @RoleCode AND IsActive = 1);

IF @AccountId IS NULL
    THROW 50001, 'No account with this mobile number. Ask the person to sign in once first (format +91XXXXXXXXXX).', 1;
IF @RoleId IS NULL
    THROW 50002, 'Unknown role code. Use ADMIN or SUPER_ADMIN.', 1;

IF NOT EXISTS (SELECT 1 FROM dbo.PVS_AccountRoles WHERE AccountId = @AccountId AND RoleId = @RoleId)
    INSERT INTO dbo.PVS_AccountRoles (AccountId, RoleId, CreatedDate, CreatedBy)
    VALUES (@AccountId, @RoleId, SYSUTCDATETIME(), N'script:GrantAdminRole');

SELECT a.MobileNumber, r.Code AS RoleCode
FROM dbo.PVS_AccountRoles ar
JOIN dbo.PVS_Accounts a ON a.AccountId = ar.AccountId
JOIN dbo.PVS_Roles r ON r.RoleId = ar.RoleId
WHERE ar.AccountId = @AccountId;
