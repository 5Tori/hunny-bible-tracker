import rawBooks from '../../../mobile/assets/data/bible_books.en.json';

export type BibleBookRow = (typeof rawBooks)[number];

export const BIBLE_BOOKS: readonly BibleBookRow[] = rawBooks;

const BOOK_KEY_SET = new Set(BIBLE_BOOKS.map((b) => b.book_key));

const BOOK_BY_KEY = new Map(BIBLE_BOOKS.map((b) => [b.book_key, b] as const));

function normalizeBookKeyLookup(bookKey: string) {
  return bookKey.trim().toLowerCase().replace(/\s+/g, '_');
}

export function getBibleBookByKey(bookKey: string): BibleBookRow | undefined {
  return BOOK_BY_KEY.get(normalizeBookKeyLookup(bookKey));
}

export function getChapterCountForBookKey(bookKey: string): number | null {
  const row = getBibleBookByKey(bookKey);
  return row ? row.chapter_count : null;
}

/** When the book is known, clamps chapters to `[1, chapter_count]` with `end >= start`. Otherwise returns the item unchanged. */
export function clampPlanItemChapters(item: {
  book_key: string;
  start_chapter: number;
  end_chapter: number;
}): { book_key: string; start_chapter: number; end_chapter: number } {
  const max = getChapterCountForBookKey(item.book_key);
  if (!max) return item;
  const s = Math.max(1, Math.min(Math.floor(Number(item.start_chapter)) || 1, max));
  const e = Math.max(s, Math.min(Math.floor(Number(item.end_chapter)) || s, max));
  return { ...item, start_chapter: s, end_chapter: e };
}

export function isKnownBookKey(bookKey: string): boolean {
  return BOOK_KEY_SET.has(normalizeBookKeyLookup(bookKey));
}

export function formatBookKeyLabel(bookKey: string): string {
  const row = BOOK_BY_KEY.get(normalizeBookKeyLookup(bookKey));
  return row ? `${row.display_name_en} (${row.book_key})` : bookKey;
}

function normalizeKeyFragment(s: string) {
  return s.trim().toLowerCase().replace(/\s+/g, '_');
}

export function filterBibleBooks(searchRaw: string): BibleBookRow[] {
  const q = searchRaw.trim().toLowerCase();
  if (!q) return [...BIBLE_BOOKS];
  const qn = normalizeKeyFragment(searchRaw);
  return BIBLE_BOOKS.filter(
    (b) =>
      b.book_key.includes(qn) ||
      b.display_name_en.toLowerCase().includes(q) ||
      b.short_name.toLowerCase().includes(q),
  );
}

/**
 * Resolves typed or pasted text to a canonical `book_key`, or returns `fallbackKey` when ambiguous / invalid.
 */
export function resolveBookKeyInput(raw: string, fallbackKey: string, allowEmpty: boolean): string {
  const t = raw.trim();
  if (!t) return allowEmpty ? '' : fallbackKey;

  const paren = /\(([a-z0-9_]+)\)\s*$/i.exec(t);
  if (paren) {
    const fromParen = paren[1].toLowerCase();
    if (BOOK_KEY_SET.has(fromParen)) return fromParen;
  }

  const n = normalizeKeyFragment(t);
  if (BOOK_KEY_SET.has(n)) return n;

  const exactDisplay = BIBLE_BOOKS.find((b) => b.display_name_en.toLowerCase() === t.toLowerCase());
  if (exactDisplay) return exactDisplay.book_key;

  const exactShort = BIBLE_BOOKS.find((b) => b.short_name.toLowerCase() === t.toLowerCase());
  if (exactShort) return exactShort.book_key;

  const matches = filterBibleBooks(t);
  if (matches.length === 1) return matches[0].book_key;

  return fallbackKey;
}
