'use client';

import { useEffect, useState, type ReactNode } from 'react';

import {
  formatEngagementCount,
  type MessageEngagementCounts,
} from '@/lib/message-engagement';

type MessageCardActionsProps = {
  slug: string;
  shareTitle: string;
  sharePath: string;
  heartCount: number;
  shareCount: number;
  saveCount: number;
  className?: string;
};

function heartStorageKey(slug: string) {
  return `hunny.message.heart.${slug}`;
}

function saveStorageKey(slug: string) {
  return `hunny.message.save.${slug}`;
}

async function postEngagement(slug: string, action: 'heart' | 'save' | 'share') {
  const response = await fetch(`/api/v1/messages/${slug}/${action}`, { method: 'POST' });
  if (!response.ok) return null;
  const body = (await response.json()) as { counts?: MessageEngagementCounts };
  return body.counts ?? null;
}

function ActionButton({
  label,
  count,
  active,
  disabled,
  onClick,
  children,
}: {
  label: string;
  count: number;
  active?: boolean;
  disabled?: boolean;
  onClick: () => void;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      aria-label={label}
      aria-pressed={active}
      disabled={disabled}
      onClick={onClick}
      className={`inline-flex items-center gap-1 rounded-lg px-2 py-1.5 text-sm text-neutral-700 transition hover:bg-neutral-100 disabled:opacity-60 ${
        active ? 'text-[#c48400]' : ''
      }`}
    >
      {children}
      <span className="text-xs font-medium tabular-nums text-neutral-600">
        {formatEngagementCount(count)}
      </span>
    </button>
  );
}

function HeartIcon({ filled }: { filled: boolean }) {
  return (
    <svg
      viewBox="0 0 24 24"
      aria-hidden
      className={`h-5 w-5 ${filled ? 'fill-current' : 'fill-none'}`}
      stroke="currentColor"
      strokeWidth="1.8"
    >
      <path d="M12 20.5s-6.8-4.4-9-8.1C1.2 9.3 2.6 6 5.8 5.4c1.8-.3 3.5.4 4.6 1.7 1.1-1.3 2.8-2 4.6-1.7 3.2.6 4.6 3.9 2.8 7-2.2 3.7-9 8.1-9 8.1z" />
    </svg>
  );
}

function BookmarkIcon({ filled }: { filled: boolean }) {
  return (
    <svg
      viewBox="0 0 24 24"
      aria-hidden
      className={`h-5 w-5 ${filled ? 'fill-current' : 'fill-none'}`}
      stroke="currentColor"
      strokeWidth="1.8"
    >
      <path d="M6 4.5A1.5 1.5 0 0 1 7.5 3h9A1.5 1.5 0 0 1 18 4.5V20l-6-3.6L6 20V4.5z" />
    </svg>
  );
}

function ShareIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      aria-hidden
      className="h-5 w-5 fill-none"
      stroke="currentColor"
      strokeWidth="1.8"
    >
      <path d="M7 12v7h10v-7M12 4v10M8.5 7.5 12 4l3.5 3.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export function MessageCardActions({
  slug,
  shareTitle,
  sharePath,
  heartCount: initialHeartCount,
  shareCount: initialShareCount,
  saveCount: initialSaveCount,
  className = '',
}: MessageCardActionsProps) {
  const [counts, setCounts] = useState({
    heartCount: initialHeartCount,
    shareCount: initialShareCount,
    saveCount: initialSaveCount,
  });
  const [hearted, setHearted] = useState(false);
  const [saved, setSaved] = useState(false);
  const [pending, setPending] = useState<'heart' | 'save' | 'share' | null>(null);

  useEffect(() => {
    setCounts({
      heartCount: initialHeartCount,
      shareCount: initialShareCount,
      saveCount: initialSaveCount,
    });
  }, [initialHeartCount, initialShareCount, initialSaveCount]);

  useEffect(() => {
    setHearted(window.localStorage.getItem(heartStorageKey(slug)) === '1');
    setSaved(window.localStorage.getItem(saveStorageKey(slug)) === '1');
  }, [slug]);

  const handleHeart = async () => {
    if (hearted || pending) return;
    setPending('heart');
    try {
      const next = await postEngagement(slug, 'heart');
      if (next) setCounts(next);
      window.localStorage.setItem(heartStorageKey(slug), '1');
      setHearted(true);
    } finally {
      setPending(null);
    }
  };

  const handleSave = async () => {
    if (saved || pending) return;
    setPending('save');
    try {
      const next = await postEngagement(slug, 'save');
      if (next) setCounts(next);
      window.localStorage.setItem(saveStorageKey(slug), '1');
      setSaved(true);
    } finally {
      setPending(null);
    }
  };

  const handleShare = async () => {
    if (pending) return;
    setPending('share');
    try {
      const url = `${window.location.origin}${sharePath}`;
      if (navigator.share) {
        await navigator.share({ title: shareTitle, url });
      } else {
        await navigator.clipboard.writeText(url);
      }
      const next = await postEngagement(slug, 'share');
      if (next) setCounts(next);
    } catch (error) {
      if (error instanceof DOMException && error.name === 'AbortError') return;
      throw error;
    } finally {
      setPending(null);
    }
  };

  return (
    <div className={`flex flex-nowrap items-center justify-between ${className}`.trim()}>
      <div className="flex items-center gap-1 sm:gap-2">
        <ActionButton
          label="Heart this message"
          count={counts.heartCount}
          active={hearted}
          disabled={hearted || pending === 'heart'}
          onClick={() => void handleHeart()}
        >
          <HeartIcon filled={hearted} />
        </ActionButton>
        <ActionButton
          label="Save this message"
          count={counts.saveCount}
          active={saved}
          disabled={saved || pending === 'save'}
          onClick={() => void handleSave()}
        >
          <BookmarkIcon filled={saved} />
        </ActionButton>
      </div>
      <ActionButton
        label="Share this message"
        count={counts.shareCount}
        disabled={pending === 'share'}
        onClick={() => void handleShare()}
      >
        <ShareIcon />
      </ActionButton>
    </div>
  );
}
