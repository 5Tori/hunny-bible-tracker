#!/usr/bin/env node
/**
 * Reconcile plan_templates.estimated_minutes in Postgres from plan_template_items
 * + apps/mobile/assets/data/bible_chapters.json (7 seconds per verse).
 *
 * Usage:
 *   DATABASE_URL=... node scripts/sync-plan-estimates-to-db.mjs           # dry-run
 *   DATABASE_URL=... node scripts/sync-plan-estimates-to-db.mjs --write   # apply
 *
 * Loads DATABASE_URL from apps/web/.env.local when unset.
 */

import { createRequire } from 'node:module';
import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  averageReadingMinutesForPlanItems,
  loadChapterIndex,
} from './lib/plan-estimate-math.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const require = createRequire(join(ROOT, 'apps/web/package.json'));
const postgres = require('postgres');
const ENV_LOCAL = join(ROOT, 'apps/web/.env.local');

function loadDatabaseUrl() {
  if (process.env.DATABASE_URL?.trim()) {
    return process.env.DATABASE_URL.trim();
  }
  if (!existsSync(ENV_LOCAL)) {
    throw new Error(
      'Set DATABASE_URL or create apps/web/.env.local with DATABASE_URL',
    );
  }
  for (const line of readFileSync(ENV_LOCAL, 'utf8').split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const match = trimmed.match(/^DATABASE_URL=(.+)$/);
    if (!match) continue;
    let value = match[1].trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    return value;
  }
  throw new Error('DATABASE_URL not found in apps/web/.env.local');
}

async function fetchPlansWithItems(sql) {
  const rows = await sql`
    select
      pt.id,
      pt.template_key,
      pt.title,
      pt.estimated_minutes as current_minutes,
      coalesce(
        json_agg(
          json_build_object(
            'book_key', pti.book_key,
            'start_chapter', pti.start_chapter,
            'end_chapter', pti.end_chapter
          )
          order by pts.order_index, pti.order_index
        ) filter (where pti.id is not null),
        '[]'::json
      ) as items
    from public.plan_templates pt
    left join public.plan_template_sections pts
      on pts.plan_template_id = pt.id
    left join public.plan_template_items pti
      on pti.section_id = pts.id
    group by pt.id, pt.template_key, pt.title, pt.estimated_minutes
    order by pt.template_key
  `;

  return rows.map((row) => ({
    id: row.id,
    templateKey: row.template_key,
    title: row.title,
    currentMinutes: row.current_minutes,
    items: row.items ?? [],
  }));
}

async function main() {
  const write = process.argv.includes('--write');
  const chapterIndex = loadChapterIndex();
  const databaseUrl = loadDatabaseUrl();
  const sql = postgres(databaseUrl, { max: 1 });

  try {
    const plans = await fetchPlansWithItems(sql);
    if (plans.length === 0) {
      console.log('No plan_templates rows found.');
      return;
    }

    console.log(
      'template_key'.padEnd(28),
      'title'.padEnd(24),
      'current',
      '→',
      'computed',
    );
    console.log('-'.repeat(72));

    const updates = [];
    for (const plan of plans) {
      const computed =
        plan.items.length === 0
          ? null
          : averageReadingMinutesForPlanItems(chapterIndex, plan.items);
      const currentLabel =
        plan.currentMinutes == null ? 'null' : String(plan.currentMinutes);
      const computedLabel = computed == null ? 'null' : String(computed);

      console.log(
        plan.templateKey.padEnd(28),
        plan.title.slice(0, 22).padEnd(24),
        currentLabel.padStart(3),
        '→',
        computedLabel.padStart(3),
      );

      if (
        computed != null &&
        computed > 0 &&
        plan.currentMinutes !== computed
      ) {
        updates.push({ ...plan, computedMinutes: computed });
      }
    }

    if (updates.length === 0) {
      console.log('\nAll plan estimated_minutes values already match bible_chapters.');
      return;
    }

    console.log(`\n${updates.length} plan(s) need updates.`);
    if (!write) {
      console.log('Dry run. Pass --write to UPDATE plan_templates.');
      return;
    }

    for (const plan of updates) {
      await sql`
        update public.plan_templates
        set estimated_minutes = ${plan.computedMinutes},
            updated_at = now()
        where id = ${plan.id}
      `;
      console.log(
        `  updated ${plan.templateKey}: ${plan.currentMinutes} → ${plan.computedMinutes}`,
      );
    }
  } finally {
    await sql.end({ timeout: 5 });
  }
}

main().catch((error) => {
  console.error(error.message ?? error);
  process.exit(1);
});
