import type { Metadata } from "next";

import { MessageDetailView, MessageNotFound } from "@/components/messages/MessageDetailView";
import { PUBLIC_CATALOG_REVALIDATE_SECONDS } from "@/lib/http/public-cache";
import { getPublishedMessageBySlug, getPublishedMessages } from "@/lib/messages";

export const revalidate = PUBLIC_CATALOG_REVALIDATE_SECONDS;

interface PageProps {
  params: Promise<{ slug: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  const message = await getPublishedMessageBySlug(slug, "en");
  if (!message) {
    return {
      title: "Message",
      alternates: { canonical: `/messages/${slug}` },
    };
  }

  const description =
    message.shortReflection ||
    message.summary ||
    message.verseText ||
    "A gentle Bible message from Hunny Bible Tracker.";

  return {
    title: message.title,
    description,
    alternates: { canonical: message.messagesUrl },
    openGraph: {
      title: message.title,
      description,
      type: "article",
      images: message.coverImageUrl ? [{ url: message.coverImageUrl }] : undefined,
    },
  };
}

export default async function MessageDetailPage({ params }: PageProps) {
  const { slug } = await params;
  const message = await getPublishedMessageBySlug(slug, "en");

  if (!message) {
    return <MessageNotFound />;
  }

  const relatedMessages = message.primaryCategory
    ? (
        await getPublishedMessages({
          language: "en",
          category: message.primaryCategory,
          limit: 4,
        })
      ).filter((item) => item.slug !== message.slug)
    : [];

  return (
    <MessageDetailView message={message} relatedMessages={relatedMessages.slice(0, 3)} />
  );
}
