import Link from 'next/link';

import { RelatedPlansSection } from '@/components/browse/RelatedPlansSection';
import { MessageCardActions } from '@/components/messages/MessageCardActions';
import { MessageDetailMeta } from '@/components/messages/MessageDetailMeta';
import {
  formatMessageReference,
  MessageCardVisual,
} from '@/components/messages/message-card-visual';
import { MarketingContainer } from '@/components/marketing/ui/MarketingContainer';
import { MarketingSection } from '@/components/marketing/ui/MarketingSection';
import type { PublicMessageCard } from '@/lib/messages';

export function MessageDetailView({
  message,
  relatedMessages = [],
}: {
  message: PublicMessageCard;
  relatedMessages?: PublicMessageCard[];
}) {
  const shareTitle = formatMessageReference(message) || message.title;

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer>
        <div className="flex flex-col gap-10 lg:grid lg:grid-cols-[minmax(0,22rem)_1fr] lg:items-start lg:gap-12 xl:grid-cols-[minmax(0,24rem)_1fr] xl:gap-16">
          <aside className="mx-auto w-full max-w-md shrink-0 lg:sticky lg:top-6 lg:mx-0 lg:max-w-none">
            <MessageCardVisual message={message} variant="detail" priority />
            <MessageCardActions
              slug={message.slug}
              shareTitle={shareTitle}
              sharePath={message.messagesUrl}
              heartCount={message.heartCount}
              shareCount={message.shareCount}
              saveCount={message.saveCount}
              className="mt-4"
            />
          </aside>

          <div className="min-w-0">
            <MessageDetailMeta message={message} />

            <RelatedPlansSection
              plans={message.relatedPlans.map((plan) => ({
                id: plan.id,
                title: plan.title,
                total_chapters: plan.totalChapters,
                estimated_minutes: plan.estimatedMinutes,
                cta_label: plan.ctaLabel,
              }))}
            />

            {relatedMessages.length > 0 ? (
              <section className="mt-12">
                <h2 className="text-lg font-semibold text-neutral-900">More like this</h2>
                <ul className="mt-4 space-y-3">
                  {relatedMessages.map((item) => (
                    <li key={item.id}>
                      <Link
                        href={item.messagesUrl}
                        className="font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
                      >
                        {formatMessageReference(item) || item.title}
                      </Link>
                    </li>
                  ))}
                </ul>
              </section>
            ) : null}

            <div className="mt-10">
              <Link
                href="/messages"
                className="font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
              >
                Browse all messages →
              </Link>
            </div>
          </div>
        </div>
      </MarketingContainer>
    </MarketingSection>
  );
}

export function MessageNotFound() {
  return (
    <MarketingSection className="!py-16">
      <MarketingContainer narrow>
        <h1 className="mkt-heading-sm">Message not found</h1>
        <p className="mkt-lead mt-4">This message is unavailable or unpublished.</p>
        <Link
          href="/messages"
          className="mt-6 inline-block font-medium text-neutral-900 underline underline-offset-4"
        >
          Browse messages
        </Link>
      </MarketingContainer>
    </MarketingSection>
  );
}
