/**
 * Single source of truth for every downloadable binary.
 *
 * The installers are served from a Cloudflare R2 bucket behind dl.torii-srs.com,
 * not from this site. See R2-UPLOAD.md for publishing a new release.
 */

/** Public base for the R2 bucket. No trailing slash. */
export const R2_BASE = 'https://dl.torii-srs.com';

export interface Binary {
  /** Button label. */
  label: string;
  /** Path within the R2 bucket. */
  key: string;
  /** Size in bytes, used for the "(49.6 MB)" hint next to each button. */
  bytes: number;
}

export const url = (b: Binary): string => `${R2_BASE}/${b.key}`;

/** Human-readable size, e.g. "49.6 MB". */
export const size = (b: Binary): string => `${(b.bytes / 1_000_000).toFixed(1)} MB`;

export const LATEST_VERSION = '1.4.9';
export const LATEST_RELEASED = 'November 20, 2025';

export const latest = {
  windows: [
    {
      label: 'Download (x64)',
      key: 'v1.4.9/ToriiSRS-winX64.zip',
      bytes: 49_596_454,
    },
  ],
  macos: [
    {
      label: 'Download (Apple Silicon)',
      key: 'v1.4.9/ToriiSRS-1.4.9-macM1.dmg',
      bytes: 51_530_296,
    },
    {
      label: 'Download (Intel)',
      key: 'v1.4.9/ToriiSRS-1.4.9-macX64.dmg',
      bytes: 52_801_544,
    },
  ],
  linux: [
    {
      label: 'Download (x64)',
      key: 'v1.4.9/ToriiSRS-linuxX64.zip',
      bytes: 51_323_920,
    },
  ],
} satisfies Record<string, Binary[]>;

export const LEGACY_VERSION = '1.4.8';

export const legacy: Binary[] = [
  {
    label: 'Windows',
    key: 'v1.4.8/Torii-SRS-v1.4.8_win.zip',
    bytes: 17_529_145,
  },
  {
    label: 'macOS',
    key: 'v1.4.8/Torii-SRS-v1.4.8.dmg',
    bytes: 19_083_713,
  },
  {
    label: 'Linux',
    key: 'v1.4.8/Torii-SRS-v1.4.8_linux.zip',
    bytes: 17_495_846,
  },
];

export const PLAY_STORE_URL =
  'https://play.google.com/store/apps/details?id=com.torii.srs';

export const JRE_DOWNLOAD_URL = 'https://java.com/download';
