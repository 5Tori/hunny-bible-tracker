import type { Metadata } from "next";

import {
  TodayMessageNotFound,
  TodayMessageView,
} from "@/components/browse/TodayMessageView";
import { getPublishedTodayMessageByShareSlug } from "@/lib/today-messages";

interface PageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const message = await getPublishedTodayMessageByShareSlug(slug, "en");
  if (!message) {
    return {
      title: "Today's Message",
      description: "A daily Bible message from Hunny Bible Tracker.",
      alternates: { canonical: `/today-message/${slug}` },
    };
  }

  const referenceLabel = message.bible_version
    ? `${message.verse_reference} · ${message.bible_version}`
    : message.verse_reference;
  const title = message.hint_title || referenceLabel;
  const description =
    message.hint_summary ||
    message.verse_text ||
    message.linked_content?.summary ||
    "A daily Bible message from Hunny Bible Tracker.";
  const previewImage = message.share_image_url || message.image_url;

  return {
    title,
    description,
    alternates: {
      canonical: `/today-message/${slug}`,
    },
    openGraph: {
      title,
      description,
      type: "article",
      images: previewImage ? [{ url: previewImage }] : undefined,
    },
    twitter: {
      card: previewImage ? "summary_large_image" : "summary",
      title,
      description,
      images: previewImage ? [previewImage] : undefined,
    },
  };
}

export default async function TodayMessagePage({ params }: PageProps) {
  const { slug } = await params;
  const message = await getPublishedTodayMessageByShareSlug(slug, "en");

  if (!message) {
    return <TodayMessageNotFound />;
  }

  return <TodayMessageView message={message} />;
}
