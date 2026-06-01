import type { Metadata } from "next";
import { redirect } from "next/navigation";

import { ContentDetail, ContentNotFound } from "@/components/browse/ContentDetail";
import {
  getPublishedContentByIdentifier,
  getPublishedDiscoverContentByIdentifier,
} from "@/lib/content";
import { isDiscoverContentType } from "@/lib/discover-content";
import { discoverContentDescription } from "@/lib/discover-content-display";

export const revalidate = 300;

interface PageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const content = await getPublishedDiscoverContentByIdentifier(slug, "en");
  if (!content) {
    return {
      title: "Discover",
      alternates: { canonical: `/content/${slug}` },
    };
  }

  const description = discoverContentDescription(content);

  return {
    title: content.title,
    description,
    alternates: { canonical: `/content/${slug}` },
    openGraph: {
      title: content.title,
      description,
      type: "article",
      images: content.cover_image_url ? [{ url: content.cover_image_url }] : undefined,
    },
    twitter: {
      card: content.cover_image_url ? "summary_large_image" : "summary",
      title: content.title,
      description,
      images: content.cover_image_url ? [content.cover_image_url] : undefined,
    },
  };
}

export default async function ContentPage({ params }: PageProps) {
  const { slug } = await params;
  const content = await getPublishedContentByIdentifier(slug, "en");

  if (!content) {
    return <ContentNotFound />;
  }

  if (content.content_type === "message") {
    redirect(`/messages/${content.slug}`);
  }

  if (!isDiscoverContentType(content.content_type)) {
    return <ContentNotFound />;
  }

  return <ContentDetail content={content} />;
}
