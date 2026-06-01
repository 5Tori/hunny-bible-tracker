#!/usr/bin/env node

/**
 * Step 3 infra gate — Hyperdrive/Worker health + static asset smoke.
 *
 * Usage:
 *   HUNNY_API_BASE_URL=https://hunnybibletracker.com node scripts/verify-infra.mjs
 */

const baseUrl = (process.env.HUNNY_API_BASE_URL ?? 'https://hunnybibletracker.com').replace(
  /\/$/,
  '',
);

const staticPaths = [
  '/brand/hunny-mark.png',
  '/plans/covers/bible.webp',
  '/plans/covers/ot.webp',
  '/plans/covers/nt.webp',
];

async function fetchJson(path, timeoutMs = 25000) {
  const url = `${baseUrl}${path}`;
  const started = performance.now();
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(url, {
      signal: controller.signal,
      headers: { Accept: 'application/json' },
    });
    const text = await response.text();
    let body = null;
    try {
      body = JSON.parse(text);
    } catch {
      body = text.slice(0, 120);
    }
    return {
      path,
      status: response.status,
      ms: Math.round(performance.now() - started),
      body,
    };
  } finally {
    clearTimeout(timer);
  }
}

async function fetchHead(path) {
  const url = `${baseUrl}${path}`;
  const started = performance.now();
  const response = await fetch(url, { method: 'HEAD' });
  return {
    path,
    status: response.status,
    ms: Math.round(performance.now() - started),
  };
}

async function main() {
  console.log(`Infra verify: ${baseUrl}\n`);

  let healthDbOk = 0;
  for (let i = 1; i <= 3; i++) {
    try {
      const result = await fetchJson('/api/health?db=1');
      const ok = result.status === 200 && result.body?.ok === true && result.body?.db === true;
      if (ok) healthDbOk += 1;
      console.log(
        `GET /api/health?db=1 #${i} -> ${result.status} ${result.ms}ms db=${result.body?.db ?? '?'}`,
      );
    } catch (error) {
      console.log(`GET /api/health?db=1 #${i} -> failed ${error.message}`);
    }
  }

  const bootstrap = await fetch(`${baseUrl}/api/v1/sync/bootstrap`, {
    headers: { Accept: 'application/json' },
  }).catch(() => null);
  console.log(
    `\nGET /api/v1/sync/bootstrap -> ${bootstrap?.status ?? 'failed'} (401 = route alive)`,
  );

  console.log('\nStatic assets:');
  for (const path of staticPaths) {
    const result = await fetchHead(path);
    console.log(`HEAD ${path} -> ${result.status} ${result.ms}ms`);
  }

  console.log('\nSecrets (local wrangler): run `pnpm exec wrangler secret list`');
  console.log('Expected: SUPABASE_SERVICE_ROLE_KEY, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET');

  const passed = healthDbOk === 3;
  console.log(`\nStep 3 health gate: ${passed ? 'PASS' : 'FAIL'} (${healthDbOk}/3 db:true)`);
  if (!passed) {
    process.exit(1);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
