// Runs after `ng build` (npm run build):
//  1. writes sitemap.xml from the prerendered routes (canonical siteUrl from src/environments/environment.ts);
//  2. fails if the output contains localhost / private-network addresses, placeholder hosts or secret-like values;
//  3. fails if a prerendered page links to a local asset or page that does not exist;
//  4. fails if an expected page was not prerendered;
//  5. allows the framework's inline scripts (hydration event replay) in the CSP by SHA-256 hash - never 'unsafe-inline'.
//     The policy is written into both staticwebapp.config.json (read by server.mjs) and web.config (IIS).
// `npm run verify` runs the same checks again on an existing build.
import { createHash } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { dirname, extname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const dist = join(root, 'dist', 'VidyaSethuWeb');
const browser = join(dist, 'browser');
const problems = [];

if (!existsSync(browser)) {
  console.error(`No build output at ${browser}. Run "npm run build" first.`);
  process.exit(1);
}

// ---------------------------------------------------------------- Routes
const env = readFileSync(join(root, 'src', 'environments', 'environment.ts'), 'utf8');
const siteUrl = /siteUrl:\s*'([^']+)'/.exec(env)?.[1];
if (!siteUrl?.startsWith('https://'))
  problems.push(`environment.ts siteUrl must be an https URL (found ${siteUrl}).`);

const prerendered = JSON.parse(readFileSync(join(dist, 'prerendered-routes.json'), 'utf8'));
const routes = Array.isArray(prerendered.routes)
  ? prerendered.routes
  : Object.keys(prerendered.routes ?? {});

const expected = [
  '/',
  '/about',
  '/features',
  '/organizations',
  '/organizations/padmashali-vidya-sethu',
  '/organizations/padmashali-vidya-sethu/privacy',
  '/organizations/padmashali-vidya-sethu/terms',
  '/organizations/padmashali-vidya-sethu/delete-account',
  '/for-organizations',
  '/for-students',
  '/for-job-seekers',
  '/contact',
  '/privacy',
  '/terms',
  '/accessibility',
  '/404',
];
for (const route of expected) {
  if (!routes.includes(route)) problems.push(`Route ${route} was not prerendered.`);
}
for (const route of routes) {
  const file =
    route === '/' ? join(browser, 'index.html') : join(browser, ...route.split('/'), 'index.html');
  if (!existsSync(file))
    problems.push(`Prerendered route ${route} has no ${relative(browser, file)}.`);
}

// ---------------------------------------------------------------- Sitemap
if (siteUrl) {
  const today = new Date().toISOString().slice(0, 10);
  const urls = routes
    .filter((r) => r !== '/404')
    .sort()
    .map(
      (r) => `  <url><loc>${siteUrl}${r === '/' ? '/' : r}</loc><lastmod>${today}</lastmod></url>`,
    )
    .join('\n');
  writeFileSync(
    join(browser, 'sitemap.xml'),
    `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls}\n</urlset>\n`,
  );
}

