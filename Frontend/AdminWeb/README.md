# PVS Admin Web

Web admin portal for Padmashali Vidya Sethu - Angular 21 (standalone components, signals), SCSS.

## Run locally

1. Start the API: `RunBackend\Start_Backend_API.bat` (http://localhost:5274).
2. Start the portal: `RunFrontend\Start_Admin_Web.bat`, or:

   ```bash
   cd Frontend/AdminWeb
   npx -y npm@11 install      # first time only (see note below)
   npx ng serve --open        # http://localhost:4200
   ```

3. Sign in with the mobile number and password of an **ADMIN** or **SUPER_ADMIN**. The first Super Admin's password is
   set with `Database/seed/05_SetSuperAdminPassword.TEMPLATE.sql`; everyone else's on the Admin users page.

> **npm note:** npm 10.9.x (bundled with Node 22.21) fails on this project with
> `Cannot read properties of null (reading 'edgesOut')`. Use `npx -y npm@11 install` or upgrade Node/npm.
> Angular 22 needs Node 22.22.3+; the project uses Angular 21 so it runs on the current Node.

## Commands

| Command | What it does |
|---|---|
| `npx ng serve` | Dev server with live reload; API at `http://localhost:5274` (`src/environments/environment.development.ts`) |
| `npm run build` | Production build into `dist/AdminWeb/browser`, then `scripts/package.mjs` → `dist/AdminWeb/pvs-admin-web.zip` (Azure Web App package); calls the API at `https://api.pvs.vidyasethu.co.in` |
| `npm run serve:dist` | Runs the deployment package with its own `server.mjs`, as on a Linux Web App (http://localhost:4500) |
| `npx ng test --watch=false` | Unit tests (Vitest) |

## How sign-in works

* Mobile number + password (`POST /api/v1/auth/admin/sign-in`) - no verification code. Passwords are set by a Super
  Admin on the Admin users page; there is no self-service change or "forgot password". 5 wrong passwords in a row lock
  the password for 15 minutes. Setting a new password signs that admin out everywhere.
* After sign-in the portal calls `GET /api/v1/admin/me`; the API allows only Admin / Super Admin. Anyone else is
  signed out with "This mobile number does not have admin access".
* Tokens are kept in `sessionStorage` (closing the browser signs out); an expired access token is refreshed once
  automatically (`core/auth.interceptor.ts`).
* Roles are read when tokens are issued, so a newly granted role applies at the next sign-in. The first Super Admin
  and their password are set with `Database/seed/05_SetSuperAdminPassword.TEMPLATE.sql`; after that, use the Admin
  users page.

## Pages

| Page | What it does |
|---|---|
| Dashboard | Totals and breakdowns of active members (temple, status, age group, gender, district, month) |
| Members | Search and filter (temple, status, class, state/district, age, active); export to Excel (CSV); member detail with deactivate / reactivate |
| "Other" values | Super Admin only: texts members typed after choosing "Other" - map to an existing entry or add as a new entry; members are moved to it |
| Master lists | Super Admin only: add, rename, reorder, activate / deactivate entries of every list (temples need a 2-digit code) |
| Locations | Review districts / taluks added by PIN lookups or members: rename, deactivate, merge duplicate taluks |
| Splash sponsor | Super Admin only: sponsor name, optional sponsor logo and "Powered by" text shown at the bottom of the app's splash screen, with a live preview |
| Admin users | Super Admin only: grant / remove Admin and Super Admin by mobile number |

Admins see Dashboard, Members and Locations. Disability details on the member page are shown to Super Admins only.

## Structure

```
src/app/
  core/      api.ts (envelope, error text), models.ts, admin-api.service.ts (all admin calls),
             auth.service.ts, auth.interceptor.ts, admin.guard.ts (admin + super admin guards)
  layout/    shell - top bar, side navigation, content area
  pages/     login, dashboard, members (+ member-detail), other-values, lists, locations, admin-users
src/environments/   apiBaseUrl per build
public/             images, robots.txt (no indexing), web.config (Windows Web App),
                    staticwebapp.config.json (security headers; also read by server.mjs)
server/             server.mjs - production web server for a Linux Web App (no dependencies)
scripts/            package.mjs (Web App zip)
```

New admin pages go under `pages/`, are added as children of the `Shell` route in `app.routes.ts` (protected by
`adminGuard`) and get a link in `layout/shell.html`. Their API endpoints go in an `Admin*Controller`
(`Backend/.../Controllers`, `[Authorize(Policy = Policies.Admin)]`) backed by a service in `Services/Admin`.

## Deployment - https://pvs-admin.vidyasethu.co.in

| Address | What it is |
|---|---|
| `https://pvs-admin.vidyasethu.co.in` | This admin portal (Azure App Service Web App) |
| `https://api.pvs.vidyasethu.co.in` | The PVS API (its own App Service) - set in `src/environments/environment.ts` |

If the API host changes, update `environment.ts` **and** the CSP (`connect-src`, `img-src`) in both
`public/staticwebapp.config.json` and `public/web.config`.

### What `npm run build` produces

```
dist/AdminWeb/
  pvs-admin-web.zip   <- upload this to the Web App
  package/            the same files, unzipped: index.html, bundles, images, robots.txt,
                      web.config (Windows/IIS), server.mjs + package.json (Linux/Node)
```

The same zip works on Windows and Linux Web Apps, with the same behaviour:
- any address that is not a file (e.g. `/members/PVS123`) is served `index.html`, so refreshing a page works;
- `server.mjs`, `web.config`, `package.json` and `staticwebapp.config.json` are never served;
- security headers: CSP (only this site and the API), HSTS, `nosniff`, `X-Frame-Options: DENY`,
  `X-Robots-Tag: noindex`;
- hashed bundles cached for a year, `index.html` always revalidated.

Critical-CSS inlining is switched off in `angular.json` (production): it adds an inline `onload` handler that the
CSP (`script-src 'self'`) would block, leaving the portal unstyled.

### Steps

1. **Build:** `npx -y npm@11 ci`, `npx ng test --watch=false`, `npm run build`. Keep each released zip as the
   rollback copy. Optionally check it with `npm run serve:dist`.
2. **Create the Web App** (Azure portal → Web App): Publish **Code**, Runtime **Node 22 LTS**, OS **Linux** (or
   Windows), region Central India, plan **Basic B1** or higher (Free F1 cannot use a custom domain with HTTPS).
3. **Configure:** HTTPS Only **On**, minimum TLS 1.2, FTP **Disabled**, Always On **On**;
   Startup Command (Linux only) `node server.mjs`; application settings `SCM_DO_BUILD_DURING_DEPLOYMENT=false`,
   `WEBSITE_RUN_FROM_PACKAGE=1`; Health check path `/`.
4. **Deploy:**
   ```powershell
   az webapp deploy --resource-group <rg> --name <pvs-admin-app> --src-path dist\AdminWeb\pvs-admin-web.zip --type zip
   ```
5. **Custom domain** (Web App → Custom domains → Add, *App Service Managed Certificate*). At the DNS provider of
   `vidyasethu.co.in`:

   | Host | Type | Value |
   |---|---|---|
   | `pvs-admin` | **CNAME** | `<pvs-admin-app>.azurewebsites.net` |
   | `asuid.pvs-admin` | **TXT** | the Custom Domain Verification ID shown in the dialog |

6. **API** (`api.pvs.vidyasethu.co.in`, its own Web App - see `Docs/Deployment.md`): add the application setting
   `Cors__AllowedOrigins__0` = `https://pvs-admin.vidyasethu.co.in` (no trailing slash). Without it every sign-in fails
   with "Cannot reach the server".
7. **Smoke test:**
   ```bash
   for p in / /login /members /robots.txt; do curl -s -o /dev/null -w "%{http_code} $p\n" https://pvs-admin.vidyasethu.co.in$p; done  # 200
   curl -s -o /dev/null -w "%{http_code} hidden\n" https://pvs-admin.vidyasethu.co.in/web.config                                     # 404
   ```
   Then sign in with an admin mobile number and open the Dashboard.

Rollback: redeploy the previous zip (step 4).
