import Image from "next/image";
import Link from "next/link";

import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import { RelatedPlansSection } from "@/components/browse/RelatedPlansSection";
import { ContentGalleryCarousel } from "@/components/browse/ContentGalleryCarousel";
import { DiscoverPostSections } from "@/components/browse/DiscoverPostSections";
import type { ContentWithRelations } from "@/lib/content";
import { discoverSectionsForDisplay } from "@/lib/discover-blocks";
import {
  shouldShowDiscoverCoverOnDetail,
  shouldShowDiscoverSummaryOnDetail,
} from "@/lib/discover-content-display";
import { discoverContentTypeLabel, isDiscoverGalleryAsset } from "@/lib/discover-content";
import { getYoutubeVideoId } from "@/lib/youtube";

export function ContentDetail({ content }: { content: ContentWithRelations }) {
  const category = content.content_type;
  const typeLabel = discoverContentTypeLabel(category);
  const youtubeId = getYoutubeVideoId(content.external_url);
  const videoAsset = content.assets.find(
    (asset) => asset.asset_type === "video" || asset.mime_type?.startsWith("video/"),
  );

  const gallerySlides = [...content.assets]
    .filter((asset) => asset.url && isDiscoverGalleryAsset(asset.asset_role))
    .sort((a, b) => a.order_index - b.order_index)
    .map((asset) => ({
      id: asset.id,
      url: asset.url,
      alt: asset.alt_text ?? "",
      caption: asset.caption,
    }));

  const displaySections = discoverSectionsForDisplay(content);
  const showCover = shouldShowDiscoverCoverOnDetail(content, {
    hasYoutube: Boolean(youtubeId),
    slideCount: gallerySlides.length,
  });
  const showSummary = shouldShowDiscoverSummaryOnDetail(content);
  const isCartoon = category === "cartoon";
  const slidesBeforeBlocks = isCartoon && gallerySlides.length > 0;

  const header = (
    <>
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
    </>
  );

  const coverImage = showCover ? (
    <div className="relative mt-8 aspect-[16/10] w-full overflow-hidden rounded-2xl border border-neutral-200">
      <Image
        src={content.cover_image_url!}
        alt=""
        fill
        className="object-cover"
        sizes="(max-width: 768px) 100vw, 720px"
        priority
      />
    </div>
  ) : null;

  const youtubeEmbed = youtubeId ? (
    <div className="mt-8 aspect-video w-full overflow-hidden rounded-2xl border border-neutral-200 bg-neutral-900">
      <iframe
        title={content.title}
        src={`https://www.youtube.com/embed/${youtubeId}`}
        className="h-full w-full"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
      />
    </div>
  ) : null;

  const externalVideoLink =
    !youtubeId && content.external_url ? (
      <p className="mt-8">
        <a
          href={content.external_url}
          target="_blank"
          rel="noreferrer"
          className="font-medium text-neutral-900 underline underline-offset-4"
        >
          Open video →
        </a>
      </p>
    ) : null;

  const summaryBlock = showSummary ? (
    <p className="mkt-lead mt-8">{content.summary}</p>
  ) : null;

  const sectionsBlock =
    displaySections.length > 0 ? (
      <DiscoverPostSections
        sections={displaySections}
        className={showSummary || showCover || youtubeId ? "mt-10" : "mt-8"}
      />
    ) : null;

  const galleryBlock =
    gallerySlides.length > 0 ? (
      <ContentGalleryCarousel
        slides={gallerySlides}
        className={slidesBeforeBlocks && !showSummary ? "mt-8" : undefined}
      />
    ) : null;

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer narrow>
        {header}

        {category === "video" ? (
          <>
            {youtubeEmbed}
            {externalVideoLink}
            {coverImage}
            {summaryBlock}
            {sectionsBlock}
            {galleryBlock}
          </>
        ) : null}

        {category === "essay" ? (
          <>
            {coverImage}
            {summaryBlock}
            {sectionsBlock}
            {galleryBlock}
          </>
        ) : null}

        {category === "cartoon" ? (
          <>
            {coverImage}
            {summaryBlock}
            {slidesBeforeBlocks ? galleryBlock : null}
            {sectionsBlock}
            {!slidesBeforeBlocks ? galleryBlock : null}
          </>
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
          <RelatedPlansSection plans={content.related_plans} />
        ) : null}
      </MarketingContainer>
    </MarketingSection>
  );
}

export function ContentNotFound() {
  return (
    <MarketingSection className="!py-16">
      <MarketingContainer narrow>
        <h1 className="mkt-heading-sm">Post not found</h1>
        <p className="mkt-lead mt-4">This Discover item is unavailable or unpublished.</p>
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
