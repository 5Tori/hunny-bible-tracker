/**
 * Import top-100 message card seeds from Downloads export.
 *
 *   node apps/web/scripts/import-message-card-seeds.mjs           # no API — empty verseText
 *   node apps/web/scripts/import-message-card-seeds.mjs --fetch   # try WEB/KJV via bible-api.com
 *
 * On rate limit or fetch errors, verseText stays empty for you to fill later.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const sourcePath = path.join(process.env.HOME ?? '', 'Downloads/top-100-message-card-seeds.ts');
const outSeedsPath = path.join(__dirname, '../src/lib/mock/fixtures/imported-message-seeds.ts');
const outIdsPath = path.join(__dirname, '../src/lib/mock/fixtures/ids.ts');

const FETCH = process.argv.includes('--fetch');
const EXISTING_SLUGS = new Set(['john-1-1-3', 'psalm-19-9-10', '1-kings-3-9']);
const EXISTING_IDS = {
  author: 'a1000000-0000-4000-8000-000000000001',
  todayToday: 't1000000-0000-4000-8000-000000000001',
  plans: {
    bible_in_a_year: 'p1000001-0000-4000-8000-000000000001',
    the_story_of_joseph: 'p1000002-0000-4000-8000-000000000002',
    gospel_of_mark: 'p1000003-0000-4000-8000-000000000003',
    psalms_for_anxiety: 'p1000004-0000-4000-8000-000000000004',
    life_of_david: 'p1000005-0000-4000-8000-000000000005',
    jonah: 'p1000006-0000-4000-8000-000000000006',
    the_story_of_zacchaeus: 'p1000007-0000-4000-8000-000000000007',
    samuels_early_life: 'p1000008-0000-4000-8000-000000000008',
  },
};

/** Maps export vocabulary aliases to `message-taxonomy` primary category keys. */
const CATEGORY_MAP = {
  love_grace: 'grace_forgiveness',
  grief_comfort: 'love_belonging',
  prayer_faith: 'hope_waiting',
  forgiveness_mercy: 'grace_forgiveness',
};

const DEFAULT_SITUATION = {
  peace_anxiety: 'future_uncertainty',
  hope_waiting: 'waiting_season',
  strength_courage: 'facing_challenge',
  wisdom_guidance: 'major_decision',
  love_belonging: 'feeling_lonely',
  grace_forgiveness: 'guilt_shame',
  joy_gratitude: 'morning_reset',
  identity_purpose: 'life_transition',
};

const VALID_THEMES = new Set([
  'trust', 'peace', 'hope', 'prayer', 'waiting', 'courage', 'wisdom', 'guidance',
  'grace', 'forgiveness', 'comfort', 'strength', 'joy', 'gratitude', 'identity', 'purpose', 'faith', 'rest',
  'presence', 'love',
]);

const THEME_MAP = {
  salvation: 'grace',
  love: 'grace',
  perseverance: 'strength',
  anxiety: 'peace',
  care: 'comfort',
  healing: 'comfort',
  mercy: 'grace',
  renewal: 'hope',
  mission: 'purpose',
  obedience: 'faith',
  worship: 'gratitude',
  protection: 'comfort',
  provision: 'trust',
  righteousness: 'faith',
  kindness: 'grace',
  patience: 'waiting',
  goodness: 'grace',
  self_control: 'strength',
};

const VALID_TONES = new Set([
  'gentle', 'comforting', 'encouraging', 'reflective', 'prayerful', 'assuring', 'uplifting',
]);

const TONE_MAP = {
  comfort: 'comforting',
  encouragement: 'encouraging',
  reflection: 'reflective',
  gratitude: 'uplifting',
  challenge: 'encouraging',
  assurance: 'assuring',
};

const SHARE_INTENT_MAP = {
  encourage_friend: 'send_encouragement',
  social_caption: 'for_self',
};

const VALID_PLANS = {
  psalms_for_anxiety: 'Read Psalms for Anxiety',
  gospel_of_mark: 'Continue in a Gospel plan',
  life_of_david: 'Read Life of David',
  the_story_of_joseph: 'Read the Story of Joseph',
  jonah: 'Read Jonah',
  samuels_early_life: "Read Samuel's Early Life",
  the_story_of_zacchaeus: 'Read Zacchaeus',
  bible_in_a_year: 'Explore Bible in a Year',
};

function tag(type, key, name, sortOrder = 10) {
  return { type, key, name, sortOrder };
}

