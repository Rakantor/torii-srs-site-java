import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const releases = defineCollection({
  loader: glob({ pattern: '*.md', base: './src/content/releases' }),
  schema: z.object({
    /** e.g. "1.4.9" */
    version: z.string(),
    /** Release date, used for sorting newest-first. */
    date: z.date(),
    /** Pre-formatted display date, e.g. "November 20, 2025". */
    released: z.string(),
  }),
});

export const collections = { releases };
