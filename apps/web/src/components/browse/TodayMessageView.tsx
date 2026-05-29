import Image from "next/image";
import Link from "next/link";

import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import type { TodayMessageBase } from "@/lib/today-messages";

type TodayMessageWithPlan = TodayMessageBase & {
  related_plan_template_key?: string | null;
  related_plan_title?: string | null;
  related_plan_chapters?: number | null;
  related_plan_minutes?: number | null;
};

export function TodayMessageView({ message }: { message: TodayMessageWithPlan }) {
  const referenceLabel = message.bible_version
    ? `${message.verse_reference} · ${message.bible_version}`
    : message.verse_reference;

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer narrow>
        <p className="mkt-kicker">Today&apos;s message</p>
        <p className="mt-2 text-sm text-neutral-500">{message.publish_date}</p>
        <h1 className="mkt-heading mt-3">{message.article_title || referenceLabel}</h1>
        {message.article_title ? (
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

        {message.message ? (
          <p className="mkt-lead mt-6">{message.message}</p>
        ) : null}

        {message.hint_title ? (
          <div className="mt-8 rounded-2xl border border-neutral-200 bg-neutral-50 p-5">
            <p className="text-sm font-semibold text-neutral-900">{message.hint_title}</p>
            {message.hint_summary ? (
              <p className="mt-2 text-sm text-neutral-600">{message.hint_summary}</p>
            ) : null}
          </div>
        ) : null}

        {message.article_body
          ? message.article_body.split("\n\n").map((paragraph) => (
              <p key={paragraph.slice(0, 48)} className="mkt-lead mt-6">
                {paragraph}
              </p>
            ))
          : null}

        {message.related_plan_title ? (
          <section className="mt-10 rounded-2xl border border-neutral-200 p-6">
            <p className="mkt-kicker">Read in context</p>
            <h2 className="mt-2 text-xl font-semibold text-neutral-900">
              {message.related_plan_title}
            </h2>
            <p className="mt-2 text-sm text-neutral-600">
              {message.related_plan_chapters ?? 0} chapters
              {message.related_plan_minutes
                ? ` · ~${message.related_plan_minutes} min`
                : ""}
            </p>
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
