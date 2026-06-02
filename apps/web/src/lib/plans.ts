import crypto from 'crypto';

import { fetchPlanCatalogRpc, isCatalogRpcAvailable } from '@/lib/catalog-rpc';
import { resolveEstimatedMinutesForSave } from '@/lib/plan-estimates';
import { sql, queryByUuidIds, type SqlLike } from '@/lib/db/postgres';
import { fetchAdminPlanByIdViaRest, fetchAdminPlansViaRest } from '@/lib/plans-admin-rest';
import { assertOnlineForWrites, isOfflineMode } from '@/lib/mock/mode';
import {
  mockGetAdminPlanById,
  mockGetAdminPlans,
  mockGetPublishedPlanByIdentifier,
  mockGetPublishedPlans,
  mockGetPublishedPlansWithRelations,
} from '@/lib/mock/readers';
import { normalizeDifficulty, normalizePlanType, normalizeTestamentScope } from '@/lib/plan-taxonomy';

export interface PlanTemplateBase {
  id: string;
  template_key: string;
  title: string;
  subtitle: string | null;
  description: string | null;
  cover_image_url: string | null;
  cover_image_public_id: string | null;
  plan_type: string | null;
  testament_scope: string | null;
  difficulty: string | null;
  estimated_minutes: number | null;
  estimated_days: number | null;
  total_chapters: number | null;
  primary_book_key: string | null;
  primary_character: string | null;
  is_builtin: boolean;
  is_published: boolean;
  is_archived: boolean;
  featured_rank: number | null;
  browse_visible: boolean;
  created_at: string;
  updated_at: string;
}

export interface PlanItem {
  id: string;
  section_id: string;
  order_index: number;
  book_key: string;
  start_chapter: number;
  end_chapter: number;
  created_at: string;
  updated_at: string;
}

export interface PlanSection {
  id: string;
  plan_template_id: string;
  section_key: string;
  title: string;
  description: string | null;
  order_index: number;
  created_at: string;
  updated_at: string;
  items: PlanItem[];
}

export interface PlanTag {
  id: string;
  key: string;
  name: string;
  type: string | null;
  created_at: string;
}

export interface PlanTemplateWithRelations extends PlanTemplateBase {
  sections: PlanSection[];
  tags: PlanTag[];
}

export interface AdminPlanInput {
  title: string;
  subtitle?: string | null;
  description?: string | null;
  cover_image_url?: string | null;
  cover_image_public_id?: string | null;
  plan_type?: string | null;
  testament_scope?: string | null;
  difficulty?: string | null;
  estimated_minutes?: number | null;
  /** When set, saved as `estimated_minutes` = total ÷ chapter count (rounded). Omit or null for auto. */
  estimated_total_minutes?: number | null;
  estimated_days?: number | null;
  total_chapters?: number | null;
  primary_book_key?: string | null;
  primary_character?: string | null;
  is_published?: boolean;
  is_archived?: boolean;
  featured_rank?: number | null;
  browse_visible?: boolean;
  sections: Array<{
    section_key?: string | null;
    title: string;
    description?: string | null;
    order_index: number;
    items: Array<{ book_key: string; start_chapter: number; end_chapter: number; order_index: number }>;
  }>;
  tags?: string[];
}

export class PlanValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'PlanValidationError';
  }
}

