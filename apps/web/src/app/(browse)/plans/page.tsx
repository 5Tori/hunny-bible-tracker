import type { Metadata } from 'next';

import { PlanCard } from '@/components/plans/PlanCard';
import { PlanSortFilters } from '@/components/plans/PlanSortFilters';
import { MarketingContainer } from '@/components/marketing/ui/MarketingContainer';
import { MarketingSection } from '@/components/marketing/ui/MarketingSection';
import { getPublishedPlans, parsePublishedPlanSort } from '@/lib/plans';

export const revalidate = 300;

export const metadata: Metadata = {
  title: 'Plans',
  description:
    'Gentle Bible reading plans — short guided paths through stories, characters, and books.',
  alternates: { canonical: '/plans' },
};

interface PageProps {
  searchParams: Promise<{ sort?: string }>;
}

export default async function PlansPage({ searchParams }: PageProps) {
  const params = await searchParams;
  const sort = parsePublishedPlanSort(params.sort);
  const plans = await getPublishedPlans(sort);

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer>
        <header className="max-w-2xl">
          <p className="mkt-kicker">Plans</p>
          <h1 className="mkt-heading mt-3">Reading plans</h1>
          <p className="mkt-lead mt-4">
            Short, guided paths through Scripture — one chapter at a time, at your own pace.
          </p>
        </header>

        <div className="mt-8">
          <PlanSortFilters active={sort} />
        </div>

        {plans.length === 0 ? (
          <p className="mt-12 text-neutral-600">No plans are published yet. Check back soon.</p>
        ) : (
          <ul className="mt-10 divide-y divide-neutral-200">
            {plans.map((plan) => (
              <PlanCard key={plan.id} plan={plan} />
            ))}
          </ul>
        )}
      </MarketingContainer>
    </MarketingSection>
  );
}
