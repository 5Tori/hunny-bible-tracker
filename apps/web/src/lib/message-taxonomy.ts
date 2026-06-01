/**
 * Hunny Message Card Taxonomy
 *
 * Public discovery facets: primary category, situations, themes
 * Internal metadata: bible context, tone, share intent
 *
 * DB `content_tags.type` keeps `category` for primary category keys.
 */

export const PUBLIC_TAXONOMY_TYPES = ['category', 'situation', 'theme'] as const;

export type PublicTaxonomyType = (typeof PUBLIC_TAXONOMY_TYPES)[number];

export const INTERNAL_METADATA_TYPES = ['bible_context', 'tone', 'share_intent'] as const;

export type InternalMetadataType = (typeof INTERNAL_METADATA_TYPES)[number];

/** All tag types stored on `content_tags`. */
export const MESSAGE_TAG_TYPES = [
  ...PUBLIC_TAXONOMY_TYPES,
  ...INTERNAL_METADATA_TYPES,
] as const;

export type MessageTagType = (typeof MESSAGE_TAG_TYPES)[number];

export interface TaxonomyEntry {
  key: string;
  label: string;
  description?: string;
  sortOrder?: number;
  aliases?: string[];
  isActive?: boolean;
}

export interface CategoryEntry extends TaxonomyEntry {
  icon?: string;
}

export interface SituationEntry extends TaxonomyEntry {
  /** Editor hints only — situations are not owned by a single category. */
  suggestedCategoryKeys?: string[];
}

export interface ThemeEntry extends TaxonomyEntry {
  relatedCategoryKeys?: string[];
}

export const MESSAGE_TAXONOMY_LIMITS = {
  primaryCategory: 1,
  situations: 2,
  themes: 3,
  bibleContexts: 2,
  tone: 1,
  shareIntents: 2,
} as const;

export const MESSAGE_PRIMARY_CATEGORIES: CategoryEntry[] = [
  { key: 'peace_anxiety', label: 'Peace & Anxiety', sortOrder: 10 },
  { key: 'hope_waiting', label: 'Hope & Waiting', sortOrder: 20 },
  { key: 'wisdom_guidance', label: 'Wisdom & Guidance', sortOrder: 30 },
  { key: 'strength_courage', label: 'Strength & Courage', sortOrder: 40 },
  { key: 'love_belonging', label: 'Love & Belonging', sortOrder: 50 },
  { key: 'grace_forgiveness', label: 'Grace & Forgiveness', sortOrder: 60 },
  { key: 'joy_gratitude', label: 'Joy & Gratitude', sortOrder: 70 },
  { key: 'identity_purpose', label: 'Identity & Purpose', sortOrder: 80 },
];

/** @deprecated Use `MESSAGE_PRIMARY_CATEGORIES`. */
export const MESSAGE_CATEGORIES = MESSAGE_PRIMARY_CATEGORIES;

