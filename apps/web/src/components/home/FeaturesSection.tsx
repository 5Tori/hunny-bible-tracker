import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import { features } from "@/components/home/data";

export function FeaturesSection() {
  return (
    <MarketingSection className="!py-16 md:!py-24">
      <MarketingContainer>
        <div className="max-w-2xl">
          <p className="mkt-kicker">What&apos;s inside</p>
          <h2 className="mkt-heading-sm mt-2">
            A calm space to build a rhythm of Scripture.
          </h2>
        </div>

        <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, index) => (
            <article
              key={feature.title}
              className="rounded-2xl border border-neutral-200 bg-white p-6"
            >
              <span className="flex h-8 w-8 items-center justify-center rounded-full bg-neutral-100 text-xs font-semibold text-[#d99a12]">
                {index + 1}
              </span>
              <h3 className="mt-4 text-base font-semibold text-neutral-900">
                {feature.title}
              </h3>
              <p className="mt-2 text-sm leading-relaxed text-neutral-600">
                {feature.body}
              </p>
            </article>
          ))}
        </div>
      </MarketingContainer>
    </MarketingSection>
  );
}
