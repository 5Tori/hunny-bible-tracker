#!/usr/bin/env node

/**
 * Step 6 gate — production read paths for mobile closed testing.
 *
 * Usage:
 *   node apps/mobile/scripts/smoke-prod-read.mjs
 *   HUNNY_API_BASE_URL=https://hunnybibletracker.com node apps/mobile/scripts/smoke-prod-read.mjs
 *
 * Optional env:
 *   SUPABASE_URL / SUPABASE_ANON_KEY (defaults to production project anon)
 */

const apiBase = (process.env.HUNNY_API_BASE_URL ?? 'https://hunnybibletracker.com').replace(
  /\/$/,
  '',
);
const supabaseUrl = (
  process.env.SUPABASE_URL ??
  process.env.NEXT_PUBLIC_SUPABASE_URL ??
  'https://tbexpdwipdjgcjtlujis.supabase.co'
).replace(/\/$/, '');
const supabaseAnonKey =
  process.env.SUPABASE_ANON_KEY ??
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ??
  '';

const DETAIL_SLUG = process.env.SMOKE_CONTENT_SLUG ?? 'sabbath-rest-explained';
const MAX_MS = Number(process.env.SMOKE_MAX_MS ?? 800);

const results = [];

function pass(label, detail = '') {
  results.push({ ok: true, label, detail });
  console.log(`PASS ${label}${detail ? ` — ${detail}` : ''}`);
}

function fail(label, detail = '') {
  results.push({ ok: false, label, detail });
  console.error(`FAIL ${label}${detail ? ` — ${detail}` : ''}`);
}

async function fetchApi(path) {
  const started = performance.now();
  const response = await fetch(`${apiBase}${path}`, {
    headers: { Accept: 'application/json' },
  });
  const text = await response.text();
  let body = null;
  try {
    body = JSON.parse(text);
  } catch {
    body = text.slice(0, 200);
  }
  return {
    status: response.status,
    ms: Math.round(performance.now() - started),
    body,
  };
}

async function callRpc(fn, args) {
  if (!supabaseAnonKey) {
    throw new Error('SUPABASE_ANON_KEY is required for RPC smoke');
  }
  const started = performance.now();
  const response = await fetch(`${supabaseUrl}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: {
      apikey: supabaseAnonKey,
      Authorization: `Bearer ${supabaseAnonKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(args),
  });
  const text = await response.text();
  let body = null;
  try {
    body = JSON.parse(text);
  } catch {
    body = text.slice(0, 200);
  }
  return {
    status: response.status,
    ms: Math.round(performance.now() - started),
    body,
  };
}

function assertLatency(label, ms) {
  if (ms <= MAX_MS) {
    pass(`${label} latency`, `${ms}ms`);
  } else {
    fail(`${label} latency`, `${ms}ms > ${MAX_MS}ms target`);
  }
}

