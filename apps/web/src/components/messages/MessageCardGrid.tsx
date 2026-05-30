import Link from "next/link";

import type { PublicMessageCard } from "@/lib/messages";

export function MessageCardTile({ message }: { message: PublicMessageCard }) {
  return (
    <Link
      href={message.messagesUrl}
      className="group flex flex-col overflow-hidden rounded-2xl border border-neutral-200 bg-white transition hover:border-neutral-300 hover:shadow-sm"
    >
      <div className="relative aspect-[4/3] bg-neutral-100">
        {message.coverImageUrl ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={message.coverImageUrl}
            alt=""
            className="h-full w-full object-cover transition group-hover:scale-[1.02]"
          />
        ) : (
          <div className="flex h-full flex-col items-center justify-center gap-2 px-6 text-center">
            {message.verseReference ? (
              <p className="text-xs font-medium uppercase tracking-wide text-[#d99a12]">
                {message.verseReference}
              </p>
            ) : null}
            {message.verseText ? (
              <p className="line-clamp-4 text-sm leading-relaxed text-neutral-700">
                {message.verseText}
              </p>
            ) : (
              <p className="text-sm text-neutral-400">Message</p>
            )}
          </div>
        )}
        <span className="absolute left-3 top-3 rounded-full bg-white/95 px-2.5 py-0.5 text-[11px] font-medium text-neutral-700">
          {message.primaryCategoryLabel || "Message"}
        </span>
      </div>
      <div className="flex flex-1 flex-col p-5">
        <h2 className="text-base font-semibold leading-snug text-neutral-900 group-hover:text-black">
          {message.title}
        </h2>
        {message.subtitle ? (
          <p className="mt-1 text-sm text-neutral-500">{message.subtitle}</p>
        ) : null}
        {message.shortReflection ? (
          <p className="mt-2 line-clamp-2 text-sm leading-relaxed text-neutral-600">
            {message.shortReflection}
          </p>
        ) : null}
        {message.situationLabels.length > 0 ? (
          <p className="mt-auto pt-4 text-xs text-neutral-500">
            {message.situationLabels.slice(0, 2).join(" · ")}
          </p>
        ) : null}
      </div>
    </Link>
  );
}

export function MessageCardGrid({ messages }: { messages: PublicMessageCard[] }) {
  if (messages.length === 0) {
    return (
      <p className="mt-12 text-neutral-600">
        No messages match these filters yet. Try another category or search phrase.
      </p>
    );
  }

  return (
    <div className="mt-10 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
      {messages.map((message) => (
        <MessageCardTile key={message.id} message={message} />
      ))}
    </div>
  );
}
