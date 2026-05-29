import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

import postgres from 'postgres';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.resolve(__dirname, '../.env.local');

function loadEnv(file) {
  if (!fs.existsSync(file)) {
    console.error(`Missing ${file}. Copy .env.example and fill DATABASE_URL.`);
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

const url = normalizePoolerUrl(rawUrl);
const parsed = new URL(url.replace(/^postgresql:/, 'http:'));

console.log(`Checking Postgres at ${parsed.hostname}:${parsed.port || 5432} …`);

const sql = postgres(url, {
  max: 1,
  prepare: false,
  connect_timeout: 15,
  ssl: 'require',
});

try {
  const rows = await sql`select 1 as ok`;
  console.log('Database connection OK.', rows[0]);
} catch (error) {
  const code = error.code || error.errno || error.message;
  console.error('Database connection failed:', code);
  console.error('');
  console.error('Fix steps:');
  console.error('1. Supabase Dashboard → Project Settings → Database → copy a fresh connection string.');
  console.error('2. Use Transaction pooler (port 6543) with ?pgbouncer=true for local next dev.');
  console.error('3. If CONNECT_TIMEOUT persists (VPN/firewall), switch to Direct connection (port 5432).');
  console.error('4. Confirm the database password matches Settings → Database → Reset database password if unsure.');
  console.error('5. Check Database → Network restrictions / IP allowlist is not blocking your IP.');
  process.exit(1);
} finally {
  await sql.end({ timeout: 2 }).catch(() => {});
}
