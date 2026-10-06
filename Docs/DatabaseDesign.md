# Database Design

Engine: SQL Server 2019+ / Azure SQL. Schema source of truth: EF Core migrations
(`Backend/PadmashaliVidyaSetu.Api/Migrations`). Generated script: `Database/schema/`.

## Conventions

* **Every SQL object name starts with `PVS_`.** Entity configurations use plain names; `SqlObjectNaming.ApplyPvsNaming`
  (`Backend/PadmashaliVidyaSetu.Api/Data/SqlObjectNaming.cs`) adds the prefix to everything, including future tables:

  | Object | Pattern | Example |
  |--------|---------|---------|
  | Table | `PVS_{Table}` | `PVS_Members` |
  | Primary key | `PVS_PK_{Table}` | `PVS_PK_Members` |
  | Foreign key | `PVS_FK_{Table}_{PrincipalTable}_{Columns}` | `PVS_FK_Members_Temples_TempleId` |
  | Index (unique or not) | `PVS_IX_{Table}_{Columns}` | `PVS_IX_Accounts_MobileNumber` |
  | Check constraint | `PVS_CK_{Table}_{Rule}` | `PVS_CK_Members_RegistrationId` |
  | Default constraint | `PVS_DF_{Table}_{Column}` | `PVS_DF_Members_CreatedDate` |
  | Migrations history | `PVS_EFMigrationsHistory` (PK `PVS_PK_EFMigrationsHistory`) | |

  The integration test `DatabaseNamingTests` fails if any object in a migrated database lacks the prefix. Hand-written
  SQL must use the prefixed names (`dbo.PVS_Temples`). The table names below omit the prefix for readability.
* Every business table carries `CreatedDate`, `ModifiedDate`, `CreatedBy`, `ModifiedBy`, `IsActive`
  (stamped automatically in `AppDbContext.SaveChangesAsync`; actor = `account:{id}` or `system`).
* Dates are UTC `datetime2(3)`; date of birth is `date`. **Age is never stored.**
* No cascading deletes except owned children (member addresses/disabilities, account roles/tokens).
  Members are deactivated (`IsActive = 0`), not deleted.
* Master tables share one shape: `{Entity}Id`, `Name`, `Code` (unique, stable), `DisplayOrder`, audit columns,
  index on `(IsActive, DisplayOrder)`.

## Tables

### Master data (configurable lists)
`Temples` (`TempleId`, `TempleName` nvarchar(200) incl. place, `TempleCode` CHECK 2 digits), `Organisations` (`OrganisationName`, `OrganisationCode`),
`Genders`, `MemberStatuses`, `Classes` (+`Stage`), `EducationLevels`, `Courses`, `Branches`, `Boards`, `Universities`,
`CareerOptions`, `InterestAreas`, `Skills` (+`Category`: Technical/General/Creative), `Sports`, `Hobbies`,
`CompetitiveExams`, `AchievementTypes`, `DisabilityTypes` (+`IsUserSubmitted`), `CommunicationTopics`,
`CommunicationChannels`, `Roles`.

### Locations
`Countries` → `States` (+`PostalName`) → `Districts` (+`PostalName`, `Source`) → `Taluks` (+`PostalName`, `Source`);
`Cities` (`PinCode`, `DistrictId`, `TalukId?`, `Source`) — also the PIN-code cache. Unique: `(CountryId, Name)`,
`(StateId, Name)`, `(DistrictId, Name)`, `(PinCode, Name)`.

### Accounts & security
| Table | Notes |
|-------|-------|
| `Accounts` | `MobileNumber` E.164, unique, CHECK `+%`. |
| `AccountRoles` | Account ↔ Role (PK both). |
| `RefreshTokens` | SHA-256 hash only, unique; rotation chain via `ReplacedByTokenHash`. |
| `PhoneVerificationChallenges` | `ChallengeId` GUID, HMAC of the code, expiry, failed-attempt count, `VerifiedDate` (single use). Index `(MobileNumber, CreatedDate)` for rate limits. |

### Members
| Table | Notes |
|-------|-------|
| `Members` | **PK `RegistrationId` char(11)** CHECK `PVS-[0-9][0-9]-[0-9][0-9][0-9][0-9]`. FKs to Account, Gender, Temple, MemberStatus, Class?, HighestEducationLevel?, Organisation. CHECK: `ClassId` and `HighestEducationLevelId` not both set. Indexes for temple, status+class, organisation, DOB (age-group reports). |
| `MemberAddresses` | One `Permanent` + one `Current` per member (unique). Current is stored even when "same as permanent" (copied) so reports by current location work. CHECK PIN 6 digits. |
| `MemberDisabilities` | Member ↔ DisabilityType. **Sensitive.** |
| `TempleRegistrationSequences` | Per-temple counter (0–9999) used by an atomic `MERGE … OUTPUT` to allocate `NNNN`. |

### Compliance
`ConsentRecords` (immutable: type, policy version, granted, time, IP) and `AuditLogs` (append-only; no FK so rows survive
account deletion; never contains codes, tokens or sensitive personal data).

## ER summary

```
Accounts 1─* Members *─1 Temples / Genders / MemberStatuses / Organisations
                │  └─0..1 Classes | 0..1 EducationLevels
                ├─1..2 MemberAddresses *─1 Taluks *─1 Districts *─1 States *─1 Countries
                │                      └─0..1 Cities (PIN cache)
                ├─* MemberDisabilities *─1 DisabilityTypes
                └─* ConsentRecords
Accounts 1─* AccountRoles *─1 Roles ;  Accounts 1─* RefreshTokens
Temples 1─1 TempleRegistrationSequences
```

## Future modules (planned tables)

Education (`MemberEducation`), Academic (`MemberAcademicRecords`, `AcademicAchievements` + secure document store),
Interests (`MemberInterestAreas`, `MemberSkills`, `MemberSports`, `MemberHobbies`), Career (`MemberCareerAspirations`,
`MemberCompetitiveExams`, `MemberHigherEducationPlans`), Employment (`MemberEmployment`, `JobSeekerProfiles`),
Communication (`CommunicationPreferences`, `CommunicationConsents`, `Notifications`). Each is keyed by
`RegistrationId` so a profile evolves from school to career without restructuring.
