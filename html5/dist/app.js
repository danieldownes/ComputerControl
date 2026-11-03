import { LptPort, OUTPUT_KEYS, INPUT_PINS, BASE_ADDRESSES, parseRecording, formatRecording, recordingDuration, parseGroups, formatGroups, SequencePlayer, RealtimeRecorder, dueSchedules, byte } from './core.js';
import { VgaScreen, DEFAULT_PALETTE } from './renderer.js';

const $ = id => document.getElementById(id);
const legacy = window.CC_LEGACY;
const screen = new VgaScreen($('screen'), legacy);
const transportArt = Uint8Array.from(atob(legacy.transport), c => c.charCodeAt(0));
const STORAGE_KEY = 'computer-control-b5-v1';
const hex = n => '0x' + n.toString(16).toUpperCase().padStart(n > 255 ? 3 : 2, '0');
const sec = n => Number(n.toFixed(3)).toString();
const safeName = (name, extension) => (String(name).split(/[\\/]/).pop().replace(/[<>:"|?*\x00-\x1f]/g, '').slice(0, 100) || 'untitled') + (String(name).toLowerCase().endsWith(extension) ? '' : extension);
let stored = {};
let storageAvailable = true;
try { stored = JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}') || {}; } catch { storageAvailable = false; }
const defaults = () => ({ port: 0, melt: false, quick: false, startupGroups: false, palette: DEFAULT_PALETTE.slice() });
const validPalette = p => Array.isArray(p) && p.length === 16 && p.every(c => /^#[0-9a-f]{6}$/i.test(c));
let settings = { ...defaults(), ...(stored.settings || {}) };
if (!validPalette(settings.palette)) settings.palette = DEFAULT_PALETTE.slice();
if (![0, 1, 2].includes(settings.port)) settings.port = 0;
screen.setPalette(settings.palette);
let savedSettings = structuredClone(settings);
const ports = BASE_ADDRESSES.map(base => new LptPort(base));
let groups = Array.isArray(stored.groups) && stored.groups.length === 10 && stored.groups.every(n => Number.isInteger(n) && n >= 0 && n <= 255) ? stored.groups : Array(10).fill(0);
let groupName = settings.startupGroups && stored.groupName ? String(stored.groupName).slice(0, 100) : 'Group file not loaded';
let groupUsed = false;
let library = new Map();
for (const item of Object.values(legacy.recordings)) library.set(item.name, { name: item.name, events: parseRecording(item.text) });
for (const item of Array.isArray(stored.recordings) ? stored.recordings : []) {
  try { if (typeof item.name === 'string') library.set(item.name.slice(0, 100), { name: item.name.slice(0, 100), events: parseRecording(item.text) }); } catch { /* Ignore invalid saved files. */ }
}
let schedules = Array.from({ length: 6 }, (_, i) => {
  const s = stored.schedules?.[i];
  return s && typeof s.name === 'string' && Number.isFinite(Date.parse(s.at)) ? { name: s.name, at: s.at, enabled: false, fired: Boolean(s.fired) } : { name: '', at: '', enabled: false, fired: false };
});
let panel = 'welcome', loaded = null, selectedPin = 9, prompt = null, optionDraft = null;
let dirty = true, startupUntil = settings.quick ? performance.now() + 1300 : 0;
let recordingName = 'recording.rec', countdownUntil = 0, recorder = new RealtimeRecorder();
let plugin = false, lastPluginInput = -1, transitionUntil = 0;
let lastTick = 0, lastScheduleCheck = 0, lastUiTime = 0;
let scheduleDraft = {};
let messageUntil = 0, screenMessage = '';
let byteEditing = false;

const port = () => ports[settings.port];
function status(message) { $('transport-status').textContent = message + (storageAvailable ? '' : ' Browser storage is unavailable; export files to keep them.'); }
function save() {
  try {
    const saved = { settings: savedSettings, groups, groupName, schedules, recordings: [...library.values()].filter(r => !legacy.recordings[r.name] || formatRecording(r.events) !== legacy.recordings[r.name].text).map(r => ({ name: r.name, text: formatRecording(r.events) })) };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(saved));
  } catch { storageAvailable = false; }
}
function announce(message) { screenMessage = message.slice(0, 36); messageUntil = performance.now() + 2500; status(message); dirty = true; }
function mark() { dirty = true; }
function setData(value, manual = false) {
  value = byte(value);
  if (manual && player.playing) { player.stop(); status('Playback interrupted by manual output control.'); }
  recorder.change(value, performance.now());
  port().write(port().base, value); groupUsed = false; mark();
}
const player = new SequencePlayer(value => setData(value), () => { status('Playback finished. Final output retained: ' + port().data + '.'); save(); mark(); });

function download(name, text) {
  const url = URL.createObjectURL(new Blob([text], { type: 'text/plain;charset=utf-8' }));
  const a = document.createElement('a'); a.href = url; a.download = name; a.click();
  setTimeout(() => URL.revokeObjectURL(url), 5000);
}
function load(item) {
  if (recorder.active || countdownUntil) stopAll();
  player.stop(); loaded = item; library.set(item.name, item); panel = 'welcome'; prompt = null;
  status(`${item.name} loaded · ${sec(recordingDuration(item.events))} seconds · ${item.events.filter(e => e.duration !== 888).length} timed steps.`);
  save(); mark();
}
function play() {
  if (recorder.active || countdownUntil) stopAll();
  if (!loaded) { panel = 'record'; announce('Select an example or open a .rec file.'); return; }
  plugin = false; panel = 'welcome'; prompt = null; groupUsed = false;
  player.start(loaded.events, performance.now(), Number($('speed').value));
  status(`Playing ${loaded.name} · ${$('speed').value}× speed.`); mark();
}
function stopAll() {
  player.stop(); plugin = false;
  if (recorder.active) {
    const events = recorder.stop(performance.now());
    loaded = { name: recordingName, events }; library.set(loaded.name, loaded); save();
    status(`Recorded ${loaded.name} · ${sec(recordingDuration(events))} seconds. Use Save .rec to export.`);
  } else status(countdownUntil ? 'Recording cancelled.' : 'Stopped. All data outputs LOW.');
  countdownUntil = 0; port().write(port().base, 0); mark();
}
function startRecording(name) {
  if (recorder.active || countdownUntil) stopAll();
  player.stop(); plugin = false; recordingName = safeName(name, '.rec');
  panel = 'welcome'; prompt = null; countdownUntil = performance.now() + 5000;
  status('Get ready to record · 5 second countdown.'); mark();
}
function go(next) {
  if (panel === 'options' && next !== 'colors' && next !== 'parpots') optionDraft = null;
  if (settings.melt && panel !== next && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) transitionUntil = performance.now() + 120;
  panel = next; prompt = null; screenMessage = ''; mark();
}
function beginPrompt(title, initial, callback, returnPanel = panel) {
  prompt = { title, text: initial, callback, returnPanel };
  mark(); $('screen').focus({ preventScroll: true });
}
function showSequence() {
  $('sequence-name').value = loaded?.name || 'sequence.rec';
  $('sequence-text').value = loaded ? formatRecording(loaded.events) : '128,1\n64,1\n32,1\n16,1\n8,1\n4,1\n2,1\n1,1\n0,888\n';
  $('sequence-error').textContent = ''; $('sequence-dialog').showModal();
}
function showSchedules() {
  renderSchedules();
  const d = new Date(Date.now() + 60000); d.setMilliseconds(0);
  $('schedule-time').value = new Date(d.getTime() - d.getTimezoneOffset() * 60000).toISOString().slice(0, 19);
  $('schedule-error').textContent = ''; $('schedule-dialog').showModal();
}
function addSchedule(at, name) {
  const i = schedules.findIndex(s => !s.name || s.fired);
  if (i < 0) throw new Error('All six scheduler banks are in use. Delete a bank first.');
  const timestamp = Date.parse(at);
  if (!Number.isFinite(timestamp) || timestamp <= Date.now()) throw new Error('Choose a future date and time.');
  if (!library.has(name)) throw new Error('Choose an available recording.');
  schedules[i] = { name, at: new Date(timestamp).toISOString(), enabled: true, fired: false };
  save(); renderSchedules(); mark(); status(`Schedule bank ${i + 1} saved.`);
}
function renderSchedules() {
  $('schedule-list').replaceChildren();
  schedules.forEach((s, i) => {
    if (!s.name) return;
    const row = document.createElement('div'); row.className = 'schedule-row';
    const text = document.createElement('div'); text.textContent = `Bank ${i + 1} · ${s.name}`;
    const detail = document.createElement('div'); detail.textContent = new Date(s.at).toLocaleString() + (s.fired ? ' · completed' : s.enabled ? ' · armed' : ' · paused'); text.append(detail);
    const toggle = document.createElement('button'); toggle.type = 'button'; toggle.textContent = s.enabled ? 'Pause' : 'Enable'; toggle.disabled = s.fired;
    toggle.addEventListener('click', () => {
      if (!s.enabled && Date.parse(s.at) <= Date.now()) { $('schedule-error').textContent = 'This saved time has passed. Delete it and choose a future time.'; return; }
      s.enabled = !s.enabled; save(); renderSchedules(); mark();
    });
    const remove = document.createElement('button'); remove.type = 'button'; remove.textContent = 'Delete'; remove.setAttribute('aria-label', `Delete schedule bank ${i + 1}`); remove.addEventListener('click', () => { schedules[i] = { name: '', at: '', enabled: false, fired: false }; save(); renderSchedules(); mark(); });
    row.append(text, toggle, remove); $('schedule-list').append(row);
  });
  if (!$('schedule-list').childElementCount) $('schedule-list').textContent = 'No scheduled recordings.';
  const previous = $('schedule-recording').value;
  $('schedule-recording').replaceChildren(...[...library.keys()].map(name => new Option(name, name)));
  if (library.has(previous)) $('schedule-recording').value = previous;
  else if (loaded) $('schedule-recording').value = loaded.name;
}
function changePort(index) {
  if (player.playing || recorder.active || countdownUntil) stopAll();
  settings.port = index; $('port-select').value = index; mark(); status('Controlling virtual LPT' + (index + 1) + ' at ' + hex(port().base) + '.');
}
function rotateColor(index, up) {
  const colors = ['#000000','#0000a0','#00a700','#00a7a0','#a00000','#a000a0','#a05700','#a0a7a0','#505050','#5050ff','#50ff50','#50ffff','#ff5050','#ff50ff','#fff850','#fff8ff'];
  let position = colors.findIndex(x => x === settings.palette[index]);
  if (position < 0) position = index;
  settings.palette[index] = colors[(position + (up ? 1 : 15)) % colors.length];
  // Keep the selected role visible against the original black screen.
  if (settings.palette[index] === '#000000') settings.palette[index] = colors[up ? 1 : 15];
  screen.setPalette(settings.palette); mark();
}

function keypress(key) {
  const originalKey = key;
  key = key.toLowerCase(); startupUntil = 0;
  if (prompt) {
    if (key === 'escape') { prompt = null; mark(); return; }
    if (key === 'enter') {
      const active = prompt; prompt = null;
      try { active.callback(active.text); } catch (e) { announce(e.message); }
      mark(); return;
    }
    if (key === 'backspace') prompt.text = prompt.text.slice(0, -1);
    else if (originalKey.length === 1 && /^[\x20-\x7e]$/.test(originalKey) && prompt.text.length < 72) prompt.text += originalKey;
    mark(); return;
  }
  if (countdownUntil && key === 's') { stopAll(); return; }
  if (player.playing && key === 's') { stopAll(); return; }
  if (key === 'escape') { go('welcome'); return; }
  if (panel === 'plugin' && key === 'x') { plugin = false; go('welcome'); return; }
  if (panel === 'welcome' || panel === 'plugin') {
    if (OUTPUT_KEYS.includes(key) && key.length === 1) { setData(port().data ^ (1 << (7 - OUTPUT_KEYS.indexOf(key))), true); return; }
    if (/^[0-9]$/.test(key)) { setData(groups[Number(key)], true); groupUsed = true; return; }
    if (key === 'p') play();
    else if (key === 's') stopAll();
    else if (key === 'c') go('record');
    else if (key === 'g') go('groups');
    else if (key === 'd') go('schedule');
    else if (key === 'o') { optionDraft = structuredClone(settings); go('options'); }
    else if (key === 'h') go('help');
    else if (key === 'l') go('plugins');
    else if (key === 'x') { stopAll(); go('exit'); }
    return;
  }
  if (panel === 'exit') { go('welcome'); return; }
  if (panel === 'groups') {
    if (/^[0-9]$/.test(key)) { groups[Number(key)] = port().data; save(); announce('Current outputs saved to bank ' + key + '.'); }
    else if (key === 's') beginPrompt('Save group file:', 'groups.gro', name => { groupName = safeName(name, '.gro'); download(groupName, formatGroups(groups)); save(); announce('Group file saved.'); });
    else if (key === 'l' || key === 'a') $('groups-file').click();
    else if (key === 'h') go('usgro');
    else if (key === 'x') go('welcome');
    return;
  }
  if (panel === 'record') {
    if (key === 't') beginPrompt('File:', 'recording.rec', startRecording);
    else if (key === 'v') showSequence();
    else if (key === 'l') $('recording-file').click();
    else if (key === 's') { $('sample').focus(); announce('Choose an example below the screen.'); }
    else if (key === 'h') go('recordhelp');
    else if (key === 'x') go('welcome');
    return;
  }
  if (panel === 'options') {
    if (key === 'c') go('colors');
    else if (key === 'p') go('parpots');
    else if (key === 'm') { settings.melt = !settings.melt; mark(); }
    else if (key === 'q') { settings.quick = !settings.quick; mark(); }
    else if (key === 'g') { settings.startupGroups = !settings.startupGroups; mark(); }
    else if (key === 'd') { const oldPort=settings.port; settings = defaults(); if(oldPort!==0)changePort(0); screen.setPalette(settings.palette); mark(); }
    else if (key === 's') { savedSettings = structuredClone(settings); save(); optionDraft = null; go('welcome'); announce('Options saved.'); }
    else if (key === 'x') { if(optionDraft){settings = optionDraft;screen.setPalette(settings.palette);$('port-select').value=settings.port;} optionDraft=null;go('welcome'); }
    return;
  }
  if (panel === 'parpots') { if (/^[123]$/.test(key)) { changePort(Number(key)-1); go('options'); } else if (key === 'x') go('options'); return; }
  if (panel === 'colors') {
    const up='asdfgh', down='zxcvbn', roles=[2,7,15,9,14,4];
    if (key==='u') rotateColor(9,false);
    else if (up.includes(key) && key.length===1) rotateColor(roles[up.indexOf(key)],true);
    else if (down.includes(key) && key.length===1) rotateColor(roles[down.indexOf(key)],false);
    else if(key==='e')go('options');return;
  }
  if (panel === 'schedule' || panel === 'makesce') {
    if (key === 'm' || key === 's') {
      const today = new Date();
      beginPrompt('Date (mm-dd-yyyy):', `${String(today.getMonth()+1).padStart(2,'0')}-${String(today.getDate()).padStart(2,'0')}-${today.getFullYear()}`, date => {
        if (!/^\d{2}[-/]\d{2}[-/]\d{4}$/.test(date)) throw new Error('Use mm-dd-yyyy.');
        scheduleDraft.date = date;
        beginPrompt('Time (hh:mm:ss):', '', time => {
          if (!/^\d{2}:\d{2}:\d{2}$/.test(time)) throw new Error('Use hh:mm:ss.');
          scheduleDraft.time = time;
          beginPrompt('Recorded file:', loaded?.name || 'eg1.rec', name => {
            const [month,day,year] = scheduleDraft.date.split(/[-/]/);
            const at = `${year}-${month}-${day}T${scheduleDraft.time}`; addSchedule(at,name);go('welcome');
          });
        });
      });
    } else if (key === 'd') go('scdel');
    else if (key === 'r') go('record');
    else if (key === 'h') go('schedulehelp');
    else if (key === 'x') go('welcome');
    return;
  }
  if(panel==='scdel') {if(/^[1-6]$/.test(key)){schedules[Number(key)-1]={name:'',at:'',enabled:false,fired:false};save();mark();}else if(key==='x')go('schedule');return;}
  if(panel==='plugins') {if(key==='1'){plugin=true;lastPluginInput=-1;go('plugin');status('Plugin demonstration: virtual inputs mirror to the data outputs.');}else if(key==='x')go('welcome');return;}
  if(panel==='help') {
    const pages={c:'conroling',m:'wiring',g:'usgro',r:'recordhelp',u:'schedulehelp',t:'troubleshooting',a:'aurhor',x:'welcome'};
    if(pages[key])go(pages[key]);return;
  }
  if(key==='x')go('help');
}

function paired(left, right = []) { return Array.from({length:10}, (_,i)=>(left[i]||'').slice(0,39).padEnd(39)+'║'+(right[i]||'').slice(0,40)); }
function menuRows() {
  if(panel==='options') return paired(['              Options','','To slightly customize how this program','works, please choose an option ----->','','Using LPT '+(settings.port+1),'Melter effect is '+(settings.melt?'on':'off'),'Quick logo is '+(settings.quick?'on':'off'),settings.startupGroups?'Group banks load on start up':'No group file on start up'],['','   c  =  Colour settings','   p  =  Select Parallel Port','   m  =  Melter effect On/Off','   q  =  Quick logo on startup On/Off','   g  =  Load group on start up','','   d  =  Load Defults','   s  =  Exit and Save','   x  =  Exit, without saving']);
  if(panel==='schedule') return paired(['            Sceduler','','There are currently '+schedules.filter(s=>s.name&&!s.fired).length+' sceduler banks','being used, a maximum of 6 can be used.','','This sceduler runs recored files at','a set time and date.','','Note: You must be in the main A/Q box','before a sceduled bank will exicute!'],['','      m     = Make a scedule','      d     = Delete a scedule bank','','','','','      r     = Goto Record section','      h     = Help on sceduler','      x     = Exit this A/Q box']);
  if(panel==='recordhelp')return paired(['          Recording/Playback','','RealTime records your output changes.','Variable lets you enter exact delays.','Each line: output byte, delay seconds.','An 888 delay marks the end of a file.','','P plays the loaded file; S stops.','Save .rec keeps a copy on your device.'],['','   c, then t = RealTime recorder','   c, then v = Variable recorder','   c, then l = Load a .rec file','','','','','','   x = Back to help']);
  if(panel==='schedulehelp')return paired(['          Using the Sceduler','','Make up to six playback banks.','Choose a date, time and recorded file.','Keep this page open for it to run.','Saved banks start paused next session.','','If busy, playback waits until idle.','Edit or re-enable using Scheduler.'],['','','','','','','','','','   x = Back to help']);
  if(panel==='troubleshooting')return paired(['             Trobleshooting','','Q W E R T Y U I toggle the data bits.','Click the screen to give it focus.','The virtual switches pull inputs LOW.','No printer port or driver is required.','','Open .rec and .gro below the screen.','Export files if browser storage fails.'],['','','','','','','','','','   x = Back to help']);
  if(panel==='plugin')return paired(['       Virtual input/output plug-in','','Input switches mirror to data bits.','This browser demo replaces DOS SHELL.','','The original program stays available.'],['','','','','','','','','','   x = Exit plug-in']);
  if(panel==='colors')return legacy.menus.colors.slice(0,10);
  if(panel==='parpots')return paired(['         Parallel Port Selector','','Please choose an installed port by','pressing the representing number.','','(Or exit)','','','Note: Addresses shown in decimal.'],['','','','1. lpt1 is installed at address 888','2. lpt2 is installed at address 632','3. lpt3 is installed at address 956','','','','     x = Exit this A/Q box']);
  return legacy.menus[panel] || legacy.menus.welcome;
}

function drawMain(now) {
  screen.clear();
  if (startupUntil > now) { drawLogo(); screen.present(); return; }
  if (panel==='exit') {
    screen.neat('Good bye!',-1,25,2,2);screen.neat('Tell me what you think at...',-1,55,15,1);screen.text(5,3,'Daniel@vincent99.freeserve.co.uk',5);screen.text(25,26,'Any key to return');screen.present();return;
  }
  screen.text(2,1,'Controlling LPT '+(settings.port+1)+' with-');
  screen.neat('Computer Control',-1,5,2,2);
  screen.text(2,57,'- By Daniel Vincent');
  const outRows=legacy.frame.out;
  outRows.forEach((t,i)=>screen.text(4+i,31,t));
  const inRows=legacy.frame.input;
  inRows.forEach((t,i)=>screen.text(9+i,31,t));
  for(let i=0;i<8;i++){
    screen.glyph(15,248+i*16,64,(port().data&(1<<(7-i)))?4:0);
    screen.glyph(15,248+i*16,144,(port().inputByte&(1<<(7-i)))?4:0);
  }
  for(let i=0;i<10;i++)screen.text(4+i,53,'Group N° KEY '+i+' < '+groups[i]+' >  ',9);
  screen.text(15,53,groupName.slice(0,26),9);
  screen.text(3,1,'──────────────────────────┐');
  screen.text(4,1,'         File Info        ',1);screen.text(4,27,'│');
  for(let row=5;row<=9;row++)screen.text(row,1,'                          │');
  if(loaded){screen.text(5,1,loaded.name.slice(0,26),1);screen.text(6,1,' '+sec(recordingDuration(loaded.events))+' seconds long',1);screen.text(7,1,' '+loaded.events.filter(e=>e.duration!==888).length+' operations',1);}
  screen.text(10,1,'──────────────────────────┤');
  screen.text(11,1,'         Scheduler',14);screen.text(11,27,'│');
  for(let row=12;row<=17;row++)screen.text(row,1,'                          │');
  schedules.forEach((s,i)=>{if(s.name&&!s.fired){const dt=new Date(s.at),pad=n=>String(n).padStart(2,'0');const date=`${pad(dt.getMonth()+1)}-${pad(dt.getDate())}-${dt.getFullYear()}`,time=`${pad(dt.getHours())}:${pad(dt.getMinutes())}:${pad(dt.getSeconds())}`;screen.text(12+i,1,`${i+1}} ${date} at ${time}`.slice(0,26),14);}});
  screen.text(18,1,'═══════════════════════════════════════╦═══════════════════════════════════════');
  screen.line(211,260,211,276,7);screen.line(212,260,212,276,7);
  for(let y=0;y<26;y++)for(let x=0;x<91;x++){
    let color=transportArt[y*91+x];
    if(color===7&&x>=5&&x<=20&&player.playing)color=2;
    if(color===7&&x>=27&&x<=43&&recorder.active)color=4;
    if(color===14&&(player.playing||recorder.active))color=7;
    screen.point(265+x,225+y,color);
  }
    if(panel==='wiring') {
    // The original embedded help illustration is displayed at its native size.
    const img=$('wiring-image');if(img?.complete){screen.present();screen.ctx.drawImage(img,0,0);return;}
  }
  const rows=menuRows(); rows.forEach((text,i)=>screen.text(19+i,1,text));
  // COLOR statements in the source apply to the left side of these menu rows.
  if(panel==='colors'){
    const roles=[2,7,15,9,14,4];roles.forEach((color,i)=>screen.text(21+i,1,(rows[2+i]||'').slice(0,39),color));
  }
  if(prompt){
    screen.rect(320,288,639,447,0);for(let i=0;i<10;i++)screen.text(19+i,40,'║');
    screen.text(20,42,prompt.title,15);
    const text=prompt.text.slice(-36);screen.text(22,42,text,7);
    if(Math.floor(now/500)%2===0)screen.glyph(95,328+text.length*8,336,15);
    screen.text(26,42,'Enter = Continue',7);screen.text(27,42,'Esc   = Cancel',7);
  }else if(countdownUntil){screen.rect(320,304,639,367,0);screen.text(20,42,'Get ready to record',15);screen.text(22,42,'in T - '+Math.max(0,Math.ceil((countdownUntil-now)/1000)),14);}
  else if(messageUntil>now)screen.text(28,42,screenMessage,15);
  if(transitionUntil>now){for(let i=0;i<35;i++){const x=Math.floor(Math.random()*271),y=Math.floor(Math.random()*150+280);screen.pixels.copyWithin((y+3)*640+x,y*640+x,y*640+x+320);}}
  screen.present();
}
function drawLogo(){
  // The original quick logo's WINDOW(-500,-500)-(500,500) coordinates.
  const px=x=>(x+500)*.64,py=y=>(500-y)*.48;
  const line=(a,b,c,d)=>screen.line(px(a),py(b),px(c),py(d),9);
  [[-135,100,-210,100],[-135,100,-135,-100],[-135,-100,-210,-100],[-200,100,-200,-100],[-50,100,25,100],[-50,100,-50,-100],[-50,0,25,0],[25,-100,25,100],[105,100,180,-100],[180,100,180,-100],[105,100,105,-100]].forEach(args=>line(...args));
  screen.rect(px(-420),py(5),px(450),py(-10),2);screen.text(7,15,'Extravaganza',2);screen.text(19,17,'Presents...',2);
}

const names={1:'/STROBE',10:'/ACK',11:'BUSY',12:'PAPER END',13:'SELECT',14:'/AUTOFEED',15:'/ERROR',16:'/INIT',17:'/SELECT IN'};
const role=p=>p>=18?'ground':p>=2&&p<=9?'data':[10,11,12,13,15].includes(p)?'status':'control';
const signalName=p=>role(p)==='ground'?'Ground':role(p)==='data'?'D'+(p-2):names[p];
function buildInspector(){
  for(let p=1;p<=25;p++){
    const button=document.createElement('button');button.type='button';button.className='pin';button.dataset.pin=p;button.dataset.role=role(p);button.innerHTML=p+'<i></i>';
    button.addEventListener('click',()=>{selectedPin=p;mark();});$(p<=13?'pins-top':'pins-bottom').append(button);
  }
  for(let i=0;i<8;i++){
    const key=OUTPUT_KEYS[i],pin=9-i;
    const button=document.createElement('button');button.type='button';button.dataset.output=i;button.setAttribute('aria-label',`${key.toUpperCase()}, bit ${7-i}, pin ${pin}`);button.innerHTML=key.toUpperCase()+`<small>D${7-i} · pin ${pin}</small>`;
    button.addEventListener('click',()=>{startupUntil=0;setData(port().data^(1<<(7-i)),true);selectedPin=pin;});$('output-keys').append(button);
    const item=document.createElement('div');item.className='signal';item.dataset.bit=7-i;item.innerHTML=`<strong>${key.toUpperCase()} → ${pin}</strong><span></span>`;$('output-signals').append(item);
  }
  for(const p of [...INPUT_PINS,15]){
    const button=document.createElement('button');button.type='button';button.className='switch';button.dataset.inputPin=p;
    button.addEventListener('click',()=>{port().pullLow(p,!port().lowPins.has(p));selectedPin=p;mark();});$('input-switches').append(button);
  }
  for(let i=0;i<10;i++){
    const row=document.createElement('div');row.className='group-bank';row.innerHTML=`<span>${i}</span><output data-group="${i}">0</output>`;
    const use=document.createElement('button');use.type='button';use.textContent='Use';use.setAttribute('aria-label',`Recall group ${i}`);use.addEventListener('click',()=>{setData(groups[i],true);groupUsed=true;});
    const store=document.createElement('button');store.type='button';store.textContent='Store';store.setAttribute('aria-label',`Save current outputs to group ${i}`);store.addEventListener('click',()=>{groups[i]=port().data;save();announce('Current outputs saved to bank '+i+'.');});row.append(use,store);$('group-banks').append(row);
  }
  const img=new Image();img.id='wiring-image';img.src='assets/original-wiring.png';img.hidden=true;img.addEventListener('load',mark);document.body.append(img);
}
function drawInspector(){
  const p=port();
  document.querySelectorAll('[data-pin]').forEach(b=>{const pin=Number(b.dataset.pin);b.dataset.level=p.pinHigh(pin)?'H':'L';b.setAttribute('aria-label',`Pin ${pin}, ${signalName(pin)}, ${role(pin)==='ground'?'ground':p.pinHigh(pin)?'HIGH':'LOW'}`);b.setAttribute('aria-pressed',String(pin===selectedPin));});
  document.querySelectorAll('[data-output]').forEach(b=>b.setAttribute('aria-pressed',String(Boolean(p.data&(1<<(7-Number(b.dataset.output)))))));
  document.querySelectorAll('[data-bit]').forEach(b=>{const on=Boolean(p.data&(1<<Number(b.dataset.bit)));b.dataset.on=on;b.querySelector('span').textContent=`D${b.dataset.bit} · ${on?'HIGH':'LOW'}`;});
  document.querySelectorAll('[data-input-pin]').forEach(b=>{const pin=Number(b.dataset.inputPin),low=p.lowPins.has(pin);b.innerHTML=`${pin} · ${low?'CLOSED':'OPEN'}<span>${names[pin]}</span>`;b.setAttribute('aria-pressed',String(low));b.setAttribute('aria-label',`Pin ${pin} ${names[pin]}, switch ${low?'closed, release HIGH':'open, pull LOW'}`);});
  document.querySelectorAll('[data-group]').forEach(o=>o.textContent=groups[Number(o.dataset.group)]);
  $('selected-pin').textContent=`Pin ${selectedPin} · ${signalName(selectedPin)} · ${role(selectedPin)==='ground'?'ground':p.pinHigh(selectedPin)?'HIGH':'LOW'}${selectedPin===15?' · not read by the original input monitor':role(selectedPin)==='control'?' · control line used as a virtual input':''}`;
  $('data-register').textContent=hex(p.data);$('status-register').textContent=hex(p.read(p.base+1));$('control-register').textContent=hex(p.read(p.base+2));
  $('data-address').textContent=hex(p.base);$('status-address').textContent=hex(p.base+1);$('control-address').textContent=hex(p.base+2);
  $('binary-byte').textContent=p.data.toString(2).padStart(8,'0');if(!byteEditing&&document.activeElement!==$('output-byte'))$('output-byte').value=p.data;
  $('play-button').disabled=player.playing;$('record-button').dataset.active=recorder.active||Boolean(countdownUntil);document.body.dataset.recording=recorder.active;
  $('export-recording').disabled=!loaded;$('screen').dataset.output=p.data;$('screen').dataset.input=p.inputByte;$('screen').dataset.panel=panel;
}

buildInspector();
$('screen').addEventListener('keydown',e=>{
  if(e.ctrlKey||e.altKey||e.metaKey||e.repeat)return;
  if(e.key.length===1||['Enter','Escape','Backspace'].includes(e.key)){e.preventDefault();keypress(e.key);}
});
$('screen').addEventListener('pointerdown',e=>{
  $('screen').focus({preventScroll:true});startupUntil=0;
  const bounds=$('screen').getBoundingClientRect(),x=(e.clientX-bounds.left)*640/bounds.width,y=(e.clientY-bounds.top)*480/bounds.height;
  if(panel==='wiring'){go('help');return;}
  if(y>=52&&y<=91&&x>=240&&x<375){setData(port().data^(1<<(7-Math.min(7,Math.floor((x-240)/16)))),true);return;}
  if(y>=225&&y<=250){if(x>=265&&x<290)play();else if(x>=290&&x<312)keypress('c');else if(x>=312&&x<=333)stopAll();else if(x>=334&&x<=356)keypress('d');}
  mark();
});
$('play-button').addEventListener('click',play);
$('record-button').addEventListener('click',()=>{go('record');beginPrompt('File:','recording.rec',startRecording);});
$('stop-button').addEventListener('click',stopAll);
$('home-button').addEventListener('click',()=>{plugin=false;startupUntil=0;go('welcome');$('screen').focus();});
$('load-sample').addEventListener('click',()=>{load(library.get($('sample').value));$('screen').focus();});
$('import-recording').addEventListener('click',()=>$('recording-file').click());
$('export-recording').addEventListener('click',()=>{if(loaded)download(safeName(loaded.name,'.rec'),formatRecording(loaded.events));});
$('edit-sequence').addEventListener('click',showSequence);
$('schedule-button').addEventListener('click',()=>{go('schedule');showSchedules();});
$('groups-button').addEventListener('click',()=>{go('groups');$('screen').focus();});
$('options-button').addEventListener('click',()=>{optionDraft=structuredClone(settings);go('options');$('screen').focus();});
$('help-button').addEventListener('click',()=>{go('help');$('screen').focus();});
$('about-button').addEventListener('click',()=>$('about-dialog').showModal());
$('port-select').value=settings.port;
$('port-select').addEventListener('change',()=>{changePort(Number($('port-select').value));savedSettings.port=settings.port;save();});
$('speed').addEventListener('change',()=>{if(player.playing){stopAll();status('Playback stopped. Press Play to use the selected speed.');}});
$('output-byte').addEventListener('input',()=>{byteEditing=true;});
$('byte-form').addEventListener('submit',e=>{e.preventDefault();try{const value=byte($('output-byte').value);byteEditing=false;setData(value,true);status('Output byte set to '+port().data+'.');}catch(error){announce(error.message);}});
$('recording-file').addEventListener('change',async e=>{const file=e.target.files[0];if(!file)return;try{if(file.size>1_000_000)throw new Error('Recording file is too large.');load({name:file.name,events:parseRecording(await file.text())});}catch(error){announce(error.message);}e.target.value='';});
$('groups-file').addEventListener('change',async e=>{const file=e.target.files[0];if(!file)return;try{if(file.size>4096)throw new Error('Group file is too large.');groups=parseGroups(await file.text());groupName=file.name;save();announce('Group file loaded.');panel='welcome';}catch(error){announce(error.message);}e.target.value='';mark();});
$('import-groups').addEventListener('click',()=>$('groups-file').click());
$('export-groups').addEventListener('click',()=>download('groups.gro',formatGroups(groups)));
$('sequence-form').addEventListener('submit',e=>{e.preventDefault();try{const item={name:safeName($('sequence-name').value,'.rec'),events:parseRecording($('sequence-text').value)};load(item);$('sequence-dialog').close();$('screen').focus();}catch(error){$('sequence-error').textContent=error.message;}});
$('schedule-form').addEventListener('submit',e=>{e.preventDefault();try{addSchedule($('schedule-time').value,$('schedule-recording').value);$('schedule-error').textContent='';}catch(error){$('schedule-error').textContent=error.message;}});
document.querySelectorAll('dialog').forEach(dialog=>dialog.addEventListener('close',()=>{mark();$('screen').focus({preventScroll:true});}));
document.addEventListener('visibilitychange',()=>{if(!document.hidden){player.tick(performance.now());mark();}});

function tick(now){
  if(startupUntil&&now>=startupUntil){startupUntil=0;mark();}
  if(transitionUntil&&now>=transitionUntil){transitionUntil=0;mark();}
  if(screenMessage&&now>=messageUntil){screenMessage='';mark();}
  player.tick(now);
  if(countdownUntil&&now>=countdownUntil){countdownUntil=0;setData(0);recorder.start(0,now);status('Recording output changes · press S to stop.');mark();}
  if(plugin){const input=port().inputByte;if(input!==lastPluginInput){lastPluginInput=input;setData(input);}}
  if(now-lastScheduleCheck>250){lastScheduleCheck=now;if(!player.playing&&!recorder.active&&!countdownUntil){const due=dueSchedules(schedules,Date.now())[0];if(due){const target=library.get(due.name);schedules[due.slot].fired=true;schedules[due.slot].enabled=false;save();if(target){loaded=target;play();}else announce('Scheduled recording is unavailable.');mark();}}}
  if((prompt||countdownUntil||startupUntil>now||transitionUntil>now||player.playing||recorder.active)&&now-lastUiTime>100){lastUiTime=now;mark();}
  if(dirty&&now-lastTick>=25){lastTick=now;dirty=false;drawMain(now);drawInspector();}
  requestAnimationFrame(tick);
}
renderSchedules();drawMain(performance.now());drawInspector();requestAnimationFrame(tick);
new ResizeObserver(() => {
  const width=Math.min(640,$('screen-viewport').clientWidth);
  $('screen').style.width=width+'px';$('screen').style.height=(width*.75)+'px';
}).observe($('screen-viewport'));
