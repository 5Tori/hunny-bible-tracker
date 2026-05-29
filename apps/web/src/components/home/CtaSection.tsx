import { MarketingButton } from "@/components/marketing/ui/MarketingButton";
import { MarketingCard } from "@/components/marketing/ui/MarketingCard";
import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import { BrandLogo } from "@/components/public/BrandLogo";
import { AndroidTesterCta } from "@/components/public/AndroidTesterCta";
import { AppStoreDownloadButton } from "@/components/public/StoreDownloadButtons";

export function CtaSection() {
  return (
    <MarketingSection className="!pb-24 md:!pb-32">
      <MarketingContainer narrow>
        <MarketingCard className="px-6 py-10 text-center sm:px-10 sm:py-14">
          <BrandLogo className="mx-auto h-9 w-auto shrink-0" />
          <h2 className="mkt-heading-sm mx-auto mt-5 max-w-lg text-balance">
            Let your reading journey grow.
          </h2>
          <p className="mx-auto mt-4 max-w-md text-neutral-600">
            Start with a story. Track your progress, one chapter at a time. Build a
            gentle rhythm of Scripture at your own pace.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
            <AndroidTesterCta />
            <AppStoreDownloadButton />
            <MarketingButton variant="secondary" href="/support">
              Contact support
            </MarketingButton>
          </div>
        </MarketingCard>
      </MarketingContainer>
    </MarketingSection>
  );
}
