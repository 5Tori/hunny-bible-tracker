import type { Metadata } from "next";

import { MessageCardGrid } from "@/components/messages/MessageCardGrid";
import { MessageFilters } from "@/components/messages/MessageFilters";
import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import { getPublishedMessages } from "@/lib/messages";

export const metadata: Metadata = {
  title: "Messages",
  description:
    "Find a Bible message for your mood, situation, and day — shareable cards from Hunny Bible Tracker.",
  alternates: { canonical: "/messages" },
};

interface PageProps {
  searchParams: Promise<{
    category?: string;
    situation?: string;
    q?: string;
    tone?: string;
  }>;
}

export default async function MessagesPage({ searchParams }: PageProps) {
  const params = await searchParams;
  const messages = await getPublishedMessages({
    language: "en",
    category: params.category,
    situation: params.situation,
    tone: params.tone,
    q: params.q,
    limit: 48,
  });

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer>
        <p className="mkt-kicker">Messages</p>
        <h1 className="mkt-heading mt-3">Find a message for today</h1>
        <p className="mkt-lead mt-4 max-w-2xl">
          Browse gentle, shareable Bible messages by how you feel and what you are facing.
        </p>

        <MessageFilters
          activeCategory={params.category}
          activeSituation={params.situation}
          query={params.q}
        />

        <MessageCardGrid messages={messages} />
      </MarketingContainer>
    </MarketingSection>
  );
}
