// Standard parallel port, plus the exact eight-input mask used by COMPCON.BAS.
export const OUTPUT_KEYS = 'qwertyui';
export const INPUT_PINS = [11, 10, 12, 13, 17, 16, 14, 1];
export const STATUS_PINS = [10, 11, 12, 13, 15];
export const CONTROL_PINS = [1, 14, 16, 17];
export const BASE_ADDRESSES = [0x378, 0x278, 0x3bc];
export const STOP_MARKER = 888;

export function byte(value) {
  const n = Number(value);
  if (!Number.isInteger(n) || n < 0 || n > 255) throw new Error('Output must be a whole number from 0 to 255.');
  return n;
}

export class LptPort {
  constructor(base = 0x378) { this.base = base; this.data = 0; this.controlLatch = 4; this.lowPins = new Set(); }
  pinHigh(pin) {
    if (pin >= 18 && pin <= 25) return false;
    if (pin >= 2 && pin <= 9) return Boolean(this.data & (1 << (pin - 2)));
    if (CONTROL_PINS.includes(pin)) {
      const bit = CONTROL_PINS.indexOf(pin);
      const drive = Boolean(this.controlLatch & (1 << bit)) !== (bit !== 2);
      return drive && !this.lowPins.has(pin);
    }
    if (STATUS_PINS.includes(pin)) return !this.lowPins.has(pin);
    throw new Error('Unknown DB-25 pin.');
  }
  pullLow(pin, low = true) {
    if (![...STATUS_PINS, ...CONTROL_PINS].includes(pin)) throw new Error('Only status and control pins accept an external switch.');
    if (low) this.lowPins.add(pin); else this.lowPins.delete(pin);
  }
  read(address) {
    if (address === this.base) return this.data;
    if (address === this.base + 1) return (Number(!this.pinHigh(11)) << 7) | (Number(this.pinHigh(10)) << 6) | (Number(this.pinHigh(12)) << 5) | (Number(this.pinHigh(13)) << 4) | (Number(this.pinHigh(15)) << 3);
    if (address === this.base + 2) return (this.controlLatch & 0xf0) | (Number(!this.pinHigh(17)) << 3) | (Number(this.pinHigh(16)) << 2) | (Number(!this.pinHigh(14)) << 1) | Number(!this.pinHigh(1));
    return 0;
  }
  write(address, value) {
    if (address === this.base) this.data = byte(value);
    else if (address === this.base + 2) this.controlLatch = byte(value);
    else throw new Error('This register is read-only.');
  }
  toggleKey(key) { const i = OUTPUT_KEYS.indexOf(key.toLowerCase()); if (i >= 0) this.data ^= 1 << (7 - i); }
  get inputByte() { return 255 - (((this.read(this.base + 1) & 0xf0) | (this.read(this.base + 2) & 0x0f)) ^ 0x8b); }
}

export function parseRecording(text) {
  const lines = String(text).replace(/^\uFEFF/, '').split(/\r?\n/).map(x => x.trim()).filter(Boolean);
  if (!lines.length) throw new Error('The recording is empty.');
  if (lines.length > 20000) throw new Error('A recording may contain at most 20,000 steps.');
  const events = lines.map((line, i) => {
    const parts = line.split(',').map(x => x.trim());
    if (parts.length !== 2 || parts.some(x => !/^[+-]?(?:\d+\.?\d*|\.\d+)(?:[eEdD][+-]?\d+)?$/.test(x))) throw new Error(`Invalid recording at line ${i + 1}. Expected output,seconds.`);
    const value = byte(Number(parts[0].replace(/[dD]/, 'E')));
    const duration = Number(parts[1].replace(/[dD]/, 'E'));
    if (!Number.isFinite(duration) || duration < 0) throw new Error(`Invalid delay at line ${i + 1}.`);
    if (duration === STOP_MARKER && i !== lines.length - 1) throw new Error('The 888 stop marker must be the last row.');
    return { value, duration };
  });
  return events;
}
export function formatRecording(events) { return events.map(e => `${byte(e.value)},${Number(e.duration).toString()}`).join('\r\n') + '\r\n'; }
export function recordingDuration(events) { return events.reduce((n, e) => n + (e.duration === STOP_MARKER ? 0 : e.duration), 0); }
export function parseGroups(text) {
  const parts = String(text).trim().split(/[\s,]+/);
  if (parts.length !== 10 || parts.some(x => !/^\d+$/.test(x))) throw new Error('A group file must contain ten bytes in key order 1–9,0.');
  const source = parts.map(byte);
  return [source[9], ...source.slice(0, 9)];
}
export function formatGroups(groups) {
  if (groups.length !== 10) throw new Error('Ten group banks are required.');
  return [...groups.slice(1), groups[0]].map(byte).join(',') + '\r\n';
}

export class SequencePlayer {
  constructor(onOutput, onEnd = () => {}) { this.onOutput = onOutput; this.onEnd = onEnd; this.playing = false; this.index = 0; this.elapsed = 0; }
  start(events, now, speed = 1) {
    if (!events.length || !(speed > 0)) throw new Error('Select a recording first.');
    this.events = events; this.speed = speed; this.started = now; this.deadline = 0; this.index = 0; this.elapsed = 0; this.playing = true;
    this.tick(now);
  }
  tick(now) {
    if (!this.playing) return;
    this.elapsed = Math.max(0, (now - this.started) * this.speed / 1000);
    while (this.playing && this.elapsed >= this.deadline) {
      if (this.index >= this.events.length) { this.playing = false; this.onEnd(); break; }
      const e = this.events[this.index++]; this.onOutput(e.value);
      if (e.duration === STOP_MARKER) { this.playing = false; this.onEnd(); break; }
      this.deadline += e.duration;
    }
  }
  stop() { this.playing = false; }
}

export class RealtimeRecorder {
  start(value, now) { this.events = []; this.current = byte(value); this.changed = now; this.started = now; this.active = true; }
  change(value, now) {
    if (!this.active || value === this.current) return;
    this.events.push({ value: this.current, duration: Math.max(0, (now - this.changed) / 1000) });
    this.current = byte(value); this.changed = now;
  }
  stop(now) {
    if (!this.active) return [];
    this.events.push({ value: this.current, duration: Math.max(0, (now - this.changed) / 1000) });
    this.events.push({ value: this.current, duration: STOP_MARKER });
    this.active = false;
    return this.events;
  }
}

// Work from explicit timestamps, rather than matching one exact clock second.
export function dueSchedules(schedules, now) {
  return schedules.map((s, i) => ({ ...s, slot: i })).filter(s => s.enabled && !s.fired && Date.parse(s.at) <= now && Number.isFinite(Date.parse(s.at)));
}
