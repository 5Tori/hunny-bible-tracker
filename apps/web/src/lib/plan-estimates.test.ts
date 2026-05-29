import { describe, expect, it } from 'vitest';

import { calculatePlanEstimatedMinutes } from '@/lib/plan-estimates';

describe('calculatePlanEstimatedMinutes', () => {
  it('returns 4 for Joseph plan (Genesis 37–50)', () => {
    const minutes = calculatePlanEstimatedMinutes([
      {
        items: [{ book_key: 'genesis', start_chapter: 37, end_chapter: 50 }],
      },
    ]);
    expect(minutes).toBe(4);
  });

  it('returns null when there are no items', () => {
    expect(calculatePlanEstimatedMinutes([])).toBeNull();
    expect(calculatePlanEstimatedMinutes([{ items: [] }])).toBeNull();
  });
});
