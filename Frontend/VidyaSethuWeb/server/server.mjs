// VidyaSethu website server for Azure App Service on Linux (Node 20+). No dependencies.
// Deployed next to the built site (npm run build -> dist/VidyaSethuWeb/package). On Windows App Service, IIS serves the
// files with web.config instead and this file is not used.
//
// Same behaviour as web.config:
//  * www.vidyasethu.co.in -> https://vidyasethu.co.in (301); http -> https behind the App Service front end (301)
//  * "/about/" -> "/about" (301); "/about" is served from about/index.html
//  * unknown addresses -> /404/index.html with status 404 (no SPA fallback)
//  * security headers from staticwebapp.config.json (CSP hashes written by scripts/postbuild.mjs)
//  * long caching for hashed bundles, gzip for text
//
// Start: node server.mjs     (PORT from the environment - App Service sets it; default 4400 locally)
import { createServer } from 'node:http';
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, extname, join, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { gzipSync } from 'node:zlib';

const root = dirname(fileURLToPath(import.meta.url));
const port = Number(process.env.PORT ?? 4400);
const canonicalHost = process.env.CANONICAL_HOST ?? 'vidyasethu.co.in';
const headers = JSON.parse(
  readFileSync(join(root, 'staticwebapp.config.json'), 'utf8'),
).globalHeaders;

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json',
  '.xml': 'application/xml',
  '.txt': 'text/plain; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.ico': 'image/x-icon',
  '.webmanifest': 'application/manifest+json',
};
const COMPRESSIBLE = new Set([
  '.html',
  '.js',
  '.css',
  '.json',
  '.xml',
  '.txt',
  '.svg',
  '.webmanifest',
]);
const HIDDEN = new Set([
  'server.mjs',
  'package.json',
  'web.config',
  'staticwebapp.config.json',
  'prerendered-routes.json',
  'index.csr.html',
]);

// The site is small and immutable per deployment: load every servable file once.
const files = new Map();
for (const full of walk(root)) {
  const path = '/' + relative(root, full).split(sep).join('/');
  const ext = extname(full).toLowerCase();
  if (!TYPES[ext] || HIDDEN.has(path.slice(1)) || path.split('/').some((s) => s.startsWith('.')))
    continue;
  const body = readFileSync(full);
  files.set(path, {
    body,
    gzip: COMPRESSIBLE.has(ext) && body.length > 1024 ? gzipSync(body) : null,
    type: TYPES[ext],
    cache: cacheControl(path, ext),
  });
}
const notFound = files.get('/404/index.html');

createServer((req, res) => {
  const host = (req.headers.host ?? '').toLowerCase().split(':')[0];
  const url = new URL(req.url ?? '/', 'http://localhost');

  if (host === `www.${canonicalHost}`)
    return redirect(res, `https://${canonicalHost}${url.pathname}${url.search}`);
  // App Service terminates TLS; the original scheme arrives in X-Forwarded-Proto.
  if (req.headers['x-forwarded-proto'] === 'http') {
    return redirect(res, `https://${req.headers.host}${url.pathname}${url.search}`);
  }
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.writeHead(405, { ...headers, Allow: 'GET, HEAD' });
    return res.end();
  }

  let path;
  try {
    path = decodeURIComponent(url.pathname);
  } catch {
    path = '/__invalid__';
  }
  if (path.length > 1 && path.endsWith('/'))
    return redirect(res, path.replace(/\/+$/, '') + url.search);

  const file = files.get(path) ?? files.get(path === '/' ? '/index.html' : `${path}/index.html`);
  send(req, res, file ?? notFound, file ? 200 : 404);
}).listen(port, () =>
  console.log(`VidyaSethu website: ${files.size} files from ${root}, port ${port}`),
);

function send(req, res, file, status) {
  const gzip = file.gzip && /\bgzip\b/.test(req.headers['accept-encoding'] ?? '');
  const body = gzip ? file.gzip : file.body;
  res.writeHead(status, {
    ...headers,
    'Content-Type': file.type,
    'Content-Length': body.length,
    'Cache-Control': status === 200 ? file.cache : 'no-cache',
    Vary: 'Accept-Encoding',
    ...(gzip ? { 'Content-Encoding': 'gzip' } : {}),
  });
  res.end(req.method === 'HEAD' ? undefined : body);
}

function redirect(res, location) {
  res.writeHead(301, { Location: location });
  res.end();
}

function cacheControl(path, ext) {
  if (/^\/(main|chunk|styles|polyfills)-[A-Z0-9]+\.(js|css)$/.test(path))
    return 'public, max-age=31536000, immutable';
  if (/^\/(brand|organizations)\//.test(path) && ext !== '.html') return 'public, max-age=86400';
  return 'no-cache';
}

function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    const full = join(dir, name);
    return statSync(full).isDirectory() ? walk(full) : [full];
  });
}
