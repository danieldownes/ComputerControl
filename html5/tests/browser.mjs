// Optional browser acceptance tests. Set PLAYWRIGHT_PATH to an installed
// Playwright module and CC_URL to the running static site (default localhost).
import { createRequire } from 'node:module';
import assert from 'node:assert/strict';
import { readFile, mkdir } from 'node:fs/promises';
import { parseRecording } from '../dist/core.js';
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.PLAYWRIGHT_PATH || 'playwright');
const browser = await chromium.launch({ headless: true, ...(process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : {}) });
const url = process.env.CC_URL || 'http://127.0.0.1:4173';
await mkdir('.qa', { recursive: true });
const context = await browser.newContext({ viewport: { width: 1200, height: 1000 } });
const page = await context.newPage();
const errors = [];
page.on('pageerror', error => errors.push(error.message));
const output = async value => page.waitForFunction(value => document.getElementById('screen').dataset.output === String(value), value);
const panel = async value => page.waitForFunction(value => document.getElementById('screen').dataset.panel === value, value);
const key = async text => { await page.locator('#screen').focus(); await page.keyboard.press(text); };
const note = text => console.log('PASS:', text);
try {
  const response = await page.goto(url); assert.equal(response.status(), 200);
  await panel('welcome');
  assert.deepEqual(await page.locator('#screen').evaluate(c => [c.width, c.height, c.getBoundingClientRect().width, c.getBoundingClientRect().height]), [640,480,640,480]);
  await key('o');await panel('options');await key('c');await panel('colors');
  await page.locator('#screen').screenshot({path:'.qa/colors.png'});
  const differentPixels=await page.evaluate(async()=>{
    const image=new Image();image.src='assets/original-screen.png';await image.decode();
    const reference=document.createElement('canvas');reference.width=640;reference.height=480;
    const ctx=reference.getContext('2d');ctx.drawImage(image,0,0);
    const a=ctx.getImageData(0,0,640,480).data,b=document.getElementById('screen').getContext('2d').getImageData(0,0,640,480).data;
    let count=0;for(let i=0;i<a.length;i+=4)if(a[i]!==b[i]||a[i+1]!==b[i+1]||a[i+2]!==b[i+2])count++;return count;
  });
  assert.equal(differentPixels,0);note('all 307,200 Colour Settings pixels match the original bitmap');
  await key('e');await key('x');await panel('welcome');
  note('640×480 framebuffer, native display dimensions, and keyboard menus');

  await key('q');await output(128);assert.equal(await page.locator('[data-pin="9"]').getAttribute('data-level'),'H');
  await key('i');await output(129);await key('q');await output(1);await key('q');await output(129);
  await page.locator('[data-input-pin="11"]').click();
  await page.waitForFunction(()=>document.getElementById('screen').dataset.input==='128');
  assert.equal(await page.locator('#status-register').textContent(),'0xF8');
  await page.locator('[data-input-pin="15"]').click();
  await page.waitForFunction(()=>document.getElementById('status-register').textContent==='0xF0');
  assert.equal(await page.locator('#screen').getAttribute('data-input'),'128');
  await page.locator('[data-input-pin="1"]').click();
  await page.waitForFunction(()=>document.getElementById('screen').dataset.input==='129');
  note('output keys, numbered pins, physical polarity and the unused pin 15');

  await key('g');await key('4');await key('x');await key('q');await output(1);await key('4');await output(129);
  await page.locator('#groups-file').setInputFiles({name:'legacy.gro',mimeType:'text/plain',buffer:Buffer.from('1,2,3,44,5,6,7,8,9,255\r\n')});
  await page.waitForFunction(()=>document.querySelector('[data-group="4"]').textContent==='44');
  await key('4');await output(44);await key('0');await output(255);
  await page.locator('.groups-details summary').click();
  const groDownload = page.waitForEvent('download');await page.locator('#export-groups').click();
  assert.equal((await readFile(await (await groDownload).path(),'utf8')).trim(),'1,2,3,44,5,6,7,8,9,255');
  note('group bank 4, digit recall, and original .gro import/export order');

  await page.locator('#recording-file').setInputFiles({name:'test.rec',mimeType:'text/plain',buffer:Buffer.from('128,5.0E-02\n1,.05\n0,888\n')});
  await page.waitForFunction(()=>document.getElementById('transport-status').textContent.includes('test.rec loaded'));
  await page.locator('#play-button').click();await page.waitForFunction(()=>document.getElementById('transport-status').textContent.includes('Playback finished'));
  await output(0);
  await page.locator('#sample').selectOption('eg3.rec');await page.locator('#load-sample').click();
  await page.locator('#speed').selectOption('10');await page.locator('#play-button').click();await output(100);
  await page.waitForFunction(()=>document.getElementById('transport-status').textContent.includes('Playback finished'));await output(1);
  note('QBASIC .rec notation, original eg3.rec, 10× playback and final-byte retention');

  await page.locator('#record-button').click();await key('Enter');
  await page.waitForFunction(()=>document.body.dataset.recording==='true',{},{timeout:8000});
  await key('q');await page.waitForTimeout(120);await key('i');await page.waitForTimeout(150);await key('s');
  await page.waitForFunction(()=>document.getElementById('transport-status').textContent.startsWith('Recorded recording.rec'));
  const recDownload = page.waitForEvent('download');await page.locator('#export-recording').click();
  const rec = parseRecording(await readFile(await (await recDownload).path(),'utf8'));
  assert.deepEqual(rec.map(e=>e.value),[0,128,129,129]);assert.equal(rec.at(-1).duration,888);assert(rec[1].duration>=.1);await output(0);
  note('five-second countdown, real-time output recording, stop and .rec download');

  await page.locator('#edit-sequence').click();await page.locator('#sequence-name').fill('Scheduled.rec');
  await page.locator('#sequence-text').fill('256,1');await page.locator('#sequence-form button[type=submit]').click();assert.match(await page.locator('#sequence-error').textContent(),/0 to 255/);
  await page.locator('#sequence-text').fill('42,.05\n0,888');await page.locator('#sequence-form button[type=submit]').click();
  await page.locator('#schedule-button').click();await page.locator('#schedule-recording').selectOption('Scheduled.rec');
  const at=new Date(Date.now()+2500);const local=new Date(at.getTime()-at.getTimezoneOffset()*60000).toISOString().slice(0,19);
  await page.locator('#schedule-time').fill(local);await page.locator('#schedule-form button[type=submit]').click();
  await page.waitForFunction(()=>document.getElementById('schedule-list').textContent.includes('Bank 1'));
  await page.locator('#schedule-dialog button[aria-label="Close scheduler"]').click();
  await page.waitForFunction(()=>document.getElementById('transport-status').textContent.includes('Playback finished'));
  await page.locator('#schedule-button').click();assert.match(await page.locator('#schedule-list').textContent(),/completed/);
  const future=new Date(Date.now()+600000);await page.locator('#schedule-time').fill(new Date(future.getTime()-future.getTimezoneOffset()*60000).toISOString().slice(0,19));
  await page.locator('#schedule-form button[type=submit]').click();await page.locator('#schedule-dialog button[aria-label="Close scheduler"]').click();
  note('variable recording validation, scheduler creation, due playback and completion');

  await page.locator('#output-byte').fill('85');await page.locator('#byte-form button').click();await output(85);
  await page.locator('#port-select').selectOption('1');await output(0);await page.locator('#port-select').selectOption('0');await output(85);
  await page.locator('#home-button').click();await key('o');await key('q');await key('s');await panel('welcome');
  await page.reload();await panel('welcome');await page.waitForTimeout(1450);
  assert.equal(await page.locator('[data-group="4"]').textContent(),'44');
  await page.locator('#schedule-button').click();assert.match(await page.locator('#schedule-list').textContent(),/paused/);await page.locator('#schedule-dialog button[aria-label="Close scheduler"]').click();
  await key('o');await key('q');await key('s');
  await page.locator('#groups-button').click();await key('x');
  await key('l');await key('1');await panel('plugin');await page.locator('[data-input-pin="10"]').click();await output(64);await key('x');await panel('welcome');
  note('independent ports, saved settings and groups, paused restored schedules, plugin demo');

  for(const width of [1200,736,320]){
    await page.setViewportSize({width,height:1100});await page.waitForTimeout(100);
    const size=await page.locator('#screen').evaluate(c=>({native:[c.width,c.height],shown:[c.clientWidth,c.clientHeight],overflow:document.documentElement.scrollWidth>innerWidth}));
    assert.deepEqual(size.native,[640,480]);assert.equal(size.overflow,false);assert(Math.abs(size.shown[1]/size.shown[0]-.75)<.005);
    if(width===320)await page.screenshot({path:'.qa/mobile.png',fullPage:true});
  }
  assert.deepEqual(errors,[]);note('native framebuffer on narrow screens, no horizontal overflow, no runtime errors');
  await page.setViewportSize({width:1200,height:1000});await page.locator('#home-button').click();await page.screenshot({path:'.qa/final.png',fullPage:true});
  const privateContext=await browser.newContext();await privateContext.addInitScript(()=>Object.defineProperty(window,'localStorage',{get(){throw new Error('Unavailable')}}));
  const privatePage=await privateContext.newPage();await privatePage.goto(url);await privatePage.locator('#load-sample').click();assert.match(await privatePage.locator('#transport-status').textContent(),/storage is unavailable/);await privateContext.close();
  note('conversion remains usable when browser storage is blocked');
} finally { await browser.close(); }
