# Security & Privacy

The platform holds information about children. These controls are implemented in V1 (✔) or planned (○).

## Authentication
* ✔ 4-digit Phone Number Verification Code, cryptographically random, 10-minute expiry (matches the DLT SMS text), **single use** (atomic update).
* ✔ Stored as HMAC-SHA256 with a server secret — never stored or logged in plain text.
* ✔ Brute force: 5 wrong attempts per code; per-number limits (1 / 30 s, 5 / hour); per-IP rate limits.
* ✔ JWT access tokens (30 min, HS256, no personal data inside) + random refresh tokens (3650 days, renewed on every use - members stay signed in) stored as SHA-256,
  **rotated on every use; reuse of a rotated token revokes every session** of the account.
* ✔ Development code exposure only in the Development environment — startup fails otherwise. No hard-coded codes.
* ✔ Delivered by SMS Gateway Hub using the DLT-registered sender/template. The request URL (API key + code) is never
  logged — the HttpClient's request logging is removed; errors log only the provider error code and a masked number.
  API key only in user-secrets / environment / Key Vault; startup fails if it is missing while SMS is enabled.
* ○ Admin portal: separate strong authentication (password/SSO + MFA).

## Authorization
* ✔ Fallback policy: every endpoint requires a signed-in account unless explicitly anonymous.
* ✔ Members can only read members registered under their own mobile number; others get 404.
* ✔ Disability details visible only to the owner and `SUPER_ADMIN` (`ViewSensitiveData` policy).
* ✔ Roles table seeded with future coordinator roles; policies map roles → capabilities in one place.

## Input & output
* ✔ Validation on client and server (server authoritative); parameterised SQL via EF Core (no string-built SQL —
  the one raw `MERGE` uses interpolated *parameters*).
* ✔ Consistent error envelope; no stack traces / SQL errors to clients.
* ✔ Security headers: `nosniff`, `X-Frame-Options: DENY`, strict CSP, `no-referrer`, `no-store`; HSTS + HTTPS
  redirection outside Development. JSON-only API with bearer tokens (no cookies ⇒ CSRF not applicable).
* ✔ CORS closed by default; only configured origins.

## Secrets
* ✔ No secrets in the repo or the Flutter app. `Jwt:SigningKey`, `PhoneVerification:CodeHashingKey` and `SMS:APIKey` come from
  user-secrets (dev) or environment variables / Key Vault. Missing or short keys stop startup outside Development.
* ✔ `.gitignore` excludes keys, certificates, `.env`, local settings, logs, build output.

## Transport / mobile
* ✔ Android release builds forbid cleartext; debug builds allow HTTP only to `10.0.2.2`/`localhost`.
* ✔ `android:allowBackup="false"`; tokens in Keystore-backed secure storage.

## Privacy
* ✔ Data minimisation: registration asks only basic details; everything else is optional and later.
* ✔ Privacy-policy consent and parent/guardian consent (under 18) stored as immutable `ConsentRecords` with policy version.
* ✔ Privacy Policy placeholder in the app — **the Sangha must supply the final text**.
* ✔ No public directory; no member data is exposed to other members.
* ✔ Audit log of sign-ins, failures, registrations, token reuse, user-submitted master data.
* ○ Self-service correction and deletion requests (V1 shows "contact the Sangha office").
* ○ Communication consent per channel/topic (Phase 8) — registration does **not** imply consent to messages.
* ○ Secure document uploads (Phase 4): allow-list, size limit, malware scanning, private storage.
* ○ Data retention policy and DPDP Act 2023 review by the Sangha.
