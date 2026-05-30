'use client';

export function MessageShareButton({ title, path }: { title: string; path: string }) {
  return (
    <button
      type="button"
      className="rounded-full border border-neutral-200 px-4 py-2 text-sm font-medium text-neutral-800 transition hover:border-neutral-300"
      onClick={() => {
        const url = `${window.location.origin}${path}`;
        if (navigator.share) {
          void navigator.share({ title, url });
          return;
        }
        void navigator.clipboard.writeText(url);
      }}
    >
      Share
    </button>
  );
}
