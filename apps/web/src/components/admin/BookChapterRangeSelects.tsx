'use client';

import { useEffect } from 'react';

import { clampPlanItemChapters, getChapterCountForBookKey } from '@/lib/bible-books';

function chapterOptionValues(max: number): number[] {
  return Array.from({ length: max }, (_, index) => index + 1);
}

export interface BookChapterRangeSelectsProps {
  bookKey: string;
  startChapter: number;
  endChapter: number;
  onChange: (next: { start_chapter: number; end_chapter: number }) => void;
  startId?: string;
  endId?: string;
}

export function BookChapterRangeSelects({
  bookKey,
  startChapter,
  endChapter,
  onChange,
  startId,
  endId,
}: BookChapterRangeSelectsProps) {
  const max = getChapterCountForBookKey(bookKey);
  const disabled = !bookKey.trim() || max == null;

  const clamped = clampPlanItemChapters({
    book_key: bookKey,
    start_chapter: startChapter,
    end_chapter: endChapter,
  });
  const start = clamped.start_chapter;
  const end = clamped.end_chapter;

  useEffect(() => {
    if (disabled) return;
    if (start !== startChapter || end !== endChapter) {
      onChange({ start_chapter: start, end_chapter: end });
    }
  }, [disabled, start, end, startChapter, endChapter, onChange]);

  if (disabled) {
    return (
      <div className="admin-field admin-form-grid-2">
        <div>
          <label htmlFor={startId}>Start chapter</label>
          <select id={startId} className="chapter-range-select" disabled value="">
            <option value="">Select a book first</option>
          </select>
        </div>
        <div>
          <label htmlFor={endId}>End chapter</label>
          <select id={endId} className="chapter-range-select" disabled value="">
            <option value="">Select a book first</option>
          </select>
        </div>
      </div>
    );
  }

  const startOptions = chapterOptionValues(max);
  const endOptions = chapterOptionValues(max).filter((chapter) => chapter >= start);

  return (
    <div className="admin-field admin-form-grid-2">
      <div>
        <label htmlFor={startId}>Start chapter</label>
        <select
          id={startId}
          className="chapter-range-select"
          value={start}
          onChange={(event) => {
            const nextStart = Number(event.target.value);
            const nextEnd = Math.max(nextStart, end);
            onChange({
              start_chapter: nextStart,
              end_chapter: Math.min(nextEnd, max),
            });
          }}
        >
          {startOptions.map((chapter) => (
            <option key={chapter} value={chapter}>
              {chapter}
            </option>
          ))}
        </select>
        <p className="muted chapter-range-hint">1–{max} for this book</p>
      </div>
      <div>
        <label htmlFor={endId}>End chapter</label>
        <select
          id={endId}
          className="chapter-range-select"
          value={end}
          onChange={(event) => {
            const nextEnd = Number(event.target.value);
            onChange({ start_chapter: start, end_chapter: nextEnd });
          }}
        >
          {endOptions.map((chapter) => (
            <option key={chapter} value={chapter}>
              {chapter}
            </option>
          ))}
        </select>
      </div>
    </div>
  );
}
