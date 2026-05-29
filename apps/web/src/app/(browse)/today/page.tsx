import Link from "next/link";
import { redirect } from "next/navigation";

import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import { getPublishedTodayMessage } from "@/lib/today-messages";

export default async function TodayRedirectPage() {
  const message = await getPublishedTodayMessage({ language: "en" });

  if (message) {
    redirect(`/today-message/${message.publish_date}`);
  }

  return (
    <MarketingSection className="!py-16">
      <MarketingContainer narrow>
        <p className="mkt-kicker">Today</p>
        <h1 className="mkt-heading mt-3">No message yet</h1>
        <p className="mkt-lead mt-4">
          There is no published message for today. Check back soon or browse
          Discover.
        </p>
        <Link
          href="/discover"
          className="mt-6 inline-block font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
        >
          Go to Discover →
        </Link>
      </MarketingContainer>
    </MarketingSection>
  );
}
