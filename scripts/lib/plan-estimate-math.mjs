import { readFileSync } from 'node:fs';
import { join } from 'node:path';

export const CHAPTERS_PATH = join(
  process.cwd(),
  'apps/mobile/assets/data/bible_chapters.json',
);

export function loadChapterIndex(chaptersPath = CHAPTERS_PATH) {
  const rows = JSON.parse(readFileSync(chaptersPath, 'utf8'));
  const chapterIndex = new Map();
  for (const row of rows) {
    chapterIndex.set(`${row.book_key}:${row.chapter_number}`, row);
  }
  return chapterIndex;
}

export function sumReadingMinutesForRange(
  chapterIndex,
  bookKey,
  startChapter,
  endChapter,
) {
  const start = Math.min(startChapter, endChapter);
  const end = Math.max(startChapter, endChapter);
  let total = 0;
  for (let chapter = start; chapter <= end; chapter += 1) {
    total +=
      chapterIndex.get(`${bookKey}:${chapter}`)?.estimated_reading_minutes ?? 0;
  }
  return total;
}

export function averageReadingMinutesForPlanItems(chapterIndex, items) {
  let totalMinutes = 0;
  let chapterCount = 0;
  for (const item of items) {
    const start = Math.min(item.start_chapter, item.end_chapter);
    const end = Math.max(item.start_chapter, item.end_chapter);
    chapterCount += end - start + 1;
    totalMinutes += sumReadingMinutesForRange(
      chapterIndex,
      item.book_key,
      start,
      end,
    );
  }
  if (chapterCount <= 0) return 0;
  return Math.round(totalMinutes / chapterCount);
}
