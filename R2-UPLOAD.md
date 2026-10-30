# Installers on Cloudflare R2

The installers are not served from this site. They live in the Cloudflare R2 bucket
`torii-downloads`, behind the custom domain `dl.torii-srs.com`. `src/data/downloads.ts` holds
every URL and is the only place that needs editing for a new release.

They were moved there in August 2026, when the site was rebuilt off WordPress. Each object was
verified byte-identical to the file WordPress had been serving before the site was switched over.

## Publishing a new release

Upload under a `v<version>/` prefix:

```bash
npx wrangler r2 object put torii-downloads/v1.5.0/ToriiSRS-winX64.zip --file ToriiSRS-winX64.zip --content-type application/zip
```

```bash
npx wrangler r2 object put torii-downloads/v1.5.0/ToriiSRS-1.5.0-macM1.dmg --file ToriiSRS-1.5.0-macM1.dmg --content-type application/x-apple-diskimage
```

Then update `latest`, `LATEST_VERSION` and `LATEST_RELEASED` in
[`src/data/downloads.ts`](src/data/downloads.ts), move the previous version into `legacy`, and add
a changelog entry under `src/content/releases/`.

Check the uploads resolve:

```bash
for f in v1.5.0/ToriiSRS-winX64.zip v1.5.0/ToriiSRS-1.5.0-macM1.dmg; do printf '%s %s\n' "$(curl -sIL -o /dev/null -w '%{http_code}' "https://dl.torii-srs.com/$f")" "$f"; done
```

## Why R2

The installers add up to about 260 MB. R2 serves them off the origin, from a CDN, at no
egress cost.

## Checksums as uploaded

sha256 of each object, recorded at upload time against the WordPress originals.

| Object | Bytes | sha256 |
| --- | ---: | --- |
| `v1.4.9/ToriiSRS-winX64.zip` | 49,596,454 | `c046d5bf0d211d79ef6b677cbf2f19c1e55f4642e6720a6b0928ab4d60ebc738` |
| `v1.4.9/ToriiSRS-1.4.9-macM1.dmg` | 51,530,296 | `676e46e50cb51269d26ee8da3a8f0a3fea7f675b5182363e4d5a4938551a7f9b` |
| `v1.4.9/ToriiSRS-1.4.9-macX64.dmg` | 52,801,544 | `cb7f534b2bcaf3c706ec9615b319a171bddb14422e87560ab3aa9da820492cea` |
| `v1.4.9/ToriiSRS-linuxX64.zip` | 51,323,920 | `dc3bbc7a2d970403b5e8ed4766d1cd1f7f9faf0967d765beebdd07da8bed1520` |
| `v1.4.8/Torii-SRS-v1.4.8_win.zip` | 17,529,145 | `ebfe6d904ce36cb8a2a14da8a155792f1f1a3f964b07838c63260785ab5b06f6` |
| `v1.4.8/Torii-SRS-v1.4.8.dmg` | 19,083,713 | `ab0c359b36fc8e6f2630eb6843cfa910b7c2e43ca1038ba4375f6daade4d92da` |
| `v1.4.8/Torii-SRS-v1.4.8_linux.zip` | 17,495,846 | `63b6e01bc4fa9271fc8bf161c3cd1ec2b5f8e45465c603bbbb74b3907a243e61` |

Verify any of them:

```bash
curl -sL https://dl.torii-srs.com/v1.4.9/ToriiSRS-winX64.zip | sha256sum
```
