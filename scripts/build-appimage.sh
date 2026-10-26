#!/usr/bin/env bash
# build-appimage.sh — build Blazing Star for Linux and package it as an AppImage
# (for Steam Deck / SteamOS and other desktop Linux).
#
# The game is a static recompilation: its 68000 code is translated to C at build
# time from the user's own ROM dumps. No ROMs or BIOS files are bundled here.
#
# If roms/ (MAME sets "blazstar" + "neogeo", unzipped) is present, the build is a
# full native recompilation. Without it the build is interpreter-only and still
# needs the ROMs at runtime (see the AppRun launcher).
#
# Usage:
#   ./scripts/build-appimage.sh            # uses ./roms if present
#   BLAZSTAR_ROM_DIR=/path/to/roms ./scripts/build-appimage.sh
set -euo pipefail

# AppImage tooling runs without FUSE on Steam Deck and in CI.
export APPIMAGE_EXTRACT_AND_RUN=1

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ROM_DIR="${BLAZSTAR_ROM_DIR:-}"
if [ -z "$ROM_DIR" ] && [ -d "$ROOT/roms" ]; then ROM_DIR="$ROOT/roms"; fi

# --- prerequisites ---
for c in cmake gcc g++ make; do
  command -v "$c" >/dev/null 2>&1 || { echo "error: '$c' not found"; exit 1; }
done

if [ -n "$ROM_DIR" ]; then
  echo "== ROMs found at $ROM_DIR (full native recompilation) =="
  CMAKE_ARGS=(-DCMAKE_BUILD_TYPE=Release "-DBLAZSTAR_ROM_DIR=$ROM_DIR")
else
  echo "== no ROMs found: building interpreter-only (supply ROMs to recompile) =="
  CMAKE_ARGS=(-DCMAKE_BUILD_TYPE=Release)
fi

# --- build ---
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release "${CMAKE_ARGS[@]}"
cmake --build build -j"$(nproc)"

BIN="$ROOT/build/blazingstar"
[ -x "$BIN" ] || BIN="$ROOT/build/Release/blazingstar"
[ -x "$BIN" ] || { echo "error: blazingstar binary not found"; exit 1; }

# --- assemble AppDir ---
APPDIR="$ROOT/build/AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib"
cp "$BIN" "$APPDIR/usr/bin/blazingstar"
cp "$ROOT/packaging/AppRun" "$APPDIR/AppRun"; chmod +x "$APPDIR/AppRun"
cp "$ROOT/packaging/blazingstar.desktop" "$APPDIR/blazingstar.desktop"
cp "$ROOT/packaging/blazingstar.svg" "$APPDIR/blazingstar.svg"
mkdir -p "$APPDIR/usr/share/licenses/blazingstar"
cp "$ROOT/LICENSE" "$APPDIR/usr/share/licenses/blazingstar/LICENSE"
cp "$ROOT/LICENSE" "$APPDIR/LICENSE"

# Bundle SDL2 (and convert the icon) with linuxdeploy when it is installed.
if command -v linuxdeploy >/dev/null 2>&1; then
  linuxdeploy --appdir "$APPDIR" --desktop-file "$APPDIR/blazingstar.desktop" \
    --icon-file "$APPDIR/blazingstar.svg" --executable "$APPDIR/usr/bin/blazingstar" \
    --output appimage 2>&1 | tail -20
  exit 0
fi

# Fallback: copy SDL2 from the system.
SDL_LIB="$(ldconfig -p 2>/dev/null | awk '/libSDL2-2\.0\.so\.0/ {print $NF; exit}')"
if [ -n "$SDL_LIB" ]; then
  cp "$SDL_LIB" "$APPDIR/usr/lib/"
fi

# --- package with appimagetool ---
APPIMAGETOOL="$(command -v appimagetool || true)"
if [ -z "$APPIMAGETOOL" ]; then
  APPIMAGETOOL="$ROOT/build/appimagetool-x86_64.AppImage"
  if [ ! -x "$APPIMAGETOOL" ]; then
    echo "== downloading appimagetool =="
    curl -L -o "$APPIMAGETOOL" \
      https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
    chmod +x "$APPIMAGETOOL"
  fi
fi

"$APPIMAGETOOL" "$APPDIR" "BlazingStar-Recomp-x86_64.AppImage"
echo "== done: $ROOT/BlazingStar-Recomp-x86_64.AppImage =="
