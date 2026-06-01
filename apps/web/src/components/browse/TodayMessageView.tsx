import Image from "next/image";
import Link from "next/link";

import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import type { PublicTodayMessage } from "@/lib/today-messages";

function verseLabel(message: PublicTodayMessage) {
  if (!message.verse_reference) return null;
  return message.bible_version
    ? `${message.verse_reference} · ${message.bible_version}`
    : message.verse_reference;
}

export function TodayMessageView({ message }: { message: PublicTodayMessage }) {
  const referenceLabel = verseLabel(message);
  const linkedContent = message.linked_content;

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer narrow>
        <div className="mx-auto max-w-xl text-center">
          <p className="mkt-kicker">Today&apos;s message</p>
          <p className="mt-2 text-sm text-neutral-500">{message.publish_date}</p>

          {message.image_url ? (
            <div className="relative mx-auto mt-8 aspect-square w-full max-w-md overflow-hidden rounded-2xl border border-neutral-200 bg-neutral-50">
              <Image
                src={message.image_url}
                alt=""
                fill
                className="object-cover"
                sizes="(max-width: 768px) 100vw, 480px"
                priority
              />
            </div>
          ) : null}

          {referenceLabel ? (
            <p className="mt-8 text-sm font-medium text-[#d99a12]">{referenceLabel}</p>
          ) : null}

          {message.verse_text ? (
            <blockquote className="mt-4 text-xl leading-relaxed text-neutral-900 md:text-2xl">
              {message.verse_text}
            </blockquote>
          ) : null}

          {message.context ? (
            <p className="mt-8 text-base leading-relaxed text-neutral-700">{message.context}</p>
          ) : null}

          {message.hint_summary ? (
            <div className="mt-8 rounded-2xl border border-neutral-200 bg-neutral-50 p-5 text-left">
              <p className="text-xs font-medium uppercase tracking-[0.12em] text-neutral-500">
                Hint
              </p>
              <p className="mt-2 text-sm leading-relaxed text-neutral-700">{message.hint_summary}</p>
            </div>
          ) : null}

          {linkedContent ? (
            <section className="mt-10 rounded-2xl border border-neutral-200 p-6 text-left">
              <p className="mkt-kicker">Message card</p>
              {linkedContent.primary_category_label ? (
                <p className="mt-2 text-xs text-neutral-500">{linkedContent.primary_category_label}</p>
              ) : null}
              <Link
                href={
                  linkedContent.content_type === "message" && linkedContent.messages_url
                    ? linkedContent.messages_url
                    : `/content/${linkedContent.slug}`
                }
                className="mt-4 inline-block font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
              >
                Open full message card →
              </Link>
              {linkedContent.related_plans.length > 0 ? (
                <p className="mt-4 text-sm text-neutral-500">
                  Includes {linkedContent.related_plans.length} related reading plan
                  {linkedContent.related_plans.length === 1 ? "" : "s"}.
                </p>
              ) : null}
            </section>
          ) : null}
        </div>

        <div className="mt-10 flex flex-wrap justify-center gap-4 text-sm">
          <Link
            href="/messages"
            className="font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
          >
            Find another message →
          </Link>
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
          href="/today"
          className="mt-6 inline-block font-medium text-neutral-900 underline underline-offset-4"
        >
          View today&apos;s message
        </Link>
      </MarketingContainer>
    </MarketingSection>
  );
}
