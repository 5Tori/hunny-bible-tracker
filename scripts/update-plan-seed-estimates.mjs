#!/usr/bin/env node
/**
 * Recompute plan_templates.estimated_minutes in seed SQL from bible_chapters.json.
 *
 * Usage:
 *   node scripts/update-plan-seed-estimates.mjs          # dry-run summary
 *   node scripts/update-plan-seed-estimates.mjs --write  # update seed SQL files
 */

import { readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const CHAPTERS_PATH = join(ROOT, 'apps/mobile/assets/data/bible_chapters.json');
const MIGRATIONS_DIR = join(ROOT, 'supabase/migrations');
const SEED_GLOB = '202605281100';

const chapterIndex = new Map();

function loadChapterIndex() {
  const rows = JSON.parse(readFileSync(CHAPTERS_PATH, 'utf8'));
  for (const row of rows) {
    chapterIndex.set(`${row.book_key}:${row.chapter_number}`, row);
  }
}

function sumReadingMinutesForRange(bookKey, startChapter, endChapter) {
  const start = Math.min(startChapter, endChapter);
  const end = Math.max(startChapter, endChapter);
  let total = 0;
  for (let chapter = start; chapter <= end; chapter += 1) {
    total +=
      chapterIndex.get(`${bookKey}:${chapter}`)?.estimated_reading_minutes ?? 0;
  }
  return total;
}

function averageReadingMinutesForPlanItems(items) {
  let totalMinutes = 0;
  let chapterCount = 0;
  for (const item of items) {
    const start = Math.min(item.start_chapter, item.end_chapter);
    const end = Math.max(item.start_chapter, item.end_chapter);
    chapterCount += end - start + 1;
    totalMinutes += sumReadingMinutesForRange(item.book_key, start, end);
  }
  if (chapterCount <= 0) return 0;
  return Math.round(totalMinutes / chapterCount);
}

function parseSeedFile(sql) {
  const templateKeyMatch = sql.match(
    /insert into public\.plan_templates[\s\S]*?\)\s*values\s*\([\s\S]*?'[^']+',\s*\n\s*'([a-z0-9_]+)',/i,
  );
  if (!templateKeyMatch) {
    throw new Error('Could not parse template_key');
  }

  const items = [];
  const itemRegex =
    /'([a-z0-9_]+)',\s*(\d+),\s*(\d+),\s*now\(\)/g;
  let match;
  while ((match = itemRegex.exec(sql)) !== null) {
    items.push({
      book_key: match[1],
      start_chapter: Number(match[2]),
      end_chapter: Number(match[3]),
    });
  }

  if (items.length === 0) {
    throw new Error('No plan_template_items found');
  }

  const currentMinutesMatch = sql.match(
    /,\s*'(easy|medium|hard)',\s*\n\s*(\d+),\s*\n\s*(\d+),\s*\n\s*(\d+),/,
  );
  const currentMinutes = currentMinutesMatch
    ? Number(currentMinutesMatch[2])
    : null;

  return {
    templateKey: templateKeyMatch[1],
    items,
    currentMinutes,
  };
}

function replaceEstimatedMinutes(sql, newMinutes) {
  const replaced = sql.replace(
    /(,\s*'(easy|medium|hard)',\s*\n\s*)\d+(\s*,\s*\n\s*\d+,\s*\n\s*\d+,)/,
    `$1${newMinutes}$3`,
  );
  if (replaced === sql) {
    throw new Error('Could not replace estimated_minutes in SQL');
  }
  return replaced;
}

function main() {
  const write = process.argv.includes('--write');
  loadChapterIndex();

  const seedFiles = readdirSync(MIGRATIONS_DIR)
    .filter((name) => name.startsWith(SEED_GLOB) && name.endsWith('.sql'))
    .sort();

  if (seedFiles.length === 0) {
    throw new Error(`No seed files matching ${SEED_GLOB}*.sql`);
  }

  console.log('template_key'.padEnd(28), 'current', '→', 'computed');
  console.log('-'.repeat(50));

  for (const fileName of seedFiles) {
    const filePath = join(MIGRATIONS_DIR, fileName);
    const sql = readFileSync(filePath, 'utf8');
    const parsed = parseSeedFile(sql);
    const computed = averageReadingMinutesForPlanItems(parsed.items);

    console.log(
      parsed.templateKey.padEnd(28),
      String(parsed.currentMinutes ?? '?').padStart(3),
      '→',
      String(computed).padStart(3),
    );

    if (write && parsed.currentMinutes !== computed) {
      const updated = replaceEstimatedMinutes(sql, computed);
      writeFileSync(filePath, updated);
      console.log(`  updated ${fileName}`);
    }
  }

  if (!write) {
    console.log('\nDry run. Pass --write to update seed SQL files.');
  }
}

main();
