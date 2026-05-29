import rawChapters from '../../../mobile/assets/data/bible_chapters.json';

export type BibleChapterRow = (typeof rawChapters)[number];

export const BIBLE_CHAPTERS: readonly BibleChapterRow[] = rawChapters;

export const SECONDS_PER_VERSE = 7;

export function readingSecondsForVerseCount(verseCount: number): number {
  return verseCount * SECONDS_PER_VERSE;
}

export function readingMinutesForVerseCount(verseCount: number): number {
  const seconds = readingSecondsForVerseCount(verseCount);
  return Math.max(1, Math.ceil(seconds / 60));
}

const chapterIndex = new Map<string, BibleChapterRow>();
for (const row of BIBLE_CHAPTERS) {
  chapterIndex.set(`${row.book_key}:${row.chapter_number}`, row);
}

export function getChapterEstimate(
  bookKey: string,
  chapterNumber: number,
): BibleChapterRow | undefined {
  return chapterIndex.get(`${bookKey.trim().toLowerCase()}:${chapterNumber}`);
}

export function sumReadingMinutesForRange(
  bookKey: string,
  startChapter: number,
  endChapter: number,
): number {
  const start = Math.min(startChapter, endChapter);
  const end = Math.max(startChapter, endChapter);
  let total = 0;
  for (let chapter = start; chapter <= end; chapter += 1) {
    total += getChapterEstimate(bookKey, chapter)?.estimated_reading_minutes ?? 0;
  }
  return total;
}

export function averageReadingMinutesForRange(
  bookKey: string,
  startChapter: number,
  endChapter: number,
): number {
  const start = Math.min(startChapter, endChapter);
  const end = Math.max(startChapter, endChapter);
  const chapterCount = end - start + 1;
  if (chapterCount <= 0) return 0;
  return Math.round(sumReadingMinutesForRange(bookKey, start, end) / chapterCount);
}

export type PlanChapterItem = {
  book_key: string;
  start_chapter: number;
  end_chapter: number;
};

export function sumReadingMinutesForPlanItems(items: PlanChapterItem[]): number {
  return items.reduce((total, item) => {
    return total + sumReadingMinutesForRange(item.book_key, item.start_chapter, item.end_chapter);
  }, 0);
}

export function averageReadingMinutesForPlanItems(items: PlanChapterItem[]): number {
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
