import {
  MESSAGE_CARD_BG_HONEY,
  MESSAGE_CARD_BG_HONEY_PUBLIC_ID,
  MESSAGE_CARD_BG_SPACE,
  MESSAGE_CARD_BG_SPACE_PUBLIC_ID,
} from '@/lib/mock/fixtures/assets';
import {
  messageCardTag as tag,
  type MessageCardSeed,
} from '@/lib/mock/fixtures/message-card-seed-builders';

/** Curated message cards with full verse text (hand-maintained). */
export const handPickedMessageSeeds: MessageCardSeed[] = [
  {
    slug: 'john-1-1-3',
    coverImageUrl: MESSAGE_CARD_BG_SPACE,
    coverImagePublicId: MESSAGE_CARD_BG_SPACE_PUBLIC_ID,
    verse: 'John 1:1-3',
    bibleVersion: 'WEB',
    verseText:
      'In the beginning was the Word, and the Word was with God, and the Word was God. He was with God in the beginning. Through him all things were made; without him nothing was made that has been made.',
    featuredRank: 10,
    metadata: {
      primaryCategory: 'hope_waiting',
      context:
        'Before anything else existed, the Word was with God — and the Word was God.',
      hint: 'Read slowly. Let the opening verses introduce who you are meeting.',
      searchAliases: ['word', 'beginning', 'gospel', 'john', 'creation'],
    },
    tags: [
      tag('category', 'hope_waiting', 'Hope & Waiting'),
      tag('situation', 'new_beginning', 'At a new beginning'),
      tag('theme', 'faith', 'Faith'),
      tag('theme', 'purpose', 'Purpose'),
      tag('bible_context', 'gospels', 'Gospels'),
      tag('tone', 'reflective', 'Reflective'),
      tag('share_intent', 'for_self', 'For yourself'),
    ],
    planLinks: [{ templateKey: 'gospel_of_mark', ctaLabel: 'Continue in a Gospel plan' }],
  },
  {
    slug: 'psalm-19-9-10',
    coverImageUrl: MESSAGE_CARD_BG_HONEY,
    coverImagePublicId: MESSAGE_CARD_BG_HONEY_PUBLIC_ID,
    verse: 'Psalm 19:9-10',
    bibleVersion: 'WEB',
    verseText:
      'The fear of the Lord is pure, enduring forever. The decrees of the Lord are firm, and all of them are righteous; they are more precious than gold, than much pure gold; they are sweeter than honey, than honey from the honeycomb.',
    featuredRank: 20,
    metadata: {
      primaryCategory: 'wisdom_guidance',
      context: "God's words are more precious than gold and sweeter than honey.",
      hint: 'What one line from Scripture do you want to savor again today?',
      searchAliases: ['word', 'scripture', 'law', 'wisdom', 'psalm', 'honey', 'gold'],
    },
    tags: [
      tag('category', 'wisdom_guidance', 'Wisdom & Guidance'),
      tag('situation', 'major_decision', 'Before a big decision'),
      tag('theme', 'wisdom', 'Wisdom'),
      tag('theme', 'guidance', 'Guidance'),
      tag('bible_context', 'psalms', 'Psalms'),
      tag('tone', 'reflective', 'Reflective'),
      tag('share_intent', 'for_self', 'For yourself'),
    ],
    planLinks: [{ templateKey: 'psalms_for_anxiety', ctaLabel: 'Read Psalms for Anxiety' }],
  },
  {
    slug: '1-kings-3-9',
    verse: '1 Kings 3:9',
    bibleVersion: 'WEB',
    verseText:
      'So give your servant a discerning heart to govern your people and to distinguish between right and wrong.',
    featuredRank: 30,
    metadata: {
      primaryCategory: 'wisdom_guidance',
      context:
        'Solomon asks not for wealth or long life, but for a discerning heart to govern well.',
      hint: 'What decision today needs wisdom more than speed?',
      searchAliases: [
        'solomon',
        'wisdom',
        'discernment',
        'kings',
        'heart',
        'govern',
        'right',
        'wrong',
      ],
    },
    tags: [
      tag('category', 'wisdom_guidance', 'Wisdom & Guidance'),
      tag('situation', 'major_decision', 'Before a big decision'),
      tag('theme', 'wisdom', 'Wisdom'),
      tag('theme', 'guidance', 'Guidance'),
      tag('bible_context', 'old_testament_story', 'Old Testament Story'),
      tag('tone', 'prayerful', 'Prayerful'),
      tag('share_intent', 'for_self', 'For yourself'),
    ],
  },
];
