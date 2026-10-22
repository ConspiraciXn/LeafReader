#!/usr/bin/env bash
# Runs in the official devkitpro/devkita64 container, including on GitHub Actions.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
: "${DEVKITPRO:=/opt/devkitpro}"
export DEVKITPRO
export DEVKITA64="$DEVKITPRO/devkitA64"
export PATH="$DEVKITA64/bin:$DEVKITPRO/tools/bin:$DEVKITPRO/portlibs/switch/bin:$PATH"

command -v aarch64-none-elf-gcc
command -v elf2nro
dkp-pacman -Q > toolchain-packages.log

# Generate embedded fonts using the runner's native compiler, before cross compiling.
make -C libs/mupdf -j2 generate CC=gcc CXX=g++ HAVE_OBJCOPY=no

if ! grep -q 'defined(__SWITCH__)' libs/mupdf/source/pdf/pdf-annot.c; then
  patch -d libs/mupdf -p1 < patches/mupdf-switch-timegm.patch
fi

make -C libs/mupdf -j2 libs \
  OS=Switch HAVE_OBJCOPY=no \
  CC=aarch64-none-elf-gcc CXX=aarch64-none-elf-g++ \
  AR=aarch64-none-elf-ar RANLIB=aarch64-none-elf-ranlib \
  XCFLAGS="-D__SWITCH__ -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE" \
  USE_SYSTEM_FREETYPE=yes \
  SYS_FREETYPE_CFLAGS="-I$DEVKITPRO/portlibs/switch/include/freetype2 -I$DEVKITPRO/portlibs/switch/include" \
  SYS_FREETYPE_LIBS=-lfreetype \
  USE_SYSTEM_LIBJPEG=yes \
  SYS_LIBJPEG_CFLAGS="-I$DEVKITPRO/portlibs/switch/include" \
  SYS_LIBJPEG_LIBS=-ljpeg \
  USE_SYSTEM_HARFBUZZ=no USE_SYSTEM_JBIG2DEC=no USE_SYSTEM_JPEGXR=no \
  USE_SYSTEM_LCMS2=no USE_SYSTEM_MUJS=no USE_SYSTEM_OPENJPEG=no USE_SYSTEM_ZLIB=no

mkdir -p libs/mupdf/lib
cp libs/mupdf/build/release/libmupdf.a libs/mupdf/lib/
cp libs/mupdf/build/release/libmupdf-third.a libs/mupdf/lib/
make -j2
test -s LeafReader.nro
sha256sum LeafReader.nro > LeafReader.nro.sha256

if [[ -n "${CRASH_ADDRESSES:-}" ]]; then
  read -r -a addresses <<< "$CRASH_ADDRESSES"
  for address in "${addresses[@]}"; do
    [[ "$address" =~ ^(0x)?[[:xdigit:]]+$ ]] || { echo "Invalid crash offset" >&2; exit 1; }
  done
  aarch64-none-elf-addr2line -a -f -C -e LeafReader.elf "${addresses[@]}"
fi
