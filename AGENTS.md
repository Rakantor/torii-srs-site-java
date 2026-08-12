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

To test redirects, use the Cloudflare Pages emulator — **`astro preview` does not read
`public/_redirects`**, so bare paths like `/mac-help` will 404 under it and work in production:

```bash
npx wrangler pages dev dist
```

## Deployment

Cloudflare Pages. Build `pnpm build`, output `dist`. `public/_redirects` and `public/_headers`
are copied into `dist/` and picked up automatically.

## Things that will bite you

- **URL parity is load-bearing.** `trailingSlash: 'always'` + `build.format: 'directory'` keeps
  every URL identical to the old WordPress ones (`/mac-help/`). `_redirects` maps the bare forms
  and all the old WP URLs (dated changelog posts, `/home-startup/`, `/category/changelog/`).
  Don't change the URL shape.
- **`compressHTML: false` is deliberate.** Astro 7 defaults it to `'jsx'`, which strips whitespace
  around inline elements and silently fuses words in this site's copy
  (`<em>spaced repetition</em>, a proven…` → `spaced repetitiona proven…`). Leave it off.
- **The Astro 7 compiler rejects malformed HTML.** FAQ/mac-help/About are ports of sloppy
  WordPress markup — make sure anything you paste in is well-formed.
- **Binaries must never be served from this site.** Cloudflare Pages enforces a 25 MB per-file
  limit and the installers are ~50 MB each. They live in Cloudflare R2 behind `dl.torii-srs.com`.
  `src/data/downloads.ts` is the single source of truth for every download URL and version.
- **Reveal animations must fail open.** The hidden state is scoped to a `.js-anim` class set only
  when JS runs and `prefers-reduced-motion` is not set. Never write a bare `opacity: 0` initial
  state — without that guard, content becomes permanently invisible with no way to reveal it.
- `src/data/privacy-content.html` is a pre-cleaned fragment rendered via `set:html`. Edit it
  directly; don't try to regenerate it from WordPress, which is being decommissioned.

## Content rules

**Site copy is verbatim from the original WordPress site.** Do not reword, tighten, or
"improve" it. The only sanctioned edits are genuine grammatical errors and factual staleness
(e.g. the About page's hosting credits). If you think a sentence reads badly, leave it and say so
rather than changing it.

Adding a release: drop `src/content/releases/vX-Y-Z.md` with `version`, `date`, `released`
frontmatter — it appears on `/release-notes/` automatically, newest first.

## Scripts

- `scripts/mirror-wp-assets.sh` — re-pulls every image and installer from WordPress. Historical;
  WordPress is being switched off.
- `scripts/cut-hero-devices.py` — regenerates `public/images/hero-devices.png` (transparent device
  mockups) from `public/images/hero.png`.

## Git conventions

- **Single-line commit messages.** No body, no bullet list.
- **No attribution trailers** — no `Co-Authored-By`, no "Generated with" lines, nothing naming
  the tool or model that made the change.
- **Never push.** Commit only when asked, and leave pushing to a human.
