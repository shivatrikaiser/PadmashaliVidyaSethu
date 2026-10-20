# API Specification (v1)

Base path `/api/v1`. JSON, camelCase. The OpenAPI document is at `/openapi/v1.json` and
Swagger UI at `/swagger` - on by default in Development; on Azure only while the app setting `Swagger__Enabled` is
`true` (remove it after testing). To call protected endpoints in Swagger UI: `POST /api/v1/auth/verification-codes`,
then `.../verify` with the SMS code, and paste the returned `accessToken` into **Authorize**.

**SMS test** - `POST /api/v1/diagnostics/sms-test`, body `{ "mobileNumber": "9876543210" }`. Available whenever
Swagger is (locally always; on Live while `Swagger__Enabled` is `true`), otherwise 404. Sends one real verification SMS
with a generated 4-digit code in the template's `{#var#}`, without using the database, and returns SMS Gateway Hub's
answer: `accepted`, `providerErrorCode` (`000` = accepted), `providerMessage`, `jobId`. Always sends through SMS
Gateway Hub, whatever `PhoneVerification:Sender` is; 422 naming the missing `SMS:*` settings if they are incomplete. Rate-limited like verification codes; costs one SMS credit per call.
Health check: `GET /health` (anonymous).

## Envelope

```json
{ "success": true,  "message": "OK", "data": { }, "errors": [] }
{ "success": false, "message": "Please correct the highlighted fields.", "data": null,
  "errors": [ { "field": "permanentAddress.pinCode", "message": "PIN code must be exactly 6 digits." } ] }
```