function loadSourceSeeds() {
  const raw = fs.readFileSync(sourcePath, 'utf8');
  const body = raw.replace(/^const messageSeeds[^=]*=\s*/, 'return ');
  const fn = new Function('tag', body);
  return fn(tag);
}

function mapCategory(raw) {
  if (DEFAULT_SITUATION[raw]) return raw;
  return CATEGORY_MAP[raw] ?? 'hope_waiting';
}

function inferBibleContext(verse) {
  const v = verse.toLowerCase();
  if (v.startsWith('psalm')) return 'psalms';
  if (v.startsWith('proverbs')) return 'proverbs';
  if (/^(matthew|mark|luke|john)\b/.test(v)) return 'gospels';
  if (/^(romans|corinthians|galatians|ephesians|philippians|colossians|thessalonians|timothy|titus|philemon)\b/.test(v)) {
    return 'paul_letters';
  }
  if (/^(isaiah|jeremiah|lamentations|ezekiel|daniel|hosea|joel|amos|obadiah|jonah|micah|nahum|habakkuk|zephaniah|haggai|zechariah|malachi)\b/.test(v)) {
    return 'prophets';
  }
  if (/^(genesis|exodus|leviticus|numbers|deuteronomy|joshua|judges|ruth|samuel|kings|chronicles|ezra|nehemiah|esther|job)\b/.test(v)) {
    return 'old_testament_story';
  }
  if (/^(hebrews|james|peter|jude|revelation|acts)\b/.test(v)) return 'paul_letters';
  return 'old_testament_story';
}

function inferPlanLink(verse, sourceKey) {
  if (sourceKey && VALID_PLANS[sourceKey]) {
    return { templateKey: sourceKey, ctaLabel: VALID_PLANS[sourceKey] };
  }
  const v = verse.toLowerCase();
  if (v.startsWith('psalm')) {
    return { templateKey: 'psalms_for_anxiety', ctaLabel: VALID_PLANS.psalms_for_anxiety };
  }
  if (/^(matthew|mark|luke|john)\b/.test(v)) {
    return { templateKey: 'gospel_of_mark', ctaLabel: VALID_PLANS.gospel_of_mark };
  }
  if (/\b1\s+samuel\b|\b2\s+samuel\b|\bdavid\b/.test(v)) {
    return { templateKey: 'life_of_david', ctaLabel: VALID_PLANS.life_of_david };
  }
  if (/\bjoseph\b/.test(v)) {
    return { templateKey: 'the_story_of_joseph', ctaLabel: VALID_PLANS.the_story_of_joseph };
  }
  if (/\bjonah\b/.test(v)) {
    return { templateKey: 'jonah', ctaLabel: VALID_PLANS.jonah };
  }
  if (/\bsamuel\b/.test(v)) {
    return { templateKey: 'samuels_early_life', ctaLabel: VALID_PLANS.samuels_early_life };
  }
  return null;
}

