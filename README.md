# torii-srs.com

Static rebuild of the Torii SRS marketing site, replacing the old WordPress install.
Astro 7 + Tailwind 4, no CMS, no database, no plugins to keep alive.

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # -> dist/
npm run preview
```

Requires Node >= 22.12 (Astro 7).

## Deploying (Cloudflare Pages)

| Setting | Value |
| --- | --- |
| Build command | `npm run build` |
| Output directory | `dist` |
| Node version | 22 or newer |

`public/_redirects` and `public/_headers` are copied into `dist/` and picked up automatically.

**The installers are not served from this site.** Cloudflare Pages caps files at 25 MB and the
installers are ~50 MB each, so they live in Cloudflare R2 — see [R2-UPLOAD.md](R2-UPLOAD.md).

## Layout

```
src/pages/            one file per URL; paths match the old WordPress URLs exactly
src/data/downloads.ts every installer URL + version number (single source of truth)
src/data/privacy-content.html  pre-cleaned Termly policy, rendered via set:html
src/content/releases/ 14 changelog entries as markdown
src/components/       Header, Footer, PageHeader, Slideshow, Prose
public/images/        screenshots, logo, hero, Play badge (mirrored from WordPress)
scripts/mirror-wp-assets.sh    re-pulls every asset from WordPress
```

### Common edits

- **New release** — add `src/content/releases/vX-Y-Z.md` with `version`, `date`, `released`
  frontmatter. It appears on `/release-notes/` automatically, newest first.
- **New version for download** — update `latest` and `LATEST_VERSION` in `src/data/downloads.ts`.
- **Point downloads at R2** — set `USE_R2 = true` in the same file.

## Notes

- `compressHTML` is disabled in `astro.config.mjs`. Astro 7 defaults it to `'jsx'`, which strips
  whitespace around inline tags and would fuse words in the body copy.
- `trailingSlash: 'always'` keeps URLs identical to the WordPress ones (`/mac-help/`), and
  `public/_redirects` 301s the bare form (`/mac-help`) onto it. Note `astro preview` does not read
  `_redirects` — to check redirect behaviour locally use `npx wrangler pages dev dist`, which runs
  the same logic Cloudflare Pages does.
- Fonts are self-hosted (latin subset only) — no Google Fonts request.
- Entrance animations replace the old theme's WOW.js: mark any element `data-reveal` (optionally
  with `style="--reveal-delay: 0.3s"`) and it fades up when scrolled into view. The hidden state is
  scoped to a `.js-anim` class that is only set when JS runs and reduced motion is not requested,
  so content is never left invisible.
- There is no contact page. Every "contact" link is a `mailto:` built from `CONTACT_EMAIL` in
  `src/data/site.ts` — change the address there and it updates site-wide.
