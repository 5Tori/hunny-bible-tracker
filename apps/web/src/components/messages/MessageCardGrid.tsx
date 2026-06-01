import Link from 'next/link';

import { MessageCardActions } from '@/components/messages/MessageCardActions';
import { MessageCardClassification } from '@/components/messages/MessageCardClassification';
import {
  formatMessageReference,
  MessageCardVisual,
} from '@/components/messages/message-card-visual';
import type { PublicMessageCard } from '@/lib/messages';

export function MessageCardTile({ message }: { message: PublicMessageCard }) {
  const shareTitle = formatMessageReference(message) || message.title;

  return (
    <article className="flex flex-col">
      <Link href={message.messagesUrl} className="group block">
        <MessageCardVisual message={message} variant="tile" />
      </Link>
      <MessageCardClassification message={message} className="mt-2.5" />
      <MessageCardActions
        slug={message.slug}
        shareTitle={shareTitle}
        sharePath={message.messagesUrl}
        heartCount={message.heartCount}
        shareCount={message.shareCount}
        saveCount={message.saveCount}
        className="mt-2"
      />
    </article>
  );
}

export function MessageCardGrid({ messages }: { messages: PublicMessageCard[] }) {
  if (messages.length === 0) {
    return (
      <p className="py-12 text-neutral-600">
        No messages match these filters yet. Try another category or search phrase.
      </p>
    );
  }

  return (
    <div className="grid grid-cols-2 gap-2 lg:grid-cols-4 lg:gap-4">
      {messages.map((message) => (
        <MessageCardTile key={message.id} message={message} />
      ))}
    </div>
  );
}
