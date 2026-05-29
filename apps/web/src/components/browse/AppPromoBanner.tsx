import { MarketingButton } from "@/components/marketing/ui/MarketingButton";
import { MarketingCard } from "@/components/marketing/ui/MarketingCard";
import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { AndroidTesterCta } from "@/components/public/AndroidTesterCta";

export function AppPromoBanner() {
  return (
    <MarketingContainer className="pb-16 pt-4">
      <MarketingCard className="flex flex-col items-start gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="mkt-kicker">Hunny app</p>
          <p className="mt-2 text-base font-semibold text-neutral-900">
            Track your reading in the app
          </p>
          <p className="mt-1 text-sm text-neutral-600">
            Offline-first plans, chapter progress, and optional backup.
          </p>
        </div>
        <div className="flex flex-wrap gap-3">
          <AndroidTesterCta />
          <MarketingButton variant="secondary" href="/">
            Learn more
          </MarketingButton>
        </div>
      </MarketingCard>
    </MarketingContainer>
  );
}
