#!/usr/bin/env bash
# Deploy the static site into the existing torii-srs.com document root.
#
# The docroot is shared with things that are NOT part of this site and must
# survive untouched:
#
#   api/                    the Torii API
#   vocab.json              vocabulary data served to the app
#   version                 version manifest the app polls
#   knowledge-base          in-app FAQ content
#   system-notification     in-app notification payload
#   transaction-*.html      payment return pages
#   img_files/ icns/ font_files/ audio_files/    app assets
#
# Because of that this NEVER uses `rsync --delete` at the docroot. It copies the
# site in additively and removes only the two WordPress entry points by name.
#
#   ./scripts/deploy.sh user@host:/var/www/torii
#   ./scripts/deploy.sh user@host:/var/www/torii --dry-run
set -euo pipefail

TARGET="${1:-}"
DRY="${2:-}"

if [[ -z "$TARGET" ]]; then
  echo "usage: $0 user@host:/path/to/docroot [--dry-run]" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> Building"
pnpm build

echo "==> Staging .htaccess"
cp deploy/htaccess dist/.htaccess

# _redirects/_headers are Cloudflare Pages formats and do nothing on Apache.
rm -f dist/_redirects dist/_headers

RSYNC_OPTS=(-avz --human-readable)
[[ "$DRY" == "--dry-run" ]] && RSYNC_OPTS+=(--dry-run) && echo "    (dry run)"

echo "==> Uploading to $TARGET"
# No --delete: the docroot holds files this repo does not own.
rsync "${RSYNC_OPTS[@]}" dist/ "$TARGET/"

echo
echo "==> Remaining manual step"
cat <<'EOF'
    Install the API error-document override and remove the WordPress entry points.
    Run on the server, from the document root:

      cp /path/to/api-htaccess api/.htaccess     # from deploy/api-htaccess
      rm -f index.php                            # WordPress bootstrap
      rm -rf wp/                                 # WordPress core + uploads

    Delete wp/ only after confirming the installers resolve from R2 - the
    .htaccess redirects /wp/wp-content/uploads/* there, so nothing should still
    be reading from that directory.

    Then verify:
      ./scripts/verify-deploy.sh https://torii-srs.com
EOF
