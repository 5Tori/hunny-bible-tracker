import type { PlanTemplateWithRelations } from '@/lib/plans';
import { calculatePlanEstimatedMinutes } from '@/lib/plan-estimates';
import { PLAN_COVER_BIBLE, PLAN_COVER_NT, PLAN_COVER_OT } from '@/lib/mock/fixtures/assets';
import { MOCK_IDS, MOCK_TS } from '@/lib/mock/fixtures/ids';

type PlanItemInput = {
  book_key: string;
  start_chapter: number;
  end_chapter: number;
};

type PlanCatalogOverrides = {
  total_chapters?: number;
  estimated_minutes?: number | null;
};

type PlanProfile = {
  plan_type?: string;
  testament_scope?: string;
  difficulty?: string;
  primary_book_key?: string | null;
  cover_image_url?: string | null;
};

function plan(
  templateKey: keyof typeof MOCK_IDS.plans,
  title: string,
  subtitle: string,
  rank: number,
  items: PlanItemInput[],
  catalog?: PlanCatalogOverrides,
  profile?: PlanProfile,
): PlanTemplateWithRelations {
  const id = MOCK_IDS.plans[templateKey];
  const sectionId = `s-${id.slice(0, 8)}`;
  const itemId = `i-${id.slice(0, 8)}`;
  const sections = [
    {
      id: sectionId,
      plan_template_id: id,
      section_key: 'main',
      title: 'Main',
      description: null,
      order_index: 0,
      created_at: MOCK_TS,
      updated_at: MOCK_TS,
      items: items.map((item, index) => ({
        id: `${itemId}-${index}`,
        section_id: sectionId,
        order_index: index,
        book_key: item.book_key,
        start_chapter: item.start_chapter,
        end_chapter: item.end_chapter,
        created_at: MOCK_TS,
        updated_at: MOCK_TS,
      })),
    },
  ];
  const total_chapters =
    catalog?.total_chapters ??
    items.reduce((sum, item) => sum + (item.end_chapter - item.start_chapter + 1), 0);
  const estimated_minutes =
    catalog?.estimated_minutes !== undefined
      ? catalog.estimated_minutes
      : calculatePlanEstimatedMinutes(sections);

  return {
    id,
    template_key: templateKey,
    title,
    subtitle,
    description: subtitle,
    cover_image_url: profile?.cover_image_url ?? null,
    cover_image_public_id: null,
    plan_type: profile?.plan_type ?? 'story',
    testament_scope: profile?.testament_scope ?? 'old_testament',
    difficulty: profile?.difficulty ?? 'easy',
    estimated_minutes,
    estimated_days: null,
    total_chapters,
    primary_book_key: profile?.primary_book_key ?? null,
    primary_character: null,
    is_builtin: true,
    is_published: true,
    is_archived: false,
    featured_rank: rank,
    browse_visible: true,
    created_at: MOCK_TS,
    updated_at: MOCK_TS,
    tags: [],
    sections,
  };
}

