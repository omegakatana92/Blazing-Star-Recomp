# Blazing Star — Native Recompilation v0.1.0

**Blazing Star (Yumekobo / SNK, 1998) running as a native x86-64 program.**

The Neo Geo's Motorola 68000 code is statically recompiled to C with the
[neogeorecomp](https://github.com/sp00nznet/neogeorecomp) v0.2.0 toolkit and runs
as native machine code against a software model of the MVS board. **This is a
recompilation, not an emulator wrapper.**

## Verified

- `--verify` re-executes every recompiled block in the Musashi interpreter and
  compares registers, flags and bus writes: **1,010,280 blocks, 0 mismatches**
- Scripted Stage 1 session: **0 interpreted instructions, 0 uncovered entry points**
  — fully native
- **2,467,114** recompiled 68000 instructions across 30,584 routines and 38,516
  dispatch entries
- ~**916 fps** headless on the Stage 1 session (~15x real time)
- Frame output byte-identical to the interpreter

## What works

- Boot through the real MVS BIOS -> eyecatcher -> title -> attract -> coin/start
  -> Stage 1
- YM2610 (ADPCM / SSG / FM) synthesized and played through SDL2
- Keyboard and gamepad input
- WAV audio capture, PNG screenshots, MP4 recording

## Downloads

| Asset | Notes |
|---|---|
| `BlazingStar-Recomp-Windows-x64.zip` | Native Windows x64 build, SDL2.dll included |
| `BlazingStar-Recomp-x86_64.AppImage` | Steam Deck / desktop Linux. The CI-built AppImage is **interpreter-only** because CI cannot include ROMs; run `scripts/build-appimage.sh` locally with your `roms/` for a fully recompiled Linux build. |

## You must supply the ROMs

No game or BIOS data is included, and none is distributed here. Unzip your own
MAME dumps into a `roms/` folder next to the executable (or pass `--rom-path`):

- **`blazstar` set:** `239-p1.p1`, `239-p2.sp2`, `239-c1.c1` .. `239-c8.c8`,
  `239-s1.s1`, `239-m1.m1`, `239-v1.v1`, `239-v2.v2`
- **`neogeo` set:** `sp-s2.sp1`, `sfix.sfix`, `sm1.sm1`, `000-lo.lo`

Then run:

```
blazingstar.exe --rom-path roms
```

## Controls

Arrows move · **Z X C V** = A B C D · **5** coin · **1** start · **Esc** quit.
Gamepad: D-pad / stick move, A/B/X/Y = A/B/C/D, Start, Back = coin.

## Known limitations

- The 3 MB P ROM has two banks. The runtime is bank-aware: it runs recompiled code
  for bank 0 and interprets the second bank when it is reached. The verified
  sessions never needed it, so they run fully native.
- `--record` produces silent video; audio goes to the window or `--wav`.
- The Windows build is unsigned, so SmartScreen may warn on first run
  (More info -> Run anyway).

## Build from source

```
git clone https://github.com/omegakatana92/Blazing-Star-Recomp
cd Blazing-Star-Recomp
# unzip your ROMs into roms/
cmake -S . -B build -DBLAZSTAR_ROM_DIR=roms
cmake --build build --config Release
```

The generated code is compiled with `/O1` + `/MP4`. MSVC `/O2` on these
multi-thousand-block functions takes roughly ten minutes per file; `/O1` plus
parallel compilation keeps the build to minutes.

## Credits and licence

- neogeorecomp toolkit by sp00nznet (MIT); Musashi (MIT), z80 (MIT), ymfm (BSD-3).
  Their licences are kept under `neogeorecomp/`.
- This repository is licensed under the **PolyForm Noncommercial License 1.0.0**
  (see `LICENSE`): free for noncommercial use, commercial use by arrangement.
- *Blazing Star* is (c) SNK / Yumekobo. This project contains none of its code or
  data and requires your own ROM dumps to run.
