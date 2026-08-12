/**
 * Single source of truth for every downloadable binary.
 *
 * The installers are moving off WordPress (which is being retired) and into a
 * Cloudflare R2 bucket fronted by dl.torii-srs.com. Until that upload happens,
 * `USE_R2` stays false and the site keeps serving the existing WordPress URLs.
 *
 * To cut over: upload the mirrored files (see scripts/mirror-wp-assets.sh and
 * R2-UPLOAD.md), then flip USE_R2 to true. That is the whole migration.
 */

/** Flip to true once the files are live in R2. */
export const USE_R2 = false;

/** Public base for the R2 bucket. No trailing slash. */
export const R2_BASE = 'https://dl.torii-srs.com';

/** Where the WordPress uploads directory currently serves from. No trailing slash. */
export const WP_BASE = 'https://torii-srs.com/wp/wp-content/uploads';

export interface Binary {
  /** Button label. */
  label: string;
  /** Path within the R2 bucket. */
  r2Key: string;
  /** Existing path under the WordPress uploads directory. */
  wpPath: string;
  /** Size in bytes, from the mirror manifest. Used for the "(48 MB)" hint. */
  bytes: number;
}

export const url = (b: Binary): string =>
  USE_R2 ? `${R2_BASE}/${b.r2Key}` : `${WP_BASE}/${b.wpPath}`;

/** Human-readable size, e.g. "49.6 MB". */
export const size = (b: Binary): string => `${(b.bytes / 1_000_000).toFixed(1)} MB`;

export const LATEST_VERSION = '1.4.9';
export const LATEST_RELEASED = 'November 20, 2025';

export const latest = {
  windows: [
    {
      label: 'Download (x64)',
      r2Key: 'v1.4.9/ToriiSRS-winX64.zip',
      wpPath: '2025/11/ToriiSRS-winX64.zip',
      bytes: 49_596_454,
    },
  ],
  macos: [
    {
      label: 'Download (Apple Silicon)',
      r2Key: 'v1.4.9/ToriiSRS-1.4.9-macM1.dmg',
      wpPath: '2025/11/ToriiSRS-1.4.9-macM1.dmg',
      bytes: 51_530_296,
    },
    {
      label: 'Download (Intel)',
      r2Key: 'v1.4.9/ToriiSRS-1.4.9-macX64.dmg',
      wpPath: '2025/11/ToriiSRS-1.4.9-macX64.dmg',
      bytes: 52_801_544,
    },
  ],
  linux: [
    {
      label: 'Download (x64)',
      r2Key: 'v1.4.9/ToriiSRS-linuxX64.zip',
      wpPath: '2025/11/ToriiSRS-linuxX64.zip',
      bytes: 51_323_920,
    },
  ],
} satisfies Record<string, Binary[]>;

export const LEGACY_VERSION = '1.4.8';

export const legacy: Binary[] = [
  {
    label: 'Windows',
    r2Key: 'v1.4.8/Torii-SRS-v1.4.8_win.zip',
    wpPath: '2020/05/Torii-SRS-v1.4.8_win.zip',
    bytes: 17_529_145,
  },
  {
    label: 'macOS',
    r2Key: 'v1.4.8/Torii-SRS-v1.4.8.dmg',
    wpPath: '2020/05/Torii-SRS-v1.4.8.dmg',
    bytes: 19_083_713,
  },
  {
    label: 'Linux',
    r2Key: 'v1.4.8/Torii-SRS-v1.4.8_linux.zip',
    wpPath: '2020/05/Torii-SRS-v1.4.8_linux.zip',
    bytes: 17_495_846,
  },
];

export const PLAY_STORE_URL =
  'https://play.google.com/store/apps/details?id=com.torii.srs';

export const JRE_DOWNLOAD_URL = 'https://java.com/download';
