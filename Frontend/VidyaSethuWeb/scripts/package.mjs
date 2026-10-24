// Last step of `npm run build`: assembles the Azure App Service deployment package.
//
//   dist/VidyaSethuWeb/package/          the site + web.config (Windows/IIS) + server.mjs and package.json (Linux/Node)
//   dist/VidyaSethuWeb/vidyasethu-web.zip   the same, zipped for `az webapp deploy --type zip` / Deployment Center
//
// The same zip works on a Windows or a Linux Web App.
//
// The Padmashali Vidya Sethu web app is included at /pvs: build it first with `npm run build:pvs` (Flutter web build
// with base href /pvs/ in Frontend/padmashali_vidya_setu/build/web). It is copied into dist/VidyaSethuWeb/browser/pvs
// as well as the package, so uploading either the browser folder or the zip publishes it. The production site links
// to /pvs, so packaging stops if that build is missing or was made for another base href.
import { execFileSync } from 'node:child_process';
import { cpSync, existsSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const dist = join(root, 'dist', 'VidyaSethuWeb');
const browser = join(dist, 'browser');
const out = join(dist, 'package');
const zip = join(dist, 'vidyasethu-web.zip');

if (!existsSync(join(browser, 'index.html'))) {
  console.error('No build in dist/VidyaSethuWeb/browser. Run "npm run build".');
  process.exit(1);
}

rmSync(out, { recursive: true, force: true });
rmSync(zip, { force: true });

const pvsBuild = join(root, '..', 'padmashali_vidya_setu', 'build', 'web');
const pvsIndex = join(pvsBuild, 'index.html');
if (!existsSync(pvsIndex)) {
  console.error(
    'The PVS web app is not built (Frontend/padmashali_vidya_setu/build/web). Run "npm run build:pvs", then "npm run build".',
  );
  process.exit(1);
}
if (!readFileSync(pvsIndex, 'utf8').includes('<base href="/pvs/">')) {
  console.error('The PVS web app was built for another address. Run "npm run build:pvs" (base href /pvs/), then "npm run build".');
  process.exit(1);
}
rmSync(join(browser, 'pvs'), { recursive: true, force: true });
cpSync(pvsBuild, join(browser, 'pvs'), { recursive: true });
// Its own Static Web Apps file would clash with this site's routing; web.config / server.mjs serve /pvs.
rmSync(join(browser, 'pvs', 'staticwebapp.config.json'), { force: true });
cpSync(browser, out, { recursive: true });
console.log(`Included the PVS web app at /pvs (built ${statSync(pvsIndex).mtime.toISOString().slice(0, 16)} UTC).`);
cpSync(join(root, 'server', 'server.mjs'), join(out, 'server.mjs'));
writeFileSync(
  join(out, 'package.json'),
  JSON.stringify(
    {
      name: 'vidyasethu-web',
      private: true,
      type: 'module',
      description: 'VidyaSethu public website (prebuilt). No dependencies; nothing to install.',
      engines: { node: '>=20' },
      scripts: { start: 'node server.mjs' },
    },
    null,
    2,
  ) + '\n',
);

// Zip the folder contents (not the folder). Windows: bsdtar (tar.exe) writes zip entries with "/" separators,
// which Linux App Service needs - PowerShell 5 Compress-Archive does not.
const entries = readdirSync(out);
if (process.platform === 'win32') {
  execFileSync(
    join(process.env.SystemRoot ?? 'C:\\Windows', 'System32', 'tar.exe'),
    ['-a', '-c', '-f', zip, ...entries],
    {
      cwd: out,
    },
  );
} else {
  execFileSync('zip', ['-r', '-q', zip, ...entries], { cwd: out });
}

const files = countFiles(out);
console.log(
  `Package ready: ${files} files in dist/VidyaSethuWeb/package, ` +
    `dist/VidyaSethuWeb/vidyasethu-web.zip (${(statSync(zip).size / 1024).toFixed(0)} KB).`,
);

function countFiles(dir) {
  return readdirSync(dir).reduce((n, name) => {
    const full = join(dir, name);
    return n + (statSync(full).isDirectory() ? countFiles(full) : 1);
  }, 0);
}
