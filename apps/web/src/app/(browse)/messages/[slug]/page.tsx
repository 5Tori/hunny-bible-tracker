import type { Metadata } from "next";

import { MessageDetailView, MessageNotFound } from "@/components/messages/MessageDetailView";
import { getPublishedMessageBySlug, getPublishedMessages } from "@/lib/messages";

export const revalidate = 300;

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
    message.context ||
    message.hint ||
    message.verseText ||
    "A gentle Bible message from Hunny Bible Tracker.";
  const pageTitle = message.verseReference
    ? message.translation
      ? `${message.verseReference} · ${message.translation}`
      : message.verseReference
    : message.title;

  return {
    title: pageTitle,
    description,
    alternates: { canonical: message.messagesUrl },
    openGraph: {
      title: pageTitle,
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
