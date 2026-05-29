import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/** Minimal JSONC parse for wrangler.jsonc (strip full-line // comments, trailing commas). */
export function parseWranglerJsonc(relativePath = '../wrangler.jsonc') {
  const filePath = path.resolve(__dirname, relativePath);
  const withoutComments = fs
    .readFileSync(filePath, 'utf8')
    .replace(/^\s*\/\/[^\n]*\n/gm, '')
    .replace(/,\s*([\]}])/g, '$1');
  return JSON.parse(withoutComments);
}

export function getWranglerPublicEnv(relativePath = '../wrangler.jsonc') {
  const config = parseWranglerJsonc(relativePath);
  const vars = config.vars ?? {};
  return Object.fromEntries(
    Object.entries(vars).filter(([key]) => key.startsWith('NEXT_PUBLIC_')),
  );
}
