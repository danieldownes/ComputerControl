import { test } from 'node:test';
import assert from 'node:assert/strict';
import { LptPort, INPUT_PINS, SequencePlayer, RealtimeRecorder, parseRecording, formatRecording, recordingDuration, parseGroups, formatGroups, dueSchedules } from '../dist/core.js';

test('Q and I control opposite ends of the physical data bus', () => {
  const p = new LptPort();
  p.toggleKey('q'); assert.equal(p.data, 128); assert.equal(p.pinHigh(9), true); assert.equal(p.pinHigh(2), false);
  p.toggleKey('i'); assert.equal(p.data, 129); assert.equal(p.pinHigh(2), true);
  p.toggleKey('q'); assert.equal(p.data, 1); assert.equal(p.pinHigh(9), false);
});
test('every data byte reaches its correctly numbered pins', () => {
  const p = new LptPort();
  for (let value=0;value<256;value++) { p.write(p.base,value); let reconstructed=0;for(let pin=2;pin<=9;pin++)if(p.pinHigh(pin))reconstructed+=2**(pin-2); assert.equal(reconstructed,value); }
});
test('SPP inversion and legacy input mask stay distinct from physical levels', () => {
  const p = new LptPort();
  assert.equal(p.read(p.base+1),0x78); assert.equal(p.read(p.base+2),4); assert.equal(p.inputByte,0);
  INPUT_PINS.forEach((pin,i)=>{p.pullLow(pin);assert.equal(p.inputByte,1<<(7-i));p.pullLow(pin,false);});
  p.pullLow(15);assert.equal(p.read(p.base+1),0x70);assert.equal(p.inputByte,0);
  p.write(p.base+2,8);assert.equal(p.pinHigh(17),false);assert.equal(p.pinHigh(16),false);
});
test('recordings accept QBASIC scientific notation and exclude stop markers from length', () => {
  const e=parseRecording('0,5.078125E-02\r\n128,.8789063\r\n1,888\r\n');
  assert.equal(e[0].duration,.05078125);assert.equal(recordingDuration(e),.92968755);
  assert.deepEqual(parseRecording(formatRecording(e)),e);
  for(const bad of ['', '256,1','1,-2','1,NaN','1,1,2','1,888\n0,1','<script>,1'])assert.throws(()=>parseRecording(bad));
});
test('playback catches up after a delayed frame and retains the terminal byte', () => {
  const output=[];let ended=0;const p=new SequencePlayer(v=>output.push(v),()=>ended++);
  p.start(parseRecording('100,10\n200,5\n5,5\n60,10\n1,888'),1000);
  assert.deepEqual(output,[100]);p.tick(26000);assert.deepEqual(output,[100,200,5,60]);assert.equal(p.playing,true);
  p.tick(31000);assert.equal(output.at(-1),1);assert.equal(ended,1);assert.equal(p.playing,false);
});
test('playback speed and zero-duration rows use the same clock', () => {
  const output=[];const p=new SequencePlayer(v=>output.push(v));p.start(parseRecording('0,0\n128,10\n0,888'),0,10);
  assert.deepEqual(output,[0,128]);p.tick(999);assert.equal(p.playing,true);p.tick(1000);assert.deepEqual(output,[0,128,0]);
});
test('real-time recorder stores the duration of the state that preceded a change', () => {
  const r=new RealtimeRecorder();r.start(0,1000);r.change(128,1500);r.change(129,2500);
  assert.deepEqual(r.stop(4000),[{value:0,duration:.5},{value:128,duration:1},{value:129,duration:1.5},{value:129,duration:888}]);
});
test('group files use legacy order 1–9,0 and include bank 4', () => {
  const banks=[255,1,2,3,44,5,6,7,8,9];const text=formatGroups(banks);
  assert.equal(text,'1,2,3,44,5,6,7,8,9,255\r\n');assert.deepEqual(parseGroups(text),banks);assert.throws(()=>parseGroups('1,2,3'));
});
test('schedules execute after their deadline and never execute twice', () => {
  const at='2026-11-02T01:00:00.000Z';const all=[{at,enabled:true,fired:false},{at,enabled:false,fired:false},{at,enabled:true,fired:true}];
  assert.equal(dueSchedules(all,Date.parse(at)-1).length,0);assert.deepEqual(dueSchedules(all,Date.parse(at)+2000).map(s=>s.slot),[0]);
});
