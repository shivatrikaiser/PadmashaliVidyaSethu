# API Specification (v1)

Base path `/api/v1`. JSON, camelCase. In Development the OpenAPI document is at `/openapi/v1.json`.
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
| `POST /auth/token/refresh` | anon | `{ refreshToken }` → tokens (old refresh token revoked; reuse revokes all sessions) |
| `POST /auth/logout` | bearer | `{ refreshToken }` |

`developmentCode` is only returned when the API runs in **Development** with
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

## Rate limits (defaults, per client IP)

Verification endpoints 10 / 10 min; refresh 30 / min; PIN lookup 30 / min; everything 300 / min.
Per mobile number: one code per 30 s, 5 per hour; 5 wrong attempts per code. All configurable.