export const MESSAGE_SITUATIONS: SituationEntry[] = [
  {
    key: 'future_uncertainty',
    label: 'When the future feels uncertain',
    sortOrder: 10,
    suggestedCategoryKeys: ['peace_anxiety', 'hope_waiting'],
  },
  {
    key: 'major_decision',
    label: 'Before a big decision',
    sortOrder: 20,
    suggestedCategoryKeys: ['wisdom_guidance', 'peace_anxiety'],
  },
  {
    key: 'feeling_overwhelmed',
    label: 'When you feel overwhelmed',
    sortOrder: 30,
    suggestedCategoryKeys: ['peace_anxiety'],
  },
  {
    key: 'waiting_season',
    label: 'In a waiting season',
    sortOrder: 40,
    suggestedCategoryKeys: ['hope_waiting'],
  },
  {
    key: 'unanswered_prayer',
    label: 'When prayer feels unanswered',
    sortOrder: 50,
    suggestedCategoryKeys: ['hope_waiting'],
  },
  {
    key: 'new_beginning',
    label: 'At a new beginning',
    sortOrder: 60,
    suggestedCategoryKeys: ['hope_waiting', 'identity_purpose'],
  },
  {
    key: 'feeling_tired',
    label: 'When you are tired',
    sortOrder: 70,
    suggestedCategoryKeys: ['strength_courage', 'peace_anxiety'],
  },
  {
    key: 'facing_challenge',
    label: 'Facing a challenge',
    sortOrder: 80,
    suggestedCategoryKeys: ['strength_courage'],
  },
  {
    key: 'feeling_lonely',
    label: 'When you feel alone',
    sortOrder: 90,
    suggestedCategoryKeys: ['love_belonging'],
  },
  {
    key: 'far_from_god',
    label: 'When God feels far away',
    sortOrder: 100,
    suggestedCategoryKeys: ['love_belonging', 'grace_forgiveness'],
  },
  {
    key: 'guilt_shame',
    label: 'When guilt or shame feels heavy',
    sortOrder: 110,
    suggestedCategoryKeys: ['grace_forgiveness'],
  },
  {
    key: 'forgiving_others',
    label: 'When forgiveness feels hard',
    sortOrder: 120,
    suggestedCategoryKeys: ['grace_forgiveness'],
  },
  {
    key: 'morning_reset',
    label: 'At the start of the day',
    sortOrder: 130,
    suggestedCategoryKeys: ['joy_gratitude', 'peace_anxiety'],
  },
  {
    key: 'need_contentment',
    label: 'When you need contentment',
    sortOrder: 140,
    suggestedCategoryKeys: ['joy_gratitude'],
  },
  {
    key: 'life_transition',
    label: 'In a life transition',
    sortOrder: 150,
    suggestedCategoryKeys: ['identity_purpose', 'hope_waiting'],
  },
];

export const MESSAGE_THEMES: ThemeEntry[] = [
  { key: 'trust', label: 'Trust', sortOrder: 10 },
  { key: 'peace', label: 'Peace', sortOrder: 20 },
  { key: 'hope', label: 'Hope', sortOrder: 30 },
  { key: 'prayer', label: 'Prayer', sortOrder: 40 },
  { key: 'waiting', label: 'Waiting', sortOrder: 50 },
  { key: 'courage', label: 'Courage', sortOrder: 60 },
  { key: 'wisdom', label: 'Wisdom', sortOrder: 70 },
  { key: 'guidance', label: 'Guidance', sortOrder: 80 },
  { key: 'grace', label: 'Grace', sortOrder: 90 },
  { key: 'forgiveness', label: 'Forgiveness', sortOrder: 100 },
  { key: 'comfort', label: 'Comfort', sortOrder: 110 },
  { key: 'strength', label: 'Strength', sortOrder: 120 },
  { key: 'joy', label: 'Joy', sortOrder: 130 },
  { key: 'gratitude', label: 'Gratitude', sortOrder: 140 },
  { key: 'identity', label: 'Identity', sortOrder: 150 },
  { key: 'purpose', label: 'Purpose', sortOrder: 160 },
  { key: 'faith', label: 'Faith', sortOrder: 170 },
  { key: 'rest', label: 'Rest', sortOrder: 180 },
  { key: 'presence', label: 'Presence', sortOrder: 190 },
  { key: 'love', label: 'Love', sortOrder: 200 },
];

/** @deprecated Use `MESSAGE_THEMES`. */
export const MESSAGE_THEME_TAGS = MESSAGE_THEMES;

export const MESSAGE_BIBLE_CONTEXTS: TaxonomyEntry[] = [
  { key: 'psalms', label: 'Psalms', sortOrder: 10 },
  { key: 'proverbs', label: 'Proverbs', sortOrder: 20 },
  { key: 'gospels', label: 'Gospels', sortOrder: 30 },
  { key: 'paul_letters', label: "Paul's Letters", sortOrder: 40 },
  { key: 'prophets', label: 'Prophets', sortOrder: 50 },
  { key: 'old_testament_story', label: 'Old Testament Story', sortOrder: 60 },
  { key: 'jesus_words', label: 'Words of Jesus', sortOrder: 70 },
];

/** @deprecated Use `MESSAGE_BIBLE_CONTEXTS`. */
export const MESSAGE_BIBLE_CONTEXT_TAGS = MESSAGE_BIBLE_CONTEXTS;

