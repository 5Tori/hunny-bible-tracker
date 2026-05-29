import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import { faqs } from "@/components/home/data";

export function FaqSection() {
  return (
    <MarketingSection id="faq" className="!py-16 md:!py-24">
      <MarketingContainer narrow>
        <h2 className="mkt-heading-sm">Questions, gently answered.</h2>
        <div className="mkt-faq mt-8 rounded-2xl border border-neutral-200 bg-white">
          {faqs.map((faq) => (
            <details key={faq.q} className="group px-5 py-4 sm:px-6 sm:py-5">
              <summary className="flex items-start justify-between gap-6 text-left text-[15px] font-medium text-neutral-900">
                {faq.q}
                <span className="mt-0.5 text-[#d99a12] transition group-open:rotate-45">
                  +
                </span>
              </summary>
              <p className="mt-3 text-sm leading-relaxed text-neutral-600">{faq.a}</p>
            </details>
          ))}
        </div>
      </MarketingContainer>
    </MarketingSection>
  );
}
