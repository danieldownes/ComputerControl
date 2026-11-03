"""Rebuild browser data from the untouched QBASIC project and the checked-in font.

Run from any directory. Pillow is needed only when regenerating the two PNGs.
The downloaded font is already checked in; there is no runtime network dependency.
"""
from pathlib import Path
import base64
import hashlib
import json
import re
from PIL import Image

project = Path(__file__).resolve().parents[1]
original = project.parent / 'CC beta 5 stuff'
dest = project / 'dist'
font = bytearray((dest / 'assets/ibm-vga-8x16.bin').read_bytes())
assert len(font) == 4096
with Image.open(original / 'Beta5.bmp') as snapshot:
    snapshot = snapshot.convert('RGB')
    # These two QBASIC glyphs differ from the archived ROM. Recover their
    # bitmap shapes from unoccluded text in the supplied original screenshot.
    for character, x, y, color in [('f',128,48,(0,0,160)), ('v',480,368,(160,167,160))]:
        for row in range(16):
            font[ord(character)*16+row] = sum(128 >> col for col in range(8) if snapshot.getpixel((x+col,y+row)) == color)
    # Original transport art, stored as palette indices so color settings and
    # play/record/stop states still work. This retains QBASIC's raster edges.
    colors = {(0,0,0):0,(80,80,80):8,(160,167,160):7,(255,248,80):14,(255,248,255):15}
    transport = bytes(colors[snapshot.getpixel((x,y))] for y in range(225,251) for x in range(265,356))
chars = ''.join(chr(i) if i < 32 else bytes([i]).decode('cp437') for i in range(256))
special = '\0☺☻♥♦♣♠•◘○◙♂♀♪♫☼►◄↕‼¶§▬↨↑↓→←∟↔▲▼'
chars = special + chars[32:127] + '⌂' + chars[128:]
source = (original / 'code/COMPCON.BAS').read_text(encoding='cp437').splitlines()
menus = {}
for name, start, end in [('colors',660,675), ('record',1174,1183), ('help',1443,1452), ('groups',1599,1610), ('plugins',1735,1744)]:
    menus[name] = [''.join(re.findall(r'PRINT\s+"([^"\r\n]*)"', line)) for line in source[start-1:end] if re.search(r'PRINT\s+"', line)]
lines = (original / 'Program/data3.dcc').read_text(encoding='cp437').splitlines()
for name in ['welcome','parpots','makesce','scdel','ssce','aurhor','conroling','usgro']:
    idx = lines.index('"' + name + '"')
    rows = []
    for line in lines[idx+1:]:
        if not line.startswith('"') or (line.endswith('"') and len(line.strip('"')) < 15):
            break
        rows.append(line.strip('"'))
        if len(rows) == 10:
            break
    menus[name] = rows
recordings = {name: {'name': name, 'text': (original / 'Program' / name).read_text()} for name in ['eg1.rec','eg2.rec','eg3.rec']}
frame = {}
for name, numbers in [('out',[256,257,258,259]), ('input',[262,263,264,265])]:
    frame[name] = [re.search(r'PRINT\s+"([^"\r\n]*)"', source[n-1]).group(1)[30:] for n in numbers]
data = {'font':base64.b64encode(font).decode(), 'characters':chars, 'frame':frame, 'transport':base64.b64encode(transport).decode(), 'menus':menus, 'recordings':recordings, 'fontSource':'https://github.com/viler-int10h/vga-text-mode-fonts/blob/master/FONTS/PC-IBM/VGA8.F16', 'fontSha256':hashlib.sha256(font).hexdigest()}
(dest / 'legacy-data.js').write_text('/* Generated from the original CP437 source and files. */\nwindow.CC_LEGACY = ' + json.dumps(data,ensure_ascii=True) + ';\n', encoding='utf-8')
for source_path, name in [(original / 'Beta5.bmp','original-screen.png'), (original / 'Program/data1.dcc','original-wiring.png')]:
    with Image.open(source_path) as image:
        image.save(dest / 'assets' / name)
print('Prepared original font, screen text, recordings, and PNG references.')
