import Link from 'next/link';

import type { PublishedPlanSortMode } from '@/lib/plans';

const sortOptions: Array<{ key: PublishedPlanSortMode; label: string }> = [
  { key: 'featured', label: 'Featured' },
  { key: 'new', label: 'New' },
  { key: 'popular', label: 'Longer reads' },
];

function buildHref(sort: PublishedPlanSortMode) {
  return sort === 'featured' ? '/plans' : `/plans?sort=${sort}`;
}

export function PlanSortFilters({ active }: { active: PublishedPlanSortMode }) {
  return (
    <div className="flex flex-wrap gap-2">
      {sortOptions.map((option) => {
        const isActive = active === option.key;
        return (
          <Link
            key={option.key}
            href={buildHref(option.key)}
            scroll={false}
            className={`rounded-full border px-3.5 py-1.5 text-sm font-medium transition ${
              isActive
                ? 'border-neutral-900 bg-neutral-900 text-white'
                : 'border-neutral-200 bg-white text-neutral-600 hover:border-neutral-300 hover:text-neutral-900'
            }`}
          >
            {option.label}
          </Link>
        );
      })}
    </div>
  );
}
