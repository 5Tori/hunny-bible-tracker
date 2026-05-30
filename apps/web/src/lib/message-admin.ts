import type { AdminContentInput, ContentWithRelations } from '@/lib/content';
import {
  getTaxonomyTagRows,
  MESSAGE_BIBLE_CONTEXT_TAGS,
  MESSAGE_CATEGORIES,
  MESSAGE_SHARE_INTENTS,
  MESSAGE_THEME_TAGS,
  MESSAGE_TONES,
  getSituationsForCategory,
} from '@/lib/message-taxonomy';
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
  shortReflection: string;
  prayerText: string;
  cardTemplateKey: string;
  isTodayEligible: boolean;
  searchAliasesText: string;
}

export function defaultMessageEditorState(): MessageEditorState {
  return {
    primaryCategory: '',
    situations: [],
    themeTags: [],
    bibleContextTags: [],
    tone: '',
    shareIntents: [...DEFAULT_MESSAGE_CARD_METADATA.shareIntents],
    shortReflection: '',
    prayerText: '',
    cardTemplateKey: DEFAULT_MESSAGE_CARD_METADATA.cardTemplateKey,
    isTodayEligible: true,
    searchAliasesText: '',
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
    shortReflection: metadata.shortReflection ?? '',
    prayerText: metadata.prayerText ?? '',
    cardTemplateKey: metadata.cardTemplateKey,
    isTodayEligible: metadata.isTodayEligible,
    searchAliasesText: metadata.searchAliases.join(', '),
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
    shortReflection: state.shortReflection.trim() || undefined,
    prayerText: state.prayerText.trim() || undefined,
    cardTemplateKey: state.cardTemplateKey || 'classic',
    shareIntents: state.shareIntents.length ? state.shareIntents : ['for_self'],
    isTodayEligible: state.isTodayEligible,
    searchAliases: state.searchAliasesText
      .split(',')
      .map((item) => item.trim())
      .filter(Boolean),
  };

  return mergeContentMetadataWithMessage(existing, metadata);
}

export {
  MESSAGE_BIBLE_CONTEXT_TAGS,
  MESSAGE_CATEGORIES,
  MESSAGE_SHARE_INTENTS,
  MESSAGE_THEME_TAGS,
  MESSAGE_TONES,
  getSituationsForCategory,
};

export function messageCategoryLabel(key: string | null | undefined) {
  if (!key) return '—';
  return MESSAGE_CATEGORIES.find((category) => category.key === key)?.label ?? key;
}