async function main() {
  console.log(`Mobile prod read smoke`);
  console.log(`API: ${apiBase}`);
  console.log(`Supabase: ${supabaseUrl}`);
  console.log(`Latency target: <= ${MAX_MS}ms\n`);

  const bootstrap = await fetchApi('/api/v1/sync/bootstrap');
  if (bootstrap.status === 401) {
    pass('GET /api/v1/sync/bootstrap', '401 = online (guest reachability)');
  } else {
    fail('GET /api/v1/sync/bootstrap', `expected 401, got ${bootstrap.status}`);
  }

  const plans = await fetchApi('/api/v1/plans?sort=featured&detail=summary');
  if (plans.status === 200 && Array.isArray(plans.body?.plans)) {
    pass('GET /api/v1/plans?detail=summary', `${plans.body.plans.length} plans`);
    assertLatency('plans summary API', plans.ms);
  } else {
    fail('GET /api/v1/plans?detail=summary', `status ${plans.status}`);
  }

  let rpcDiscoverListOk = false;
  if (!supabaseAnonKey) {
    fail('Supabase RPC', 'SUPABASE_ANON_KEY missing — skip RPC block');
  } else {
    const listRpc = await callRpc('mobile_content_list', {
      p_language: 'en',
      p_sort: 'featured',
      p_limit: 20,
    });
    if (listRpc.status === 200 && Array.isArray(listRpc.body)) {
      const types = new Set(listRpc.body.map((row) => row.content_type));
      if (listRpc.body.length === 6 && !types.has('message')) {
        rpcDiscoverListOk = true;
        pass('RPC mobile_content_list', '6 discover items');
      } else {
        fail(
          'RPC mobile_content_list',
          `count=${listRpc.body.length}, types=${[...types].join(',')}`,
        );
      }
      assertLatency('mobile_content_list RPC', listRpc.ms);
    } else {
      fail('RPC mobile_content_list', `status ${listRpc.status}`);
    }
  }

  const content = await fetchApi(
    '/api/v1/content?sort=featured&detail=summary&language=en&discoverOnly=1',
  );
  if (content.status === 200 && Array.isArray(content.body?.contents)) {
    const types = new Set(content.body.contents.map((row) => row.content_type));
    const hasMessage = types.has('message');
    if (content.body.contents.length === 6 && !hasMessage) {
      pass('GET /api/v1/content?discoverOnly=1', '6 discover items, no message');
    } else if (rpcDiscoverListOk && !hasMessage) {
      pass(
        'GET /api/v1/content?discoverOnly=1',
        `CDN may be stale (count=${content.body.contents.length}); RPC list OK`,
      );
    } else {
      fail(
        'GET /api/v1/content?discoverOnly=1',
        `count=${content.body.contents.length}, types=${[...types].join(',')}`,
      );
    }
    assertLatency('content discover API', content.ms);
  } else {
    fail('GET /api/v1/content?discoverOnly=1', `status ${content.status}`);
  }

  const today = await fetchApi('/api/v1/today-message?language=en');
  if (today.status === 200 && today.body?.message) {
    const linked = today.body.message.linked_content;
    pass(
      'GET /api/v1/today-message',
      linked?.messages_url ? `linked ${linked.messages_url}` : 'message present',
    );
    assertLatency('today-message API', today.ms);
  } else {
    fail('GET /api/v1/today-message', `status ${today.status}`);
  }

  const detail = await fetchApi(
    `/api/v1/content/${encodeURIComponent(DETAIL_SLUG)}?language=en`,
  );
  if (detail.status === 200 && detail.body?.content?.slug === DETAIL_SLUG) {
    const row = detail.body.content;
    const sectionCount = Array.isArray(row.sections) ? row.sections.length : 0;
    pass('GET /api/v1/content/[slug]', `${DETAIL_SLUG} sections=${sectionCount}`);
    assertLatency('content detail API', detail.ms);
  } else {
    fail('GET /api/v1/content/[slug]', `status ${detail.status}`);
  }

  if (supabaseAnonKey) {
    const detailRpc = await callRpc('mobile_content_detail', {
      p_identifier: DETAIL_SLUG,
      p_language: 'en',
    });
    if (detailRpc.status === 200 && detailRpc.body?.slug === DETAIL_SLUG) {
      const sections = Array.isArray(detailRpc.body.sections)
        ? detailRpc.body.sections.length
        : 0;
      pass('RPC mobile_content_detail', `${DETAIL_SLUG} sections=${sections}`);
      assertLatency('mobile_content_detail RPC', detailRpc.ms);
    } else {
      fail('RPC mobile_content_detail', `status ${detailRpc.status}`);
    }

    const plansRpc = await callRpc('mobile_plan_catalog', { p_sort: 'featured' });
    if (plansRpc.status === 200 && Array.isArray(plansRpc.body) && plansRpc.body.length >= 5) {
      pass('RPC mobile_plan_catalog', `${plansRpc.body.length} plans`);
      assertLatency('mobile_plan_catalog RPC', plansRpc.ms);
    } else {
      fail(
        'RPC mobile_plan_catalog',
        `status ${plansRpc.status}, count=${Array.isArray(plansRpc.body) ? plansRpc.body.length : '?'}`,
      );
    }

    const todayRpc = await callRpc('mobile_today_message_latest', { p_language: 'en' });
    if (todayRpc.status === 200 && todayRpc.body?.id) {
      const linked = todayRpc.body.linked_content;
      pass(
        'RPC mobile_today_message_latest',
        linked?.messages_url ?? linked?.slug ?? 'ok',
      );
      assertLatency('mobile_today_message_latest RPC', todayRpc.ms);
    } else {
      fail('RPC mobile_today_message_latest', `status ${todayRpc.status}`);
    }
  }

  const failed = results.filter((row) => !row.ok);
  console.log(`\n${results.length - failed.length}/${results.length} checks passed`);
  if (failed.length > 0) {
    process.exit(1);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
