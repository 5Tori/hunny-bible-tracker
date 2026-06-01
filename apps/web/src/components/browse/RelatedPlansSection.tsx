import Link from "next/link";

import {
  GooglePlayStoreBadgeIcon,
  StoreDownloadLabel,
} from "@/components/public/StoreDownloadButtons";
import { formatPlanMeta } from "@/lib/plan-display";
import { siteConfig } from "@/lib/site-config";

export interface BrowseRelatedPlan {
  id: string;
  title: string;
  subtitle?: string | null;
  cover_image_url?: string | null;
  total_chapters: number | null;
  estimated_minutes: number | null;
  cta_label?: string | null;
}

export function RelatedPlansSection({ plans }: { plans: BrowseRelatedPlan[] }) {
  if (plans.length === 0) {
    return null;
  }

  return (
    <section className="mt-12 rounded-2xl border border-neutral-200 p-6">
      <p className="mkt-kicker">Reading plans</p>
      <h2 className="mt-2 text-xl font-semibold text-neutral-900">
        Want to explore the full story?
      </h2>
      <p className="mt-2 text-sm text-neutral-600">
        Guided reading plans live in the Hunny app — start there and read one chapter at a
        time.
      </p>
      <ul className="mt-6 space-y-3">
        {plans.map((plan) => {
          const meta = formatPlanMeta(plan);
          const buttonLabel = plan.cta_label?.trim() || "Start this plan in the app";

          return (
            <li
              key={plan.id}
              className="rounded-xl border border-neutral-200 bg-neutral-50 p-4"
            >
              <p className="font-semibold text-neutral-900">{plan.title}</p>
              {plan.subtitle ? (
                <p className="mt-1 text-sm text-neutral-600">{plan.subtitle}</p>
              ) : null}
              {meta ? <p className="mt-1 text-sm text-neutral-500">{meta}</p> : null}
              <Link
                href={siteConfig.googlePlayUrl}
                target="_blank"
                rel="noreferrer"
                className="mt-4 inline-flex items-center gap-3 rounded-xl bg-neutral-900 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-black"
              >
                <GooglePlayStoreBadgeIcon className="h-6 w-auto shrink-0" />
                <StoreDownloadLabel caption="Get the app" store={buttonLabel} />
              </Link>
            </li>
          );
        })}
      </ul>
    </section>
  );
}
