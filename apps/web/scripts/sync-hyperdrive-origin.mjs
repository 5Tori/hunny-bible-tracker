#!/usr/bin/env node

/**
 * Sync Hyperdrive origin password with apps/web/.env.local DATABASE_URL.
 *
 * Usage:
 *   node scripts/sync-hyperdrive-origin.mjs
 *   node scripts/sync-hyperdrive-origin.mjs --apply
 */

import fs from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.resolve(__dirname, '../.env.local');
const hyperdriveId = '403144eafd1b46f7b38e60472478fb34';

function loadEnv(file) {
  if (!fs.existsSync(file)) {
    console.error(`Missing ${file}`);
    process.exit(1);
  }
  for (const line of fs.readFileSync(file, 'utf8').split('\n')) {
    const match = line.match(/^([A-Z0-9_]+)="(.*)"\s*$/);
    if (match) process.env[match[1]] = match[2];
  }
}

function normalizePoolerUrl(url) {
  if (!url.includes(':6543/') || url.includes('pgbouncer=true')) return url;
  return `${url}${url.includes('?') ? '&' : '?'}pgbouncer=true`;
}

loadEnv(envPath);

const rawUrl = process.env.DATABASE_URL?.trim();
if (!rawUrl) {
  console.error('DATABASE_URL is not set in .env.local');
  process.exit(1);
}

const connectionString = normalizePoolerUrl(rawUrl).replace(':6543/', ':5432/').replace(/[?&]pgbouncer=true/g, '');
const apply = process.argv.includes('--apply');

console.log(`Hyperdrive config: ${hyperdriveId}`);
console.log(`Origin host: ${new URL(connectionString.replace(/^postgresql:/, 'http:')).hostname}`);

if (!apply) {
  console.log('\nDry run. Re-run with --apply to update Cloudflare Hyperdrive.');
  console.log(
    `\npnpm exec wrangler hyperdrive update ${hyperdriveId} --connection-string="<DATABASE_URL with pgbouncer=true>"`,
  );
  process.exit(0);
}

const result = spawnSync(
  'pnpm',
  ['exec', 'wrangler', 'hyperdrive', 'update', hyperdriveId, '--connection-string', connectionString, '--sslmode', 'require'],
  { cwd: path.resolve(__dirname, '..'), stdio: 'inherit' },
);

process.exit(result.status ?? 1);
