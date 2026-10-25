# Blazing Star: porting notes

What this title needs from the toolkit, and what bringing it up showed. These notes
cover behaviour only. Code addresses and disassembly lifted from the ROM are not
published here beyond what a runtime trace reports.

## The set

MAME set `blazstar` (NGH-239), plus the `neogeo` system set. See the README for the
full table. The board has no protection or encryption (PROG board: PROGBK1; CHA board:
CHA512Y).

The P ROM is unusual for the toolkit: **3 MB, as two files** — `239-p1.p1` (1 MB, the
fixed `$000000` bank) and `239-p2.sp2` (2 MB, the banked `$200000` region, i.e. two
banks). MAME loads them with `ROM_LOAD16_WORD_SWAP` at offsets `0x000000` and
`0x100000`, which `game.c` mirrors directly.

## What it exercises

- **Boot through the real MVS BIOS**: RAM test, Z80 handshake, eyecatcher, coin and
  credit handling, and the attract loop.
- **P ROM bank switching.** The game writes the bank-select register (`$2FFFF0`) with a
  value read from a PC-relative table, so both banks of the 2 MB banked region are
  used. The board model (bus.c) handles the mapping; see "Multi-bank P ROMs" below.
- **Sprites**: four C-ROM pairs (32 MB), large multi-sprite objects, and the fix layer.

## What the toolkit needed

### Multi-bank P ROMs

neogeorecomp v0.2.0 recompiles only the fixed bank and the *first* banked megabyte
(`docs/recompiler.md`: "bank — the first banked MB"). Its dispatcher assumed bank 0 was
always selected, so for a two-bank game it would have dispatched bank-0 code while
bank 1 was mapped — wrong. The fix, kept generic rather than title-specific:

- `bus.c` exposes `bus_current_bank()`.
- `exec.c` `lookup()` returns no recompiled entry for the `$200000` region while any
  bank other than 0 is selected, so that bank runs in Musashi.
- `exec.c` `note_miss()` skips those addresses so `--dump-misses` does not feed a
  different bank's entry points back as bank-0 seeds.

Result: bank 0 runs natively, bank 1 runs interpreted, and `--verify` stays clean.

### Runtime-only entry points

Like Metal Slug, Blazing Star copies memory with unrolled `move.w (A3)+,(A2)` loops
entered at computed offsets. Static discovery cannot see the landing points; the
profile pass (`--dump-misses` → `--entries` → rebuild) covers them.

## Status

Recompiled: **2,467,114 instructions** across **30,584 routines** and **38,516 dispatch
entries** (after one profile pass). `--verify` reports **0 mismatches** over the boot
and gameplay sessions, and native frames are byte-identical to interpreted ones.
