import { describe, expect, it } from 'vitest';

import {
  calculatePlanEstimatedMinutes,
  estimatedMinutesPerChapterFromTotal,
  resolveEstimatedMinutesForSave,
} from '@/lib/plan-estimates';

const sampleSections = [
  {
    items: [{ book_key: 'genesis', start_chapter: 1, end_chapter: 2 }],
  },
];

describe('plan-estimates', () => {
  it('estimatedMinutesPerChapterFromTotal', () => {
    expect(estimatedMinutesPerChapterFromTotal(3716, 929)).toBe(4);
    expect(estimatedMinutesPerChapterFromTotal(56, 14)).toBe(4);
  });

  it('resolveEstimatedMinutesForSave uses total override when set', () => {
    expect(resolveEstimatedMinutesForSave(56, sampleSections, 14)).toBe(4);
    expect(resolveEstimatedMinutesForSave(3716, sampleSections, 929)).toBe(4);
  });

  it('resolveEstimatedMinutesForSave auto-calculates when total blank', () => {
    const chapters = 2;
    expect(resolveEstimatedMinutesForSave(null, sampleSections, chapters)).toBe(
      calculatePlanEstimatedMinutes(sampleSections),
    );
    expect(resolveEstimatedMinutesForSave(undefined, sampleSections, chapters)).toBe(
      calculatePlanEstimatedMinutes(sampleSections),
    );
    expect(resolveEstimatedMinutesForSave(0, sampleSections, chapters)).toBe(
      calculatePlanEstimatedMinutes(sampleSections),
    );
  });
});
