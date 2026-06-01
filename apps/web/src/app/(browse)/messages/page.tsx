import type { Metadata } from 'next';

import { MessageCardGrid } from '@/components/messages/MessageCardGrid';
import { MessageFilters } from '@/components/messages/MessageFilters';
import { MarketingSection } from '@/components/marketing/ui/MarketingSection';
import { getPublishedMessages } from '@/lib/messages';

export const revalidate = 300;

export const metadata: Metadata = {
  title: 'Messages',
  description:
    'Find a Bible message for your mood, situation, and day — shareable cards from Hunny Bible Tracker.',
  alternates: { canonical: '/messages' },
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
    language: 'en',
    category: params.category,
    situation: params.situation,
    tone: params.tone,
    q: params.q,
    limit: 100,
  });

  return (
    <MarketingSection className="!py-8 md:!py-12">
      <div className="w-full px-4 sm:px-6 lg:px-8 xl:px-10">
        <header>
          <p className="mkt-kicker">Messages</p>
        </header>

        <div className="mt-8 flex flex-col gap-10 lg:mt-10 lg:flex-row lg:items-start lg:gap-8 xl:gap-12">
          <aside className="w-full shrink-0 lg:sticky lg:top-6 lg:w-72 lg:max-h-[calc(100vh-2rem)] lg:overflow-y-auto xl:w-80">
            <MessageFilters
              layout="sidebar"
              activeCategory={params.category}
              activeSituation={params.situation}
              query={params.q}
            />
          </aside>

          <main className="min-w-0 flex-1">
            <MessageCardGrid messages={messages} />
          </main>
        </div>
      </div>
    </MarketingSection>
  );
}
