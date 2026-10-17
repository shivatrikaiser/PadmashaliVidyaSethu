# Master Data

All dropdown values live in database tables and are seeded by the EF migration (`Data/Seed/SeedData.cs`).
The app never hard-codes a list. **Code** is a stable identifier; **Name**, **DisplayOrder** and **IsActive** may be
edited by administrators (until the admin portal exists: SQL, see `Database/`).

Codes the application logic relies on — do not change:

| Table | Code | Used for |
|---|---|---|
| `MemberStatuses` | `STUDENT`, `WORKING`, `UNEMPLOYED` | Class Studying vs Highest Education; default status |
| `DisabilityTypes` | `OTHER` | "Please specify" |
| `Organisations` | `NONE` | "Not Linked to Any Organisation" |
| `Countries` | `IN` | Address country (V1 India only) |
| `Temples` | `01`…`05` (more later) | Embedded in Registration IDs — never change once members exist |
| `Roles` | `MEMBER`, `ADMIN`, `SUPER_ADMIN`, … | Authorization |

## Seeded lists and their source

| List | Count | Source / status |
|---|---|---|
| Temples | 5 | Barkur (01), Mangaluru (02), Kallianapura (03), Salikeri (04), Kinnimulky (05) — supplied by the Sangha. `TempleName` is `nvarchar(200)` (name with place). More to be added → `Database/seed/01_AddTemples.TEMPLATE.sql`. |
| Organisations | 6 | Spec §14 |
| Genders, Member statuses | 3, 3 | Spec §11, §16 |
| Classes | 20 | Spec §12, with education *stage* |
| Education levels (highest education) | 10 | Sensible default — review |
| Courses / Branches / Boards / Universities | 27 / 23 / 9 / 10 | Common Karnataka options + "Other" — review |
| Career options, Sports, Hobbies, Competitive exams, Achievement types | 21, 10, 11, 17, 12 | Spec §23–26 |
| Interest areas, Skills (Technical/General/Creative) | 13, 23 | Sensible defaults — review |
| Disability types | 8 | Spec §19 (+ member-added) |
| Communication topics / channels | 10 / 4 | Spec §29 |
| Countries | 14 | India + common destinations (Gulf, US, UK, …) for future use |
| States / UTs | 36 | All Indian states and union territories |
| Districts | 31 | All Karnataka districts (others learned from PIN lookups) |
| Taluks | 40 | Dakshina Kannada, Udupi, Shivamogga, Bengaluru Urban, Uttara Kannada — **to be verified by the Sangha**; others learned from PIN lookups |

## Values added at runtime
* **PIN lookups** add `Cities` and, when unknown, `Districts`/`Taluks`/`States` with `Source = 'PinLookup'`.
* **Members** add taluks ("My taluk is not listed", `Source = 'UserSubmitted'`). They are visible to everyone immediately.
* **"Other" + free text.** Lists that cannot be captured in advance (Education Levels, Courses, Branches, Boards,
  Universities, Career Options, Interest Areas, Skills, Sports, Hobbies, Competitive Exams, Achievement Types,
  Disability Types) each have an `OTHER` row. Choosing it shows a text box; the member is linked to the `OTHER` row
  and the text is stored in a separate column next to the reference - it never creates a master row:
  * single choice: `<Reference>OtherText` on the same table, e.g. `PVS_Members.HighestEducationLevelOtherText`;
  * multiple choice: `OtherText` on the link row - `PVS_MemberDisabilities`, `PVS_MemberSkills`,
    `PVS_MemberInterestAreas`, `PVS_MemberSports`, `PVS_MemberHobbies`, `PVS_MemberCareerAspirations`,
    `PVS_MemberCompetitiveExams`;
  * records: `PVS_MemberEducation` (`EducationLevelOtherText`, `CourseOtherText`, `BranchOtherText`, `BoardOtherText`),
    `PVS_AcademicAchievements` (`AchievementTypeOtherText`).

  Administrators review these texts (`Database/scripts/Useful_Queries.sql`), create the proper master row and re-map
  the member to it (then clear the text). Registration fills Highest Education and Disability Types today; the other
  tables are filled by the profile screens.
* Review these periodically (`Database/scripts/Useful_Queries.sql`): rename, merge or set `IsActive = 0`.
  Deactivated values disappear from dropdowns but stay valid on existing records.

## Adding a value
Insert a row with a new unique `Code`, the display `Name`, and a `DisplayOrder` (lists sort by it, then name).
To ship a value with the application instead, add it to `SeedData.cs` and create a migration.
