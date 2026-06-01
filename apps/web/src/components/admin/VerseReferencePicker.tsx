'use client';

import { useEffect, useId, useMemo, useState } from 'react';

import { BookKeyCombobox } from '@/components/admin/BookKeyCombobox';
import { getChapterCountForBookKey } from '@/lib/bible-books';
import {
  clampVerseReferenceParts,
  formatVerseReference,
  getVerseCountForChapter,
  parseVerseReference,
  type VerseReferenceParts,
} from '@/lib/bible-verse-reference';

export interface VerseReferencePickerProps {
  idPrefix?: string;
  value: string;
  onChange: (reference: string) => void;
}

function chapterOptions(max: number) {
  return Array.from({ length: max }, (_, index) => index + 1);
}

function verseOptions(max: number, min = 1) {
  return Array.from({ length: max - min + 1 }, (_, index) => min + index);
}

export function VerseReferencePicker({ idPrefix, value, onChange }: VerseReferencePickerProps) {
  const generatedId = useId();
  const baseId = idPrefix ?? `verse-ref-${generatedId}`;

  const parsedValue = useMemo(() => parseVerseReference(value), [value]);
  const [parts, setParts] = useState<VerseReferenceParts | null>(() => parsedValue);
  const [useRange, setUseRange] = useState(Boolean(parsedValue?.endVerse));

  useEffect(() => {
    const parsed = parseVerseReference(value);
    if (parsed) {
      setParts(parsed);
      setUseRange(Boolean(parsed.endVerse));
      return;
    }
    if (!value.trim()) {
      setParts(null);
      setUseRange(false);
    }
  }, [value]);

  const bookKey = parts?.bookKey ?? '';
  const maxChapter = bookKey ? getChapterCountForBookKey(bookKey) : null;
  const chapter = parts?.chapter ?? 1;
  const maxVerse = bookKey ? getVerseCountForChapter(bookKey, chapter) : null;

  const updateParts = (next: VerseReferenceParts, rangeEnabled = useRange) => {
    const clamped = clampVerseReferenceParts({
      ...next,
      endVerse: rangeEnabled ? next.endVerse ?? next.startVerse : undefined,
    });
    setParts(clamped);
    onChange(formatVerseReference(clamped));
  };

  return (
    <div className="verse-reference-picker">
      <div className="admin-field">
        <label htmlFor={`${baseId}-book`}>Book</label>
        <BookKeyCombobox
          id={`${baseId}-book`}
          value={bookKey}
          onChange={(nextBookKey) => {
            if (!nextBookKey) {
              setParts(null);
              onChange('');
              return;
            }
            updateParts({
              bookKey: nextBookKey,
              chapter: 1,
              startVerse: 1,
              endVerse: useRange ? 1 : undefined,
            });
          }}
        />
      </div>

      <div className="admin-field admin-form-grid-2">
        <div>
          <label htmlFor={`${baseId}-chapter`}>Chapter</label>
          <select
            id={`${baseId}-chapter`}
            className="chapter-range-select"
            value={parts?.chapter ?? ''}
            disabled={!parts || !maxChapter}
            onChange={(event) => {
              if (!parts) return;
              const nextChapter = Number(event.target.value);
              const verseCount = getVerseCountForChapter(parts.bookKey, nextChapter) ?? 1;
              updateParts({
                ...parts,
                chapter: nextChapter,
                startVerse: Math.min(parts.startVerse, verseCount),
                endVerse: useRange
                  ? Math.min(parts.endVerse ?? parts.startVerse, verseCount)
                  : undefined,
              });
            }}
          >
            {!parts || !maxChapter ? (
              <option value="">Select a book first</option>
            ) : (
              chapterOptions(maxChapter).map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))
            )}
          </select>
        </div>
        <div>
          <label htmlFor={`${baseId}-verse`}>Start verse</label>
          <select
            id={`${baseId}-verse`}
            className="chapter-range-select"
            value={parts?.startVerse ?? ''}
            disabled={!parts || !maxVerse}
            onChange={(event) => {
              if (!parts) return;
              const startVerse = Number(event.target.value);
              updateParts({
                ...parts,
                startVerse,
                endVerse: useRange
                  ? Math.max(startVerse, parts.endVerse ?? startVerse)
                  : undefined,
              });
            }}
          >
            {!parts || !maxVerse ? (
              <option value="">—</option>
            ) : (
              verseOptions(maxVerse).map((verse) => (
                <option key={verse} value={verse}>
                  {verse}
                </option>
              ))
            )}
          </select>
        </div>
      </div>

      <div className="admin-checkbox-row">
        <input
          id={`${baseId}-range`}
          type="checkbox"
          checked={useRange}
          disabled={!parts}
          onChange={(event) => {
            if (!parts) return;
            const enabled = event.target.checked;
            setUseRange(enabled);
            updateParts(
              {
                ...parts,
                endVerse: enabled ? parts.endVerse ?? parts.startVerse : undefined,
              },
              enabled,
            );
          }}
        />
        <label htmlFor={`${baseId}-range`}>Include multiple verses (same chapter)</label>
      </div>

      {useRange && parts ? (
        <div className="admin-field">
          <label htmlFor={`${baseId}-end-verse`}>End verse</label>
          <select
            id={`${baseId}-end-verse`}
            className="chapter-range-select"
            value={parts.endVerse ?? parts.startVerse}
            disabled={!maxVerse}
            onChange={(event) => {
              updateParts({ ...parts, endVerse: Number(event.target.value) }, true);
            }}
          >
            {maxVerse
              ? verseOptions(maxVerse, parts.startVerse).map((verse) => (
                  <option key={verse} value={verse}>
                    {verse}
                  </option>
                ))
              : null}
          </select>
        </div>
      ) : null}

      <p className="admin-muted">
        Preview:{' '}
        <strong>{parts ? formatVerseReference(parts) : 'Select book, chapter, and verse'}</strong>
      </p>
      {useRange ? (
        <p className="admin-muted">Same-chapter ranges only (e.g. Philippians 4:6-7).</p>
      ) : null}
    </div>
  );
}
