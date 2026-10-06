# Profile Modules

Status as of 2026-10-06.

| Section (dashboard key) | Phase | Status | Applies to |
|---|---|---|---|
| Basic Information (`basic`) | 2 | **Implemented** — registration | Everyone |
| Education (`education`) | 4 | Planned — "Coming soon" | Everyone |
| Academic Profile + Special Achievements (`academic`) | 4 | Planned | Everyone |
| Interests & Skills (`interests`) | 5 | Planned (master lists already seeded) | Everyone |
| Career Aspirations / *Areas of Career Interest* under 13 (`career`) | 6 | Planned | Everyone |
| Competitive Exams (`competitiveExams`) | 6 | Planned | Non-students, and students from Class 8 / High School stage up |
| Higher Education (`higherEducation`) | 6 | Planned | Same as above |
| Employment (`employment`) | 7 | Planned | Working / Unemployed only (Not Applicable for students) |
| Communication Preferences (`communication`) | 8 | Planned (topics/channels seeded) | Everyone |

## Completion calculation
`ProfileCompletionService` computes each section's status (`Complete`, `InProgress`, `NotStarted`, `NotApplicable`)
and percent; overall % = average of applicable sections. Unbuilt modules report 0 % with `isAvailable = false` and
the app shows **"Coming soon"** — no simulated progress. With only Basic Information complete a student sees about
11–14 % depending on how many sections apply.

## Applicability inputs
Member status code, class **stage** (`Classes.Stage`: PrePrimary, Primary, HighSchool, PreUniversity, Vocational,
UnderGraduate, PostGraduate, Professional, Other) and age. Changing the master list's stages changes which
questions apply — no code change.

## Planned module design (summary)
* Each module has its own tables keyed by `RegistrationId`, its own endpoints under `/api/v1/members/{id}/…`, and
  contributes one section to the completion service.
* Special Achievements: multiple `AcademicAchievements` rows (type, title, level, year, institution, optional
  document). Documents: private blob storage, type allow-list (PDF/JPEG/PNG), size limit, malware scan, served only
  through authorised short-lived links.
