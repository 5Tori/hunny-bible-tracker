import type { AdminContentInput, ContentWithRelations } from '@/lib/content';
import type { PublicMessageCard } from '@/lib/messages';
import {
  getCategoryLabel,
  getTaxonomyTagRows,
  MESSAGE_BIBLE_CONTEXTS,
  MESSAGE_PRIMARY_CATEGORIES,
  MESSAGE_SHARE_INTENTS,
  MESSAGE_TAXONOMY_LIMITS,
  MESSAGE_THEMES,
  MESSAGE_TONES,
  getAllSituations,
  getSuggestedSituationsForCategory,
  resolveTagLabel,
  validateMessageCardTaxonomy,
  type MessageCardTaxonomy,
} from '@/lib/message-taxonomy';
import { resolveMessageCardImages } from '@/lib/message-images';
import {
  DEFAULT_MESSAGE_CARD_METADATA,
  mergeContentMetadataWithMessage,
  parseMessageMetadata,
  type MessageCardMetadata,
} from '@/lib/message-metadata';

export interface MessageEditorState {
  primaryCategory: string;
  situations: string[];
  themeTags: string[];
  bibleContextTags: string[];
  tone: string;
  shareIntents: string[];
  context: string;
  hint: string;
  cardTemplateKey: string;
  searchAliasesText: string;
  /** Pre-rendered card (verse baked in). Stored in `contents.metadata`. */
  compositeImageUrl: string;
  compositeImagePublicId: string;
}

export function defaultMessageEditorState(): MessageEditorState {
  return {
    primaryCategory: '',
    situations: [],
    themeTags: [],
    bibleContextTags: [],
    tone: '',
    shareIntents: [...DEFAULT_MESSAGE_CARD_METADATA.shareIntents],
    context: '',
    hint: '',
    cardTemplateKey: DEFAULT_MESSAGE_CARD_METADATA.cardTemplateKey,
    searchAliasesText: '',
    compositeImageUrl: '',
    compositeImagePublicId: '',
  };
}

export function messageEditorStateFromContent(content: ContentWithRelations): MessageEditorState {
  const metadata = parseMessageMetadata(content.metadata);
  const tagsByType = new Map<string, string[]>();

  for (const tag of content.tags) {
    const bucket = tagsByType.get(tag.type) ?? [];
    bucket.push(tag.key);
    tagsByType.set(tag.type, bucket);
  }

  return {
    primaryCategory: metadata.primaryCategory || tagsByType.get('category')?.[0] || '',
    situations: tagsByType.get('situation') ?? [],
    themeTags: tagsByType.get('theme') ?? [],
    bibleContextTags: tagsByType.get('bible_context') ?? [],
    tone: tagsByType.get('tone')?.[0] ?? '',
    shareIntents: metadata.shareIntents,
    context: metadata.context ?? '',
    hint: metadata.hint ?? '',
    cardTemplateKey: metadata.cardTemplateKey,
    searchAliasesText: metadata.searchAliases.join(', '),
    compositeImageUrl: metadata.compositeImageUrl ?? '',
    compositeImagePublicId: metadata.compositeImagePublicId ?? '',
  };
}

function taxonomyName(type: string, key: string) {
  const row = getTaxonomyTagRows().find((entry) => entry.type === type && entry.key === key);
  return row?.name ?? key;
}

type MessageTagInput = NonNullable<AdminContentInput['tags']>[number];

export function buildMessageTags(state: MessageEditorState): MessageTagInput[] {
  const tags: MessageTagInput[] = [];
  let sortOrder = 0;

  const push = (type: string, key: string) => {
    if (!key) return;
    tags.push({
      type,
      key,
      name: taxonomyName(type, key),
      description: '',
      sort_order: sortOrder++,
    });
  };

  if (state.primaryCategory) push('category', state.primaryCategory);
  for (const situation of state.situations) push('situation', situation);
  for (const theme of state.themeTags) push('theme', theme);
  for (const context of state.bibleContextTags) push('bible_context', context);
  if (state.tone) push('tone', state.tone);
  for (const intent of state.shareIntents) push('share_intent', intent);

  return tags;
}

