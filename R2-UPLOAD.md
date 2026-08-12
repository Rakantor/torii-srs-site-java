# Moving the installers to Cloudflare R2

The 7 installers (~250 MB) currently live in the WordPress uploads directory. They must move
before WordPress is retired, because **Cloudflare Pages cannot host them** — it enforces a 25 MB
per-file limit and these files are ~50 MB each.

They are already mirrored locally by `npm run mirror-assets` into `binaries/` (gitignored), with
sha256 checksums in `assets-manifest.txt`.

## 1. Create the bucket

```bash
npx wrangler r2 bucket create torii-downloads
```

## 2. Upload

```bash
npx wrangler r2 object put torii-downloads/v1.4.9/ToriiSRS-winX64.zip       --file binaries/v1.4.9/ToriiSRS-winX64.zip      --content-type application/zip
```

```bash
npx wrangler r2 object put torii-downloads/v1.4.9/ToriiSRS-1.4.9-macM1.dmg  --file binaries/v1.4.9/ToriiSRS-1.4.9-macM1.dmg --content-type application/x-apple-diskimage
```

```bash
npx wrangler r2 object put torii-downloads/v1.4.9/ToriiSRS-1.4.9-macX64.dmg --file binaries/v1.4.9/ToriiSRS-1.4.9-macX64.dmg --content-type application/x-apple-diskimage
```

```bash
npx wrangler r2 object put torii-downloads/v1.4.9/ToriiSRS-linuxX64.zip     --file binaries/v1.4.9/ToriiSRS-linuxX64.zip    --content-type application/zip
```

```bash
npx wrangler r2 object put torii-downloads/v1.4.8/Torii-SRS-v1.4.8_win.zip   --file binaries/v1.4.8/Torii-SRS-v1.4.8_win.zip   --content-type application/zip
```

```bash
npx wrangler r2 object put torii-downloads/v1.4.8/Torii-SRS-v1.4.8.dmg       --file binaries/v1.4.8/Torii-SRS-v1.4.8.dmg       --content-type application/x-apple-diskimage
```

```bash
npx wrangler r2 object put torii-downloads/v1.4.8/Torii-SRS-v1.4.8_linux.zip --file binaries/v1.4.8/Torii-SRS-v1.4.8_linux.zip --content-type application/zip
```

## 3. Expose it at dl.torii-srs.com

In the Cloudflare dashboard: **R2 → torii-downloads → Settings → Public access → Custom domain**,
add `dl.torii-srs.com`. (Use a custom domain rather than the `r2.dev` URL — `r2.dev` is rate
limited and not meant for production traffic.)

## 4. Flip the site over

In [`src/data/downloads.ts`](src/data/downloads.ts):

```ts
export const USE_R2 = true;
```

That single constant switches all 7 links. Rebuild and deploy.

## 5. Verify

```bash
for f in v1.4.9/ToriiSRS-winX64.zip v1.4.9/ToriiSRS-1.4.9-macM1.dmg v1.4.9/ToriiSRS-1.4.9-macX64.dmg v1.4.9/ToriiSRS-linuxX64.zip v1.4.8/Torii-SRS-v1.4.8_win.zip v1.4.8/Torii-SRS-v1.4.8.dmg v1.4.8/Torii-SRS-v1.4.8_linux.zip; do printf '%s %s\n' "$(curl -sIL -o /dev/null -w '%{http_code}' "https://dl.torii-srs.com/$f")" "$f"; done
```

All 7 must return `200`. To confirm the uploads are byte-identical to what WordPress served,
re-run `sha256sum` on the downloaded files and compare against `assets-manifest.txt`.

## 6. Optional: redirect the old URLs

Once R2 is live, uncomment the last two rules in [`public/_redirects`](public/_redirects) so any
old link to `/wp/wp-content/uploads/...` forwards to R2 instead of 404ing.
