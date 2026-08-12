#!/usr/bin/env bash
# Check a deployed Torii SRS site: pages resolve, old WordPress URLs redirect,
# installers are reachable, and - critically - the API is still being served.
#
#   ./scripts/verify-deploy.sh                    # against https://torii-srs.com
#   ./scripts/verify-deploy.sh http://localhost   # against somewhere else
set -uo pipefail

BASE="${1:-https://torii-srs.com}"
pass=0
fail=0

# check <description> <expected-code> <path> [expected-location-substring]
check() {
  local desc="$1" want="$2" path="$3" loc="${4:-}"
  local out code got_loc
  out=$(curl -s -o /dev/null -w '%{http_code}|%{redirect_url}' --max-time 25 "$BASE$path" 2>/dev/null)
  code="${out%%|*}"
  got_loc="${out#*|}"

  local ok=1
  [[ "$code" == "$want" ]] || ok=0
  [[ -z "$loc" || "$got_loc" == *"$loc"* ]] || ok=0

  if [[ "$ok" == 1 ]]; then
    printf '  \033[32mok\033[0m   %-44s %s\n' "$path" "$code"
    ((pass++))
  else
    printf '  \033[31mFAIL\033[0m %-44s got %s' "$path" "$code"
    [[ -n "$loc" ]] && printf ' -> %s (wanted %s -> %s)' "$got_loc" "$want" "$loc" || printf ' (wanted %s)' "$want"
    printf '  [%s]\n' "$desc"
    ((fail++))
  fi
}

echo "Verifying $BASE"
echo
echo "Pages"
for p in / /download/ /release-notes/ /frequently-asked-questions/ /mac-help/ /about/ /privacy/; do
  check "page" 200 "$p"
done

echo
echo "Trailing slash (Apache DirectorySlash / Pages redirect)"
for p in /download /release-notes /mac-help /about /privacy; do
  check "bare path redirects" 301 "$p" "$p/"
done

echo
echo "Unmatched paths must 404, not serve the home page"
check "soft 404 guard" 404 /test
check "soft 404 guard" 404 /nope/deep/path

echo
echo "Old WordPress URLs"
check "home slug"     301 /home-startup/                  /
check "changelog post" 301 /2025/11/20/version-1-4-9/      /release-notes/
check "changelog post" 301 /2018/06/10/version-1-0-1-june-10-2018/ /release-notes/
check "category"      301 /category/changelog/            /release-notes/
check "pagination"    301 /release-notes/page/2/          /release-notes/
check "author"        301 /author/rakantor/               /about/

echo
echo "Installers redirect to R2"
check "1.4.9 win" 301 /wp/wp-content/uploads/2025/11/ToriiSRS-winX64.zip dl.torii-srs.com/v1.4.9/
check "1.4.8 dmg" 301 /wp/wp-content/uploads/2020/05/Torii-SRS-v1.4.8.dmg dl.torii-srs.com/v1.4.8/

echo
echo "API must still be served by this host"
api=$(curl -s -o /tmp/torii-api-probe -w '%{http_code}' --max-time 25 "$BASE/api/v1/" 2>/dev/null)
if grep -qi '<title>Torii SRS' /tmp/torii-api-probe 2>/dev/null; then
  printf '  \033[31mFAIL\033[0m /api/v1/ returned the website (%s) - the API is being shadowed by the static site\n' "$api"
  ((fail++))
else
  printf '  \033[32mok\033[0m   /api/v1/ is not being served by the static site (%s)\n' "$api"
  ((pass++))
fi
rm -f /tmp/torii-api-probe

echo
echo "Non-site files sharing the docroot must survive the deploy"
for p in /vocab.json /version /knowledge-base /system-notification \
         /transaction-success.html /transaction-cancel.html; do
  check "app resource" 200 "$p"
done

echo
echo "Binaries on R2"
for k in v1.4.9/ToriiSRS-winX64.zip v1.4.9/ToriiSRS-1.4.9-macM1.dmg v1.4.8/Torii-SRS-v1.4.8.dmg; do
  code=$(curl -sIL -o /dev/null -w '%{http_code}' --max-time 30 "https://dl.torii-srs.com/$k")
  if [[ "$code" == "200" ]]; then
    printf '  \033[32mok\033[0m   %-44s %s\n' "$k" "$code"; ((pass++))
  else
    printf '  \033[31mFAIL\033[0m %-44s %s\n' "$k" "$code"; ((fail++))
  fi
done

echo
echo "-------------------------------------------"
printf 'passed %d, failed %d\n' "$pass" "$fail"
[[ "$fail" -eq 0 ]] || exit 1
