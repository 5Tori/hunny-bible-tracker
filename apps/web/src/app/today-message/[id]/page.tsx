import type { Metadata } from 'next';
import Link from 'next/link';

import { getPublishedTodayMessageById } from '@/lib/today-messages';

interface PageProps {
  params: Promise<{ id: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { id } = await params;
  const message = await getPublishedTodayMessageById(id);
  if (!message) {
    return {
      title: 'Today’s Message | Hunny Bible Tracker',
      description: 'A daily Bible message from Hunny Bible Tracker.',
    };
  }

  const title = `${message.verse_reference} | Hunny Bible Tracker`;
  const description =
    message.verse_text || message.message || 'A daily Bible message from Hunny Bible Tracker.';

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      type: 'article',
      images: message.image_url ? [{ url: message.image_url }] : undefined,
    },
    twitter: {
      card: message.image_url ? 'summary_large_image' : 'summary',
      title,
      description,
      images: message.image_url ? [message.image_url] : undefined,
    },
  };
}

export default async function TodayMessagePage({ params }: PageProps) {
  const { id } = await params;
  const message = await getPublishedTodayMessageById(id);

  if (!message) {
    return (
      <main>
        <h1>Message not found</h1>
        <p className="lede">This daily message is unavailable or unpublished.</p>
        <Link href="/" className="btn">
          Go home
        </Link>
      </main>
    );
  }

  return (
    <main>
      <p className="eyebrow">Today’s Message</p>
      <h1>{message.verse_reference}</h1>
      {message.image_url ? (
        <img
          src={message.image_url}
          alt=""
          style={{
            width: '100%',
            maxHeight: 420,
            objectFit: 'cover',
            borderRadius: 8,
            border: '1px solid rgba(0,0,0,0.12)',
          }}
        />
      ) : null}
      {message.verse_text ? <p className="lede">{message.verse_text}</p> : null}
      {message.message ? <p>{message.message}</p> : null}
      <p>
        {message.heart_count} hearts · {message.share_count} shares
      </p>
      <Link href="/" className="btn">
        Open Hunny Bible Tracker
      </Link>
    </main>
  );
}
