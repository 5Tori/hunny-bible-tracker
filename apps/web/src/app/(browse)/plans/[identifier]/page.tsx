import type { Metadata } from 'next';
import Link from 'next/link';
import { notFound } from 'next/navigation';

import { PlanCoverImage } from '@/components/plans/PlanCoverImage';
import {
  GooglePlayStoreBadgeIcon,
  StoreDownloadLabel,
} from '@/components/public/StoreDownloadButtons';
import { MarketingContainer } from '@/components/marketing/ui/MarketingContainer';
import { MarketingSection } from '@/components/marketing/ui/MarketingSection';
import {
  difficultyLabel,
  formatPlanMeta,
  planSummary,
  planTypeDisplayLabel,
  testamentScopeLabel,
} from '@/lib/plan-display';
import { getPublishedPlanByIdentifier } from '@/lib/plans';
import { siteConfig } from '@/lib/site-config';

export const revalidate = 300;

interface PageProps {
  params: Promise<{ identifier: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { identifier } = await params;
  const plan = await getPublishedPlanByIdentifier(identifier);
  if (!plan) {
    return { title: 'Plan not found' };
  }
  return {
    title: plan.title,
    description: planSummary(plan) ?? plan.subtitle ?? undefined,
    alternates: { canonical: `/plans/${plan.template_key}` },
  };
}

export default async function PlanDetailPage({ params }: PageProps) {
  const { identifier } = await params;
  const plan = await getPublishedPlanByIdentifier(identifier);
  if (!plan) {
    notFound();
  }

  const meta = formatPlanMeta(plan);
  const typeLabel = planTypeDisplayLabel(plan.plan_type);
  const difficulty = difficultyLabel(plan.difficulty);
  const scope = testamentScopeLabel(plan.testament_scope);
  const chips = [typeLabel, difficulty, scope].filter(Boolean);
  const summary = planSummary(plan);
  const sectionCount = plan.sections.length;

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer narrow>
        <div className="flex flex-col gap-10 md:flex-row md:items-start md:gap-12">
          <aside className="mx-auto w-full max-w-[220px] shrink-0 md:sticky md:top-6 md:mx-0 md:w-[240px]">
            <PlanCoverImage
              coverImageUrl={plan.cover_image_url}
              title={plan.title}
              priority
            />
          </aside>

          <div className="min-w-0 flex-1">
            <p className="mkt-kicker">Plan</p>
            <h1 className="mkt-heading mt-3">{plan.title}</h1>
            {plan.subtitle ? (
              <p className="mt-2 text-lg text-neutral-600">{plan.subtitle}</p>
            ) : null}
            {summary ? (
              <p className="mt-6 text-[15px] leading-relaxed text-neutral-700">{summary}</p>
            ) : null}
            {plan.description && plan.description !== summary ? (
              <p className="mt-4 text-[15px] leading-relaxed text-neutral-600">{plan.description}</p>
            ) : null}

            {chips.length > 0 || meta ? (
              <ul className="mt-6 flex flex-wrap gap-2 text-sm text-neutral-600">
                {chips.map((chip) => (
                  <li
                    key={chip}
                    className="rounded-full border border-neutral-200 bg-white px-3 py-1"
                  >
                    {chip}
                  </li>
                ))}
                {meta ? (
                  <li className="rounded-full border border-neutral-200 bg-neutral-50 px-3 py-1">
                    {meta}
                  </li>
                ) : null}
                {sectionCount > 0 ? (
                  <li className="rounded-full border border-neutral-200 bg-neutral-50 px-3 py-1">
                    {sectionCount} {sectionCount === 1 ? 'section' : 'sections'}
                  </li>
                ) : null}
              </ul>
            ) : null}

            <div className="mt-10 rounded-2xl border border-neutral-200 bg-neutral-50 p-6">
          <p className="text-sm text-neutral-600">
            Track progress chapter by chapter in the Hunny app.
          </p>
          <Link
            href={siteConfig.googlePlayUrl}
            target="_blank"
            rel="noreferrer"
            className="mt-4 inline-flex items-center gap-3 rounded-xl bg-neutral-900 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-black"
          >
            <GooglePlayStoreBadgeIcon className="h-6 w-auto shrink-0" />
            <StoreDownloadLabel caption="Get the app" store="Start this plan" />
          </Link>
            </div>

            <p className="mt-10">
              <Link
                href="/plans"
                className="font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
              >
                ← All plans
              </Link>
            </p>
          </div>
        </div>
      </MarketingContainer>
    </MarketingSection>
  );
}
