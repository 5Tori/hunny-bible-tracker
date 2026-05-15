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

  const referenceLabel = message.bible_version
    ? `${message.verse_reference} · ${message.bible_version}`
    : message.verse_reference;
  const title = `${message.article_title || referenceLabel} | Hunny Bible Tracker`;
  const description =
    message.hint_summary ||
    message.article_body ||
    message.verse_text ||
    message.message ||
    'A daily Bible message from Hunny Bible Tracker.';

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
      {message.bible_version ? <p className="eyebrow">{message.bible_version}</p> : null}
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
      {message.article_title ? <h2>{message.article_title}</h2> : null}
      {message.article_body
        ? message.article_body.split('\n\n').map((paragraph) => <p key={paragraph}>{paragraph}</p>)
        : null}
      {message.related_plan_title ? (
        <section>
          <p className="eyebrow">Read in context</p>
          <h2>{message.related_plan_title}</h2>
          <p>
            {message.related_plan_chapters ?? 0} chapters
            {message.related_plan_minutes ? ` · ~${message.related_plan_minutes} min` : ''}
          </p>
        </section>
      ) : null}
      <p>
        {message.heart_count} hearts · {message.share_count} shares
      </p>
      <Link href="/" className="btn">
        Open Hunny Bible Tracker
      </Link>
    </main>
  );
}
