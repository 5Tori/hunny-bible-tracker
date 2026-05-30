/** Message Card Library taxonomy — single source of truth for Admin, API, and web UI. */

export const MESSAGE_TAG_TYPES = [
  'category',
  'situation',
  'theme',
  'bible_context',
  'tone',
  'share_intent',
] as const;

export type MessageTagType = (typeof MESSAGE_TAG_TYPES)[number];

export interface TaxonomyEntry {
  key: string;
  label: string;
  description?: string;
  sortOrder?: number;
}

export const MESSAGE_CATEGORIES: TaxonomyEntry[] = [
  { key: 'anxiety_worry', label: 'Anxiety & Worry', sortOrder: 10 },
  { key: 'peace_rest', label: 'Peace & Rest', sortOrder: 20 },
  { key: 'hope_waiting', label: 'Hope & Waiting', sortOrder: 30 },
  { key: 'strength_courage', label: 'Strength & Courage', sortOrder: 40 },
  { key: 'wisdom_guidance', label: 'Wisdom & Guidance', sortOrder: 50 },
  { key: 'loneliness_belonging', label: 'Loneliness & Belonging', sortOrder: 60 },
  { key: 'forgiveness_grace', label: 'Forgiveness & Grace', sortOrder: 70 },
  { key: 'gratitude_joy', label: 'Gratitude & Joy', sortOrder: 80 },
];

export const MESSAGE_SITUATIONS: (TaxonomyEntry & { categoryKey: string })[] = [
  { categoryKey: 'anxiety_worry', key: 'future_uncertainty', label: 'When the future feels uncertain', sortOrder: 10 },
  { categoryKey: 'anxiety_worry', key: 'relationships', label: 'When relationships feel heavy', sortOrder: 20 },
  { categoryKey: 'anxiety_worry', key: 'decision_pressure', label: 'Before a big decision', sortOrder: 30 },
  { categoryKey: 'anxiety_worry', key: 'money_work_pressure', label: 'When work or money weighs on you', sortOrder: 40 },
  { categoryKey: 'anxiety_worry', key: 'health_fear', label: 'When health feels scary', sortOrder: 50 },
  { categoryKey: 'anxiety_worry', key: 'feeling_behind', label: 'When you feel behind', sortOrder: 60 },
  { categoryKey: 'anxiety_worry', key: 'spiritual_doubt', label: 'When faith feels distant', sortOrder: 70 },
  { categoryKey: 'peace_rest', key: 'overwhelmed', label: 'When your mind feels crowded', sortOrder: 10 },
  { categoryKey: 'peace_rest', key: 'before_sleep', label: 'Before sleep', sortOrder: 20 },
  { categoryKey: 'peace_rest', key: 'busy_life', label: 'In a busy day', sortOrder: 30 },
  { categoryKey: 'peace_rest', key: 'inner_noise', label: 'When thoughts will not stop', sortOrder: 40 },
  { categoryKey: 'peace_rest', key: 'need_stillness', label: 'When you need stillness', sortOrder: 50 },
  { categoryKey: 'hope_waiting', key: 'waiting_season', label: 'In a waiting season', sortOrder: 10 },
  { categoryKey: 'hope_waiting', key: 'discouraged', label: 'When you feel discouraged', sortOrder: 20 },
  { categoryKey: 'hope_waiting', key: 'unanswered_prayer', label: 'When prayer feels unanswered', sortOrder: 30 },
  { categoryKey: 'hope_waiting', key: 'new_beginning', label: 'At a new beginning', sortOrder: 40 },
  { categoryKey: 'hope_waiting', key: 'long_process', label: 'When the process feels long', sortOrder: 50 },
  { categoryKey: 'strength_courage', key: 'tired', label: 'When you are tired', sortOrder: 10 },
  { categoryKey: 'strength_courage', key: 'afraid_to_start', label: 'When starting feels scary', sortOrder: 20 },
  { categoryKey: 'strength_courage', key: 'facing_challenge', label: 'Facing a challenge', sortOrder: 30 },
  { categoryKey: 'strength_courage', key: 'need_endurance', label: 'When you need endurance', sortOrder: 40 },
  { categoryKey: 'strength_courage', key: 'standing_firm', label: 'When you want to stand firm', sortOrder: 50 },
  { categoryKey: 'wisdom_guidance', key: 'big_decision', label: 'Before a big decision', sortOrder: 10 },
  { categoryKey: 'wisdom_guidance', key: 'confused_direction', label: 'When direction is unclear', sortOrder: 20 },
  { categoryKey: 'wisdom_guidance', key: 'need_discernment', label: 'When you need discernment', sortOrder: 30 },
  { categoryKey: 'wisdom_guidance', key: 'work_school_choice', label: 'Choosing work or study', sortOrder: 40 },
  { categoryKey: 'wisdom_guidance', key: 'relationship_decision', label: 'In a relationship decision', sortOrder: 50 },
  { categoryKey: 'loneliness_belonging', key: 'feeling_alone', label: 'When you feel alone', sortOrder: 10 },
  { categoryKey: 'loneliness_belonging', key: 'left_out', label: 'When you feel left out', sortOrder: 20 },
  { categoryKey: 'loneliness_belonging', key: 'far_from_god', label: 'When God feels far away', sortOrder: 30 },
  { categoryKey: 'loneliness_belonging', key: 'need_comfort', label: 'When you need quiet comfort', sortOrder: 40 },
  { categoryKey: 'loneliness_belonging', key: 'missing_home', label: 'When you miss belonging', sortOrder: 50 },
  { categoryKey: 'forgiveness_grace', key: 'guilt', label: 'When guilt weighs on you', sortOrder: 10 },
  { categoryKey: 'forgiveness_grace', key: 'shame', label: 'When shame feels heavy', sortOrder: 20 },
  { categoryKey: 'forgiveness_grace', key: 'need_mercy', label: 'When you need mercy', sortOrder: 30 },
  { categoryKey: 'forgiveness_grace', key: 'starting_over', label: 'When you want to start again', sortOrder: 40 },
  { categoryKey: 'forgiveness_grace', key: 'forgiving_others', label: 'When forgiveness is hard', sortOrder: 50 },
  { categoryKey: 'gratitude_joy', key: 'morning_gratitude', label: 'Morning gratitude', sortOrder: 10 },
  { categoryKey: 'gratitude_joy', key: 'small_blessings', label: 'Small blessings', sortOrder: 20 },
  { categoryKey: 'gratitude_joy', key: 'celebration', label: 'Celebration', sortOrder: 30 },
  { categoryKey: 'gratitude_joy', key: 'contentment', label: 'Contentment', sortOrder: 40 },
  { categoryKey: 'gratitude_joy', key: 'praise', label: 'Praise', sortOrder: 50 },
];

