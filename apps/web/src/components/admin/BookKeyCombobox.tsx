'use client';

import { useCallback, useEffect, useId, useMemo, useRef, useState } from 'react';

import {
  filterBibleBooks,
  formatBookKeyLabel,
  getBibleBookByKey,
  resolveBookKeyInput,
  type BibleBookRow,
} from '@/lib/bible-books';

export interface BookKeyComboboxProps {
  id?: string;
  value: string;
  onChange: (bookKey: string) => void;
  /** When true, blur with empty input commits `''` and list shows a clear row. */
  allowEmpty?: boolean;
}

export function BookKeyCombobox({ id, value, onChange, allowEmpty }: BookKeyComboboxProps) {
  const generatedId = useId();
  const inputId = id ?? `book-key-${generatedId}`;
  const listboxId = `${inputId}-listbox`;

  const skipBlurCommitRef = useRef(false);

  const [open, setOpen] = useState(false);
  const [draft, setDraft] = useState(() => (value ? formatBookKeyLabel(value) : ''));
  const [highlight, setHighlight] = useState(0);

  const displayRows: BibleBookRow[] = useMemo(() => filterBibleBooks(draft), [draft]);

  useEffect(() => {
    if (!open) {
      setDraft(value ? formatBookKeyLabel(value) : '');
    }
  }, [value, open]);

  const closeAndCommit = useCallback(() => {
    const resolved = resolveBookKeyInput(draft, value, Boolean(allowEmpty));
    onChange(resolved);
    setOpen(false);
    setDraft(resolved ? formatBookKeyLabel(resolved) : '');
    setHighlight(0);
  }, [allowEmpty, draft, onChange, value]);

  const pick = useCallback(
    (key: string) => {
      skipBlurCommitRef.current = true;
      onChange(key);
      setOpen(false);
      setDraft(key ? formatBookKeyLabel(key) : '');
      setHighlight(0);
    },
    [onChange],
  );

  useEffect(() => {
    setHighlight((h) => {
      const max = Math.max(0, displayRows.length - 1 + (allowEmpty ? 1 : 0));
      return Math.min(h, max);
    });
  }, [displayRows.length, allowEmpty]);

  const onInputChange = (next: string) => {
    setDraft(next);
    setOpen(true);
    setHighlight(0);
    const known = getBibleBookByKey(next.trim());
    if (known && next.trim() === known.book_key) {
      onChange(known.book_key);
    }
  };

  const onKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (!open && (event.key === 'ArrowDown' || event.key === 'Enter')) {
      setOpen(true);
    }

    if (!open) return;

    const len = displayRows.length + (allowEmpty ? 1 : 0);
    if (len === 0) return;

    if (event.key === 'ArrowDown') {
      event.preventDefault();
      setHighlight((h) => (h + 1) % len);
    } else if (event.key === 'ArrowUp') {
      event.preventDefault();
      setHighlight((h) => (h - 1 + len) % len);
    } else if (event.key === 'Enter') {
      event.preventDefault();
      if (allowEmpty && highlight === 0) {
        pick('');
      } else {
        const book = allowEmpty ? displayRows[highlight - 1] : displayRows[highlight];
        if (book) pick(book.book_key);
      }
    } else if (event.key === 'Escape') {
      event.preventDefault();
      setOpen(false);
      setDraft(value ? formatBookKeyLabel(value) : '');
      setHighlight(0);
    }
  };

  return (
    <div className="book-key-combobox">
      <input
        id={inputId}
        type="text"
        role="combobox"
        aria-expanded={open}
        aria-controls={listboxId}
        aria-autocomplete="list"
        autoComplete="off"
        spellCheck={false}
        value={draft}
        onChange={(event) => onInputChange(event.target.value)}
        onFocus={() => {
          setOpen(true);
          setDraft(value ? value : '');
          setHighlight(0);
        }}
        onBlur={() => {
          if (skipBlurCommitRef.current) {
            skipBlurCommitRef.current = false;
            return;
          }
          closeAndCommit();
        }}
        onKeyDown={onKeyDown}
        placeholder="Type name or key (e.g. gen, Matthew)"
      />
      {open ? (
        <ul id={listboxId} className="book-key-combobox-list" role="listbox">
          {displayRows.length === 0 ? (
            <li className="muted">No matching books</li>
          ) : (
            <>
              {allowEmpty ? (
                <li
                  role="option"
                  aria-selected={highlight === 0}
                  className={highlight === 0 ? 'is-highlighted' : undefined}
                  onMouseDown={(event) => {
                    event.preventDefault();
                    pick('');
                  }}
                >
                  <span className="muted">No primary book</span>
                </li>
              ) : null}
              {displayRows.map((book, index) => {
                const rowIndex = allowEmpty ? index + 1 : index;
                return (
                  <li
                    key={book.book_key}
                    role="option"
                    aria-selected={highlight === rowIndex}
                    className={highlight === rowIndex ? 'is-highlighted' : undefined}
                    onMouseDown={(event) => {
                      event.preventDefault();
                      pick(book.book_key);
                    }}
                  >
                    <span className="book-key-combobox-title">{book.display_name_en}</span>
                    <span className="book-key-combobox-meta">
                      {book.short_name} · {book.book_key}
                    </span>
                  </li>
                );
              })}
            </>
          )}
        </ul>
      ) : null}
    </div>
  );
}
