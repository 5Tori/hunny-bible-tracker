import { spawnSync } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';

import { getWranglerPublicEnv } from './parse-wrangler-jsonc.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const webRoot = path.resolve(__dirname, '..');

for (const [key, value] of Object.entries(getWranglerPublicEnv())) {
  if (process.env[key]?.trim()) continue;
  process.env[key] = String(value);
}

const result = spawnSync('pnpm', ['exec', 'opennextjs-cloudflare', 'build'], {
  cwd: webRoot,
  stdio: 'inherit',
  env: process.env,
});

process.exit(result.status ?? 1);
