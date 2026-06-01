/** Message-specific fields stored in `contents.metadata` for content_type = message. */

export interface MessageCardMetadata {
  primaryCategory: string;
  /**
   * Optional pre-rendered card image (verse text baked in).
   * When absent, UI uses `cover_image_url` with a live text overlay.
   */
  compositeImageUrl?: string;
  compositeImagePublicId?: string;
  /** Optional reflection shown below the verse on the card. */
  context?: string;
  /** Optional gentle prompt or prayer-like note. */
  hint?: string;
  /** @deprecated Use `context`. */
  shortReflection?: string;
  /** @deprecated Use `hint`. */
  prayerText?: string;
  cardTemplateKey: string;
  shareIntents: string[];
  searchAliases: string[];
}

export const DEFAULT_MESSAGE_CARD_METADATA: MessageCardMetadata = {
  primaryCategory: '',
  context: '',
  hint: '',
  shortReflection: '',
  prayerText: '',
  cardTemplateKey: 'classic',
  shareIntents: ['for_self'],
  searchAliases: [],
};

function asString(value: unknown) {
  return typeof value === 'string' ? value.trim() : '';
}

function asStringArray(value: unknown) {
  if (!Array.isArray(value)) return [];
  return value
    .map((item) => (typeof item === 'string' ? item.trim() : ''))
    .filter(Boolean);
}

export function parseMessageMetadata(raw: Record<string, unknown> | null | undefined): MessageCardMetadata {
  const source = raw ?? {};
  const primaryCategory = asString(source.primaryCategory);

  const context =
    asString(source.context) || asString(source.shortReflection) || undefined;
  const hint = asString(source.hint) || asString(source.prayerText) || undefined;

  const compositeImageUrl = asString(source.compositeImageUrl) || asString(source.composite_image_url) || undefined;
  const compositeImagePublicId =
    asString(source.compositeImagePublicId) || asString(source.composite_image_public_id) || undefined;

  return {
    primaryCategory,
    compositeImageUrl,
    compositeImagePublicId,
    context,
    hint,
    shortReflection: context,
    prayerText: hint,
    cardTemplateKey: asString(source.cardTemplateKey) || DEFAULT_MESSAGE_CARD_METADATA.cardTemplateKey,
    shareIntents: asStringArray(source.shareIntents).length
      ? asStringArray(source.shareIntents)
      : DEFAULT_MESSAGE_CARD_METADATA.shareIntents,
    searchAliases: asStringArray(source.searchAliases),
  };
}

export function serializeMessageMetadata(
  metadata: MessageCardMetadata,
  existing: Record<string, unknown> = {},
): Record<string, unknown> {
  const next: Record<string, unknown> = { ...existing };

  next.primaryCategory = metadata.primaryCategory;
  next.cardTemplateKey = metadata.cardTemplateKey || 'classic';
  delete next.isTodayEligible;

  const context = metadata.context?.trim() || metadata.shortReflection?.trim();
  const hint = metadata.hint?.trim() || metadata.prayerText?.trim();

  if (context) {
    next.context = context;
    delete next.shortReflection;
  } else {
    delete next.context;
    delete next.shortReflection;
  }

  if (hint) {
    next.hint = hint;
    delete next.prayerText;
  } else {
    delete next.hint;
    delete next.prayerText;
  }

  if (metadata.shareIntents.length) next.shareIntents = metadata.shareIntents;
  else delete next.shareIntents;

  if (metadata.searchAliases.length) next.searchAliases = metadata.searchAliases;
  else delete next.searchAliases;

  if (metadata.compositeImageUrl?.trim()) {
    next.compositeImageUrl = metadata.compositeImageUrl.trim();
    delete next.composite_image_url;
  } else {
    delete next.compositeImageUrl;
    delete next.composite_image_url;
  }

  if (metadata.compositeImagePublicId?.trim()) {
    next.compositeImagePublicId = metadata.compositeImagePublicId.trim();
    delete next.composite_image_public_id;
  } else {
    delete next.compositeImagePublicId;
    delete next.composite_image_public_id;
  }

  return next;
}

export function mergeContentMetadataWithMessage(
  existing: Record<string, unknown> | null | undefined,
  message: MessageCardMetadata,
) {
  return serializeMessageMetadata(message, existing ?? {});
}

/** Message cards display copy lives in metadata — not `contents.summary`. */
export function resolveMessageDisplayContext(
  raw: Record<string, unknown> | null | undefined,
): string | null {
  const metadata = parseMessageMetadata(raw);
  return metadata.context ?? metadata.shortReflection ?? null;
}

export function resolveMessageTitle(
  primaryVerseReference?: string | null,
  fallbackTitle?: string | null,
): string | null {
  const reference = asString(primaryVerseReference);
  if (reference) return reference;
  const title = asString(fallbackTitle);
  return title || null;
}
