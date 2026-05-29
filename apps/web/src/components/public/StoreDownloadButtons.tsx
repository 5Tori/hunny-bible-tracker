import Image from "next/image";
import type { ComponentProps, ReactNode } from "react";

export const STORE_BADGES = {
  googlePlay: {
    src: "/store/google-play-icon.png",
    width: 79,
    height: 88,
  },
  appleWhite: {
    src: "/store/apple-logo-white.png",
    width: 74,
    height: 88,
  },
} as const;

const storeButtonClass =
  "inline-flex items-center gap-3 rounded-xl px-5 py-3 transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900";

export function GooglePlayStoreBadgeIcon({
  className = "h-7 w-auto shrink-0",
}: {
  className?: string;
}) {
  const badge = STORE_BADGES.googlePlay;
  return (
    <Image
      src={badge.src}
      alt=""
      width={badge.width}
      height={badge.height}
      className={className}
      aria-hidden
    />
  );
}

export function AppleStoreBadgeIcon({
  className = "h-7 w-auto shrink-0",
}: {
  className?: string;
}) {
  const badge = STORE_BADGES.appleWhite;
  return (
    <Image
      src={badge.src}
      alt=""
      width={badge.width}
      height={badge.height}
      className={className}
      aria-hidden
    />
  );
}

export function StoreDownloadLabel({
  caption,
  store,
}: {
  caption: string;
  store: string;
}) {
  return (
    <span className="text-left leading-tight">
      <span className="block text-[10px] uppercase tracking-[0.15em] opacity-70">
        {caption}
      </span>
      <span className="block text-sm font-medium">{store}</span>
    </span>
  );
}

export function AppStoreDownloadButton({
  disabled = true,
  href = "#",
  caption = "Coming soon to",
  store = "App Store",
  className = "",
}: {
  disabled?: boolean;
  href?: string;
  caption?: string;
  store?: string;
  className?: string;
}) {
  return (
    <a
      href={href}
      aria-disabled={disabled}
      className={`${storeButtonClass} ${
        disabled
          ? "pointer-events-none bg-neutral-900/55 text-white/85"
          : "bg-neutral-900 text-white hover:bg-black"
      } ${className}`}
    >
      <AppleStoreBadgeIcon />
      <StoreDownloadLabel caption={caption} store={store} />
    </a>
  );
}

export function GooglePlayDownloadButtonShell({
  children,
  className = "",
  ...props
}: {
  children: ReactNode;
  className?: string;
} & Omit<ComponentProps<"button">, "children">) {
  return (
    <button
      type="button"
      className={`${storeButtonClass} bg-neutral-900 text-white hover:bg-black ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
