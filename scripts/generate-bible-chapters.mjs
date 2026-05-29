#!/usr/bin/env node
/**
 * Generate apps/mobile/assets/data/bible_chapters.json from Protestant KJV structure.
 *
 * Source: thiagobodruk/bible en_kjv.json (chapter verse counts; order matches bible_books.en.json).
 * Reading time: verse_count * 7 seconds, minutes = max(1, ceil(seconds / 60)).
 */

import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
const BOOKS_PATH = join(ROOT, 'apps/mobile/assets/data/bible_books.en.json');
const OUT_PATH = join(ROOT, 'apps/mobile/assets/data/bible_chapters.json');
const CACHE_PATH = join(__dirname, 'data/en_kjv.json');
const KJV_URL =
  'https://raw.githubusercontent.com/thiagobodruk/bible/master/json/en_kjv.json';

const SECONDS_PER_VERSE = 7;
const EXPECTED_CHAPTER_TOTAL = 1189;

function readingSeconds(verseCount) {
  return verseCount * SECONDS_PER_VERSE;
}

function readingMinutes(verseCount) {
  const seconds = readingSeconds(verseCount);
  return Math.max(1, Math.ceil(seconds / 60));
}

async function loadKjv() {
  try {
    return JSON.parse(readFileSync(CACHE_PATH, 'utf8'));
  } catch {
    console.log(`Downloading KJV structure from ${KJV_URL} ...`);
    const response = await fetch(KJV_URL);
    if (!response.ok) {
      throw new Error(`Failed to download KJV JSON: ${response.status}`);
    }
    const text = await response.text();
    mkdirSync(dirname(CACHE_PATH), { recursive: true });
    writeFileSync(CACHE_PATH, text);
    return JSON.parse(text);
  }
}

async function main() {
  const books = JSON.parse(readFileSync(BOOKS_PATH, 'utf8'));
  if (!Array.isArray(books) || books.length !== 66) {
    throw new Error('bible_books.en.json must contain exactly 66 books');
  }

  const kjv = await loadKjv();
  if (!Array.isArray(kjv) || kjv.length !== 66) {
    throw new Error('KJV source must contain exactly 66 books');
  }

  const rows = [];

  for (let i = 0; i < books.length; i += 1) {
    const book = books[i];
    const kjvBook = kjv[i];
    const chapterCount = book.chapter_count;
    const kjvChapters = kjvBook.chapters ?? [];

    if (kjvChapters.length !== chapterCount) {
      throw new Error(
        `Chapter count mismatch for ${book.book_key}: books=${chapterCount}, kjv=${kjvChapters.length}`,
      );
    }

    for (let chapterIndex = 0; chapterIndex < chapterCount; chapterIndex += 1) {
      const chapterNumber = chapterIndex + 1;
      const verses = kjvChapters[chapterIndex];
      if (!Array.isArray(verses) || verses.length === 0) {
        throw new Error(
          `Missing verses for ${book.book_key} chapter ${chapterNumber}`,
        );
      }

      const verseCount = verses.length;
      rows.push({
        book_key: book.book_key,
        chapter_number: chapterNumber,
        verse_count: verseCount,
        estimated_reading_seconds: readingSeconds(verseCount),
        estimated_reading_minutes: readingMinutes(verseCount),
      });
    }
  }

  if (rows.length !== EXPECTED_CHAPTER_TOTAL) {
    throw new Error(`Expected ${EXPECTED_CHAPTER_TOTAL} chapters, got ${rows.length}`);
  }

  const byBook = new Map();
  for (const row of rows) {
    byBook.set(row.book_key, (byBook.get(row.book_key) ?? 0) + 1);
  }
  for (const book of books) {
    const count = byBook.get(book.book_key);
    if (count !== book.chapter_count) {
      throw new Error(
        `Row count mismatch for ${book.book_key}: expected ${book.chapter_count}, got ${count ?? 0}`,
      );
    }
  }

  writeFileSync(OUT_PATH, `${JSON.stringify(rows, null, 2)}\n`);
  console.log(`Wrote ${rows.length} chapters → ${OUT_PATH}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
