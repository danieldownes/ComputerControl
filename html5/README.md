# Computer Control — HTML5 conversion

A browser conversion of Daniel Vincent’s QBASIC Computer Control beta 5, with a live emulated LPT port. Original files remain in the parent directory.

## Run

For immediate offline use, open **`dist/computer-control.html`** directly in a browser. This self-contained file includes all runtime assets and needs no server or installed packages.

For development, run `npm start` in this directory and open `http://127.0.0.1:4173`. Any static HTTP server can serve `dist/`. `npm run build` regenerates the standalone HTML file from the modular source; no package installation is needed.

The screen always renders at **640×480** in a palette-indexed framebuffer. Text uses actual **8×16 IBM VGA bitmap glyphs**, with CP437 box drawing and the original drawing coordinates. The supplied screenshot’s `f` and `v` glyphs are restored from that image, and its transport-button art is retained as palette indices. The recreated Colour Settings screen matches **all 307,200 pixels** of the supplied `Beta5.bmp`. The native viewing size is 640×480; a smaller viewport scales the complete image without rearranging it. No browser fonts or antialiasing are used inside the program screen.

## Controls and features

- Click the screen, then use `Q W E R T Y U I` to latch output bits 7–0 (pins 9–2). Clicking the output indicators also works.
- `G` opens group programming: press a digit to store the current output in that bank. On the main screen a digit recalls it. `.gro` import/export retains the original order **1–9,0**.
- `C` opens recording. `T` starts the real-time recorder after the original five-second countdown; `V` opens the variable sequence editor; `L` imports a recording. `P` plays and `S` stops. The browser buttons expose the same actions. The browser recorder saves the byte held during each elapsed interval; the original source instead associates that interval with the new byte, which can shift playback transitions.
- All three original examples are supplied. `.rec` and `.seq` use `output,seconds`; scientific notation is accepted. Delay **888** is a terminal marker, excluded from duration. Normal completion retains the terminal output; an explicit Stop sets data outputs LOW.
- `D` opens scheduling. Create up to six banks using the DOS prompts or browser dialog. Schedules run while this page is open and idle, catch up after a delayed frame, and are marked fired before starting playback. After reopening the page, saved schedules are paused and need re-enabling with a future time.
- `O` opens original-style settings, port selection and color settings. Options `S` saves; `X` discards the draft. Quick-logo startup and the optional menu melt effect are retained.
- `H` opens original help and its wiring illustration. `L` opens Plugins; the available browser demonstration mirrors virtual inputs to the eight data outputs. DOS `.EXE` plugins are not executed.
- The inspector displays all 25 connector pins, data/status/control registers, virtual input switches, and group banks. LPT1–3 have independent states at 0x378, 0x278, and 0x3BC.
- Browser storage keeps recordings, group banks, schedules and settings. File export supplies portable copies. A storage failure is reported without preventing use.

## Hardware interpretation

The simulator implements standard SPP data, status and control register polarity. Pin 11 is inverted in the status register; control pins 1, 14 and 17 are inverted. Control lines model open-collector outputs released HIGH by control byte 4, with virtual switches able to pull them LOW.

The original source combines `(STATUS AND &HF0)` and `(CONTROL AND &HF)`, XORs `&H8B`, then inverts that byte for its eight input indicators. Their order is **11,10,12,13,17,16,14,1**. Thus LOW is displayed as active. Pin 15 is a real status input that this source mask omits. The supplied wiring illustration instead marks pin 16 NC, so it does not agree with the source. The port follows the source mapping and labels this difference.

## Corrections and boundaries

This is a port of the program’s intended behavior, not an x86 emulator. The supplied source is not an exact match for the shipped EXE: it requests `SCREEN.HEL`, while the release uses `data3.dcc`. This conversion uses the supplied text and corrects the delayed/uninitialized register addresses, the group-bank 4 `fou`/`fff` mismatch, the second schedule slot check, truncated config saves, stop-marker duration totals, and busy-loop/midnight timing problems. A toggle after a recalled group updates that group’s byte consistently.

Physical electrical behavior, printer protocols, OS drivers, DOS shell searches, historical registration services, and DOS executable plugins are outside the simulation. File pickers, downloads and the local recording library replace DOS filesystem access. The startup logo uses the original vector coordinates in the fixed main framebuffer; the long introductory animation and historical registration screens are omitted.

## Verification

`npm test` runs meaningful register, pin mapping, recording format, timing, group round-trip and scheduler tests. Browser QA also checks original keyboard menus, file import/export, recording, scheduling, storage restoration, pin states, mobile scaling and VGA screenshot pixels.

`scripts/prepare-assets.py` regenerates browser data from the supplied project; it needs Python and Pillow only during regeneration. The site itself has no external runtime assets.

## Sources

- Original QBASIC code, screen text, artwork and sample sequences: the supplied Computer Control project by Daniel Vincent.
- IBM VGA 8×16 raw bitmap: [VileR’s VGA text mode font archive](https://github.com/viler-int10h/vga-text-mode-fonts/blob/master/FONTS/PC-IBM/VGA8.F16). The archive’s [FONT documentation](https://github.com/viler-int10h/vga-text-mode-fonts/blob/master/FONTS.TXT) describes its format and provenance. `dist/legacy-data.js` records its SHA-256 checksum.
- [Parallel-port pin reference](https://docs.oracle.com/cd/E19088-01/220r.srvr/806-1081-11/6jad2i1l2/index.html).
