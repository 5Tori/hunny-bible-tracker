import Image from "next/image";
import Link from "next/link";

import { RelatedPlansSection } from "@/components/browse/RelatedPlansSection";
import { MessageShareButton } from "@/components/messages/MessageShareButton";
import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import type { PublicMessageCard } from "@/lib/messages";

export function MessageDetailView({
  message,
  relatedMessages = [],
}: {
  message: PublicMessageCard;
  relatedMessages?: PublicMessageCard[];
}) {
  const referenceLabel = message.translation
    ? `${message.verseReference} · ${message.translation}`
    : message.verseReference;

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer narrow>
        <p className="mkt-kicker">Message</p>
        <p className="mt-2 text-sm text-neutral-500">{message.primaryCategoryLabel}</p>
        <h1 className="mkt-heading mt-3">{message.title}</h1>
        {message.subtitle ? (
          <p className="mt-2 text-lg text-neutral-600">{message.subtitle}</p>
        ) : null}

        <div className="relative mt-8 overflow-hidden rounded-2xl border border-neutral-200 bg-neutral-50">
          {message.coverImageUrl ? (
            <div className="relative aspect-[4/3] w-full">
              <Image
                src={message.coverImageUrl}
                alt=""
                fill
                className="object-cover"
                sizes="(max-width: 768px) 100vw, 720px"
                priority
              />
            </div>
          ) : null}
          <div className="p-6">
            {referenceLabel ? (
              <p className="text-sm font-medium text-[#d99a12]">{referenceLabel}</p>
            ) : null}
            {message.verseText ? (
              <blockquote className="mt-4 text-lg leading-relaxed text-neutral-800">
                {message.verseText}
              </blockquote>
            ) : null}
          </div>
        </div>

        {message.shortReflection ? (
          <p className="mt-8 text-base leading-relaxed text-neutral-700">
            {message.shortReflection}
          </p>
        ) : null}

        {message.prayerText ? (
          <div className="mt-8 rounded-2xl border border-neutral-200 bg-neutral-50 p-5">
            <p className="text-xs font-medium uppercase tracking-[0.12em] text-neutral-500">
              Prayer
            </p>
            <p className="mt-2 text-sm leading-relaxed text-neutral-700">{message.prayerText}</p>
          </div>
        ) : null}

        {(message.situationLabels.length > 0 || message.themeTagLabels.length > 0) && (
          <div className="mt-8 flex flex-wrap gap-2">
            {message.situationLabels.map((label) => (
              <span
                key={label}
                className="rounded-full border border-neutral-200 px-3 py-1 text-xs text-neutral-600"
              >
                {label}
              </span>
            ))}
            {message.themeTagLabels.map((label) => (
              <span
                key={label}
                className="rounded-full bg-[#fff8df] px-3 py-1 text-xs text-neutral-700"
              >
                {label}
              </span>
            ))}
          </div>
        )}

        <RelatedPlansSection
          plans={message.relatedPlans.map((plan) => ({
            id: plan.id,
            title: plan.title,
            total_chapters: plan.totalChapters,
            estimated_minutes: plan.estimatedMinutes,
            cta_label: plan.ctaLabel,
          }))}
        />

        <div className="mt-8">
          <MessageShareButton title={message.title} path={message.messagesUrl} />
        </div>

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
                    {item.title}
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
