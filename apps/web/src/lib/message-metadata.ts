/** Message-specific fields stored in `contents.metadata` for content_type = message. */

export interface MessageCardMetadata {
  primaryCategory: string;
  shortReflection?: string;
  prayerText?: string;
  cardTemplateKey: string;
  shareIntents: string[];
  isTodayEligible: boolean;
  searchAliases: string[];
}

export const DEFAULT_MESSAGE_CARD_METADATA: MessageCardMetadata = {
  primaryCategory: '',
  shortReflection: '',
  prayerText: '',
  cardTemplateKey: 'classic',
  shareIntents: ['for_self'],
  isTodayEligible: true,
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

  return {
    primaryCategory,
    shortReflection: asString(source.shortReflection) || undefined,
    prayerText: asString(source.prayerText) || undefined,
    cardTemplateKey: asString(source.cardTemplateKey) || DEFAULT_MESSAGE_CARD_METADATA.cardTemplateKey,
    shareIntents: asStringArray(source.shareIntents).length
      ? asStringArray(source.shareIntents)
      : DEFAULT_MESSAGE_CARD_METADATA.shareIntents,
    isTodayEligible:
      typeof source.isTodayEligible === 'boolean'
        ? source.isTodayEligible
        : DEFAULT_MESSAGE_CARD_METADATA.isTodayEligible,
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
  next.isTodayEligible = metadata.isTodayEligible;

  if (metadata.shortReflection) next.shortReflection = metadata.shortReflection;
  else delete next.shortReflection;

  if (metadata.prayerText) next.prayerText = metadata.prayerText;
  else delete next.prayerText;

  if (metadata.shareIntents.length) next.shareIntents = metadata.shareIntents;
  else delete next.shareIntents;

  if (metadata.searchAliases.length) next.searchAliases = metadata.searchAliases;
  else delete next.searchAliases;

  return next;
}

export function mergeContentMetadataWithMessage(
  existing: Record<string, unknown> | null | undefined,
  message: MessageCardMetadata,
) {
  return serializeMessageMetadata(message, existing ?? {});
}
