#!/usr/bin/env node
/**
 * Start Next dev with sensible offline/online defaults.
 *
 * - `pnpm dev` — online when apps/web/.env.local has DATABASE_URL + Supabase keys
 * - `pnpm dev --offline` — force mock fixtures
 * - `pnpm dev --online` — force live database
 */
import fs from 'node:fs';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const appRoot = path.resolve(__dirname, '..');
const envPath = path.join(appRoot, '.env.local');

function parseEnvValue(raw) {
  const trimmed = raw.trim();
  if (
    (trimmed.startsWith('"') && trimmed.endsWith('"')) ||
    (trimmed.startsWith("'") && trimmed.endsWith("'"))
  ) {
    return trimmed.slice(1, -1);
  }
  return trimmed;
}

function loadEnvFile(file) {
  if (!fs.existsSync(file)) return {};
  const env = {};
  for (const line of fs.readFileSync(file, 'utf8').split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const match = trimmed.match(/^([A-Z0-9_]+)=(.*)$/);
    if (!match) continue;
    env[match[1]] = parseEnvValue(match[2]);
  }
  return env;
}

function truthyFlag(value) {
  const flag = value?.trim().toLowerCase();
  return flag === '1' || flag === 'true' || flag === 'yes';
}

function falsyFlag(value) {
  const flag = value?.trim().toLowerCase();
  return flag === '0' || flag === 'false' || flag === 'no';
}

function hasOnlineDevCredentials(env) {
  return Boolean(
    env.DATABASE_URL?.trim() &&
      env.SUPABASE_SERVICE_ROLE_KEY?.trim() &&
      env.NEXT_PUBLIC_SUPABASE_URL?.trim() &&
      env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.trim(),
  );
}

function resolveOfflineMode(fileEnv) {
  if (process.argv.includes('--offline')) return true;
  if (process.argv.includes('--online')) return false;

  const explicit = fileEnv.HUNNY_OFFLINE_MODE ?? process.env.HUNNY_OFFLINE_MODE;
  if (truthyFlag(explicit)) return true;
  if (falsyFlag(explicit)) return false;

  return !hasOnlineDevCredentials({ ...process.env, ...fileEnv });
}

const fileEnv = loadEnvFile(envPath);
const offlineMode = resolveOfflineMode(fileEnv);
const modeFlag = offlineMode ? '1' : '0';

console.log(
  offlineMode
    ? 'Local dev: offline mock mode (HUNNY_OFFLINE_MODE=1)'
    : 'Local dev: live Supabase/Postgres (HUNNY_OFFLINE_MODE=0)',
);

const child = spawn('pnpm', ['exec', 'next', 'dev'], {
  cwd: appRoot,
  stdio: 'inherit',
  env: {
    ...process.env,
    ...fileEnv,
    HUNNY_OFFLINE_MODE: modeFlag,
    NEXT_PUBLIC_HUNNY_OFFLINE_MODE: modeFlag,
  },
});

child.on('exit', (code) => {
  process.exit(code ?? 0);
});