| Status | Meaning |
|--------|---------|
| 400 | Validation failed (`errors[].field` = JSON path) |
| 401 | Not signed in / token invalid or expired (`X-Token-Expired: true` when expired) |
| 403 | Not allowed |
| 404 | Not found (also used for other people's members, so IDs cannot be probed) |
| 409 | Duplicate (member already registered on this account) |
| 422 | Business rule (e.g. account member limit) |
| 429 | Rate limited (`Retry-After` header) |
| 503 | Dependency unavailable (SMS / PIN service) |
| 500 | Unexpected — generic message + reference id |

## Authentication

| Method & path | Auth | Body → Data |
|---|---|---|
| `POST /auth/verification-codes` | anon, rate-limited | `{ mobileNumber }` → `{ challengeId, maskedMobileNumber, codeLength: 4, expiresInSeconds, resendAfterSeconds, developmentCode? }` |
| `POST /auth/verification-codes/verify` | anon, rate-limited | `{ challengeId, code }` (exactly 4 digits) → `{ accessToken, accessTokenExpiresAt, refreshToken, refreshTokenExpiresAt, isNewAccount, registeredMemberCount }` |
| `POST /auth/admin/sign-in` | anon | `{ mobileNumber, password }` → tokens. Admin portal only: accounts with ADMIN / SUPER_ADMIN and a password set by a Super Admin. Same 401 message for every failure; 5 wrong passwords lock it for 15 minutes |
| `POST /auth/token/refresh` | anon | `{ refreshToken }` → tokens (old refresh token revoked; reusing it within 2 minutes - a retry after a lost response - is allowed, later reuse revokes all sessions) |
| `POST /auth/logout` | bearer | `{ refreshToken }` |

The code is sent by SMS (SMS Gateway Hub) and is valid for 10 minutes. `developmentCode` is only returned when the API runs in **Development** with
`PhoneVerification:ExposeCodeInResponse=true`; startup fails if that is set elsewhere.

## Members (bearer)

| Method & path | Description |
|---|---|
| `GET /me` | Masked mobile number, members on this account (id, name, age, temple, status, completion %), member limit |
| `POST /members` | Register a member → `201 { registrationId, fullName, templeName }` |
| `GET /members/{registrationId}` | Basic profile (owner only; disability details only to owner / Super Admin) |
| `GET /members/{registrationId}/dashboard` | Profile completion by section |

`registrationId` must match `PVS-\d{2}-\d{4}`.

### `POST /members` body

```json
{
  "fullName": "Anu Suresh", "fatherName": "Suresh", "motherName": "Lakshmi",
  "dateOfBirth": "2014-08-15", "genderId": 2, "templeId": 1,
  "memberStatusId": 1, "classId": 13, "highestEducationLevelId": null,
  "organisationId": 1,
  "permanentAddress": { "addressLine1": "House 12, Temple Road", "addressLine2": null, "pinCode": "574201",
                        "cityVillageName": "Puttur", "cityId": 3, "talukId": 3, "newTalukName": null,
                        "districtId": 11, "stateId": 11, "countryId": 1 },
  "currentAddressSameAsPermanent": true, "currentAddress": null,
  "isDisabled": false, "disabilityTypeIds": [], "otherDisabilityDescription": null,
  "acceptPrivacyPolicy": true, "guardianConsent": true
}
```

Rules: age 5–100 (calendar date in IST); Student ⇒ `classId` required and `highestEducationLevelId` must be null;
Working/Unemployed ⇒ the reverse; `isDisabled=false` ⇒ no types; `isDisabled=true` ⇒ ≥1 type; type `OTHER` ⇒
description required (added to the master list); `currentAddress` required unless same as permanent; `talukId` or
`newTalukName`; taluk ∈ district ∈ state ∈ country (India only in V1); privacy policy must be accepted;
guardian consent required under 18; max 10 members per account; duplicate name + DOB on the same account ⇒ 409.

## Master data & locations (bearer)

| Method & path | Description |
|---|---|
| `GET /master-data/{type}` | Active items `[{ id, name, code }]` ordered by `DisplayOrder`. Types: `temples, organisations, genders, member-statuses, classes, education-levels, courses, branches, boards, universities, career-options, interest-areas, skills, sports, hobbies, competitive-exams, achievement-types, disability-types, communication-topics, communication-channels, countries` |
| `GET /master-data?types=a,b,c` | Several lists in one call (max 25) |
| `GET /locations/countries/{id}/states` | States |
| `GET /locations/states/{id}/districts` | Districts |
| `GET /locations/districts/{id}/taluks` | Taluks |
| `GET /locations/pin-codes/{pin}` | `{ pinCode, country, state, district, localities[{cityId,name,talukId}], taluks[], suggestedTalukId }`; 404 unknown PIN; 503 provider down (select manually) |

## App content (anonymous)

| Method & path | Purpose |
|---|---|
| `GET /app/branding` | Sponsor name, organisation and address, "Powered by" text, whether a sponsor logo exists and its version |
| `GET /app/branding/sponsor-logo?v={version}` | The sponsor logo image (cacheable; the version changes with every edit) |
| `GET /app/version?platform={android\|ios}` | Current app release `{ platform, latestVersion, isMandatory, storeUrl }` (table `PVS_AppVersions`, never cached). The app checks it on every screen; older apps show "Update required" (mandatory) or "Update available" |

## Admin portal (bearer, role ADMIN or SUPER_ADMIN)

Used by `Frontend/AdminWeb`. Members get 403.

| Method & path | Purpose |
|---|---|
| `GET /admin/me` | Signed-in administrator (masked mobile, roles) |
| `GET /admin/members?search=&templeId=&memberStatusId=&classId=&districtId=&ageFrom=&ageTo=&isActive=&page=&pageSize=` | Member search, paged (max 100 per page) |
| `GET /admin/members/export?<same filters>` | CSV for Excel (UTF-8 BOM, up to 50,000 rows) |
| `GET /admin/members/{registrationId}` | Full profile + mobile, status, consents (disability details: Super Admin only) |
| `PUT /admin/members/{registrationId}/status` `{ isActive }` | Deactivate / reactivate (nothing is deleted) |
| `GET /admin/reports/summary` | Totals and breakdowns (temple, status, gender, age group, district, month) |
| `GET /admin/lists`, `GET /admin/lists/{type}` | Configurable lists incl. inactive entries - **Super Admin only** (all `/admin/lists` and `/admin/other-values` endpoints) |
| `POST /admin/lists/{type}` `{ name, code?, displayOrder? }` | Add (code required for temples: 2 digits) |
| `PUT /admin/lists/{type}/{id}` `{ name?, displayOrder?, isActive? }` | Rename / reorder / (de)activate; required codes cannot be deactivated |
| `GET /admin/other-values` | "Other" texts typed by members, with member counts |
| `POST /admin/other-values/map` `{ listType, text, targetId }` | Move every member who typed the text to a list entry |
| `GET /admin/locations?includeSeed=` | Districts / taluks added by PIN lookups or members, with address counts |
| `PUT /admin/locations/{districts\|taluks}/{id}` `{ name?, isActive? }` | Rename / (de)activate |
| `POST /admin/locations/taluks/{id}/merge` `{ targetTalukId }` | Move all addresses to another taluk of the same district |
| `GET /admin/branding`, `PUT /admin/branding` `{ sponsorName, sponsorOrganisation, sponsorAddress, poweredBy }` (address: up to 4 lines, 300 chars), `POST /admin/branding/sponsor-logo` (multipart `file`, PNG/JPEG/WebP <= 300 KB), `DELETE /admin/branding/sponsor-logo` | App sponsor (splash, welcome screen, footer) - **Super Admin only** |
| `GET /admin/users`, `POST /admin/users` `{ mobileNumber, roleCode, password? }`, `PUT /admin/users/{accountId}/password` `{ password }`, `DELETE /admin/users/{accountId}/roles/{roleCode}` | Admin users and their portal passwords - **Super Admin only**; a new password or a removed role signs the person out (not when you set your own password) |

Every change is written to `PVS_AuditLogs` (`Admin.*` actions).

## Rate limits (defaults, per client IP)

Verification endpoints 10 / 10 min; refresh 30 / min; PIN lookup 30 / min; everything 300 / min.
Per mobile number: one code per 30 s, 5 per hour; 5 wrong attempts per code. All configurable.