export const mockPlans: PlanTemplateWithRelations[] = [
  plan(
    'old_testament',
    'Old Testament',
    'Genesis through Malachi, one chapter at a time',
    5,
    [{ book_key: 'genesis', start_chapter: 1, end_chapter: 1 }],
    { total_chapters: 929, estimated_minutes: 4 },
    {
      plan_type: 'journey',
      testament_scope: 'old_testament',
      difficulty: 'medium',
      primary_book_key: 'genesis',
      cover_image_url: PLAN_COVER_OT,
    },
  ),
  plan(
    'new_testament',
    'New Testament',
    'Matthew through Revelation, one chapter at a time',
    6,
    [{ book_key: 'matthew', start_chapter: 1, end_chapter: 1 }],
    { total_chapters: 260, estimated_minutes: 4 },
    {
      plan_type: 'journey',
      testament_scope: 'new_testament',
      difficulty: 'medium',
      primary_book_key: 'matthew',
      cover_image_url: PLAN_COVER_NT,
    },
  ),
  plan(
    'bible_in_a_year',
    'Bible in a Year',
    'A long arc for steady readers',
    80,
    [{ book_key: 'genesis', start_chapter: 1, end_chapter: 1 }],
    { total_chapters: 1189, estimated_minutes: 4 },
    {
      plan_type: 'journey',
      testament_scope: 'whole_bible',
      difficulty: 'medium',
      primary_book_key: 'genesis',
      cover_image_url: PLAN_COVER_BIBLE,
    },
  ),
  plan('the_story_of_joseph', 'The Story of Joseph', 'From pit to palace', 10, [
    { book_key: 'genesis', start_chapter: 37, end_chapter: 50 },
  ], undefined, { plan_type: 'story', testament_scope: 'old_testament', primary_book_key: 'genesis' }),
  plan('gospel_of_mark', 'Gospel of Mark', 'Follow Jesus through Mark', 20, [
    { book_key: 'mark', start_chapter: 1, end_chapter: 8 },
    { book_key: 'mark', start_chapter: 9, end_chapter: 16 },
  ], undefined, { plan_type: 'guided_reading', testament_scope: 'new_testament', primary_book_key: 'mark' }),
  plan('psalms_for_anxiety', 'Psalms for Anxiety', 'Comfort when you feel overwhelmed', 30, [
    { book_key: 'psalms', start_chapter: 23, end_chapter: 23 },
    { book_key: 'psalms', start_chapter: 27, end_chapter: 27 },
    { book_key: 'psalms', start_chapter: 46, end_chapter: 46 },
    { book_key: 'psalms', start_chapter: 91, end_chapter: 91 },
    { book_key: 'psalms', start_chapter: 121, end_chapter: 121 },
    { book_key: 'psalms', start_chapter: 131, end_chapter: 131 },
    { book_key: 'psalms', start_chapter: 55, end_chapter: 55 },
    { book_key: 'psalms', start_chapter: 56, end_chapter: 56 },
    { book_key: 'psalms', start_chapter: 57, end_chapter: 57 },
    { book_key: 'psalms', start_chapter: 61, end_chapter: 61 },
    { book_key: 'psalms', start_chapter: 62, end_chapter: 62 },
    { book_key: 'psalms', start_chapter: 64, end_chapter: 64 },
  ], undefined, { plan_type: 'devotional', testament_scope: 'old_testament', primary_book_key: 'psalms' }),
  plan('life_of_david', 'Life of David', 'Shepherd, king, psalmist', 40, [
    { book_key: '1_samuel', start_chapter: 16, end_chapter: 18 },
    { book_key: '1_samuel', start_chapter: 24, end_chapter: 24 },
    { book_key: '2_samuel', start_chapter: 5, end_chapter: 7 },
    { book_key: '2_samuel', start_chapter: 11, end_chapter: 12 },
    { book_key: '2_samuel', start_chapter: 22, end_chapter: 22 },
    { book_key: '1_kings', start_chapter: 2, end_chapter: 2 },
  ], undefined, { plan_type: 'character', testament_scope: 'old_testament' }),
  plan('jonah', 'The Story of Jonah', 'Running, mercy, and second chances', 50, [
    { book_key: 'jonah', start_chapter: 1, end_chapter: 4 },
  ], undefined, { plan_type: 'story', testament_scope: 'old_testament', primary_book_key: 'jonah' }),
  plan('the_story_of_zacchaeus', 'The Story of Zacchaeus', 'A short encounter with Jesus', 60, [
    { book_key: 'luke', start_chapter: 19, end_chapter: 19 },
  ], undefined, { plan_type: 'story', testament_scope: 'new_testament', primary_book_key: 'luke' }),
  plan('samuels_early_life', "Samuel's Early Life", 'Called as a boy', 70, [
    { book_key: '1_samuel', start_chapter: 1, end_chapter: 3 },
  ], undefined, { plan_type: 'story', testament_scope: 'old_testament' }),
];

export function getMockPlanByIdentifier(identifier: string) {
  const key = identifier.trim().toLowerCase();
  return (
    mockPlans.find((item) => item.id === identifier || item.template_key === key) ?? null
  );
}

export function sortMockPlans(sort: 'featured' | 'new' | 'popular') {
  const plans = [...mockPlans];
  if (sort === 'new') {
    return plans.sort(
      (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    );
  }
  if (sort === 'popular') {
    return plans.sort(
      (a, b) => (b.total_chapters ?? 0) - (a.total_chapters ?? 0),
    );
  }
  return plans.sort(
    (a, b) => (a.featured_rank ?? 999) - (b.featured_rank ?? 999),
  );
}
