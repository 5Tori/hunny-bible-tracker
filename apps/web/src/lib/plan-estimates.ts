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
