// Refresh both browser distribution forms without adding build dependencies.
import { spawnSync } from 'node:child_process';
import { copyFile, mkdir, writeFile } from 'node:fs/promises';
const root = new URL('../', import.meta.url);
const result = spawnSync(process.execPath, ['html5/scripts/build-standalone.mjs'], { cwd: root, stdio: 'inherit' });
if (result.status !== 0) process.exit(result.status || 1);
await mkdir(new URL('docs/', root), { recursive: true });
await copyFile(new URL('html5/dist/computer-control.html', root), new URL('docs/index.html', root));
await writeFile(new URL('docs/.nojekyll', root), '');
console.log('Updated docs/index.html for GitHub Pages (main /docs).');
