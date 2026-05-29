import { SiteFooter, SiteHeader } from "@/components/public/SiteShell";
import { CtaSection } from "@/components/home/CtaSection";
import { FaqSection } from "@/components/home/FaqSection";
import { FeaturesSection } from "@/components/home/FeaturesSection";
import { HeroSection } from "@/components/home/HeroSection";
import { PlansSection } from "@/components/home/PlansSection";
import { QuietIdeaSection } from "@/components/home/QuietIdeaSection";
import { faqs } from "@/components/home/data";

export default function HomePage() {
  const faqJsonLd = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: { "@type": "Answer", text: faq.a },
    })),
  };

  return (
    <>
      <SiteHeader />
      <main>
        <HeroSection />
        <QuietIdeaSection />
        <PlansSection />
        <FeaturesSection />
        <FaqSection />
        <CtaSection />
      </main>
      <SiteFooter />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqJsonLd) }}
      />
    </>
  );
}
