#!/usr/bin/env node

const baseUrl = (process.env.HUNNY_API_BASE_URL ?? 'http://127.0.0.1:3000').replace(/\/$/, '');

const endpoints = [
  { method: 'GET', path: '/api/health' },
  { method: 'GET', path: '/api/v1/plans?sort=featured&detail=full' },
  { method: 'GET', path: '/api/v1/plans?sort=featured&detail=summary' },
  { method: 'GET', path: '/api/v1/content?sort=featured&detail=summary' },
  { method: 'GET', path: '/api/v1/content?sort=featured&language=en' },
  { method: 'GET', path: '/api/v1/today-message?language=en' },
];

async function measureEndpoint({ method, path }) {
  const url = `${baseUrl}${path}`;
  const started = performance.now();
  const response = await fetch(url, { method, headers: { Accept: 'application/json' } });
  const body = await response.text();
  const totalMs = performance.now() - started;

  return {
    method,
    path,
    status: response.status,
    totalMs: Math.round(totalMs),
    responseBytes: Buffer.byteLength(body, 'utf8'),
  };
}

async function main() {
  console.log(`Benchmarking ${baseUrl}`);
  console.log('Set API_PERF_LOG=1 in apps/web/.env.local to see server-side db_ms logs.\n');

  for (const endpoint of endpoints) {
    try {
      const result = await measureEndpoint(endpoint);
      console.log(
        `${result.method} ${result.path} -> ${result.status} ${result.totalMs}ms ${result.responseBytes}B`,
      );
    } catch (error) {
      console.error(`${endpoint.method} ${endpoint.path} -> failed`, error.message);
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