function emptyToNull(value?: string | null) {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

function normalizeNullableNumber(value?: number | null) {
  return typeof value === 'number' && Number.isFinite(value) ? Math.floor(value) : null;
}

function normalizeFeaturedRank(value?: number | string | null) {
  if (value === undefined || value === null || value === '') return null;
  const n = typeof value === 'string' ? Number(value) : value;
  if (typeof n !== 'number' || !Number.isFinite(n)) return null;
  const floor = Math.floor(n);
  if (floor < 0) return null;
  return floor;
}

function slugify(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function parseTagKey(name: string) {
  return slugify(name) || `tag_${Date.now()}`;
}

function normalizeTags(tags?: string[]) {
  const seen = new Set<string>();
  return (tags ?? [])
    .map((tag) => tag.trim())
    .filter(Boolean)
    .map((name) => ({ key: parseTagKey(name), name, type: null as string | null }))
    .filter((tag) => {
      if (seen.has(tag.key)) return false;
      seen.add(tag.key);
      return true;
    });
}

function normalizeInput(input: AdminPlanInput): AdminPlanInput {
  const title = input.title.trim();
  if (!title) {
    throw new PlanValidationError('Plan title is required.');
  }

  const planType = normalizePlanType(String(input.plan_type ?? ''));
  if (!planType) {
    throw new PlanValidationError('Plan type is required. Choose one of the standard types.');
  }

  if (!input.sections?.length) {
    throw new PlanValidationError('At least one section is required.');
  }

  const sections = input.sections.map((section, sectionIndex) => {
    const sectionTitle = section.title.trim();
    if (!sectionTitle) {
      throw new PlanValidationError(`Section ${sectionIndex + 1} needs a title.`);
    }
    if (!section.items?.length) {
      throw new PlanValidationError(`Section ${sectionIndex + 1} needs at least one chapter range.`);
    }

    const items = section.items.map((item, itemIndex) => {
      const bookKey = item.book_key.trim().toLowerCase().replace(/\s+/g, '_');
      const start = Math.max(1, Math.floor(Number(item.start_chapter) || 1));
      const end = Math.max(1, Math.floor(Number(item.end_chapter) || start));

      if (!bookKey) {
        throw new PlanValidationError(`Section ${sectionIndex + 1}, range ${itemIndex + 1} needs a book key.`);
      }
      if (end < start) {
        throw new PlanValidationError(`Section ${sectionIndex + 1}, range ${itemIndex + 1} has an invalid chapter range.`);
      }

      return {
        book_key: bookKey,
        start_chapter: start,
        end_chapter: end,
        order_index: item.order_index ?? itemIndex,
      };
    });

    return {
      section_key: slugify(section.section_key || sectionTitle) || `section_${sectionIndex + 1}`,
      title: sectionTitle,
      description: emptyToNull(section.description),
      order_index: section.order_index ?? sectionIndex,
      items,
    };
  });

  return {
    ...input,
    title,
    subtitle: emptyToNull(input.subtitle),
    description: emptyToNull(input.description),
    cover_image_url: emptyToNull(input.cover_image_url),
    cover_image_public_id: emptyToNull(input.cover_image_public_id),
    plan_type: planType,
    testament_scope: emptyToNull(normalizeTestamentScope(String(input.testament_scope ?? ''))),
    difficulty: emptyToNull(normalizeDifficulty(String(input.difficulty ?? ''))),
    estimated_minutes: resolveEstimatedMinutesForSave(
      input.estimated_total_minutes,
      sections,
      calculateTotalChapters(sections),
    ),
    estimated_days: normalizeNullableNumber(input.estimated_days),
    total_chapters: calculateTotalChapters(sections),
    primary_book_key: emptyToNull(input.primary_book_key),
    primary_character: emptyToNull(input.primary_character),
    is_archived: Boolean(input.is_archived),
    is_published: Boolean(input.is_published) && !Boolean(input.is_archived),
    featured_rank: normalizeFeaturedRank(input.featured_rank as number | string | null | undefined),
    browse_visible: input.browse_visible !== false,
    sections,
    tags: normalizeTags(input.tags).map((tag) => tag.name),
  };
}

function calculateTotalChapters(sections: AdminPlanInput['sections']) {
  return sections.reduce((sum, section) => {
    return sum + section.items.reduce((sectionSum, item) => sectionSum + (item.end_chapter - item.start_chapter + 1), 0);
  }, 0);
}

function hydratePlan(
  plan: PlanTemplateBase,
  sections: Array<Omit<PlanSection, 'items'>>,
  items: PlanItem[],
  tags: PlanTag[],
): PlanTemplateWithRelations {
  return {
    ...plan,
    sections: sections.map((section) => ({
      ...section,
      items: items.filter((item) => item.section_id === section.id),
    })),
    tags,
  };
}

async function getPlanRelationsForPlans(
  sqlExecutor: SqlLike,
  planIds: string[],
) {
  if (planIds.length === 0) {
    return {
      sectionsByPlan: new Map<string, Array<Omit<PlanSection, 'items'>>>(),
      itemsBySection: new Map<string, PlanItem[]>(),
      tagsByPlan: new Map<string, PlanTag[]>(),
    };
  }

  if (planIds.length === 1) {
    const planId = planIds[0]!;
    const sections = (await sqlExecutor`
      select * from plan_template_sections
      where plan_template_id = ${planId}
      order by order_index asc, created_at asc
    `) as Array<Omit<PlanSection, 'items'>>;

    const items = (await sqlExecutor`
      select * from plan_template_items
      where section_id in (
        select id from plan_template_sections
        where plan_template_id = ${planId}
      )
      order by section_id asc, order_index asc, created_at asc
    `) as PlanItem[];

    const tagRows = (await sqlExecutor`
      select t.*, ptt.plan_template_id
      from plan_tags t
      join plan_template_tags ptt on ptt.tag_id = t.id
      where ptt.plan_template_id = ${planId}
      order by t.name asc
    `) as Array<PlanTag & { plan_template_id: string }>;

    const sectionsByPlan = new Map([[planId, sections]]);
    const itemsBySection = new Map<string, PlanItem[]>();
    for (const item of items) {
      const bucket = itemsBySection.get(item.section_id) ?? [];
      bucket.push(item);
      itemsBySection.set(item.section_id, bucket);
    }
    const tagsByPlan = new Map<string, PlanTag[]>([
      [planId, tagRows.map(({ plan_template_id: _id, ...tag }) => tag)],
    ]);

    return { sectionsByPlan, itemsBySection, tagsByPlan };
  }

  const sections = await queryByUuidIds<Omit<PlanSection, 'items'>>(
    planIds,
    (id) => sqlExecutor`
      select * from plan_template_sections
      where plan_template_id = ${id}
      order by order_index asc, created_at asc
    `,
    (pg, ids) => pg`
      select * from plan_template_sections
      where plan_template_id in ${pg(ids)}
      order by plan_template_id asc, order_index asc, created_at asc
    `,
  );

  const sectionIds = sections.map((section) => section.id);
  const items = await queryByUuidIds<PlanItem>(
    sectionIds,
    (id) => sqlExecutor`
      select * from plan_template_items
      where section_id = ${id}
      order by section_id asc, order_index asc, created_at asc
    `,
    (pg, ids) => pg`
      select * from plan_template_items
      where section_id in ${pg(ids)}
      order by section_id asc, order_index asc, created_at asc
    `,
  );

  const tagRows = await queryByUuidIds<PlanTag & { plan_template_id: string }>(
    planIds,
    (id) => sqlExecutor`
      select t.*, ptt.plan_template_id
      from plan_tags t
      join plan_template_tags ptt on ptt.tag_id = t.id
      where ptt.plan_template_id = ${id}
      order by t.name asc
    `,
    (pg, ids) => pg`
      select t.*, ptt.plan_template_id
      from plan_tags t
      join plan_template_tags ptt on ptt.tag_id = t.id
      where ptt.plan_template_id in ${pg(ids)}
      order by ptt.plan_template_id asc, t.name asc
    `,
  );

  const sectionsByPlan = new Map<string, Array<Omit<PlanSection, 'items'>>>();
  const itemsBySection = new Map<string, PlanItem[]>();
  const tagsByPlan = new Map<string, PlanTag[]>();

  for (const planId of planIds) {
    sectionsByPlan.set(planId, []);
    tagsByPlan.set(planId, []);
  }

  for (const section of sections) {
    const bucket = sectionsByPlan.get(section.plan_template_id) ?? [];
    bucket.push(section);
    sectionsByPlan.set(section.plan_template_id, bucket);
  }

  for (const item of items) {
    const bucket = itemsBySection.get(item.section_id) ?? [];
    bucket.push(item);
    itemsBySection.set(item.section_id, bucket);
  }

  for (const row of tagRows) {
    const bucket = tagsByPlan.get(row.plan_template_id) ?? [];
    const { plan_template_id: _planTemplateId, ...tag } = row;
    bucket.push(tag);
    tagsByPlan.set(row.plan_template_id, bucket);
  }

  return { sectionsByPlan, itemsBySection, tagsByPlan };
}

async function getPlanRelations(sqlExecutor: SqlLike, planId: string) {
  const { sectionsByPlan, itemsBySection, tagsByPlan } = await getPlanRelationsForPlans(
    sqlExecutor,
    [planId],
  );
  const sections = sectionsByPlan.get(planId) ?? [];
  const items = sections.flatMap((section) => itemsBySection.get(section.id) ?? []);
  const tags = tagsByPlan.get(planId) ?? [];
  return { sections, items, tags };
}

export type PublishedPlanSortMode = 'featured' | 'new' | 'popular';

export function parsePublishedPlanSort(value: string | null | undefined): PublishedPlanSortMode {
  if (value === 'new') return 'new';
  if (value === 'popular') return 'popular';
  return 'featured';
}

export async function getPublishedPlans(sort: PublishedPlanSortMode = 'featured') {
  if (isOfflineMode()) {
    return mockGetPublishedPlans(sort);
  }

  if (isCatalogRpcAvailable()) {
    return fetchPlanCatalogRpc(sort);
  }

  if (sort === 'new') {
    return (await sql`
      select * from plan_templates
      where is_published = true and is_archived = false and browse_visible = true
      order by created_at desc
    `) as PlanTemplateBase[];
  }
  if (sort === 'popular') {
    return (await sql`
      select * from plan_templates
      where is_published = true and is_archived = false and browse_visible = true
      order by total_chapters desc nulls last, updated_at desc
    `) as PlanTemplateBase[];
  }
  return (await sql`
    select * from plan_templates
    where is_published = true and is_archived = false and browse_visible = true
    order by featured_rank asc nulls last, updated_at desc
  `) as PlanTemplateBase[];
}

export async function getPublishedPlansWithRelations(sort: PublishedPlanSortMode = 'featured') {
  if (isOfflineMode()) {
    return mockGetPublishedPlansWithRelations(sort);
  }

  const plans = await getPublishedPlans(sort);
  if (plans.length === 0) {
    return [];
  }

  const planIds = plans.map((plan) => plan.id);
  const { sectionsByPlan, itemsBySection, tagsByPlan } = await getPlanRelationsForPlans(
    sql,
    planIds,
  );

  return plans.map((plan) => {
    const sections = sectionsByPlan.get(plan.id) ?? [];
    const items = sections.flatMap((section) => itemsBySection.get(section.id) ?? []);
    const tags = tagsByPlan.get(plan.id) ?? [];
    return hydratePlan(plan, sections, items, tags);
  });
}

export async function getPublishedPlanByIdentifier(identifier: string) {
  if (isOfflineMode()) {
    return mockGetPublishedPlanByIdentifier(identifier);
  }

  const planRows = (await sql`
    select * from plan_templates
    where is_published = true and is_archived = false and browse_visible = true and (id::text = ${identifier} or template_key = ${identifier})
    limit 1
  `) as PlanTemplateBase[];
  const plan = planRows[0];
  if (!plan) return null;
  const { sections, items, tags } = await getPlanRelations(sql, plan.id);
  return hydratePlan(plan, sections, items, tags);
}

export async function getAdminPlans() {
  if (isOfflineMode()) {
    return mockGetAdminPlans();
  }

  return fetchAdminPlansViaRest();
}

export async function getAdminPlanById(id: string) {
  if (isOfflineMode()) {
    return mockGetAdminPlanById(id);
  }

  return fetchAdminPlanByIdViaRest(id);
}

async function generateTemplateKey(title: string) {
  const baseKey = slugify(title) || `plan_${Date.now()}`;
  const existing = (await sql`
    select template_key from plan_templates where template_key like ${`${baseKey}%`}
  `) as Array<{ template_key: string }>;
  const existingKeys = new Set(existing.map((row) => row.template_key));
  if (!existingKeys.has(baseKey)) return baseKey;
  let suffix = 1;
  while (existingKeys.has(`${baseKey}_${suffix}`)) suffix += 1;
  return `${baseKey}_${suffix}`;
}

function buildSectionAndItemQueries(planId: string, sections: AdminPlanInput['sections'], txn: SqlLike) {
  const queries: unknown[] = [];

  sections.forEach((section) => {
    const sectionId = crypto.randomUUID();
    queries.push(txn`
      insert into plan_template_sections (
        id,
        plan_template_id,
        section_key,
        title,
        description,
        order_index,
        created_at,
        updated_at
      ) values (
        ${sectionId},
        ${planId},
        ${section.section_key},
        ${section.title},
        ${section.description ?? null},
        ${section.order_index},
        now(),
        now()
      )
    `);

    section.items.forEach((item) => {
      queries.push(txn`
        insert into plan_template_items (
          id,
          section_id,
          order_index,
          book_key,
          start_chapter,
          end_chapter,
          created_at,
          updated_at
        ) values (
          ${crypto.randomUUID()},
          ${sectionId},
          ${item.order_index},
          ${item.book_key},
          ${item.start_chapter},
          ${item.end_chapter},
          now(),
          now()
        )
      `);
    });
  });

  return queries;
}

function buildTagQueries(planId: string, tags: string[] | undefined, txn: SqlLike) {
  const normalizedTags = normalizeTags(tags);
  const queries: unknown[] = [];

  normalizedTags.forEach((tag) => {
    queries.push(txn`
      insert into plan_tags (key, name, type, created_at)
      values (${tag.key}, ${tag.name}, ${tag.type}, now())
      on conflict (key) do update set name = excluded.name
    `);
    queries.push(txn`
      insert into plan_template_tags (plan_template_id, tag_id)
      select ${planId}, id from plan_tags where key = ${tag.key}
      on conflict (plan_template_id, tag_id) do nothing
    `);
  });

  return queries;
}

export async function createAdminPlan(rawInput: AdminPlanInput) {
  assertOnlineForWrites();
  const input = normalizeInput(rawInput);
  const planId = crypto.randomUUID();
  const totalChapters = calculateTotalChapters(input.sections);
  const templateKey = await generateTemplateKey(input.title);

  await sql.transaction((txn: SqlLike) => [
    txn`
      insert into plan_templates (
        id,
        template_key,
        title,
        subtitle,
        description,
        cover_image_url,
        cover_image_public_id,
        plan_type,
        testament_scope,
        difficulty,
        estimated_minutes,
        estimated_days,
        total_chapters,
        primary_book_key,
        primary_character,
        is_published,
        is_archived,
        featured_rank,
        browse_visible,
        created_at,
        updated_at
      ) values (
        ${planId},
        ${templateKey},
        ${input.title},
        ${input.subtitle ?? null},
        ${input.description ?? null},
        ${input.cover_image_url ?? null},
        ${input.cover_image_public_id ?? null},
        ${input.plan_type ?? null},
        ${input.testament_scope ?? null},
        ${input.difficulty ?? null},
        ${input.estimated_minutes ?? null},
        ${input.estimated_days ?? null},
        ${totalChapters},
        ${input.primary_book_key ?? null},
        ${input.primary_character ?? null},
        ${Boolean(input.is_published)},
        ${Boolean(input.is_archived)},
        ${input.featured_rank ?? null},
        ${Boolean(input.browse_visible)},
        now(),
        now()
      )
    `,
    ...buildSectionAndItemQueries(planId, input.sections, txn),
    ...buildTagQueries(planId, input.tags, txn),
  ] as any);

  return await getAdminPlanById(planId);
}

export async function updateAdminPlan(id: string, rawInput: AdminPlanInput) {
  assertOnlineForWrites();
  const input = normalizeInput(rawInput);
  const totalChapters = calculateTotalChapters(input.sections);

  await sql.transaction((txn: SqlLike) => [
    txn`
      update plan_templates set
        title = ${input.title},
        subtitle = ${input.subtitle ?? null},
        short_description = null,
        description = ${input.description ?? null},
        cover_image_url = ${input.cover_image_url ?? null},
        cover_image_public_id = ${input.cover_image_public_id ?? null},
        plan_type = ${input.plan_type ?? null},
        testament_scope = ${input.testament_scope ?? null},
        difficulty = ${input.difficulty ?? null},
        estimated_minutes = ${input.estimated_minutes ?? null},
        estimated_days = ${input.estimated_days ?? null},
        total_chapters = ${totalChapters},
        primary_book_key = ${input.primary_book_key ?? null},
        primary_character = ${input.primary_character ?? null},
        is_published = ${Boolean(input.is_published)},
        is_archived = ${Boolean(input.is_archived)},
        featured_rank = ${input.featured_rank ?? null},
        browse_visible = ${Boolean(input.browse_visible)},
        updated_at = now()
      where id::text = ${id}
    `,
    txn`delete from plan_template_sections where plan_template_id::text = ${id}`,
    txn`delete from plan_template_tags where plan_template_id::text = ${id}`,
    ...buildSectionAndItemQueries(id, input.sections, txn),
    ...buildTagQueries(id, input.tags, txn),
  ] as any);

  return await getAdminPlanById(id);
}

type CatalogPatch = { is_published?: boolean; is_archived?: boolean };

export async function patchAdminPlanCatalog(id: string, patch: CatalogPatch) {
  assertOnlineForWrites();
  if (typeof patch.is_published !== 'boolean' && typeof patch.is_archived !== 'boolean') {
    throw new PlanValidationError('Provide is_published and/or is_archived.');
  }

  const row = (
    (await sql`
    select is_published, is_archived from plan_templates where id::text = ${id} limit 1
  `) as Array<{ is_published: boolean; is_archived: boolean }>
  )[0];
  if (!row) return null;

  let nextPublished = row.is_published;
  let nextArchived = row.is_archived;

  if (typeof patch.is_archived === 'boolean') {
    nextArchived = patch.is_archived;
    if (nextArchived) nextPublished = false;
  }

  if (typeof patch.is_published === 'boolean') {
    if (nextArchived && patch.is_published) {
      throw new PlanValidationError('Unarchive the plan before publishing.');
    }
    nextPublished = patch.is_published;
  }

  const updated = (await sql`
    update plan_templates set
      is_published = ${nextPublished},
      is_archived = ${nextArchived},
      updated_at = now()
    where id::text = ${id}
    returning *
  `) as PlanTemplateBase[];
  return updated[0] ?? null;
}

export async function deleteAdminPlan(id: string): Promise<boolean> {
  assertOnlineForWrites();
  const row = (
    (await sql`
    select is_builtin from plan_templates where id::text = ${id} limit 1
  `) as Array<{ is_builtin: boolean }>
  )[0];
  if (!row) return false;
  if (row.is_builtin) {
    throw new PlanValidationError('Built-in plans cannot be deleted.');
  }

  const deleted = (await sql`
    delete from plan_templates where id::text = ${id} returning id
  `) as Array<{ id: string }>;
  return deleted.length > 0;
}