export const MESSAGE_THEME_TAGS: TaxonomyEntry[] = [
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
];

export const MESSAGE_BIBLE_CONTEXT_TAGS: TaxonomyEntry[] = [
  { key: 'psalms', label: 'Psalms', sortOrder: 10 },
  { key: 'proverbs', label: 'Proverbs', sortOrder: 20 },
  { key: 'gospels', label: 'Gospels', sortOrder: 30 },
  { key: 'paul_letters', label: "Paul's Letters", sortOrder: 40 },
  { key: 'prophets', label: 'Prophets', sortOrder: 50 },
  { key: 'old_testament_story', label: 'Old Testament Story', sortOrder: 60 },
  { key: 'jesus_words', label: 'Words of Jesus', sortOrder: 70 },
];

export const MESSAGE_TONES: TaxonomyEntry[] = [
  { key: 'comfort', label: 'Comfort', sortOrder: 10 },
  { key: 'encouragement', label: 'Encouragement', sortOrder: 20 },
  { key: 'reflection', label: 'Reflection', sortOrder: 30 },
  { key: 'prayerful', label: 'Prayerful', sortOrder: 40 },
  { key: 'gratitude', label: 'Gratitude', sortOrder: 50 },
  { key: 'challenge', label: 'Challenge', sortOrder: 60 },
  { key: 'assurance', label: 'Assurance', sortOrder: 70 },
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
  { type: 'category', entries: MESSAGE_CATEGORIES },
  { type: 'situation', entries: MESSAGE_SITUATIONS },
  { type: 'theme', entries: MESSAGE_THEME_TAGS },
  { type: 'bible_context', entries: MESSAGE_BIBLE_CONTEXT_TAGS },
  { type: 'tone', entries: MESSAGE_TONES },
  { type: 'share_intent', entries: MESSAGE_SHARE_INTENTS },
];

export function getSituationsForCategory(categoryKey: string) {
  return MESSAGE_SITUATIONS.filter((entry) => entry.categoryKey === categoryKey);
}

export function getCategoryLabel(categoryKey: string) {
  return MESSAGE_CATEGORIES.find((entry) => entry.key === categoryKey)?.label ?? categoryKey;
}

export function resolveTagLabel(type: MessageTagType, key: string) {
  const list = ALL_ENTRIES.find((group) => group.type === type)?.entries ?? [];
  return list.find((entry) => entry.key === key)?.label ?? key;
}

export function getMessageTaxonomyPayload() {
  return {
    categories: MESSAGE_CATEGORIES.map(({ key, label, description, sortOrder }) => ({
      key,
      label,
      description,
      sortOrder,
      situations: getSituationsForCategory(key).map(({ key: situationKey, label: situationLabel, sortOrder: situationSort }) => ({
        key: situationKey,
        label: situationLabel,
        sortOrder: situationSort,
      })),
    })),
    themeTags: MESSAGE_THEME_TAGS,
    bibleContextTags: MESSAGE_BIBLE_CONTEXT_TAGS,
    tones: MESSAGE_TONES,
    shareIntents: MESSAGE_SHARE_INTENTS,
  };
}

export function isValidCategoryKey(key: string) {
  return MESSAGE_CATEGORIES.some((entry) => entry.key === key);
}

export function isValidSituationForCategory(categoryKey: string, situationKey: string) {
  return MESSAGE_SITUATIONS.some(
    (entry) => entry.categoryKey === categoryKey && entry.key === situationKey,
  );
}

/** Flat list for SQL seed generation and Admin pickers. */
export function getTaxonomyTagRows(): Array<{ type: MessageTagType; key: string; name: string; sort_order: number }> {
  const rows: Array<{ type: MessageTagType; key: string; name: string; sort_order: number }> = [];

  for (const category of MESSAGE_CATEGORIES) {
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
    { type: 'theme' as const, entries: MESSAGE_THEME_TAGS },
    { type: 'bible_context' as const, entries: MESSAGE_BIBLE_CONTEXT_TAGS },
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
