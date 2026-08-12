# AGENTS.md

Guidance for AI agents working in this repo. Read before making changes.

## What this is

The marketing/landing site for **Torii SRS**, a Japanese vocabulary app. It is a static
Astro 7 + Tailwind 4 rebuild of an old WordPress site (Jevelin theme, Smart Slider, WPBakery)
that became unmaintainable as its plugins died.

**This is a legacy site.** It exists to keep working and stay cheap to maintain, not to grow.
Prefer the boring, dependency-free option. Do not introduce a framework, a CMS, a UI library, or
a client-side router. Most pages ship zero JavaScript; keep it that way.

## Commands

Package manager is **pnpm** (`node_modules/.pnpm`, `pnpm-workspace.yaml`). Node >= 22.12 (Astro 7).

```bash
pnpm install
pnpm dev        # http://localhost:4321
pnpm build      # -> dist/
pnpm preview
```

## Deployment

Apache, serving the document root of the existing torii-srs.com server — the same host as the
Torii API. Build with `pnpm build`, upload the contents of `dist/`, and install `deploy/htaccess`
there as `.htaccess` (redirects, 404, caching, security headers).

**The document root is shared and not owned by this repo.** `api/`, `vocab.json`, `version`,
`knowledge-base`, `system-notification`, `transaction-*.html`, `img_files/`, `icns/`,
`font_files/` and `audio_files/` all live there and must survive any deploy. Never
`rsync --delete` into it without excluding them.

`/api/v1/` and `/api/v2/` each have their own `.htaccess` with a PHP front controller. Because
they switch on their own `RewriteEngine`, they do not inherit the document root's rewrite rules —
but they *do* inherit `Header` and `ErrorDocument` directives.

## Things that will bite you

- **URL parity is load-bearing.** `trailingSlash: 'always'` + `build.format: 'directory'` keeps
  every URL identical to the old WordPress ones (`/mac-help/`). Apache's `DirectorySlash` handles
  the bare form, and `deploy/htaccess` maps all the old WP URLs (dated changelog posts,
  `/home-startup/`, `/category/changelog/`, the installer paths). Don't change the URL shape.
- **`compressHTML: false` is deliberate.** Astro 7 defaults it to `'jsx'`, which strips whitespace
  around inline elements and silently fuses words in this site's copy
  (`<em>spaced repetition</em>, a proven…` → `spaced repetitiona proven…`). Leave it off.
- **The Astro 7 compiler rejects malformed HTML.** FAQ/mac-help/About are ports of sloppy
  WordPress markup — make sure anything you paste in is well-formed.
- **Binaries are not served from this site.** ~250 MB of installers live in Cloudflare R2 behind
  `dl.torii-srs.com`, off the origin and on a CDN. `src/data/downloads.ts` is the single source of
  truth for every download URL and version. Don't commit installers to the repo.
- **Reveal animations must fail open.** The hidden state is scoped to a `.js-anim` class set only
  when JS runs and `prefers-reduced-motion` is not set. Never write a bare `opacity: 0` initial
  state — without that guard, content becomes permanently invisible with no way to reveal it.
- `src/data/privacy-content.html` is a pre-cleaned fragment rendered via `set:html`. Edit it
  directly — WordPress is gone, so it cannot be regenerated from the original.

## Content rules

**Site copy is verbatim from the original WordPress site.** Do not reword, tighten, or
"improve" it. The only sanctioned edits are genuine grammatical errors and factual staleness
(e.g. the About page's hosting credits). If you think a sentence reads badly, leave it and say so
rather than changing it.

Adding a release: drop `src/content/releases/vX-Y-Z.md` with `version`, `date`, `released`
frontmatter — it appears on `/release-notes/` automatically, newest first.

## Git conventions

- **Single-line commit messages.** No body, no bullet list.
- **No attribution trailers** — no `Co-Authored-By`, no "Generated with" lines, nothing naming
  the tool or model that made the change.
- **Never push.** Commit only when asked, and leave pushing to a human.
