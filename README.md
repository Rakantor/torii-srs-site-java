# torii-srs.com

Static rebuild of the Torii SRS marketing site, replacing the old WordPress install.
Astro 7 + Tailwind 4, no CMS, no database, no plugins to keep alive.

```bash
pnpm install
pnpm dev        # http://localhost:4321
pnpm build      # writes dist/
pnpm preview
```

Requires Node >= 22.12 (Astro 7). Package manager is pnpm.

## Deploying

The site is served by Apache from the document root of the existing torii-srs.com server,
the same host as the Torii API.

1. `pnpm build`
2. Upload the **contents** of `dist/` to the document root
3. Install `deploy/htaccess` there as `.htaccess`

**The document root is shared.** These are not part of this site and must not be deleted:

```
api/                  the Torii API (v1 and v2, each with its own .htaccess)
vocab.json            vocabulary data served to the app
version               version manifest the app polls
knowledge-base        in-app FAQ content
system-notification   in-app notification payload
transaction-*.html    payment return pages
img_files/ icns/ font_files/ audio_files/    app assets
```

So never `rsync --delete` into the document root without excluding those.

Installers are **not** served from here. They live in Cloudflare R2 behind `dl.torii-srs.com`.
See [R2-UPLOAD.md](R2-UPLOAD.md).

## Layout

```
src/pages/            one file per URL; paths match the old WordPress URLs exactly
src/data/downloads.ts every installer URL and version (single source of truth)
src/data/privacy-content.html  pre-cleaned Termly policy, rendered via set:html
src/content/releases/ changelog entries as markdown
src/components/       AnnouncementBar, Header, Footer, PageHeader, Slideshow, FeatureIcon, Prose
public/images/        screenshots, logo, hero devices, Play badge
deploy/htaccess       Apache config: redirects, 404, caching, security headers
```

### Common edits

- **New release**: add `src/content/releases/vX-Y-Z.md` with `version`, `date`, `released`
  frontmatter. It appears on `/release-notes/` automatically, newest first.
- **New version for download**: upload to R2, then update `latest` and `LATEST_VERSION` in
  `src/data/downloads.ts`.

## Notes

- `compressHTML` is disabled in `astro.config.mjs`. Astro 7 defaults it to `'jsx'`, which strips
  whitespace around inline tags and would fuse words in the body copy.
- `trailingSlash: 'always'` keeps URLs identical to the WordPress ones (`/mac-help/`). Apache's
  `DirectorySlash` redirects the bare form onto it.
- Fonts are self-hosted, latin subset only. No Google Fonts request.
- Entrance animations: mark an element `data-reveal` (optionally with
  `style="--reveal-delay: 0.3s"`) and it fades up when scrolled into view. The hidden state is
  scoped to a `.js-anim` class set only when JS runs and reduced motion is not requested.
  Without JS nothing is hidden.
- There is no contact page. Every "contact" link is a `mailto:` built from `CONTACT_EMAIL` in
  `src/data/site.ts`.
