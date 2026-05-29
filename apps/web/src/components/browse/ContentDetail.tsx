import Image from "next/image";
import Link from "next/link";

import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import type { ContentWithRelations } from "@/lib/content";
import { getYoutubeVideoId } from "@/lib/youtube";

const typeLabels: Record<string, string> = {
  video: "Video",
  essay: "Essay",
  cartoon: "Cartoon",
  message: "Message",
};

export function ContentDetail({ content }: { content: ContentWithRelations }) {
  const typeLabel = typeLabels[content.content_type] ?? content.content_type;
  const youtubeId = getYoutubeVideoId(content.external_url);
  const videoAsset = content.assets.find(
    (asset) => asset.asset_type === "video" || asset.mime_type?.startsWith("video/"),
  );

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer narrow>
        <Link
          href="/discover"
          className="text-sm font-medium text-neutral-600 hover:text-neutral-900"
        >
          ← Discover
        </Link>
        <p className="mkt-kicker mt-6">{typeLabel}</p>
        <h1 className="mkt-heading mt-3">{content.title}</h1>
        {content.subtitle ? (
          <p className="mt-3 text-lg text-neutral-600">{content.subtitle}</p>
        ) : null}
        {content.author?.display_name ? (
          <p className="mt-2 text-sm text-neutral-500">By {content.author.display_name}</p>
        ) : null}

        {content.cover_image_url && content.content_type !== "video" ? (
          <div className="relative mt-8 aspect-[16/10] w-full overflow-hidden rounded-2xl border border-neutral-200">
            <Image
              src={content.cover_image_url}
              alt=""
              fill
              className="object-cover"
              sizes="(max-width: 768px) 100vw, 720px"
              priority
            />
          </div>
        ) : null}

        {content.content_type === "video" && youtubeId ? (
          <div className="mt-8 aspect-video w-full overflow-hidden rounded-2xl border border-neutral-200 bg-neutral-900">
            <iframe
              title={content.title}
              src={`https://www.youtube.com/embed/${youtubeId}`}
              className="h-full w-full"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
            />
          </div>
        ) : null}

        {content.content_type === "video" && !youtubeId && content.external_url ? (
          <p className="mt-8">
            <a
              href={content.external_url}
              target="_blank"
              rel="noreferrer"
              className="font-medium text-neutral-900 underline underline-offset-4"
            >
              Watch video →
            </a>
          </p>
        ) : null}

        {content.summary ? <p className="mkt-lead mt-8">{content.summary}</p> : null}

        {content.verse_text ? (
          <blockquote className="mt-8 border-l-2 border-[#d99a12] pl-4 text-lg leading-relaxed text-neutral-800">
            {content.primary_verse_reference ? (
              <span className="mb-2 block text-sm font-medium text-neutral-500">
                {content.primary_verse_reference}
                {content.bible_version ? ` · ${content.bible_version}` : ""}
              </span>
            ) : null}
            {content.verse_text}
          </blockquote>
        ) : null}

        {content.body
          ? content.body.split("\n\n").map((paragraph) => (
              <p key={paragraph.slice(0, 48)} className="mkt-lead mt-6">
                {paragraph}
              </p>
            ))
          : null}

        {content.sections.length > 0 ? (
          <div className="mt-10 space-y-10">
            {content.sections.map((section) => (
              <section key={section.id}>
                {section.title ? (
                  <h2 className="text-xl font-semibold text-neutral-900">{section.title}</h2>
                ) : null}
                {section.image_url ? (
                  <div className="relative mt-4 aspect-[16/10] w-full overflow-hidden rounded-2xl border border-neutral-200">
                    <Image
                      src={section.image_url}
                      alt={section.image_alt_text ?? ""}
                      fill
                      className="object-cover"
                      sizes="(max-width: 768px) 100vw, 720px"
                    />
                  </div>
                ) : null}
                {section.body
                  ? section.body.split("\n\n").map((paragraph) => (
                      <p key={paragraph.slice(0, 48)} className="mkt-lead mt-4">
                        {paragraph}
                      </p>
                    ))
                  : null}
              </section>
            ))}
          </div>
        ) : null}

        {content.content_type === "cartoon" && content.assets.length > 0 ? (
          <div className="mt-10 grid gap-4">
            {content.assets.map((asset) => (
              <figure
                key={asset.id}
                className="overflow-hidden rounded-2xl border border-neutral-200"
              >
                <div className="relative aspect-[4/3] w-full bg-neutral-50">
                  <Image
                    src={asset.url}
                    alt={asset.alt_text ?? ""}
                    fill
                    className="object-contain"
                    sizes="(max-width: 768px) 100vw, 720px"
                  />
                </div>
                {asset.caption ? (
                  <figcaption className="px-4 py-3 text-sm text-neutral-600">
                    {asset.caption}
                  </figcaption>
                ) : null}
              </figure>
            ))}
          </div>
        ) : null}

        {videoAsset && !youtubeId ? (
          <p className="mt-8">
            <a
              href={videoAsset.url}
              target="_blank"
              rel="noreferrer"
              className="font-medium underline underline-offset-4"
            >
              Open media →
            </a>
          </p>
        ) : null}

        {content.related_plans.length > 0 ? (
          <section className="mt-12 rounded-2xl border border-neutral-200 p-6">
            <p className="mkt-kicker">Related plans</p>
            <ul className="mt-4 space-y-3">
              {content.related_plans.map((plan) => (
                <li key={plan.id} className="text-sm text-neutral-700">
                  <span className="font-medium text-neutral-900">{plan.title}</span>
                  {plan.estimated_minutes ? (
                    <span className="text-neutral-500"> · ~{plan.estimated_minutes} min/ch</span>
                  ) : null}
                </li>
              ))}
            </ul>
          </section>
        ) : null}
      </MarketingContainer>
    </MarketingSection>
  );
}

export function ContentNotFound() {
  return (
    <MarketingSection className="!py-16">
      <MarketingContainer narrow>
        <h1 className="mkt-heading-sm">Content not found</h1>
        <p className="mkt-lead mt-4">This item is unavailable or unpublished.</p>
        <Link
          href="/discover"
          className="mt-6 inline-block font-medium underline underline-offset-4"
        >
          Back to Discover
        </Link>
      </MarketingContainer>
    </MarketingSection>
  );
}
