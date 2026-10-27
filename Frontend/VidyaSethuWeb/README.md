# VidyaSethu Web

Public product website for **VidyaSethu** (https://vidyasethu.co.in), the multi-organization education and career
platform from Swaprajna Technologies (OPC) Private Limited. **Padmashali Vidya Sethu (PVS)** is the first
organization listed on it.

VidyaSethu is the product; PVS is one organization using it. This website has no backend, no database and no sign-in.
It never calls the PVS API and never touches PVS data. It describes the platform and links to each organization's own
portal.

Angular 21 (standalone components, signals, SCSS), prerendered to static HTML at build time, published to an Azure
App Service Web App (Windows or Linux) from one zip package.

## Run locally

```bash
cd Frontend/VidyaSethuWeb
npx -y npm@11 install      # first time only (npm 10.9.x fails on Angular 21 projects, see AdminWeb/README.md)
npx ng serve --open        # http://localhost:4300
```

Or double-click `RunFrontend/Start_VidyaSethu_Web.bat`.

In development the PVS organization page links to `http://localhost:8080/`, labelled as a development link. To
make that link work, run the PVS Flutter app as a web app on that port (with the API running):

```bash
cd Frontend/padmashali_vidya_setu
flutter run -d chrome --web-port 8080 --dart-define-from-file=config/development.json
```

The PVS API only accepts browser calls from origins listed in `Cors:AllowedOrigins`, so a local web run of PVS
also needs `http://localhost:8080` there (PVS user-secrets). This affects PVS only, not this website.

## Commands

| Command | What it does |
|---|---|
| `npx ng serve` | Dev server (development configuration) on port 4300 |
| `npm run build` | Production build + prerender of every page, `scripts/postbuild.mjs` checks, then `scripts/package.mjs` → `dist/VidyaSethuWeb/vidyasethu-web.zip` (Azure Web App package) |
| `npm run verify` | Re-runs the post-build checks on an existing build |
| `npm test` | Unit tests (Vitest, 57 tests) |
| `npm run serve:dist` | Runs the deployment package with its own `server.mjs`, exactly as on a Linux Web App (http://localhost:4400) |

`scripts/postbuild.mjs` writes `sitemap.xml` from the prerendered routes. It **fails the build** if:
- an expected page was not prerendered;
- a prerendered page links to a local file or page that doesn't exist;
- the output contains a localhost, loopback, emulator or private-network URL, an `example.org` placeholder,
  secret-like settings, development configuration, or `allowLocalhostLinks` switched on.

## Structure

```
src/
  environments/         environment.ts (production), environment.development.ts - the only per-environment settings
  app/
    core/               site-config.ts (SiteConfig + SITE_CONFIG token), safe-url.ts (link validation), seo.ts
    organizations/      organization.model.ts, organizations.data.ts (the listings), organization-directory.ts
    enquiry/            enquiry form + service (posts to the configured endpoint)
    i18n/               i18n.ts (I18n service, Messages type), localized-text.ts, en/ (all English text)
    layout/             header (responsive nav), footer, nav-links.ts
    shared/             icon, logo, status badge, organization card
    pages/              home, about, features, organizations, organization (detail), for-organizations,
                        audience (students / job seekers), contact, legal (privacy / terms / accessibility), not-found
    app.routes.ts       routes (+ seo key per page);  app.routes.server.ts: prerender rules
public/                 brand/vidyasethu-logo-{96,192,480}.png, favicon-48.png, apple-touch-icon.png, og-image.png,
                        robots.txt, site.webmanifest, web.config (Windows Web App), staticwebapp.config.json
                        (security headers; also read by server.mjs), organizations/{slug}/logo.*
branding/               vidyasethu-logo.png - master logo (1254 px, transparent; not deployed)
server/                 server.mjs - production web server for a Linux Web App (no dependencies)
scripts/                postbuild.mjs (checks), package.mjs (Web App zip), generate-images.ps1 (brand images from the master)
```

To change the logo, replace `branding/vidyasethu-logo.png` (square, transparent PNG) and run
`powershell -ExecutionPolicy Bypass -File scripts/generate-images.ps1`. The site colours (`src/styles.scss`) are taken
from the logo: deep blue `#01377f`, sky blue `#05bafd` / `#097cd6`, sunrise orange `#f7a600`.

## Organizations

Listings live in `src/app/organizations/organizations.data.ts`. It is version-controlled, and developers add
organizations there. Each record follows `organization.model.ts`, which mirrors the planned `VS_Organization` table
(`Database/vidyasethu/VS_Platform_Schema.sql`). When a platform-admin backend exists, the listings move there.

Rules the code enforces:
- Only `status: 'listed'` records with valid data (slug format, logo path, colours) appear anywhere, including
  prerendered pages and the sitemap.
- A link is shown only if its kind is in `enabledPublicLinks` **and** its URL passes `safeExternalLink`. In
  production that means `https`, a host in `allowedLinkHosts`, and no credentials. `javascript:`, `data:` and the
  like are rejected. Links are plain anchors; the site never redirects automatically.
- PVS publishes only its **application** link. Registration starts on the PVS welcome screen (phone verification
  first, then `/register`), and PVS has no scholarship or job pages yet, so no deep links are listed. Enable them in
  `enabledPublicLinks` once PVS has those pages.

To add an organization:
1. Add its logo under `public/organizations/{slug}/`.
2. Append a record to `organizations.data.ts`.
3. Set its links in both environment files.
4. If its portal is outside `vidyasethu.co.in`, add the host to `allowedLinkHosts`.
5. Set `status: 'listed'` only after the organization approves the listing.

The page `/organizations/{slug}` is generated automatically.

## Setting the PVS application URL

The destination is configured per environment in `organizationLinks.pvs.application`:

| File | Current value | Effect |
|---|---|---|
| `src/environments/environment.ts` (production) | `'https://pvs.vidyasethu.co.in/'` | "Open Padmashali Vidya Sethu" button |
| `src/environments/environment.development.ts` | `'http://localhost:8080/'` | Button shown, with a "Development link" notice |

To change it (or set it to `null`, which makes the PVS page say "Portal not yet available online", with no button):
1. Edit `pvs: { application: ... }` in `environment.ts`.
2. Run `npm run build`. The tests and post-build checks reject non-https, non-allowed or localhost URLs.
3. Deploy.

## Enquiry endpoint

The contact and "For organizations" forms post JSON to `enquiryEndpoint` (in the environment files). Production
uses the shared enquiry service in the API, `https://api.pvs.vidyasethu.co.in/api/v1/enquiries`, for every
organization: it validates the enquiry, rate-limits per IP (5 an hour), rejects submissions filled in under 3
seconds and emails it (plain text, enquirer as Reply-To) to `Enquiries:Recipient` (default support@iqexplore.com)
through the API's SMTP settings (`Email:*`, `PhoneVerification:EmailSender`). The API must allow the website's origin:
`Cors__AllowedOrigins__N` (next free number) = `https://vidyasethu.co.in`. If `enquiryEndpoint` is `null`, the forms are shown disabled
with "Online enquiries are not open yet" and nothing is ever reported as sent. Success is shown only after the
endpoint returns 2xx.

The rest of this section is the contract the endpoint follows.

To enable the forms, build a small endpoint and set `enquiryEndpoint`. Options:
- An API on the same domain, e.g. an Azure Function or small App Service API routed at `/api/enquiries` (no CORS).
- A separate HTTPS service on an allowed host. Also add its origin to `connect-src` in
  `public/staticwebapp.config.json`.

Request body (`EnquiryPayload` in `enquiry.service.ts`):

```json
{ "category": "organization|general|partnership|feedback|privacy", "name": "…", "organization": "…|null",
  "email": "…|null", "phone": "…|null", "message": "…", "consent": true, "locale": "en",
  "page": "/contact", "elapsedMs": 8423 }
```

The endpoint **must**:
- re-validate every field (same limits as the form: name 2–100, message 10–2000, email or phone required,
  consent true);
- rate-limit per IP;
- reject very fast submissions using `elapsedMs`;
- preferably verify a CAPTCHA token (e.g. Cloudflare Turnstile; the CSP then needs its script and frame hosts);
- store or forward without logging message bodies;
- return 2xx only once the enquiry is safely stored or sent.

The planned storage table is `VS_Enquiry` in `Database/vidyasethu/VS_Platform_Schema.sql`. The browser side
already has a hidden honeypot field and a minimum fill time.

## Company contact details

`company.email`, `company.phone` and `company.address` in the environment files are `null`, and the Contact page
says "Our contact details will be published here soon." Fill them in only with details approved for publication.

## Padmashali Vidya Sethu web app

The Padmashali Vidya Sethu app (Flutter) has its own address, `https://pvs.vidyasethu.co.in` (its own Web App - see
`Docs/Deployment.md` "Member web app"); the organization page's "Open Padmashali Vidya Sethu" button links there.
This website no longer contains it: `/pvs` and any `/pvs/...` address redirect (301) to `https://pvs.vidyasethu.co.in`
(`web.config`, `server.mjs`, `staticwebapp.config.json`), so old links keep working.

## Legal pages

`/privacy`, `/terms` and `/accessibility` are **drafts** (`src/app/i18n/en/legal.ts`, with `[For review: …]`
markers) and show a "Draft for review" notice while `legalPagesApproved` is `false`. Have them reviewed, update the
text and dates, then set `legalPagesApproved: true` in `src/environments/shared.ts` (one switch for the production
and the development build - development differs from production only in its data sources).

## Localization (Kannada)

All visible text is in `src/app/i18n/en/*.ts`; organization data uses `LocalizedText` (`{ en, kn? }`). To add
Kannada:
1. Create `src/app/i18n/kn/index.ts` exporting `kn: Messages`. The compiler then flags every missing string.
2. Register it in `CATALOGS` in `i18n.ts`.
3. Add a language switch to the header.
4. Decide on URLs (e.g. `/kn/...`) so Kannada pages are prerendered too.

The font stack already includes Noto Sans Kannada and Nirmala UI.

## Deployment (Azure App Service - Web App)

Nothing below has been created yet: no Azure resources, DNS records or pipelines. These are the exact steps.

### What `npm run build` produces

```
dist/VidyaSethuWeb/
  vidyasethu-web.zip      <- upload this to the Web App
  package/                the same files, unzipped:
    index.html, about/index.html, ... (13 prerendered pages), JS/CSS bundles, images
    web.config            used by a Windows Web App (IIS)
    server.mjs            used by a Linux Web App (Node, no dependencies)
    package.json          "npm start" -> node server.mjs
```

The **same zip works on Windows and Linux** Web Apps. Both give the same behaviour:
- **Redirects (301):** `www.vidyasethu.co.in` → `https://vidyasethu.co.in`, and `/about/` → `/about`.
- **Pages:** each address is served from its prerendered file, so direct refresh works.
- **Unknown addresses:** the site's 404 page with status **404**.
- **Hidden files:** `web.config`, `server.mjs`, `package.json` and the other deployment files are never served.
- **Security headers:** CSP (with the event-replay script hashes), HSTS, `nosniff`, `X-Frame-Options`, Referrer-Policy
  and Permissions-Policy.
- **Caching and compression:** bundles cached for a year, images for a day, pages revalidated (`no-cache`); text is
  gzip-compressed.

Before deploying, test the package locally with `npm run serve:dist` (Node, as on Linux) → http://localhost:4400.

### 1. Build

```powershell
cd Frontend\VidyaSethuWeb
npx -y npm@11 ci
npm test
npm run build          # build + checks + dist\VidyaSethuWeb\vidyasethu-web.zip
```

Keep each released zip (e.g. rename it to `vidyasethu-web-2026-10-13.zip`). It is your rollback copy.

### 2. Create the Web App (Azure portal)

**Create a resource → Web App**:

| Field | Value |
|---|---|
| Resource group | new, e.g. `rg-vidyasethu-web` |
| Name | e.g. `vidyasethu-web` → `https://vidyasethu-web.azurewebsites.net` (must be globally unique) |
| Publish | **Code** |
| Runtime stack | **Node 22 LTS** |
| Operating system | **Linux** (recommended, cheaper) or Windows. Both work with the same zip. |
| Region | **Central India** (or South India) |
| Pricing plan | **Basic B1** or higher. Free F1 cannot use custom domains with HTTPS. Use **Standard S1** if you want deployment slots (zero-downtime swaps). |

Leave Application Insights on; it is used for monitoring below. Then **Review + create**.

### 3. Configure the Web App (once)

Web App → **Settings → Configuration**:
- **General settings:**
  - **HTTPS Only: On**
  - **Minimum TLS version: 1.2**
  - **FTP state: Disabled**
  - **HTTP version: 2.0**
  - **Always On: On**
- **Startup Command (Linux only):** `node server.mjs`
- **Application settings** (environment variables):

  | Name | Value | Why |
  |---|---|---|
  | `SCM_DO_BUILD_DURING_DEPLOYMENT` | `false` | The zip is already built; nothing to install |
  | `WEBSITE_RUN_FROM_PACKAGE` | `1` | Runs straight from the uploaded zip: atomic switch-over and read-only files |

Web App → **Monitoring → Health check**: enable it with path `/`.

### 4. Deploy

Use any one of these:
- **Azure CLI:**
  ```powershell
  az login
  az webapp deploy --resource-group rg-vidyasethu-web --name vidyasethu-web `
    --src-path dist\VidyaSethuWeb\vidyasethu-web.zip --type zip
  ```
- **VS Code:** install the *Azure App Service* extension. Right-click `dist\VidyaSethuWeb\package` → **Deploy to Web App…** → pick `vidyasethu-web`.
- **Portal / Kudu:** open `https://vidyasethu-web.scm.azurewebsites.net/ZipDeployUI` and drag `vidyasethu-web.zip` onto
  the page.

Then open `https://vidyasethu-web.azurewebsites.net`. The home page should load, and `/no-such-page` should show the
404 page.

### 5. Custom domain `vidyasethu.co.in` + `www`

Web App → **Settings → Custom domains → Add custom domain**. Choose *All other domain services* and **App Service
Managed Certificate** for TLS. The portal shows the exact records; add them at your DNS provider:

| Host | Type | Value |
|---|---|---|
| `@` (vidyasethu.co.in) | **A** | the Web App's inbound IP address (shown in the dialog) |
| `asuid` | **TXT** | the Custom Domain Verification ID (shown in the dialog) |
| `www` | **CNAME** | `vidyasethu-web.azurewebsites.net` |
| `asuid.www` | **TXT** | the same verification ID |

1. Add `vidyasethu.co.in`, then add `www.vidyasethu.co.in`. Each gets a free managed certificate (SNI SSL), renewed
   automatically. Certificates can take a few minutes to issue after DNS has propagated.
2. **HTTPS** is enforced by *HTTPS Only*. HSTS is sent by the site.
3. **www → apex:** handled by the site itself (`web.config` / `server.mjs`). After setup, check:
   ```bash
   curl -I https://www.vidyasethu.co.in/about     # 301 -> https://vidyasethu.co.in/about
   ```

### 6. Smoke test after every deployment

```bash
for p in / /about /organizations /organizations/padmashali-vidya-sethu /contact /privacy; do
  curl -s -o /dev/null -w "%{http_code} $p\n" https://vidyasethu.co.in$p; done          # all 200
curl -s -o /dev/null -w "%{http_code} 404-check\n" https://vidyasethu.co.in/no-such-page   # 404
curl -s -o /dev/null -w "%{http_code} hidden\n" https://vidyasethu.co.in/web.config        # 404
```

### 7. Monitoring

- **Uptime:** Application Insights → **Availability → Add standard test** on `https://vidyasethu.co.in/` and
  `/organizations/padmashali-vidya-sethu`, every 5 minutes from 3+ locations, with an email alert.
- **Server errors:** Web App → **Alerts → Create alert rule** on *Http Server Errors* (5xx) > 0 over 5 minutes.
  Health check (step 3) also replaces an unhealthy instance automatically.
- **Logs:** Web App → **App Service logs** (Linux: application logging to filesystem) and **Log stream**.
- **Browser JavaScript errors:** these need the Application Insights JS snippet. That adds a third-party script, so
  the CSP and privacy notice must be updated first.

### 8. Rollback

Redeploy the previous release zip (step 4) - for example:

```powershell
az webapp deploy --resource-group rg-vidyasethu-web --name vidyasethu-web --src-path vidyasethu-web-<previous>.zip --type zip
```

With no saved zip, rebuild from the last good commit (`git checkout <commit> -- Frontend/VidyaSethuWeb`, then step 1).

On **Standard** or higher, deploy to a `staging` slot instead and **Swap** with production. A rollback is then
another **Swap**, with no downtime.

The site has no database or server state, so a rollback never needs a data migration.

### 9. Updating the site

1. Edit the code or settings (e.g. the PVS address in `src/environments/environment.ts`).
2. Run `npm test` and `npm run build`.
3. Deploy the new zip (step 4) and run the smoke test (step 6).

### 10. Organization apps on their own subdomain

PVS runs at `https://pvs.vidyasethu.co.in` on its own Web App (`Docs/Deployment.md` "Member web app"); this site only
links to it (`organizationLinks.pvs.application`) and redirects the old `/pvs` addresses there.

Future organizations follow the same pattern (`{org}.vidyasethu.co.in`). A subdomain is only an address. The
organization application's backend must still check tenant identity and user permissions on every request.

### Alternative: Azure Static Web Apps

The build output also contains `staticwebapp.config.json`, so `dist/VidyaSethuWeb/browser` can be deployed to Azure
Static Web Apps unchanged:

```bash
npx @azure/static-web-apps-cli deploy ./dist/VidyaSethuWeb/browser --env production --deployment-token <token>
```

## Future multi-organization platform

This site is ready for more organizations without new components: listings, pages, prerendering and the sitemap
all come from the data file. Later work, in separate services:
- a secured platform-admin backend (`platform.vidyasethu.co.in`) that owns `VS_Organization`;
- tenant-aware organization applications with their own records and permissions;
- custom domains.

The PVS database stays separate unless a reviewed migration is approved.
