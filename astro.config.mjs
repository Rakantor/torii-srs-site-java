// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://torii-srs.com',

  // Same URL shape as the WordPress site: every page with a trailing slash.
  trailingSlash: 'always',
  build: { format: 'directory' },

  // Astro 7 defaults this to 'jsx', which strips the whitespace around inline
  // elements and fuses words in the copy.
  compressHTML: false,

  integrations: [sitemap()],

  vite: {
    plugins: [tailwindcss()],
  },
});