export const MESSAGE_TONES: TaxonomyEntry[] = [
  { key: 'gentle', label: 'Gentle', sortOrder: 10 },
  { key: 'comforting', label: 'Comforting', sortOrder: 20 },
  { key: 'encouraging', label: 'Encouraging', sortOrder: 30 },
  { key: 'reflective', label: 'Reflective', sortOrder: 40 },
  { key: 'prayerful', label: 'Prayerful', sortOrder: 50 },
  { key: 'assuring', label: 'Assuring', sortOrder: 60 },
  { key: 'uplifting', label: 'Uplifting', sortOrder: 70 },
];

export const MESSAGE_SHARE_INTENTS: TaxonomyEntry[] = [
  { key: 'for_self', label: 'For yourself', sortOrder: 10 },
  { key: 'send_comfort', label: 'Send comfort', sortOrder: 20 },
  { key: 'send_encouragement', label: 'Send encouragement', sortOrder: 30 },
  { key: 'morning_share', label: 'Morning share', sortOrder: 40 },
  { key: 'night_share', label: 'Night share', sortOrder: 50 },
  { key: 'thank_you', label: 'Say thank you', sortOrder: 60 },
  { key: 'celebration', label: 'Share joy', sortOrder: 70 },
];

const ALL_ENTRIES: Array<{ type: MessageTagType; entries: TaxonomyEntry[] }> = [
  { type: 'category', entries: MESSAGE_PRIMARY_CATEGORIES },
  { type: 'situation', entries: MESSAGE_SITUATIONS },
  { type: 'theme', entries: MESSAGE_THEMES },
  { type: 'bible_context', entries: MESSAGE_BIBLE_CONTEXTS },
  { type: 'tone', entries: MESSAGE_TONES },
  { type: 'share_intent', entries: MESSAGE_SHARE_INTENTS },
];

export function getSuggestedSituationsForCategory(categoryKey: string) {
  const suggested = MESSAGE_SITUATIONS.filter((entry) =>
    entry.suggestedCategoryKeys?.includes(categoryKey),
  );
  if (suggested.length > 0) return suggested;
  return getAllSituations();
}

/** @deprecated Use `getSuggestedSituationsForCategory`. */
export function getSituationsForCategory(categoryKey: string) {
  return getSuggestedSituationsForCategory(categoryKey);
}

export function getAllSituations() {
  return [...MESSAGE_SITUATIONS].sort((a, b) => (a.sortOrder ?? 0) - (b.sortOrder ?? 0));
}

export function getCategoryLabel(categoryKey: string) {
  return (
    MESSAGE_PRIMARY_CATEGORIES.find((entry) => entry.key === categoryKey)?.label ?? categoryKey
  );
}

export function resolveTagLabel(type: MessageTagType, key: string) {
  const list = ALL_ENTRIES.find((group) => group.type === type)?.entries ?? [];
  return list.find((entry) => entry.key === key)?.label ?? key;
}

export interface MessageCardTaxonomy {
  primaryCategoryKey: string;
  situationKeys: string[];
  themeKeys: string[];
  bibleContextKeys?: string[];
  toneKey?: string;
  shareIntentKeys?: string[];
}

export interface MessageTaxonomyDictionary {
  primaryCategories: CategoryEntry[];
  situations: SituationEntry[];
  themes: ThemeEntry[];
  bibleContexts: TaxonomyEntry[];
  tones: TaxonomyEntry[];
  shareIntents: TaxonomyEntry[];
  limits: typeof MESSAGE_TAXONOMY_LIMITS;
}

export function getMessageTaxonomyDictionary(): MessageTaxonomyDictionary {
  return {
    primaryCategories: MESSAGE_PRIMARY_CATEGORIES,
    situations: MESSAGE_SITUATIONS,
    themes: MESSAGE_THEMES,
    bibleContexts: MESSAGE_BIBLE_CONTEXTS,
    tones: MESSAGE_TONES,
    shareIntents: MESSAGE_SHARE_INTENTS,
    limits: MESSAGE_TAXONOMY_LIMITS,
  };
}

