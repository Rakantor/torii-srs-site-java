#!/usr/bin/env bash
# Mirror every asset off the WordPress site before it is taken offline.
# Binaries land in binaries/ (gitignored, staged for R2); images in public/images/.
# Re-running is safe: curl -C - resumes, and existing complete files are skipped.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UP="https://torii-srs.com/wp/wp-content/uploads"
BIN="$ROOT/binaries"
IMG="$ROOT/public/images"
MANIFEST="$ROOT/assets-manifest.txt"

mkdir -p "$BIN/v1.4.9" "$BIN/v1.4.8" "$IMG"

fail=0

# fetch <url> <destination>
fetch() {
  local url="$1" dest="$2" name
  name="$(basename "$dest")"

  local remote
  remote="$(curl -sIL "$url" | awk 'BEGIN{IGNORECASE=1}/^content-length:/{v=$2}END{gsub(/\r/,"",v);print v}')"

  if [[ -f "$dest" && -n "$remote" && "$(stat -c%s "$dest")" == "$remote" ]]; then
    echo "  = $name (already complete)"
    return 0
  fi

  echo "  > $name"
  if ! curl -fsSL -C - -o "$dest" "$url"; then
    echo "  ! FAILED: $url" >&2
    fail=1
    return 1
  fi

  if [[ -n "$remote" && "$(stat -c%s "$dest")" != "$remote" ]]; then
    echo "  ! SIZE MISMATCH: $name (got $(stat -c%s "$dest"), expected $remote)" >&2
    fail=1
  fi
}

echo "== Installers (v1.4.9) =="
fetch "$UP/2025/11/ToriiSRS-winX64.zip"        "$BIN/v1.4.9/ToriiSRS-winX64.zip"
fetch "$UP/2025/11/ToriiSRS-1.4.9-macM1.dmg"   "$BIN/v1.4.9/ToriiSRS-1.4.9-macM1.dmg"
fetch "$UP/2025/11/ToriiSRS-1.4.9-macX64.dmg"  "$BIN/v1.4.9/ToriiSRS-1.4.9-macX64.dmg"
fetch "$UP/2025/11/ToriiSRS-linuxX64.zip"      "$BIN/v1.4.9/ToriiSRS-linuxX64.zip"

echo "== Installers (v1.4.8 legacy) =="
fetch "$UP/2020/05/Torii-SRS-v1.4.8_win.zip"   "$BIN/v1.4.8/Torii-SRS-v1.4.8_win.zip"
fetch "$UP/2020/05/Torii-SRS-v1.4.8.dmg"       "$BIN/v1.4.8/Torii-SRS-v1.4.8.dmg"
fetch "$UP/2020/05/Torii-SRS-v1.4.8_linux.zip" "$BIN/v1.4.8/Torii-SRS-v1.4.8_linux.zip"

echo "== Images =="
for i in 1 2 3 4 5 6 7 8; do
  fetch "$UP/2019/05/showcase_00$i.png" "$IMG/showcase_00$i.png"
done
fetch "$UP/2019/04/logo.png"             "$IMG/logo.png"
fetch "$UP/2019/04/Untitled3.png"        "$IMG/hero.png"
fetch "$UP/2019/05/google-play-badge.png" "$IMG/google-play-badge.png"
fetch "$UP/2020/04/Apr-14-2020-22-35-04.gif" "$IMG/macos-audio-help.gif"

echo "== Checksums =="
{
  echo "# torii-srs.com asset mirror - generated $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "# sha256  size-bytes  path"
  while IFS= read -r f; do
    printf '%s  %s  %s\n' \
      "$(sha256sum "$f" | cut -d' ' -f1)" \
      "$(stat -c%s "$f")" \
      "${f#"$ROOT/"}"
  done < <(find "$BIN" "$IMG" -type f | sort)
} > "$MANIFEST"

echo
if [[ "$fail" -ne 0 ]]; then
  echo "COMPLETED WITH ERRORS - see FAILED/MISMATCH lines above" >&2
  exit 1
fi
echo "OK - all assets mirrored. Manifest: ${MANIFEST#"$ROOT/"}"
