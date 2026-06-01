import { averageReadingMinutesForPlanItems, type PlanChapterItem } from '@/lib/bible-chapters';

export type PlanSectionForEstimate = {
  items: Array<{
    book_key: string;
    start_chapter: number;
    end_chapter: number;
  }>;
};

export function calculatePlanEstimatedMinutes(sections: PlanSectionForEstimate[]): number | null {
  const items: PlanChapterItem[] = sections.flatMap((section) =>
    section.items.map((item) => ({
      book_key: item.book_key,
      start_chapter: item.start_chapter,
      end_chapter: item.end_chapter,
    })),
  );
  const average = averageReadingMinutesForPlanItems(items);
  return average > 0 ? average : null;
}

export function estimatedMinutesPerChapterFromTotal(
  totalMinutes: number,
  totalChapters: number,
): number {
  return Math.max(1, Math.round(totalMinutes / totalChapters));
}

/** Manual total when set; otherwise derive per-chapter average from section chapters. */
export function resolveEstimatedMinutesForSave(
  estimatedTotalMinutes: number | null | undefined,
  sections: PlanSectionForEstimate[],
  totalChapters: number,
): number | null {
  if (
    estimatedTotalMinutes != null &&
    Number.isFinite(estimatedTotalMinutes) &&
    estimatedTotalMinutes > 0 &&
    totalChapters > 0
  ) {
    return estimatedMinutesPerChapterFromTotal(estimatedTotalMinutes, totalChapters);
  }
  return calculatePlanEstimatedMinutes(sections);
}