function buildTags(seed, category) {
  const validSituation = DEFAULT_SITUATION[category];

  const rawThemes = (seed.tags ?? [])
    .filter((t) => t.type === 'theme')
    .map((t) => (VALID_THEMES.has(t.key) ? t.key : THEME_MAP[t.key]))
    .filter(Boolean);
  const themes = [...new Set(rawThemes.length ? rawThemes : ['faith'])].slice(0, 2);

  const rawTone = seed.tags?.find((t) => t.type === 'tone')?.key ?? 'reflective';
  const toneKey = VALID_TONES.has(rawTone) ? rawTone : (TONE_MAP[rawTone] ?? 'reflective');

  const shareRaw =
    seed.metadata?.shareIntents?.[0] ??
    seed.tags?.find((t) => t.type === 'share_intent')?.key ??
    'for_self';
  const shareKey =
    SHARE_INTENT_MAP[shareRaw] ??
    (['for_self', 'send_encouragement', 'send_comfort', 'morning_share', 'night_share', 'thank_you', 'celebration'].includes(shareRaw)
      ? shareRaw
      : 'for_self');

  const bibleContext = inferBibleContext(seed.verse);

  const labels = {
    peace_anxiety: 'Peace & Anxiety',
    hope_waiting: 'Hope & Waiting',
    strength_courage: 'Strength & Courage',
    wisdom_guidance: 'Wisdom & Guidance',
    love_belonging: 'Love & Belonging',
    grace_forgiveness: 'Grace & Forgiveness',
    joy_gratitude: 'Joy & Gratitude',
    identity_purpose: 'Identity & Purpose',
  };

  const situationLabels = {
    future_uncertainty: 'When the future feels uncertain',
    major_decision: 'Before a big decision',
    feeling_overwhelmed: 'When you feel overwhelmed',
    waiting_season: 'In a waiting season',
    facing_challenge: 'Facing a challenge',
    feeling_lonely: 'When you feel alone',
    guilt_shame: 'When guilt or shame feels heavy',
    morning_reset: 'At the start of the day',
    life_transition: 'In a life transition',
  };

  const themeLabels = {
    trust: 'Trust', peace: 'Peace', hope: 'Hope', prayer: 'Prayer', waiting: 'Waiting',
    courage: 'Courage', wisdom: 'Wisdom', guidance: 'Guidance', grace: 'Grace',
    forgiveness: 'Forgiveness', comfort: 'Comfort', strength: 'Strength', joy: 'Joy',
    gratitude: 'Gratitude', identity: 'Identity', purpose: 'Purpose', faith: 'Faith', rest: 'Rest',
    presence: 'Presence', love: 'Love',
  };

  const toneLabels = {
    gentle: 'Gentle', comforting: 'Comforting', encouraging: 'Encouraging', reflective: 'Reflective',
    prayerful: 'Prayerful', assuring: 'Assuring', uplifting: 'Uplifting',
  };

  const shareLabels = {
    for_self: 'For yourself', send_encouragement: 'Send encouragement', send_comfort: 'Send comfort',
    morning_share: 'Morning share', night_share: 'Night share', thank_you: 'Say thank you', celebration: 'Share joy',
  };

  const bibleLabels = {
    psalms: 'Psalms', proverbs: 'Proverbs', gospels: 'Gospels', paul_letters: "Paul's Letters",
    prophets: 'Prophets', old_testament_story: 'Old Testament Story', jesus_words: 'Words of Jesus',
  };

  return [
    tag('category', category, labels[category] ?? category),
    tag('situation', validSituation, situationLabels[validSituation] ?? validSituation),
    ...themes.map((key) => tag('theme', key, themeLabels[key] ?? key)),
    tag('bible_context', bibleContext, bibleLabels[bibleContext] ?? bibleContext),
    tag('tone', toneKey, toneLabels[toneKey] ?? toneKey),
    tag('share_intent', shareKey, shareLabels[shareKey] ?? shareKey),
  ];
}

async function fetchVerseTextOnce(verse, translation) {
  const ref = encodeURIComponent(verse.replace(/\s+/g, ' ').trim());
  const res = await fetch(`https://bible-api.com/${ref}?translation=${translation}`, {
    signal: AbortSignal.timeout(10_000),
  });
  if (res.status === 429 || !res.ok) return null;
  const data = await res.json();
  if (typeof data.text === 'string') {
    return data.text.replace(/\n/g, ' ').replace(/\s+/g, ' ').trim();
  }
  if (Array.isArray(data.verses)) {
    return data.verses.map((v) => v.text.trim()).join(' ');
  }
  return null;
}

async function resolveVerseText(verse, index) {
  const defaultVersion = index % 2 === 0 ? 'WEB' : 'KJV';
  if (!FETCH) {
    return { text: '', version: defaultVersion };
  }

  for (const [translation, version] of [
    ['web', 'WEB'],
    ['kjv', 'KJV'],
  ]) {
    const text = await fetchVerseTextOnce(verse, translation);
    if (text) return { text, version };
    await new Promise((r) => setTimeout(r, 400));
  }

  return { text: '', version: defaultVersion };
}

function esc(str) {
  return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, ' ');
}

function serializeSeed(seed) {
  const lines = [];
  lines.push('  {');
  lines.push(`    slug: '${seed.slug}',`);
  lines.push(`    verse: '${esc(seed.verse)}',`);
  lines.push(`    bibleVersion: '${seed.bibleVersion}',`);
  if (seed.verseText) {
    lines.push(`    verseText: '${esc(seed.verseText)}',`);
  } else {
    lines.push(`    verseText: '',`);
  }
  lines.push(`    featuredRank: ${seed.featuredRank},`);
  lines.push('    metadata: {');
  lines.push(`      primaryCategory: '${seed.metadata.primaryCategory}',`);
  lines.push(`      context: '${esc(seed.metadata.context)}',`);
  if (seed.metadata.hint) lines.push(`      hint: '${esc(seed.metadata.hint)}',`);
  if (seed.metadata.searchAliases?.length) {
    lines.push(`      searchAliases: [${seed.metadata.searchAliases.map((a) => `'${esc(a)}'`).join(', ')}],`);
  }
  lines.push('    },');
  lines.push('    tags: [');
  for (const t of seed.tags) {
    lines.push(`      tag('${t.type}', '${t.key}', '${esc(t.name)}'),`);
  }
  lines.push('    ],');
  if (seed.planLinks?.length) {
    lines.push('    planLinks: [{');
    lines.push(`      templateKey: '${seed.planLinks[0].templateKey}',`);
    lines.push(`      ctaLabel: '${esc(seed.planLinks[0].ctaLabel)}',`);
    lines.push('    }],');
  }
  lines.push('  },');
  return lines.join('\n');
}

