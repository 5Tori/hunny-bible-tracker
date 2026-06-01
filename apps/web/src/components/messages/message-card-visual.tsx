import Image from 'next/image';

import type { PublicMessageCard } from '@/lib/messages';

/** Portrait ratio aligned with common phone screens (9:16). */
export const MESSAGE_CARD_ASPECT_CLASS = 'aspect-[9/16]';

/** Serif overlay type (Fraunces) — readable on photo backgrounds. */
const MESSAGE_CARD_OVERLAY_TEXT =
  'font-display text-center text-balance [font-feature-settings:"liga","kern"]';

export function formatMessageReference(message: PublicMessageCard) {
  if (!message.verseReference) return null;
  if (message.translation) {
    return `${message.verseReference} (${message.translation})`;
  }
  return message.verseReference;
}

export function MessageCardVisual({
  message,
  variant = 'tile',
  priority = false,
}: {
  message: PublicMessageCard;
  variant?: 'tile' | 'detail';
  priority?: boolean;
}) {
  const reference = formatMessageReference(message);
  const isDetail = variant === 'detail';
  const imageUrl = message.displayImageUrl ?? message.coverImageUrl;
  const showLiveTextOverlay = !message.hasCompositeImage;

  return (
    <div
      className={`relative overflow-hidden rounded-2xl border border-neutral-200 bg-neutral-900 ${MESSAGE_CARD_ASPECT_CLASS} w-full`}
    >
      {imageUrl ? (
        isDetail ? (
          <Image
            src={imageUrl}
            alt=""
            fill
            className="object-cover"
            sizes="(max-width: 768px) 100vw, 480px"
            priority={priority}
          />
        ) : (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={imageUrl}
            alt=""
            className="absolute inset-0 h-full w-full object-cover transition duration-300 group-hover:scale-[1.02]"
          />
        )
      ) : (
        <div className="absolute inset-0 bg-gradient-to-br from-neutral-800 via-neutral-700 to-neutral-900" />
      )}

      <div className="absolute inset-0 bg-black/15" aria-hidden />
      <div
        className={`absolute inset-0 ${
          isDetail
            ? 'bg-[radial-gradient(ellipse_92%_80%_at_50%_50%,rgba(0,0,0,0.62)_0%,rgba(0,0,0,0.32)_48%,transparent_82%)]'
            : 'bg-[radial-gradient(ellipse_88%_72%_at_50%_50%,rgba(0,0,0,0.55)_0%,rgba(0,0,0,0.26)_45%,transparent_78%)]'
        }`}
        aria-hidden
      />

      {showLiveTextOverlay ? (
      <div className="absolute inset-0 flex flex-col items-center justify-center p-4 text-white">
        <div className={`mx-auto w-full max-w-[92%] ${MESSAGE_CARD_OVERLAY_TEXT}`}>
          {message.verseText ? (
            <blockquote
              className={`mx-auto text-center ${
                isDetail
                  ? 'text-lg font-normal leading-[calc(1.625em+2px)] sm:text-xl md:text-2xl'
                  : 'text-[12px] font-normal leading-[18.5px]'
              }`}
            >
              {message.verseText}
            </blockquote>
          ) : (
            <p
              className={`mx-auto text-center text-white/70 ${
                isDetail ? 'text-base' : 'text-sm'
              }`}
            >
              Verse text coming soon
            </p>
          )}

          {reference ? (
            <p
              className={`mx-auto mt-3 text-center font-medium tracking-wide text-white/90 ${
                isDetail ? 'text-sm' : 'text-[11px]'
              }`}
            >
              {reference}
            </p>
          ) : null}
        </div>
      </div>
      ) : null}
    </div>
  );
}
