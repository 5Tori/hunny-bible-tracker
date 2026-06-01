import {
  getBibleBookByKey,
  getChapterCountForBookKey,
  resolveBookKeyInput,
} from '@/lib/bible-books';
import { getChapterEstimate } from '@/lib/bible-chapters';

export interface VerseReferenceParts {
  bookKey: string;
  chapter: number;
  startVerse: number;
  endVerse?: number;
}

function normalizeReferenceBookPart(raw: string) {
  const trimmed = raw.trim();
  if (!trimmed) return trimmed;
  if (/^psalm$/i.test(trimmed)) return 'Psalms';
  return trimmed;
}

export function referenceBookLabel(bookKey: string) {
  if (bookKey === 'psalms') return 'Psalm';
  return getBibleBookByKey(bookKey)?.display_name_en ?? bookKey;
}

export function getVerseCountForChapter(bookKey: string, chapterNumber: number): number | null {
  return getChapterEstimate(bookKey, chapterNumber)?.verse_count ?? null;
}

export function clampVerseReferenceParts(parts: VerseReferenceParts): VerseReferenceParts {
  const maxChapter = getChapterCountForBookKey(parts.bookKey);
  if (!maxChapter) return parts;

  const chapter = Math.max(1, Math.min(Math.floor(parts.chapter) || 1, maxChapter));
  const maxVerse = getVerseCountForChapter(parts.bookKey, chapter) ?? 1;
  const startVerse = Math.max(1, Math.min(Math.floor(parts.startVerse) || 1, maxVerse));
  let endVerse = parts.endVerse == null ? undefined : Math.floor(parts.endVerse);

  if (endVerse != null) {
    endVerse = Math.max(startVerse, Math.min(endVerse, maxVerse));
    if (endVerse === startVerse) endVerse = undefined;
  }

  return {
    bookKey: parts.bookKey,
    chapter,
    startVerse,
    endVerse,
  };
}

export function formatVerseReference(parts: VerseReferenceParts): string {
  const clamped = clampVerseReferenceParts(parts);
  const label = referenceBookLabel(clamped.bookKey);
  if (clamped.endVerse) {
    return `${label} ${clamped.chapter}:${clamped.startVerse}-${clamped.endVerse}`;
  }
  return `${label} ${clamped.chapter}:${clamped.startVerse}`;
}

export function parseVerseReference(raw: string): VerseReferenceParts | null {
  const trimmed = raw.trim();
  if (!trimmed) return null;

  const match = /^(.+?)\s+(\d+)\s*:\s*(\d+)(?:\s*-\s*(\d+))?\s*$/.exec(trimmed);
  if (!match) return null;

  const bookPart = normalizeReferenceBookPart(match[1]);
  const bookKey = resolveBookKeyInput(bookPart, '', true);
  if (!bookKey) return null;

  const chapter = Number(match[2]);
  const startVerse = Number(match[3]);
  const endVerse = match[4] ? Number(match[4]) : undefined;
  if (!Number.isFinite(chapter) || !Number.isFinite(startVerse)) return null;
  if (endVerse != null && !Number.isFinite(endVerse)) return null;

  const clamped = clampVerseReferenceParts({
    bookKey,
    chapter,
    startVerse,
    endVerse,
  });

  const maxChapter = getChapterCountForBookKey(clamped.bookKey);
  const maxVerse = getVerseCountForChapter(clamped.bookKey, clamped.chapter);
  if (!maxChapter || !maxVerse) return null;
  if (chapter < 1 || chapter > maxChapter) return null;
  if (startVerse < 1 || startVerse > maxVerse) return null;
  if (endVerse != null && (endVerse < startVerse || endVerse > maxVerse)) return null;

  return clamped;
}

const VERSE_REFERENCE_FORMAT_HINT =
  'Use Book Chapter:Verse or Book Chapter:Verse-Verse within the same chapter (e.g. Philippians 4:6-7).';

export function getVerseReferenceValidationError(raw?: string | null): string | null {
  const trimmed = raw?.trim();
  if (!trimmed) return 'Verse reference is required.';
  if (!parseVerseReference(trimmed)) return VERSE_REFERENCE_FORMAT_HINT;
  return null;
}

export function normalizeVerseReferenceString(raw?: string | null): string | null {
  const trimmed = raw?.trim();
  if (!trimmed) return null;
  const parsed = parseVerseReference(trimmed);
  return parsed ? formatVerseReference(parsed) : null;
}
