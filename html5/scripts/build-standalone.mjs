// Produce a self-contained HTML file that also runs directly from disk.
import { readFile, writeFile } from 'node:fs/promises';
const dist = new URL('../dist/', import.meta.url);
const get = name => readFile(new URL(name, dist), 'utf8');
let html = await get('index.html');
const css = await get('style.css');
const data = await get('legacy-data.js');
const core = (await get('core.js')).replace(/^export /gm, '');
const renderer = (await get('renderer.js')).replace(/^export /gm, '');
const app = (await get('app.js')).replace(/^import .*?;\r?\n/gm, '');
const escapeScript = value => value.replace(/<\/script/gi, '<\\/script');
html = html.replace('<link rel="stylesheet" href="style.css">', `<style>\n${css}\n</style>`)
  .replace('<script src="legacy-data.js" defer></script>', `<script>\n${escapeScript(data)}\n</script>`)
  .replace('<script type="module" src="app.js"></script>', `<script type="module">\n${escapeScript(core+'\n'+renderer+'\n'+app)}\n</script>`);
for (const name of ['original-wiring.png', 'original-screen.png']) {
  const bytes = await readFile(new URL('assets/'+name, dist));
  const dataUrl = 'data:image/png;base64,' + bytes.toString('base64');
  html = html.replaceAll('href="assets/'+name+'" target="_blank" rel="noopener"', 'href="'+dataUrl+'" download="'+name+'"');
  html = html.replaceAll("'assets/"+name+"'", "'"+dataUrl+"'");
}
await writeFile(new URL('computer-control.html', dist), html);
console.log('Built dist/computer-control.html · standalone, no server required.');
