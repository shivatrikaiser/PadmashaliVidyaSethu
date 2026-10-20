/*
  Tell the mobile app that a new version is out. The app checks PVS_AppVersions on every screen; an app older
  than LatestVersion shows "Update required" (IsMandatory = 1, the app cannot be used until updated) or a
  dismissible "Update available" bar (IsMandatory = 0).

  1. Publish the new build to the Play Store / App Store and WAIT until the update is live for everyone
     (store review and staged rollouts can take hours or days). Running this earlier blocks members who
     cannot get the update yet.
  2. Set the values below. @Version must equal the version name in the app's pubspec.yaml
     (e.g. version: 1.0.3+7  ->  '1.0.3'). Run it once per platform you released.
*/
SET XACT_ABORT ON;

DECLARE @Platform    varchar(20)   = 'android';   -- android or ios
DECLARE @Version     varchar(20)   = 'X.Y.Z';     -- e.g. '1.0.3'
DECLARE @IsMandatory bit           = 1;           -- 1 = must update, 0 = update is optional
DECLARE @StoreUrl    nvarchar(500) = NULL;        -- NULL keeps the current store link

IF @Platform NOT IN ('android', 'ios')
    THROW 50001, 'Platform must be android or ios.', 1;
IF @Version NOT LIKE '[0-9]%.[0-9]%.[0-9]%' OR @Version LIKE '%[^0-9.]%'
    THROW 50002, 'Version must be major.minor.patch digits, e.g. 1.0.3 (as in pubspec.yaml, without +build).', 1;

UPDATE dbo.PVS_AppVersions
SET LatestVersion = @Version,
    IsMandatory = @IsMandatory,
    StoreUrl = COALESCE(@StoreUrl, StoreUrl),
    ModifiedDate = SYSUTCDATETIME(),
    ModifiedBy = N'script:ReleaseAppVersion'
WHERE Platform = @Platform;

IF @@ROWCOUNT = 0
    THROW 50003, 'No row for this platform. Run Database/deploy/PVS_Deploy_SharedDatabase.sql first.', 1;

SELECT Platform, LatestVersion, IsMandatory, StoreUrl, ModifiedDate FROM dbo.PVS_AppVersions ORDER BY Platform;
