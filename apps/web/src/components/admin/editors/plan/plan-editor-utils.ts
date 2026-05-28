import type { AdminPlanInput, PlanTemplateWithRelations } from '@/lib/plans';
import { clampPlanItemChapters } from '@/lib/bible-books';
import {
  normalizeDifficulty,
  normalizePlanType,
  normalizeTestamentScope,
} from '@/lib/plan-taxonomy';

export const emptyPlan: AdminPlanInput = {
  title: '',
  subtitle: '',
  short_description: '',
  description: '',
  cover_image_url: '',
  cover_image_public_id: '',
  plan_type: '',
  testament_scope: 'whole_bible',
  difficulty: '',
  estimated_minutes: null,
  estimated_days: null,
  total_chapters: null,
  primary_book_key: '',
  primary_character: '',
  is_published: false,
  is_archived: false,
  browse_visible: true,
  featured_rank: null,
  sections: [
    {
      section_key: 'section_0',
      title: '',
      description: '',
      order_index: 0,
      items: [{ book_key: '', start_chapter: 1, end_chapter: 1, order_index: 0 }],
    },
  ],
  tags: [],
};

export function parseNumber(value: string) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

export function calculatePlanTotalChapters(sections: AdminPlanInput['sections']) {
  return sections.reduce((sum, section) => {
    return (
      sum +
      section.items.reduce((sectionSum, item) => {
        const start = Math.max(1, Math.floor(Number(item.start_chapter) || 1));
        const end = Math.max(start, Math.floor(Number(item.end_chapter) || start));
        return sectionSum + (end - start + 1);
      }, 0)
    );
  }, 0);
}

export function normalizeSections(sections: AdminPlanInput['sections']) {
  if (!sections || sections.length === 0) {
    return emptyPlan.sections;
  }
  return sections.map((section, sectionIndex) => ({
    section_key: section.section_key || `section_${sectionIndex}`,
    title: section.title || '',
    description: section.description || '',
    order_index: section.order_index ?? sectionIndex,
    items:
      section.items?.length > 0
        ? section.items.map((item, itemIndex) => {
            const base = {
              book_key: item.book_key || '',
              start_chapter: item.start_chapter ?? 1,
              end_chapter: item.end_chapter ?? 1,
              order_index: item.order_index ?? itemIndex,
            };
            const clamped = clampPlanItemChapters({
              book_key: base.book_key,
              start_chapter: base.start_chapter,
              end_chapter: base.end_chapter,
            });
            return { ...base, start_chapter: clamped.start_chapter, end_chapter: clamped.end_chapter };
          })
        : [{ book_key: '', start_chapter: 1, end_chapter: 1, order_index: 0 }],
  }));
}

export function mapPlanToForm(plan: PlanTemplateWithRelations): AdminPlanInput {
  return {
    title: plan.title,
    subtitle: plan.subtitle,
    short_description: plan.short_description,
    description: plan.description,
    cover_image_url: plan.cover_image_url,
    cover_image_public_id: plan.cover_image_public_id,
    plan_type: normalizePlanType(plan.plan_type ?? '') || '',
    testament_scope: normalizeTestamentScope(plan.testament_scope ?? '') || '',
    difficulty: normalizeDifficulty(plan.difficulty ?? '') || '',
    estimated_minutes: plan.estimated_minutes,
    estimated_days: plan.estimated_days,
    total_chapters: plan.total_chapters,
    primary_book_key: plan.primary_book_key,
    primary_character: plan.primary_character,
    is_published: plan.is_published,
    is_archived: Boolean(plan.is_archived),
    browse_visible: plan.browse_visible !== false,
    featured_rank: plan.featured_rank ?? null,
    sections: normalizeSections(plan.sections),
    tags: plan.tags.map((tag) => tag.name),
  };
}
