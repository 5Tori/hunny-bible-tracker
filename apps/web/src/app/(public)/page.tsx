import AppPreviewSection from "@/components/marketing/AppPreviewSection";
import FAQSection from "@/components/marketing/FAQSection";
import FaithSection from "@/components/marketing/FaithSection";
import FinalCTA from "@/components/marketing/FinalCTA";
import GentleReturnSection from "@/components/marketing/GentleReturnSection";
import HeroSection from "@/components/marketing/HeroSection";
import MarketingFooter from "@/components/marketing/MarketingFooter";
import MarketingHeader from "@/components/marketing/MarketingHeader";
import PlansSection from "@/components/marketing/PlansSection";
import ProblemSection from "@/components/marketing/ProblemSection";
import ProgressSection from "@/components/marketing/ProgressSection";
import { siteConfig } from "@/lib/site-config";

export default function HomePage() {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "MobileApplication",
    name: siteConfig.name,
    operatingSystem: "Android, iOS",
    applicationCategory: "Books & Reference",
    description: siteConfig.description,
    url: siteConfig.url,
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "USD",
    },
    ...(siteConfig.googlePlayUrl !== "#"
      ? { installUrl: siteConfig.googlePlayUrl }
      : {}),
  };

  return (
    <>
      <MarketingHeader />
      <main className="hb-marketing-page">
        <HeroSection />
        <ProblemSection />
        <PlansSection />
        <ProgressSection />
        <GentleReturnSection />
        <FaithSection />
        <AppPreviewSection />
        <FAQSection />
        <FinalCTA />
      </main>
      <MarketingFooter />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
    </>
  );
}
