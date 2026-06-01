import {
  getVerseReferenceValidationError,
  normalizeVerseReferenceString,
} from '@/lib/bible-verse-reference';
import { validateMessageEditorState, type MessageEditorState } from '@/lib/message-admin';

export interface MessageCardValidationInput {
  primary_verse_reference?: string | null;
  bible_version?: string | null;
  verse_text?: string | null;
  cover_image_url?: string | null;
  is_published?: boolean;
  messageState?: MessageEditorState;
}

export function validateMessageCardInput(input: MessageCardValidationInput): string | null {
  const referenceError = getVerseReferenceValidationError(input.primary_verse_reference);
  const reference = input.primary_verse_reference?.trim() ?? '';

  if (reference && referenceError) {
    return referenceError;
  }

  if (!input.is_published) {
    return null;
  }

  if (referenceError) return referenceError;

  if (!input.bible_version?.trim()) {
    return 'Bible version is required to publish.';
  }
  if (!input.verse_text?.trim()) {
    return 'Verse text is required to publish. Paste every verse in the selected range.';
  }
  if (!input.cover_image_url?.trim()) {
    return 'Message image is required to publish.';
  }

  if (input.messageState) {
    const taxonomyError = validateMessageEditorState(input.messageState, {
      isPublished: true,
    });
    if (taxonomyError) return taxonomyError;
  }

  return null;
}

export function normalizeMessageCardReferenceFields(input: MessageCardValidationInput) {
  const normalizedReference = normalizeVerseReferenceString(input.primary_verse_reference);
  return {
    primary_verse_reference: normalizedReference,
    bible_version: input.bible_version?.trim().toUpperCase() || null,
  };
}
