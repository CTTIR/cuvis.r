#!/bin/sh
# Shared SDK discovery for R's Unix and Windows configure entry points.
set -eu
platform=${1:-unix}
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
cd "$root"
case "$platform" in
  unix) output=src/Makevars ;;
  windows) output=src/Makevars.win ;;
  *) printf '%s\n' 'Unknown configure platform.' >&2; exit 1 ;;
esac

stub() {
  printf '%s\n' 'PKG_CPPFLAGS = -DCUVIS_STUB' 'PKG_LIBS =' > "$output"
  printf '%s\n' '* cuvis.r: stub build; SDK operations are unavailable.'
}

case "${CUVIS_STUB:-0}" in
  1) stub; exit 0 ;;
  0|'') ;;
  *) printf '%s\n' 'CUVIS_STUB must be 0 or 1.' >&2; exit 1 ;;
esac

include=
library=
find_sdk() {
  candidate=$1
  [ -d "$candidate" ] || return 1
  candidate=$(CDPATH= cd -- "$candidate" && pwd -P)
  for headers in "$candidate/include" "$candidate/sdk/cuvis_c" "$candidate"; do
    [ -f "$headers/cuvis.h" ] || continue
    include=$headers
    for libdir in "$candidate/lib" "$candidate/lib64" "$candidate/bin" \
        "$candidate" "$candidate/../lib" "$candidate/../../bin" \
        "$candidate/lib/x86_64-linux-gnu" "$candidate/lib/aarch64-linux-gnu"; do
      if [ "$platform" = windows ]; then
        names='cuvis.lib libcuvis.dll.a cuvis.dll cuvis_c.lib libcuvis_c.dll.a cuvis_c.dll'
      else
        names='libcuvis.so libcuvis_c.so libcuvis.dylib libcuvis_c.dylib'
      fi
      for name in $names; do
        if [ -f "$libdir/$name" ]; then
          libdir=$(CDPATH= cd -- "$libdir" && pwd -P)
          library=$libdir/$name
          return 0
        fi
      done
    done
    printf '%s\n' 'CUVIS header found without a matching SDK library. Fix the installation or set CUVIS_STUB=1.' >&2
    exit 1
  done
  return 1
}

requested=${CUVIS_SDK:-${CUVIS:-}}
if [ -n "$requested" ]; then
  if ! find_sdk "$requested"; then
    printf '%s\n' 'Requested CUVIS SDK was not found. Use its installation root or set CUVIS_STUB=1.' >&2
    exit 1
  fi
else
  for candidate in /opt/cuvis /usr/local/cuvis /usr/local /usr \
      'C:/Program Files/Cuvis' 'C:/Program Files/Cubert GmbH/Cuvis'; do
    if find_sdk "$candidate"; then break; fi
  done
  if [ -z "$include" ] && [ -d .cuvis ]; then
    header=$(find "$root/.cuvis" -type f -name cuvis.h | LC_ALL=C sort | head -n 1)
    if [ -n "$header" ]; then find_sdk "$(dirname -- "$header")" || :; fi
  fi
fi

if [ -z "$include" ]; then
  stub
  printf '%s\n' 'Install the SDK from https://github.com/cubert-hyperspectral/cuvis.sdk/releases' \
    'and reinstall cuvis.r with CUVIS_SDK set to its installation root.'
  exit 0
fi

# Make expands dollar signs and treats hash as a comment even inside quotes.
# Reject those and shell quote/escape characters rather than emitting an unsafe
# Makevars file. Ordinary spaces, ampersands and apostrophes remain supported.
case "$include$library" in
  *'$'*|*'#'*|*'"'*|*'`'*|*'\'*|*'
'*) printf '%s\n' 'SDK path contains characters unsupported by Makevars. Choose a plain installation path.' >&2; exit 1 ;;
esac

{
  printf 'PKG_CPPFLAGS = -I"%s"\n' "$include"
  if [ "$platform" = windows ]; then
    printf 'PKG_LIBS = "%s"\n' "$library"
  else
    printf 'PKG_LIBS = "%s" -Xlinker -rpath -Xlinker "%s"\n' "$library" "$(dirname -- "$library")"
  fi
} > "$output"
printf '%s\n' "* cuvis.r: SDK headers $include" "* cuvis.r: SDK library $library"
