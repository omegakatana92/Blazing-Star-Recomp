Blazing Star — Native Windows Recompilation
===========================================

A native Windows x64 build of Blazing Star (SNK Neo Geo, 1998), produced by
statically recompiling the game's Motorola 68000 code to C with the neogeorecomp
v0.2.0 toolkit. This is a recompilation, not an emulator wrapper: the 68000 code
runs as native machine code against a software model of the Neo Geo board.

WHAT'S INCLUDED
---------------
  blazingstar.exe   the game (native x64)
  SDL2.dll          runtime dependency (window, input, audio)
  README.txt        this file
  LICENSE.txt       PolyForm Noncommercial 1.0.0

No game ROMs, BIOS images, or ROM-derived source are included. You supply those
from your own legally obtained dumps.

YOU NEED THESE FILES
--------------------
Unzip these into a folder called `roms` next to `blazingstar.exe` (or point the
game at them with --rom-path):

From the MAME "blazstar" set:
  239-p1.p1   239-p2.sp2
  239-c1.c1 .. 239-c8.c8
  239-s1.s1   239-m1.m1
  239-v1.v1   239-v2.v2

From the MAME "neogeo" system set:
  sp-s2.sp1   sfix.sfix   sm1.sm1   000-lo.lo

(The default system ROM is sp-s2.sp1, MVS Asia/Europe v2. The other BIOS files in
the neogeo set are not needed.)

RUNNING
-------
  blazingstar.exe --rom-path roms

Run from a command prompt so you can see messages. On first run Windows may show a
SmartScreen warning for an unsigned build: choose "More info" then "Run anyway".

CONTROLS
--------
  Arrow keys      move
  Z X C V         Neo Geo A / B / C / D
  5               insert coin
  1               start (player 1)
  Esc             quit

  Gamepad         D-pad or left stick move; A/B/X/Y = A/B/C/D; Start = start;
                  Back = coin. Two pads play as players 1 and 2.

COMMAND-LINE OPTIONS
--------------------
  --rom-path DIR    game ROM files (default: roms)
  --bios-path DIR   system ROM files (default: the ROM path)
  --headless        no window; run as fast as possible
  --interp          run everything in the interpreter
  --verify          re-check every recompiled block against the interpreter
  --frames N        stop after N frames
  --screenshot N:F  save frame N as a PNG
  --record FILE.mp4 pipe frames to ffmpeg
  --wav FILE        write the audio to a WAV file
  --mute            no sound

KNOWN LIMITATIONS
-----------------
- Blazing Star's 3 MB program ROM has two banks. The recompiler covers the fixed
  bank and the first bank; the second bank runs in the interpreter fallback. The
  game is correct (and verified block-for-block), but that bank is not accelerated.
- Sound plays in the window and via --wav; --record still produces silent video.

LICENCE
-------
This build is distributed under the PolyForm Noncommercial License 1.0.0: free
for personal, hobby, research, educational and other noncommercial use; commercial
use needs a separate licence. The full text is in LICENSE.txt and at
<https://polyformproject.org/licenses/noncommercial/1.0.0>.

The vendored neogeorecomp toolkit and its Musashi, z80 and ymfm components keep
their own MIT / BSD-3-Clause licences (see the source repository).

Blazing Star is (c) SNK. This build contains none of its code or data and requires
your own ROM dumps to run.
