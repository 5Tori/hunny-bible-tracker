import { describe, expect, it } from 'vitest';

import {
  estimatePlanTotalMinutes,
  formatCatalogReadingDuration,
  formatPlanAdminClassification,
  formatPlanListMeta,
  formatPlanMeta,
  formatPlanMinutes,
  formatReadingDuration,
} from '@/lib/plan-display';

describe('plan-display', () => {
  it('formatReadingDuration (in-session precision)', () => {
    expect(formatReadingDuration(56)).toBe('56 mins');
    expect(formatReadingDuration(60)).toBe('1 hr');
    expect(formatReadingDuration(100)).toBe('1 hr 40 mins');
  });

  it('formatCatalogReadingDuration rounds to nearest 0.5 hr', () => {
    expect(formatCatalogReadingDuration(0)).toBe('0 hrs');
    expect(formatCatalogReadingDuration(15)).toBe('0.5 hrs');
    expect(formatCatalogReadingDuration(56)).toBe('1 hr');
    expect(formatCatalogReadingDuration(3600)).toBe('60 hrs');
    expect(formatCatalogReadingDuration(3716)).toBe('62 hrs');
  });

  it('formatPlanMinutes uses per-chapter estimate × chapter count', () => {
    expect(formatPlanMinutes(4, 14)).toBe('1 hr');
    expect(formatPlanMinutes(2, 12)).toBe('0.5 hrs');
  });

  it('estimatePlanTotalMinutes', () => {
    expect(estimatePlanTotalMinutes(4, 14)).toBe(56);
    expect(estimatePlanTotalMinutes(null, 14)).toBeNull();
  });

  it('formatPlanMeta', () => {
    expect(
      formatPlanMeta({ total_chapters: 14, estimated_minutes: 4 }),
    ).toBe('14 chapters · 1 hr');
  });

  it('formatPlanListMeta omits chapter count', () => {
    expect(
      formatPlanListMeta({ total_chapters: 929, estimated_minutes: 4 }),
    ).toBe('62 hrs');
  });

  it('formatPlanAdminClassification', () => {
    expect(
      formatPlanAdminClassification({
        plan_type: 'journey',
        testament_scope: 'old_testament',
        difficulty: 'medium',
      }),
    ).toBe('Journey · Old Testament · Medium');
    expect(formatPlanAdminClassification({ plan_type: '', testament_scope: '', difficulty: '' })).toBe('—');
  });
});
