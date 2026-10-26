# Blazing Star: static recompilation

**Blazing Star (Yumekobo/SNK, 1998) running as a native Windows program: its 68000
code is recompiled to C and runs on the [neogeorecomp](https://github.com/sp00nznet/neogeorecomp)
board model.**

This is a game project for the neogeorecomp v0.2.0 toolkit. The toolkit does all the
work; this repo describes the ROM set and builds the game.

> **No game data here.** You need your own Blazing Star and Neo Geo system ROM dumps
> (MAME sets `blazstar` and `neogeo`). The recompiled C is generated from your dump on
> your machine, into `build/`. It is never committed or distributed, and neither is
> anything else derived from the ROMs.

## Status

**v0.1.0, alpha.** Blazing Star boots through the real MVS BIOS, runs attract mode,
takes a coin and plays into Stage 1 on recompiled 68000 code.

- Boot through the real MVS system ROM → eyecatcher → title → attract → coin/start.
- `--verify` re-runs every recompiled block in the Musashi interpreter and compares
  registers, flags and bus writes: **0 mismatches** over the boot and gameplay sessions.
- A profiling pass captures the entry points that only appear at runtime (computed jumps
  into unrolled code), so the scripted Stage 1 session now runs **fully native — 0
  interpreted instructions, 0 uncovered entry points** — at ~900 fps headless.
- Frame output is **byte-identical** to the interpreter's.
- YM2610 sound is synthesized and played through SDL2 (or `--wav`); keyboard and gamepad
  input through SDL2.

### Compatibility notes

- **Multi-bank P ROM.** Blazing Star has a 3 MB P ROM (1 MB fixed + 2 MB banked, i.e.
  two banks). neogeorecomp v0.2.0 recompiles only the fixed bank and the *first* banked
  MB; code in the *second* bank runs in the Musashi fallback. This project patches the
  runtime so the dispatcher is **bank-aware**: it runs recompiled code for bank 0 and
  interprets any other bank, instead of wrongly dispatching bank-0 code when bank 1 is
  selected. See `neogeorecomp/src/exec.c` (`lookup`, `note_miss`) and
  `bus_current_bank()` in `neogeorecomp/src/bus.c`.

## ROM set

MAME set `blazstar` (NGH-239) plus the `neogeo` system set, unzipped into `roms/`:

| File | Size | CRC32 | Role |
|---|---|---|---|
| `239-p1.p1` | 1 MB | `183682f8` | 68000 program, fixed `$000000` bank |
| `239-p2.sp2` | 2 MB | `9a9f4154` | 68000 program, `$200000` bank (two banks) |
| `239-c1.c1`..`239-c8.c8` | 8 × 4 MB | see MAME | sprite tiles, four odd/even pairs |
| `239-s1.s1` | 128 KB | `d56cb498` | fix-layer tiles |
| `239-m1.m1` | 128 KB | `d31a3aea` | Z80 sound driver |
| `239-v1.v1`, `239-v2.v2` | 2 × 4 MB | `1b8d5bf7` `74cf0a70` | ADPCM samples |
| `sp-s2.sp1` | 128 KB | `9036d879` | MVS system ROM (Asia/Europe v2) |
| `sfix.sfix`, `sm1.sm1`, `000-lo.lo` | 128 KB each | `c2ea0cfd` `94416d67` `5a86cff2` | BIOS fix tiles, BIOS sound driver, sprite shrink table |

The board has no protection or encryption. The P ROMs are stored byte-swapped
(`ROM_LOAD16_WORD_SWAP`), which `game.c` expresses with `swap = 1`.

## Building

Prerequisites: Git, CMake 3.21+, Visual Studio 2022/2026 with *Desktop development with
C++* (or another C/C++ toolchain), and SDL2 for the window (optional — a headless build
needs nothing extra).

1. Clone this repo (the toolkit is vendored under `neogeorecomp/`), and unzip your ROMs
   into `roms/`.
2. Configure (point CMake at SDL2 with `-DSDL2_DIR=<SDL2-devel-VC>/cmake` for a window):
   ```
   cmake -S . -B build -DBLAZSTAR_ROM_DIR=roms
   ```
3. Build — the generator recompiles your ROMs into `build/generated` first:
   ```
   cmake --build build --config Release
   ```
   The generated files are compiled with `/O1` and `/MP4`. MSVC `/O2` on these
   multi-thousand-block functions takes roughly ten minutes *per file*; `/O1` plus
   four-way parallel compilation brings the whole build down to a few minutes. If
   you want maximum runtime speed and can wait, raise `/O1` to `/O2` in
   `CMakeLists.txt`.
4. Profile (optional): play scripted sessions headless to find code only reached at
   runtime, then rebuild with it:
   ```
   cmake --build build --config Release --target profile
   cmake --build build --config Release
   ```
5. Play:
   ```
   build/Release/blazingstar --rom-path roms
   ```

`BLAZSTAR_ROM_DIR` is the only game-specific option. Without it the player builds
interpreter-only, which is useful for working on the toolkit without regenerating.

## Usage

```
blazingstar --rom-path roms                                     # play
blazingstar --headless --frames 1900 --input tests/coin_start.txt --record run.mp4
blazingstar --headless --verify --frames 1801 --input tests/coin_start.txt
blazingstar --headless --interp --frames 1801 --screenshot 1800:interp.png
blazingstar --headless --frames 1900 --input tests/coin_start.txt --wav run.wav
```

See the toolkit's `docs/running.md` for every option and the input-script format.

Keys: **arrows** move, **Z X C V** = A B C D, **5** coin, **1** start, **Esc** quit.
Gamepad: D-pad or stick move, **A B X Y** = A B C D, **Start** start, **Back** coin.

## Project layout

```
blazingstar-recomp/
├── CMakeLists.txt
├── neogeorecomp/          the toolkit (vendored at commit af96b2b4, with a multi-bank
│                          dispatch fix applied — see Status)
├── src/game.c, game.h     the ng_game_t (ROM layout)
├── src/main.c             the player: ng_main(...)
├── src/recomp_main.c      the generator: ng_recomp_main(...)
├── tests/*.txt            input scripts for headless runs and the profile pass
└── roms/                  your ROM files (never committed)
```

## License

This repository is licensed under the **PolyForm Noncommercial License 1.0.0**
(see [LICENSE](LICENSE)): free for personal, hobby, research, educational and other
noncommercial use; commercial use needs a separate licence. The vendored
[neogeorecomp](neogeorecomp) toolkit and its third-party components (Musashi, z80,
ymfm) keep their own permissive licences — see `neogeorecomp/LICENSE`,
`neogeorecomp/NOTICE` and `neogeorecomp/LICENSES/`.

*Blazing Star* is © SNK; this project contains none of its code or data and needs your
own dump to do anything.