// ---------------------------------------------------------------- CSP hashes for inline scripts
const swaConfigPath = join(browser, 'staticwebapp.config.json');
const swaConfig = JSON.parse(readFileSync(swaConfigPath, 'utf8'));
const hashes = new Set();
for (const file of walk(browser).filter((f) => f.endsWith('.html'))) {
  for (const [, attrs, body] of readFileSync(file, 'utf8').matchAll(
    /<script\b([^>]*)>([\s\S]*?)<\/script>/g,
  )) {
    if (/\bsrc=/.test(attrs) || /type="application\/json"/.test(attrs) || !body.trim()) continue;
    // Only Angular's event-replay scripts are allowed; any other inline script is a problem to review.
    const replay =
      /id="ng-event-dispatch-contract"/.test(attrs) ||
      /^window\.__jsaction_bootstrap\(/.test(body.trim());
    if (!replay) {
      problems.push(
        `${relative(browser, file)}: unexpected inline script ("${body.trim().slice(0, 60)}").`,
      );
      continue;
    }
    hashes.add(`'sha256-${createHash('sha256').update(body, 'utf8').digest('base64')}'`);
  }
}
const csp = swaConfig.globalHeaders['Content-Security-Policy'];
const scriptSrc = `script-src 'self'${[...hashes].map((h) => ` ${h}`).join('')}`;
swaConfig.globalHeaders['Content-Security-Policy'] = csp.replace(/script-src [^;]*/, scriptSrc);
writeFileSync(swaConfigPath, JSON.stringify(swaConfig, null, 2) + '\n');

// Same policy for Windows App Service (IIS). server.mjs (Linux) reads staticwebapp.config.json.
const webConfigPath = join(browser, 'web.config');
const webConfig = readFileSync(webConfigPath, 'utf8');
const cspPattern = /(name="Content-Security-Policy" value="[^"]*?)script-src [^;"]*/;
if (!cspPattern.test(webConfig))
  problems.push('web.config has no Content-Security-Policy script-src to update.');
writeFileSync(webConfigPath, webConfig.replace(cspPattern, `$1${scriptSrc}`));

// ---------------------------------------------------------------- Forbidden content
const files = walk(browser).filter((f) =>
  ['.js', '.html', '.json', '.txt', '.xml', '.css', '.webmanifest'].includes(extname(f)),
);
const forbidden = [
  [/(https?:)?\/\/localhost\b/i, 'localhost URL'],
  [/(https?:)?\/\/(127\.0\.0\.1|\[::1\])/, 'loopback URL'],
  [/(https?:)?\/\/10\.0\.2\.2\b/, 'Android emulator host URL'],
  [
    /(https?:)?\/\/(192\.168|10\.\d{1,3}|172\.(1[6-9]|2\d|3[01]))\.\d{1,3}\.\d{1,3}/,
    'private network URL',
  ],
  [/example\.(org|com)/i, 'placeholder host'],
  [/connectionstring|signingkey|apikey|password\s*[:=]/i, 'secret-like setting'],
  [/environmentName:\s*["']development/, 'development configuration'],
  [/allowLocalhostLinks:\s*(!0|true)/, 'localhost links enabled'],
];
for (const file of files) {
  const text = readFileSync(file, 'utf8');
  for (const [pattern, label] of forbidden) {
    const match = pattern.exec(text);
    if (match)
      problems.push(`${relative(browser, file)}: ${label} ("${excerpt(text, match.index)}").`);
  }
}

// ---------------------------------------------------------------- Local links and assets in prerendered pages
for (const file of files.filter((f) => f.endsWith('.html'))) {
  const html = readFileSync(file, 'utf8');
  for (const [, attr, value] of html.matchAll(/\s(href|src)="([^"]+)"/g)) {
    if (/^(https?:|mailto:|tel:|data:|#)/.test(value)) continue;
    const path = decodeURI(value.split(/[?#]/)[0]).replace(/^\//, '');
    if (!path) continue;
    const target = join(browser, ...path.split('/'));
    const ok =
      (existsSync(target) && statSync(target).isFile()) || existsSync(join(target, 'index.html'));
    if (!ok)
      problems.push(`${relative(browser, file)}: ${attr}="${value}" does not exist in the build.`);
  }
}

if (problems.length) {
  console.error(`\nBuild verification FAILED (${problems.length}):`);
  for (const p of [...new Set(problems)]) console.error(`  - ${p}`);
  process.exit(1);
}
console.log(
  `Build verified: ${routes.length} prerendered pages, sitemap.xml written, ${hashes.size} inline script hash(es) in CSP, no forbidden content.`,
);

function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    // browser/pvs is the PVS Flutter web app copied in by package.mjs - checked by its own build, not this site's.
    if (dir === browser && name === 'pvs') return [];
    const full = join(dir, name);
    return statSync(full).isDirectory() ? walk(full) : [full];
  });
}

function excerpt(text, index) {
  return text.slice(Math.max(0, index - 30), index + 40).replace(/\s+/g, ' ');
}