export function buildMessageMetadataPayload(
  state: MessageEditorState,
  existing: Record<string, unknown> = {},
): Record<string, unknown> {
  const metadata: MessageCardMetadata = {
    primaryCategory: state.primaryCategory,
    compositeImageUrl: state.compositeImageUrl.trim() || undefined,
    compositeImagePublicId: state.compositeImagePublicId.trim() || undefined,
    context: state.context.trim() || undefined,
    hint: state.hint.trim() || undefined,
    cardTemplateKey: state.cardTemplateKey || 'classic',
    shareIntents: state.shareIntents.length ? state.shareIntents : ['for_self'],
    searchAliases: state.searchAliasesText
      .split(',')
      .map((item) => item.trim())
      .filter(Boolean),
  };

  return mergeContentMetadataWithMessage(existing, metadata);
}

export {
  MESSAGE_BIBLE_CONTEXTS,
  MESSAGE_PRIMARY_CATEGORIES,
  MESSAGE_SHARE_INTENTS,
  MESSAGE_TAXONOMY_LIMITS,
  MESSAGE_THEMES,
  MESSAGE_TONES,
  getAllSituations,
  getSuggestedSituationsForCategory,
};

/** @deprecated */
export const MESSAGE_CATEGORIES = MESSAGE_PRIMARY_CATEGORIES;
/** @deprecated */
export const MESSAGE_THEME_TAGS = MESSAGE_THEMES;
/** @deprecated */
export const MESSAGE_BIBLE_CONTEXT_TAGS = MESSAGE_BIBLE_CONTEXTS;
/** @deprecated */
export const getSituationsForCategory = getSuggestedSituationsForCategory;

export function messageCategoryLabel(key: string | null | undefined) {
  if (!key) return '—';
  return getCategoryLabel(key);
}

export function messageEditorStateToTaxonomy(state: MessageEditorState): MessageCardTaxonomy {
  return {
    primaryCategoryKey: state.primaryCategory,
    situationKeys: state.situations,
    themeKeys: state.themeTags,
    bibleContextKeys: state.bibleContextTags,
    toneKey: state.tone || undefined,
    shareIntentKeys: state.shareIntents,
  };
}

export function messageEditorStateFromTags(
  tags: Array<{ type: string; key: string }>,
  metadata?: Record<string, unknown> | null,
): MessageEditorState {
  const parsed = parseMessageMetadata(metadata);
  const grouped = new Map<string, string[]>();
  for (const tag of tags) {
    const bucket = grouped.get(tag.type) ?? [];
    bucket.push(tag.key);
    grouped.set(tag.type, bucket);
  }

  return {
    ...defaultMessageEditorState(),
    primaryCategory: parsed.primaryCategory || grouped.get('category')?.[0] || '',
    situations: grouped.get('situation') ?? [],
    themeTags: grouped.get('theme') ?? [],
    bibleContextTags: grouped.get('bible_context') ?? [],
    tone: grouped.get('tone')?.[0] ?? '',
    shareIntents: parsed.shareIntents.length ? parsed.shareIntents : grouped.get('share_intent') ?? [],
    context: parsed.context ?? '',
    hint: parsed.hint ?? '',
    cardTemplateKey: parsed.cardTemplateKey,
    searchAliasesText: parsed.searchAliases.join(', '),
    compositeImageUrl: parsed.compositeImageUrl ?? '',
    compositeImagePublicId: parsed.compositeImagePublicId ?? '',
  };
}

export function validateMessageEditorState(
  state: MessageEditorState,
  options: { isPublished: boolean },
): string | null {
  if (!options.isPublished) {
    return null;
  }

  if (!state.primaryCategory.trim()) {
    return 'Primary category is required to publish.';
  }

  const taxonomy = messageEditorStateToTaxonomy(state);
  const checks = validateMessageCardTaxonomy(taxonomy);

  if (!checks.primaryCategory) {
    return 'Choose a valid primary category.';
  }
  if (!checks.situations) {
    return 'One or more situation tags are invalid.';
  }
  if (!checks.themes) {
    return 'One or more theme tags are invalid.';
  }
  if (!checks.bibleContexts) {
    return 'One or more bible context tags are invalid.';
  }
  if (!checks.tone) {
    return 'Choose a valid tone.';
  }
  if (!checks.shareIntents) {
    return 'One or more share intent tags are invalid.';
  }
  if (!checks.withinLimits) {
    return `Classification limits: ${MESSAGE_TAXONOMY_LIMITS.situations} situations, ${MESSAGE_TAXONOMY_LIMITS.themes} themes.`;
  }

  if (!state.tone.trim()) {
    return 'Tone is required to publish.';
  }
  if (state.shareIntents.length === 0) {
    return 'Select at least one share intent.';
  }

  return null;
}

export interface MessageListTaxonomy {
  primaryCategory: string | null;
  situations: string[];
  themes: string[];
}

