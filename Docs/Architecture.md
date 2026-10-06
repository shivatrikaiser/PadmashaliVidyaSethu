# Architecture

## Overview

```
┌────────────────────────┐   HTTPS / JSON (REST, /api/v1)   ┌──────────────────────────────┐      ┌──────────────────┐
│ Flutter app            │ ───────────────────────────────▶ │ ASP.NET Core Web API (.NET 10)│ ───▶ │ SQL Server /     │
│ Android (primary),     │ ◀─────────────────────────────── │ Controllers → Services → EF   │ ◀─── │ Azure SQL        │
│ iOS / Web later        │   JWT access + refresh tokens    │ Core (AppDbContext)           │      └──────────────────┘
└────────────────────────┘                                  │                               │ ───▶ India Post PIN API
                                                            │                               │ ───▶ SMS provider (TBD)
                                                            └──────────────────────────────┘
```

## Repository layout

```
PVS/
├── Backend/                         ASP.NET Core solution (PadmashaliVidyaSetu.slnx)
│   └── PadmashaliVidyaSetu.Api/
│       ├── Controllers/             Thin HTTP layer only
│       ├── Services/                Business logic (Auth, Members, MasterData, Locations, Verification)
│       ├── DTOs/                    Request/response contracts
│       ├── Entities/                EF entity classes
│       ├── Data/                    AppDbContext, entity configurations, seed data
│       ├── Validators/              FluentValidation rules + MVC filter
│       ├── Middleware/              Error envelope, security headers
│       ├── Authentication/          JWT/refresh tokens, keys, current user
│       ├── Authorization/           Policies (role → capability mapping)
│       ├── Configuration/           Options, DI wiring, rate limits
│       ├── Logging/                 Audit logger
│       └── Migrations/              EF Core migrations (schema source of truth)
├── Frontend/padmashali_vidya_setu/  Flutter app
│   └── lib/{config,core,models,repositories,providers,routing,screens,widgets,theme,utils,l10n}
├── Database/                        Generated idempotent SQL + operational scripts
├── Tests/Backend/                   xUnit unit + integration tests
├── Docs/                            This documentation (+ ui/screenshots)
└── Deployment/                      Environment notes
```

Frontend tests live with the Flutter project (`test/`, `integration_test/`) because Flutter tooling expects them there.

## Backend

* **Layering:** Controller → Service → `AppDbContext`. Controllers contain no business logic.
  EF Core's `DbContext` already is a unit of work / repository, so no generic repository layer was added (spec §51:
  avoid abstraction for its own sake). Query-heavy reporting in the admin phase may add read-model services.
* **Validation:** two stages. FluentValidation validators (format, required, request-level conditionals) run in an
  MVC filter; services enforce database-dependent rules (master value exists and is active, Current Status ⇄ Class,
  address hierarchy). Both produce the same error envelope.
* **Errors:** `ExceptionHandlingMiddleware` maps `AppException` subclasses to 400/401/403/404/409/422/429/503 and
  everything else to a generic 500 with a trace reference. No stack traces, SQL errors or secrets reach clients.
* **Configuration:** strongly-typed options, validated on start. All configuration is read lazily from DI so
  environment overrides, secret stores and test hosts are honoured.
* **Logging:** Serilog (console; rolling file in Development). Mobile numbers are masked; verification codes and
  tokens are never logged. Business/security events also go to the `AuditLogs` table.
* **Time:** `TimeProvider` is injected (testable). Ages are computed on the Indian calendar date (IST).

## Frontend

* **State:** Riverpod 2 (`providers/`). Session (signed-in account + members) is a `StateNotifier`.
* **Navigation:** go_router with a pure redirect function driven by the session (`routing/app_router.dart`).
* **API:** `core/api/api_client.dart` (Dio) unwraps the envelope, attaches the bearer token, refreshes once on 401
  (concurrent requests share one refresh) and throws typed `ApiException`s.
* **Tokens:** `flutter_secure_storage` (Android Keystore / iOS Keychain).
* **Master data:** every dropdown loads from `/api/v1/master-data/{type}`. The app relies only on a few stable
  *codes* (`STUDENT`, `OTHER`); display names are editable server-side.
* **Localisation:** all strings in `lib/l10n/app_en.arb` (gen-l10n). Add `app_kn.arb` / `app_hi.arb` for Kannada/Hindi.
* **Responsive:** content width capped at 640–720 dp and centred on tablets; no fixed screen sizes; text scale
  respected up to 1.6×.

## Key decisions

| # | Decision | Why |
|---|----------|-----|
| D1 | **.NET 10** instead of .NET 9 | Installed, LTS, and newer — the spec allows a newer stable version. |
| D2 | **Account ≠ Member.** A verified mobile number is an *account*; it can register up to 10 *members*. | Children aged 5+ rarely have phones; parents register siblings with their own number. |
| D3 | **Registration ID is the Member primary key** (`PVS-TT-NNNN`, `char(11)`), as requested. | Allocated atomically per temple via `TempleRegistrationSequences`. TT is the temple's 2-digit *code*, so temple codes must never change once used. Max 9,999 per temple. |
| D4 | Phone verification creates the account; registration is a separate authenticated call. | Lets a returning parent sign in and add another child; no half-registered state. |
| D5 | PIN look-ups are cached in `Cities`; unknown districts/taluks are learned automatically (`Source = PinLookup`). | Each PIN hits the external service once; the app works when the provider is down (manual State/District selection). |
| D6 | Legacy postal names (`PostalName`) on states/districts/taluks. | India Post returns "Shimoga", "Bangalore", "Mangalore"; these map onto Shivamogga, Bengaluru Urban, Mangaluru. |
| D7 | Indian mobile numbers and Indian addresses only in V1. | Phone provider and PIN data are India-specific. International (e.g. Dubai) support needs an E.164 phone field and a non-PIN address form — planned. |
| D8 | "Other" disability text becomes a new `DisabilityTypes` row (flagged `IsUserSubmitted`), shown to everyone, listed just before "Other". | Spec §19. Admins can rename/deactivate. Same pattern for "My taluk is not listed". |
| D9 | Guardian consent required below 18; consents stored as immutable `ConsentRecords`. | Children's data; spec §35. |
| D10 | Unbuilt profile modules appear on the dashboard as "Coming soon" with 0 %. | Spec §52: never present mocked functionality as real. |
| D11 | Riverpod 2.6 / go_router 17 | Riverpod 3 / go_router 18 need a newer Dart SDK than installed (3.11.5); not upgraded per spec §49. |

## Extending

* **New profile module** (e.g. Education): entity + configuration + migration → service + DTOs + validator →
  controller → update `ProfileCompletionService` section → Flutter repository/provider/screen → tests.
* **New role:** roles are seeded (`Roles`); map them to policies in `Authorization/Policies.cs`.
* **SMS provider:** implement `IVerificationCodeSender`, register it in `ServiceCollectionExtensions`, set
  `PhoneVerification:Sender`.
* **PIN provider:** implement `IPinCodeProvider`.
