import { describe, expect, it } from 'vitest';

import {
  formatVerseReference,
  getVerseReferenceValidationError,
  parseVerseReference,
  referenceBookLabel,
} from '@/lib/bible-verse-reference';

describe('bible-verse-reference', () => {
  it('formats a single verse', () => {
    expect(
      formatVerseReference({
        bookKey: 'matthew',
        chapter: 6,
        startVerse: 34,
      }),
    ).toBe('Matthew 6:34');
  });

  it('formats a verse range', () => {
    expect(
      formatVerseReference({
        bookKey: 'philippians',
        chapter: 4,
        startVerse: 6,
        endVerse: 7,
      }),
    ).toBe('Philippians 4:6-7');
  });

  it('uses Psalm label for psalms book key', () => {
    expect(referenceBookLabel('psalms')).toBe('Psalm');
    expect(
      formatVerseReference({
        bookKey: 'psalms',
        chapter: 46,
        startVerse: 10,
      }),
    ).toBe('Psalm 46:10');
  });

  it('parses formatted references', () => {
    expect(parseVerseReference('Matthew 6:34')).toEqual({
      bookKey: 'matthew',
      chapter: 6,
      startVerse: 34,
    });
    expect(parseVerseReference('Psalm 46:10')).toEqual({
      bookKey: 'psalms',
      chapter: 46,
      startVerse: 10,
    });
    expect(parseVerseReference('Philippians 4:6-7')).toEqual({
      bookKey: 'philippians',
      chapter: 4,
      startVerse: 6,
      endVerse: 7,
    });
  });

  it('reports validation errors for invalid references', () => {
    expect(getVerseReferenceValidationError('Philippians 4:6-7')).toBeNull();
    expect(getVerseReferenceValidationError('bad reference')).toMatch(/same chapter/i);
  });
});
