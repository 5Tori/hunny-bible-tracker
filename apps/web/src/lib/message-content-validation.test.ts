import { describe, expect, it } from 'vitest';

import { validateMessageCardInput } from '@/lib/message-content-validation';

describe('message-content-validation', () => {
  it('allows draft saves without publish fields', () => {
    expect(
      validateMessageCardInput({
        primary_verse_reference: '',
        is_published: false,
      }),
    ).toBeNull();
  });

  it('rejects invalid reference strings even for drafts', () => {
    expect(
      validateMessageCardInput({
        primary_verse_reference: 'Not a reference',
        is_published: false,
      }),
    ).toMatch(/same chapter/i);
  });

  it('accepts parsed single-verse references for drafts', () => {
    expect(
      validateMessageCardInput({
        primary_verse_reference: 'Psalm 46:10',
        is_published: false,
      }),
    ).toBeNull();
  });

  it('accepts parsed same-chapter ranges for drafts', () => {
    expect(
      validateMessageCardInput({
        primary_verse_reference: 'Philippians 4:6-7',
        is_published: false,
      }),
    ).toBeNull();
  });

  it('requires publish fields when published', () => {
    expect(
      validateMessageCardInput({
        primary_verse_reference: 'Philippians 4:6-7',
        is_published: true,
      }),
    ).toBe('Bible version is required to publish.');
  });

  it('requires verse text when published', () => {
    expect(
      validateMessageCardInput({
        primary_verse_reference: 'Philippians 4:6-7',
        bible_version: 'NIV',
        cover_image_url: '/messages/sample-card.webp',
        is_published: true,
      }),
    ).toBe('Verse text is required to publish. Paste every verse in the selected range.');
  });

  it('requires taxonomy when published with messageState', () => {
    expect(
      validateMessageCardInput({
        primary_verse_reference: 'Philippians 4:6-7',
        bible_version: 'NIV',
        verse_text: 'Do not be anxious about anything.',
        cover_image_url: '/messages/sample-card.webp',
        is_published: true,
        messageState: {
          primaryCategory: '',
          situations: [],
          themeTags: [],
          bibleContextTags: [],
          tone: '',
          shareIntents: ['for_self'],
          context: '',
          hint: '',
          cardTemplateKey: 'classic',
          searchAliasesText: '',
          compositeImageUrl: '',
          compositeImagePublicId: '',
        },
      }),
    ).toBe('Primary category is required to publish.');
  });
});
