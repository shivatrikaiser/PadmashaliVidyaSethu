// PVS admin portal server for Azure App Service on Linux (Node 20+). No dependencies.
// Deployed next to the built portal (npm run build -> dist/AdminWeb/package). On Windows App Service, IIS serves the
// files with web.config instead and this file is not used.
//
// Same behaviour as web.config:
//  * http -> https behind the App Service front end (301)
//  * files are served as they are; any other address gets index.html (client-side routes)
//  * security headers from staticwebapp.config.json
//  * long caching for hashed bundles, gzip for text
//
// Start: node server.mjs     (PORT from the environment - App Service sets it; default 4500 locally)
import { createServer } from 'node:http';
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, extname, join, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { gzipSync } from 'node:zlib';

const root = dirname(fileURLToPath(import.meta.url));
const port = Number(process.env.PORT ?? 4500);
const headers = JSON.parse(
  readFileSync(join(root, 'staticwebapp.config.json'), 'utf8'),
).globalHeaders;

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json',
  '.txt': 'text/plain; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.ico': 'image/x-icon',
};
const COMPRESSIBLE = new Set(['.html', '.js', '.css', '.json', '.txt', '.svg']);
const HIDDEN = new Set(['server.mjs', 'package.json', 'web.config', 'staticwebapp.config.json']);

// The portal is small and immutable per deployment: load every servable file once.
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
    cache: /^\/(main|chunk|styles|polyfills)-[A-Z0-9]+\.(js|css)$/.test(path)
      ? 'public, max-age=31536000, immutable'
      : 'no-cache',
  });
}
const app = files.get('/index.html');

createServer((req, res) => {
  const url = new URL(req.url ?? '/', 'http://localhost');

  // App Service terminates TLS; the original scheme arrives in X-Forwarded-Proto.
  if (req.headers['x-forwarded-proto'] === 'http') {
    res.writeHead(301, { Location: `https://${req.headers.host}${url.pathname}${url.search}` });
    return res.end();
  }
  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.writeHead(405, { ...headers, Allow: 'GET, HEAD' });
    return res.end();
  }

  let path;
  try {
    path = decodeURIComponent(url.pathname);
  } catch {
    path = '/';
  }
  const file = files.get(path);
  // A missing bundle or image is a real 404; anything else is a portal route.
  if (!file && extname(path) && path !== '/index.html') {
    res.writeHead(404, { ...headers, 'Content-Type': 'text/plain; charset=utf-8' });
    return res.end('Not found');
  }
  send(req, res, file ?? app);
}).listen(port, () => console.log(`PVS admin portal: ${files.size} files from ${root}, port ${port}`));

function send(req, res, file) {
  const gzip = file.gzip && /\bgzip\b/.test(req.headers['accept-encoding'] ?? '');
  const body = gzip ? file.gzip : file.body;
  res.writeHead(200, {
    ...headers,
    'Content-Type': file.type,
    'Content-Length': body.length,
    'Cache-Control': file.cache,
    Vary: 'Accept-Encoding',
    ...(gzip ? { 'Content-Encoding': 'gzip' } : {}),
  });
  res.end(req.method === 'HEAD' ? undefined : body);
}

function walk(dir) {
  return readdirSync(dir).flatMap((name) => {
    const full = join(dir, name);
    return statSync(full).isDirectory() ? walk(full) : [full];
  });
}
