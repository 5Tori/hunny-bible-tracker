import Image from "next/image";
import Link from "next/link";

import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import type { PublicTodayMessage } from "@/lib/today-messages";

export function TodayMessageView({ message }: { message: PublicTodayMessage }) {
  const referenceLabel = message.bible_version
    ? `${message.verse_reference} · ${message.bible_version}`
    : message.verse_reference;
  const linkedContent = message.linked_content;

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer narrow>
        <p className="mkt-kicker">Today&apos;s message</p>
        <p className="mt-2 text-sm text-neutral-500">{message.publish_date}</p>
        <h1 className="mkt-heading mt-3">{message.hint_title || referenceLabel}</h1>
        {message.hint_title ? (
          <p className="mt-2 text-lg text-neutral-600">{referenceLabel}</p>
        ) : null}

        {message.image_url ? (
          <div className="relative mt-8 aspect-[4/3] w-full overflow-hidden rounded-2xl border border-neutral-200 bg-neutral-50">
            <Image
              src={message.image_url}
              alt=""
              fill
              className="object-cover"
              sizes="(max-width: 768px) 100vw, 720px"
              priority
            />
          </div>
        ) : null}

        {message.verse_text ? (
          <blockquote className="mt-8 border-l-2 border-[#d99a12] pl-4 text-lg leading-relaxed text-neutral-800">
            {message.verse_text}
          </blockquote>
        ) : null}

        {message.hint_title || message.hint_summary ? (
          <div className="mt-8 rounded-2xl border border-neutral-200 bg-neutral-50 p-5">
            {message.hint_title ? (
              <p className="text-sm font-semibold text-neutral-900">{message.hint_title}</p>
            ) : null}
            {message.hint_summary ? (
              <p className="mt-2 text-sm text-neutral-600">{message.hint_summary}</p>
            ) : null}
          </div>
        ) : null}

        {linkedContent ? (
          <section className="mt-10 rounded-2xl border border-neutral-200 p-6">
            <p className="mkt-kicker">Related content</p>
            <h2 className="mt-2 text-xl font-semibold text-neutral-900">{linkedContent.title}</h2>
            {linkedContent.summary ? (
              <p className="mt-2 text-sm text-neutral-600">{linkedContent.summary}</p>
            ) : null}
            <Link
              href={`/content/${linkedContent.slug}`}
              className="mt-4 inline-block font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
            >
              Read full story →
            </Link>
            {linkedContent.related_plans.length > 0 ? (
              <div className="mt-6 border-t border-neutral-200 pt-4">
                <p className="text-sm font-medium text-neutral-900">Related plans</p>
                <ul className="mt-2 space-y-2 text-sm text-neutral-600">
                  {linkedContent.related_plans.map((plan) => (
                    <li key={plan.id}>
                      {plan.title}
                      {plan.total_chapters ? ` · ${plan.total_chapters} chapters` : ""}
                      {plan.estimated_minutes ? ` · ~${plan.estimated_minutes} min/ch` : ""}
                    </li>
                  ))}
                </ul>
              </div>
            ) : null}
          </section>
        ) : null}

        <div className="mt-10 flex flex-wrap gap-4 text-sm">
          <Link
            href="/discover"
            className="font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
          >
            More in Discover →
          </Link>
          <Link
            href="/today"
            className="font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
          >
            Latest message →
          </Link>
        </div>
      </MarketingContainer>
    </MarketingSection>
  );
}

export function TodayMessageNotFound() {
  return (
    <MarketingSection className="!py-16">
      <MarketingContainer narrow>
        <h1 className="mkt-heading-sm">Message not found</h1>
        <p className="mkt-lead mt-4">
          This daily message is unavailable or unpublished.
        </p>
        <Link
          href="/discover"
          className="mt-6 inline-block font-medium text-neutral-900 underline underline-offset-4"
        >
          Browse Discover
        </Link>
      </MarketingContainer>
    </MarketingSection>
  );
}
