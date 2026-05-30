import type { Metadata } from "next";

import { ContentDetail, ContentNotFound } from "@/components/browse/ContentDetail";
import { getPublishedContentByIdentifier } from "@/lib/content";

export const dynamic = "force-dynamic";

interface PageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const content = await getPublishedContentByIdentifier(slug, "en");
  if (!content) {
    return {
      title: "Content",
      alternates: { canonical: `/content/${slug}` },
    };
  }

  const description =
    content.summary ||
    content.subtitle ||
    content.body?.slice(0, 160) ||
    "Explore Scripture with Hunny Bible Tracker.";

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

  return <ContentDetail content={content} />;
}