export function getMessageTaxonomyPayload() {
  const dictionary = getMessageTaxonomyDictionary();

  return {
    ...dictionary,
    /** Legacy nested shape for older clients. */
    categories: MESSAGE_PRIMARY_CATEGORIES.map(({ key, label, description, sortOrder }) => ({
      key,
      label,
      description,
      sortOrder,
      suggestedSituations: MESSAGE_SITUATIONS.filter((situation) =>
        situation.suggestedCategoryKeys?.includes(key),
      ).map(({ key: situationKey, label: situationLabel, sortOrder: situationSort }) => ({
        key: situationKey,
        label: situationLabel,
        sortOrder: situationSort,
      })),
    })),
    themeTags: MESSAGE_THEMES,
    bibleContextTags: MESSAGE_BIBLE_CONTEXTS,
  };
}

export function isValidPrimaryCategoryKey(key: string) {
  return MESSAGE_PRIMARY_CATEGORIES.some((entry) => entry.key === key);
}

/** @deprecated Use `isValidPrimaryCategoryKey`. */
export function isValidCategoryKey(key: string) {
  return isValidPrimaryCategoryKey(key);
}

export function isValidSituationKey(key: string) {
  return MESSAGE_SITUATIONS.some((entry) => entry.key === key);
}

export function isValidThemeKey(key: string) {
  return MESSAGE_THEMES.some((entry) => entry.key === key);
}

export function isValidBibleContextKey(key: string) {
  return MESSAGE_BIBLE_CONTEXTS.some((entry) => entry.key === key);
}

export function isValidToneKey(key: string) {
  return MESSAGE_TONES.some((entry) => entry.key === key);
}

export function isValidShareIntentKey(key: string) {
  return MESSAGE_SHARE_INTENTS.some((entry) => entry.key === key);
}

/** @deprecated Situations are no longer category-scoped. */
export function isValidSituationForCategory(categoryKey: string, situationKey: string) {
  return isValidSituationKey(situationKey);
}

export function validateMessageCardTaxonomy(taxonomy: MessageCardTaxonomy) {
  return {
    primaryCategory: isValidPrimaryCategoryKey(taxonomy.primaryCategoryKey),
    situations: taxonomy.situationKeys.every(isValidSituationKey),
    themes: taxonomy.themeKeys.every(isValidThemeKey),
    bibleContexts: (taxonomy.bibleContextKeys ?? []).every(isValidBibleContextKey),
    tone: taxonomy.toneKey ? isValidToneKey(taxonomy.toneKey) : true,
    shareIntents: (taxonomy.shareIntentKeys ?? []).every(isValidShareIntentKey),
    withinLimits:
      taxonomy.situationKeys.length <= MESSAGE_TAXONOMY_LIMITS.situations &&
      taxonomy.themeKeys.length <= MESSAGE_TAXONOMY_LIMITS.themes &&
      (taxonomy.bibleContextKeys?.length ?? 0) <= MESSAGE_TAXONOMY_LIMITS.bibleContexts &&
      (taxonomy.shareIntentKeys?.length ?? 0) <= MESSAGE_TAXONOMY_LIMITS.shareIntents,
  };
}

/** Flat list for SQL seed generation and Admin pickers. */
export function getTaxonomyTagRows(): Array<{
  type: MessageTagType;
  key: string;
  name: string;
  sort_order: number;
}> {
  const rows: Array<{ type: MessageTagType; key: string; name: string; sort_order: number }> = [];

  for (const category of MESSAGE_PRIMARY_CATEGORIES) {
    rows.push({
      type: 'category',
      key: category.key,
      name: category.label,
      sort_order: category.sortOrder ?? 0,
    });
  }

  for (const situation of MESSAGE_SITUATIONS) {
    rows.push({
      type: 'situation',
      key: situation.key,
      name: situation.label,
      sort_order: situation.sortOrder ?? 0,
    });
  }

  for (const group of [
    { type: 'theme' as const, entries: MESSAGE_THEMES },
    { type: 'bible_context' as const, entries: MESSAGE_BIBLE_CONTEXTS },
    { type: 'tone' as const, entries: MESSAGE_TONES },
    { type: 'share_intent' as const, entries: MESSAGE_SHARE_INTENTS },
  ]) {
    for (const entry of group.entries) {
      rows.push({
        type: group.type,
        key: entry.key,
        name: entry.label,
        sort_order: entry.sortOrder ?? 0,
      });
    }
  }

  return rows;
}
