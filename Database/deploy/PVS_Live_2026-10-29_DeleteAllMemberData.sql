/*
================================================================================================================
  Padmashali Vidya Setu (PVS) - DELETE ALL MEMBER DATA (end of UAT), 29 Oct 2026
  Removes every member registered in the PVS app so far, so the app starts empty for the real launch.
================================================================================================================
  WHAT IT DELETES (PVS_ tables only - nothing outside PVS is read or written)
    * Every member (PVS_Members) and everything entered for them:
        PVS_MemberAddresses, PVS_MemberDisabilities, PVS_MemberEducation, PVS_AcademicAchievements,
        PVS_MemberSkills, PVS_MemberInterestAreas, PVS_MemberSports, PVS_MemberHobbies,
        PVS_MemberCareerAspirations, PVS_MemberCompetitiveExams, PVS_ConsentRecords
    * Member logins: every PVS_Accounts row that has no role other than MEMBER, with its PVS_AccountRoles and
      PVS_RefreshTokens (they are signed out). This includes accounts closed with "Delete my account", so those
      mobile numbers can register again.
    * All PVS_PhoneVerificationChallenges (verification codes; they hold mobile numbers and email addresses).

  WHAT IT RESETS
    * PVS_TempleRegistrationSequences: every temple starts again at 0001 (the next member is PVS-xx-0001).

  WHAT IT KEEPS
    * Admin portal logins: accounts with any role other than MEMBER (ADMIN, SUPER_ADMIN, coordinators), their
      roles, passwords and sessions. If an admin had registered members, the members are deleted, the login stays.
    * All lists and master data (temples, organisations, classes, places, taluks - including those added by PIN
      lookups or by members), branding and footer sponsors, app versions, push notification history.
    * PVS_AuditLogs (the security history; it holds masked mobile numbers only).

  SAFETY
    * PREVIEW BY DEFAULT: with @Commit = 0 it deletes inside a transaction, prints the counts and ROLLS BACK -
      nothing changes. Read the counts, then set @Commit = 1 and run it again to delete for real.
    * ONE transaction: on any error everything is rolled back.
    * Before committing it checks that no member data is left and that every admin login is still there.
    * CANNOT BE UNDONE once committed. Take a backup / point-in-time restore point first if you may need the data.

  HOW TO RUN  (login allowed to delete from the PVS_ tables, e.g. the server admin)
    * SSMS / Azure Data Studio: connect to IQExploreDB_Live (check the database drop-down!) and execute.
    * First run as it is (preview). Then change @Commit to 1 and execute again.
    Expected result: "PVS member data DELETED: ..." (or "PREVIEW ONLY ..." while @Commit = 0).
================================================================================================================
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @Commit bit = 0;   -- 0 = preview (rolled back), 1 = delete for real

IF OBJECT_ID(N'dbo.PVS_Members') IS NULL OR OBJECT_ID(N'dbo.PVS_TempleRegistrationSequences') IS NULL
    THROW 50001, 'PVS is not deployed in this database - check the database drop-down. Nothing was changed.', 1;

PRINT CONCAT('Database: ', DB_NAME(), CASE WHEN @Commit = 1 THEN '   (DELETING FOR REAL)' ELSE '   (preview - will roll back)' END);

BEGIN TRANSACTION;

-- Member logins = accounts without any role other than MEMBER.
SELECT a.AccountId
INTO #MemberAccounts
FROM dbo.PVS_Accounts a
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.PVS_AccountRoles ar
    JOIN dbo.PVS_Roles r ON r.RoleId = ar.RoleId
    WHERE ar.AccountId = a.AccountId AND r.Code <> 'MEMBER'
);

DECLARE @MemberAccounts int = (SELECT COUNT(*) FROM #MemberAccounts);
DECLARE @AdminAccountsBefore int = (SELECT COUNT(*) FROM dbo.PVS_Accounts) - @MemberAccounts;
DECLARE @Members int = (SELECT COUNT(*) FROM dbo.PVS_Members);
DECLARE @n int;

PRINT CONCAT('Members to delete: ', @Members, '   member logins to delete: ', @MemberAccounts,
             '   admin logins kept: ', @AdminAccountsBefore);

-- 1. Everything entered for members (children first; most also cascade, deleted explicitly to report counts).
DELETE FROM dbo.PVS_ConsentRecords;            PRINT CONCAT('  PVS_ConsentRecords            ', @@ROWCOUNT);
DELETE FROM dbo.PVS_MemberAddresses;           PRINT CONCAT('  PVS_MemberAddresses           ', @@ROWCOUNT);
DELETE FROM dbo.PVS_MemberDisabilities;        PRINT CONCAT('  PVS_MemberDisabilities        ', @@ROWCOUNT);
DELETE FROM dbo.PVS_MemberEducation;           PRINT CONCAT('  PVS_MemberEducation           ', @@ROWCOUNT);
DELETE FROM dbo.PVS_AcademicAchievements;      PRINT CONCAT('  PVS_AcademicAchievements      ', @@ROWCOUNT);
DELETE FROM dbo.PVS_MemberSkills;              PRINT CONCAT('  PVS_MemberSkills              ', @@ROWCOUNT);
DELETE FROM dbo.PVS_MemberInterestAreas;       PRINT CONCAT('  PVS_MemberInterestAreas       ', @@ROWCOUNT);
DELETE FROM dbo.PVS_MemberSports;              PRINT CONCAT('  PVS_MemberSports              ', @@ROWCOUNT);
DELETE FROM dbo.PVS_MemberHobbies;             PRINT CONCAT('  PVS_MemberHobbies             ', @@ROWCOUNT);
DELETE FROM dbo.PVS_MemberCareerAspirations;   PRINT CONCAT('  PVS_MemberCareerAspirations   ', @@ROWCOUNT);
DELETE FROM dbo.PVS_MemberCompetitiveExams;    PRINT CONCAT('  PVS_MemberCompetitiveExams    ', @@ROWCOUNT);

-- 2. The members themselves.
DELETE FROM dbo.PVS_Members;                   PRINT CONCAT('  PVS_Members                   ', @@ROWCOUNT);

-- 3. Member logins (sessions and roles first).
DELETE rt FROM dbo.PVS_RefreshTokens rt JOIN #MemberAccounts m ON m.AccountId = rt.AccountId;
SET @n = @@ROWCOUNT;                           PRINT CONCAT('  PVS_RefreshTokens (members)   ', @n);
DELETE ar FROM dbo.PVS_AccountRoles ar JOIN #MemberAccounts m ON m.AccountId = ar.AccountId;
SET @n = @@ROWCOUNT;                           PRINT CONCAT('  PVS_AccountRoles (members)    ', @n);
DELETE FROM dbo.PVS_PhoneVerificationChallenges;
SET @n = @@ROWCOUNT;                           PRINT CONCAT('  PVS_PhoneVerificationChallenges ', @n);
DELETE a FROM dbo.PVS_Accounts a JOIN #MemberAccounts m ON m.AccountId = a.AccountId;
SET @n = @@ROWCOUNT;                           PRINT CONCAT('  PVS_Accounts (members)        ', @n);

-- 4. Registration numbers start again at 0001 for every temple.
UPDATE dbo.PVS_TempleRegistrationSequences SET LastSequenceNumber = 0 WHERE LastSequenceNumber <> 0;
SET @n = @@ROWCOUNT;                           PRINT CONCAT('  Temple registration numbers reset: ', @n, ' temple(s)');

-- 5. Checks before committing.
IF EXISTS (SELECT 1 FROM dbo.PVS_Members)
   OR EXISTS (SELECT 1 FROM dbo.PVS_MemberAddresses)
   OR EXISTS (SELECT 1 FROM dbo.PVS_ConsentRecords)
   OR EXISTS (SELECT 1 FROM dbo.PVS_Accounts a JOIN #MemberAccounts m ON m.AccountId = a.AccountId)
    THROW 50002, 'Member data is still present - rolled back, nothing was changed.', 1;

IF (SELECT COUNT(*) FROM dbo.PVS_Accounts) <> @AdminAccountsBefore
    THROW 50003, 'Admin login count changed unexpectedly - rolled back, nothing was changed.', 1;

IF @Commit = 1
BEGIN
    COMMIT TRANSACTION;
    PRINT CONCAT('PVS member data DELETED: ', @Members, ' member(s) removed; ', @AdminAccountsBefore,
                 ' admin login(s) kept; registration numbers restart at 0001.');
END
ELSE
BEGIN
    ROLLBACK TRANSACTION;
    PRINT CONCAT('PREVIEW ONLY - nothing was changed. Set @Commit = 1 and run again to delete ', @Members, ' member(s).');
END;

DROP TABLE IF EXISTS #MemberAccounts;
