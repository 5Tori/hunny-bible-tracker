import Link from 'next/link';

import { PlanCoverImage } from '@/components/plans/PlanCoverImage';
import {
  formatPlanListMeta,
  planListBlurb,
  planTypeDisplayLabel,
  planUrl,
} from '@/lib/plan-display';
import type { PlanTemplateBase } from '@/lib/plans';

export function PlanCard({ plan }: { plan: PlanTemplateBase }) {
  const typeLabel = planTypeDisplayLabel(plan.plan_type);
  const listMeta = formatPlanListMeta(plan);
  const blurb = planListBlurb(plan);

  return (
    <li>
      <Link
        href={planUrl(plan.template_key)}
        className="group flex items-stretch gap-4 py-5 sm:gap-5 sm:py-6 md:gap-6"
      >
        <PlanCoverImage
          coverImageUrl={plan.cover_image_url}
          title={plan.title}
          className="w-[100px] shrink-0 sm:w-[112px] md:w-[128px]"
          sizes="(max-width: 640px) 100px, 128px"
        />
        <div className="flex min-w-0 flex-1 flex-col">
          {typeLabel ? (
            <p className="text-[11px] font-medium uppercase tracking-[0.12em] text-[#d99a12]">
              {typeLabel}
            </p>
          ) : null}
          <h2
            className={`text-base font-semibold leading-snug text-neutral-900 group-hover:text-black sm:text-lg ${typeLabel ? 'mt-1' : ''}`}
          >
            {plan.title}
          </h2>
          <div className="mt-1 flex min-h-0 flex-1 flex-col">
            {blurb ? (
              <p className="line-clamp-2 text-sm leading-relaxed text-neutral-600">{blurb}</p>
            ) : null}
            {listMeta ? (
              <p className="mt-auto pt-3 text-xs text-neutral-500">{listMeta}</p>
            ) : null}
          </div>
        </div>
      </Link>
    </li>
  );
}