async function main() {
  const sourceSeeds = loadSourceSeeds();
  const imported = [];
  let rank = 40;
  let idIndex = 4;

  const contentIds = {
    'john-1-1-3': 'c1000001-0000-4000-8000-000000000001',
    'psalm-19-9-10': 'c1000002-0000-4000-8000-000000000002',
    '1-kings-3-9': 'c1000003-0000-4000-8000-000000000003',
  };

  for (let i = 0; i < sourceSeeds.length; i++) {
    const raw = sourceSeeds[i];
    if (EXISTING_SLUGS.has(raw.slug)) continue;

    const category = mapCategory(raw.metadata.primaryCategory);
    const sourcePlanKey = raw.planLinks?.[0]?.templateKey;
    const planLink = inferPlanLink(
      raw.verse,
      sourcePlanKey === 'psalms_for_anxiety' ? 'psalms_for_anxiety' : null,
    );

    if (FETCH) process.stderr.write(`Fetching ${raw.verse}...\n`);
    const { text, version } = await resolveVerseText(raw.verse, i);

    imported.push({
      slug: raw.slug,
      verse: raw.verse,
      bibleVersion: version,
      verseText: text,
      featuredRank: rank,
      metadata: {
        primaryCategory: category,
        context: raw.metadata.context,
        hint: raw.metadata.hint,
        searchAliases: raw.metadata.searchAliases ?? [],
      },
      tags: buildTags(raw, category),
      planLinks: planLink ? [planLink] : undefined,
    });

    contentIds[raw.slug] =
      `c100${String(idIndex).padStart(4, '0')}-0000-4000-8000-00000000${String(idIndex).padStart(4, '0')}`;
    rank += 10;
    idIndex += 1;

    if (FETCH) await new Promise((r) => setTimeout(r, 500));
  }

  const seedsBody = imported.map((s) => serializeSeed(s)).join('\n');

  fs.writeFileSync(
    outSeedsPath,
    `/** Auto-generated by scripts/import-message-card-seeds.mjs — edit verseText by hand or re-run with --fetch. */\nimport {\n  messageCardTag as tag,\n  type MessageCardSeed,\n} from '@/lib/mock/fixtures/message-card-seed-builders';\n\nexport const importedMessageSeeds = [\n${seedsBody}\n] satisfies MessageCardSeed[];\n`,
  );

  const idLines = Object.entries(contentIds)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([slug, id]) => `    '${slug}': '${id}',`);

  fs.writeFileSync(
    outIdsPath,
    `/** Stable mock UUIDs for local fixtures (deterministic across runs). */\nexport const MOCK_IDS = {\n  author: '${EXISTING_IDS.author}',\n  todayToday: '${EXISTING_IDS.todayToday}',\n  plans: {\n    bible_in_a_year: '${EXISTING_IDS.plans.bible_in_a_year}',\n    the_story_of_joseph: '${EXISTING_IDS.plans.the_story_of_joseph}',\n    gospel_of_mark: '${EXISTING_IDS.plans.gospel_of_mark}',\n    psalms_for_anxiety: '${EXISTING_IDS.plans.psalms_for_anxiety}',\n    life_of_david: '${EXISTING_IDS.plans.life_of_david}',\n    jonah: '${EXISTING_IDS.plans.jonah}',\n    the_story_of_zacchaeus: '${EXISTING_IDS.plans.the_story_of_zacchaeus}',\n    samuels_early_life: '${EXISTING_IDS.plans.samuels_early_life}',\n  },\n  contents: {\n${idLines.join('\n')}\n  },\n} as const;\n\nexport const MOCK_TS = '2026-05-01T12:00:00.000Z';\n`,
  );

  const filled = imported.filter((s) => s.verseText).length;
  console.error(
    `Imported ${imported.length} seeds (${EXISTING_SLUGS.size} hand-picked skipped). Verse text filled: ${filled}/${imported.length}.`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
