import { MarketingCard } from "@/components/marketing/ui/MarketingCard";
import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import { BrandLogo } from "@/components/public/BrandLogo";
import { plans } from "@/components/home/data";

export function PlansSection() {
  return (
    <MarketingSection id="plans" className="!py-16 md:!py-24">
      <MarketingContainer>
        <div className="flex items-end justify-between gap-6">
          <div>
            <p className="mkt-kicker">Starter plans</p>
            <h2 className="mkt-heading-sm mt-2">Begin with a story.</h2>
          </div>
          <p className="hidden max-w-xs text-sm text-neutral-500 sm:block">
            Each plan is short enough to finish and meaningful enough to stay with
            you.
          </p>
        </div>

        <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {plans.map((plan) => (
            <MarketingCard key={plan.name} className="p-5">
              <div className="flex items-center justify-between">
                <BrandLogo className="h-5 w-auto shrink-0" />
                <span className="text-[11px] font-medium uppercase tracking-wider text-[#d99a12]">
                  Plan
                </span>
              </div>
              <h3 className="mt-5 text-lg font-semibold text-neutral-900">{plan.name}</h3>
              <p className="mt-1 text-sm text-neutral-500">{plan.verses}</p>
              <div className="mt-5 flex items-center justify-between border-t border-neutral-200 pt-4 text-xs text-neutral-600">
                <span>{plan.minutes}</span>
                <span className="text-right text-neutral-500">{plan.tone}</span>
              </div>
            </MarketingCard>
          ))}
        </div>
      </MarketingContainer>
    </MarketingSection>
  );
}
