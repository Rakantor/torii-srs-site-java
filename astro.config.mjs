// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://torii-srs.com',

  // The WordPress site served every page with a trailing slash. Keeping that exact
  // shape means old links and search results keep resolving after the migration.
  trailingSlash: 'always',
  build: { format: 'directory' },

  // Astro 7 defaults compressHTML to 'jsx', which drops the whitespace around inline
  // elements. This site's copy is full of <strong>/<em>/<a> mid-sentence, so that
  // default silently fuses words together. Off.
  compressHTML: false,

  integrations: [sitemap()],

  vite: {
    plugins: [tailwindcss()],
  },
});