export function taxonomyFromContentTags(
  tags: Array<{ type: string; key: string }>,
  metadataPrimaryCategory?: string | null,
): MessageListTaxonomy {
  const grouped = new Map<string, string[]>();
  for (const tag of tags) {
    const bucket = grouped.get(tag.type) ?? [];
    bucket.push(tag.key);
    grouped.set(tag.type, bucket);
  }

  return {
    primaryCategory:
      metadataPrimaryCategory?.trim() ||
      grouped.get('category')?.[0] ||
      null,
    situations: grouped.get('situation') ?? [],
    themes: grouped.get('theme') ?? [],
  };
}

export function messageListTaxonomyFromItem(message: {
  metadata?: Record<string, unknown> | null;
  situation_keys?: string[];
  theme_keys?: string[];
}): MessageListTaxonomy {
  const metadata = parseMessageMetadata(message.metadata);
  return taxonomyFromContentTags(
    [
      ...(message.situation_keys ?? []).map((key) => ({ type: 'situation', key })),
      ...(message.theme_keys ?? []).map((key) => ({ type: 'theme', key })),
    ],
    metadata.primaryCategory,
  );
}

export function formatMessageClassificationSummary(taxonomy: MessageListTaxonomy): string {
  const parts: string[] = [];
  if (taxonomy.primaryCategory) {
    parts.push(getCategoryLabel(taxonomy.primaryCategory));
  }
  for (const key of taxonomy.situations.slice(0, 2)) {
    parts.push(resolveTagLabel('situation', key));
  }
  if (taxonomy.situations.length > 2) {
    parts.push(`+${taxonomy.situations.length - 2} situations`);
  }
  for (const key of taxonomy.themes.slice(0, 1)) {
    parts.push(resolveTagLabel('theme', key));
  }
  if (taxonomy.themes.length > 1) {
    parts.push(`+${taxonomy.themes.length - 1} themes`);
  }
  return parts.length > 0 ? parts.join(' · ') : '—';
}

export function buildAdminMessagePreview(
  content: AdminContentInput,
  messageState: MessageEditorState,
  contentId = 'preview',
): PublicMessageCard {
  const metadata = buildMessageMetadataPayload(messageState, {});
  const parsed = parseMessageMetadata(metadata);
  const verseReference =
    content.primary_verse_reference?.trim() || content.title?.trim() || 'Verse reference';
  const images = resolveMessageCardImages({
    coverImageUrl: content.cover_image_url,
    compositeImageUrl: messageState.compositeImageUrl.trim() || parsed.compositeImageUrl || null,
  });

  return {
    id: contentId,
    slug: content.slug || 'preview',
    title: verseReference,
    subtitle: null,
    verseReference,
    verseText: content.verse_text?.trim() || null,
    translation: content.bible_version?.trim() || null,
    context: parsed.context ?? null,
    hint: parsed.hint ?? null,
    shortReflection: parsed.context ?? null,
    prayerText: parsed.hint ?? null,
    primaryCategory: messageState.primaryCategory,
    primaryCategoryLabel: getCategoryLabel(messageState.primaryCategory),
    situations: messageState.situations,
    situationLabels: messageState.situations.map((key) => resolveTagLabel('situation', key)),
    themeTags: messageState.themeTags,
    themeTagLabels: messageState.themeTags.map((key) => resolveTagLabel('theme', key)),
    bibleContextTags: messageState.bibleContextTags,
    tone: messageState.tone || null,
    toneLabel: messageState.tone ? resolveTagLabel('tone', messageState.tone) : null,
    shareIntents: messageState.shareIntents,
    cardTemplateKey: parsed.cardTemplateKey,
    shareImageUrl: images.displayImageUrl,
    coverImageUrl: images.coverImageUrl,
    compositeImageUrl: images.compositeImageUrl,
    displayImageUrl: images.displayImageUrl,
    hasCompositeImage: images.hasCompositeImage,
    heartCount: 0,
    shareCount: 0,
    saveCount: 0,
    relatedPlans: [],
    messagesUrl: `/messages/${content.slug || 'preview'}`,
  };
}

export function messageCardListPreview(message: {
  title: string;
  primary_verse_reference?: string | null;
  metadata?: Record<string, unknown> | null;
}) {
  const metadata = parseMessageMetadata(message.metadata);
  const verseReference =
    message.primary_verse_reference?.trim() || message.title.trim() || '—';
  const context = metadata.context?.trim() || '';

  return { verseReference, context };
}
