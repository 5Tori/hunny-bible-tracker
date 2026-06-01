import {
  DIFFICULTY_OPTIONS,
  normalizeDifficulty,
  normalizeTestamentScope,
  planTypeLabel,
  TESTAMENT_SCOPE_OPTIONS,
} from '@/lib/plan-taxonomy';
import type { PlanTemplateBase } from '@/lib/plans';

export function planUrl(templateKey: string) {
  return `/plans/${encodeURIComponent(templateKey)}`;
}

export function formatPlanChapters(totalChapters: number | null | undefined): string | null {
  if (!totalChapters || totalChapters <= 0) return null;
  return totalChapters === 1 ? '1 chapter' : `${totalChapters} chapters`;
}

/** `estimated_minutes` on plans is average minutes per chapter (from bible_chapters.json). */
export function estimatePlanTotalMinutes(
  minutesPerChapter: number | null | undefined,
  totalChapters: number | null | undefined,
): number | null {
  if (!minutesPerChapter || minutesPerChapter <= 0) return null;
  if (!totalChapters || totalChapters <= 0) return null;
  return minutesPerChapter * totalChapters;
}

function minuteUnit(minutes: number): string {
  return minutes === 1 ? 'min' : 'mins';
}

function hourUnit(hours: number): string {
  return hours === 1 ? 'hr' : 'hrs';
}

/** In-session / progress labels (minute precision). */
export function formatReadingDuration(totalMinutes: number): string {
  if (totalMinutes <= 0) return '0 min';

  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  if (hours === 0) {
    return `${minutes} ${minuteUnit(minutes)}`;
  }
  if (minutes === 0) {
    return `${hours} ${hourUnit(hours)}`;
  }
  return `${hours} ${hourUnit(hours)} ${minutes} ${minuteUnit(minutes)}`;
}

/** Plan catalog totals — rounded to nearest 0.5 hr (matches mobile `formatCatalogReadingDuration`). */
export function formatCatalogReadingDuration(totalMinutes: number): string {
  if (totalMinutes <= 0) return '0 hrs';

  const halfHours = Math.round(totalMinutes / 30);
  if (halfHours % 2 === 0) {
    const wholeHours = halfHours / 2;
    return wholeHours === 1 ? '1 hr' : `${wholeHours} hrs`;
  }
  return `${(halfHours / 2).toFixed(1)} hrs`;
}

export function formatPlanMinutes(
  minutesPerChapter: number | null | undefined,
  totalChapters?: number | null | undefined,
): string | null {
  const total = estimatePlanTotalMinutes(minutesPerChapter, totalChapters);
  if (!total || total <= 0) return null;
  return formatCatalogReadingDuration(total);
}

export function formatPlanMeta(plan: Pick<
  PlanTemplateBase,
  'total_chapters' | 'estimated_minutes'
>): string | null {
  const parts = [
    formatPlanChapters(plan.total_chapters),
    formatPlanMinutes(plan.estimated_minutes, plan.total_chapters),
  ].filter(Boolean);
  return parts.length > 0 ? parts.join(' · ') : null;
}

/** Plan list rows: total reading time only (chapters and scope stay on the detail page). */
export function formatPlanListMeta(plan: Pick<
  PlanTemplateBase,
  'total_chapters' | 'estimated_minutes'
>): string | null {
  return formatPlanMinutes(plan.estimated_minutes, plan.total_chapters);
}

export function difficultyLabel(raw: string | null | undefined): string | null {
  const value = normalizeDifficulty(raw ?? '');
  if (!value) return null;
  return DIFFICULTY_OPTIONS.find((option) => option.value === value)?.label ?? null;
}

export function testamentScopeLabel(raw: string | null | undefined): string | null {
  const value = normalizeTestamentScope(raw ?? '');
  if (!value) return null;
  const label = TESTAMENT_SCOPE_OPTIONS.find((option) => option.value === value)?.label;
  return label && label !== 'Not set' ? label : null;
}

export function planTypeDisplayLabel(raw: string | null | undefined): string | null {
  const label = planTypeLabel(raw);
  return label === '—' ? null : label;
}

export function planSummary(plan: Pick<PlanTemplateBase, 'subtitle' | 'description'>): string | null {
  const subtitle = plan.subtitle?.trim();
  const description = plan.description?.trim();
  if (subtitle) return subtitle;
  return description || null;
}

/** Single tagline for plan list rows. */
export function planListBlurb(plan: Pick<PlanTemplateBase, 'subtitle'>): string | null {
  const subtitle = plan.subtitle?.trim();
  return subtitle || null;
}

/** Admin list: plan type, testament scope, and difficulty. */
export function formatPlanAdminClassification(
  plan: Pick<PlanTemplateBase, 'plan_type' | 'testament_scope' | 'difficulty'>,
): string {
  const parts = [
    planTypeDisplayLabel(plan.plan_type),
    testamentScopeLabel(plan.testament_scope),
    difficultyLabel(plan.difficulty),
  ].filter(Boolean);
  return parts.length > 0 ? parts.join(' · ') : '—';
}
