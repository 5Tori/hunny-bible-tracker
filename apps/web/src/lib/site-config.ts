const DEFAULT_SITE_URL = "http://127.0.0.1:3000";

/** Production workers.dev hostname — 301 to canonical domain (preview `*.workers.dev` URLs are excluded). */
export const LEGACY_WORKER_HOST = "hunny-bible-tracker-web.hunnybibletracker.workers.dev";

/** Apex host for production redirects. Set `CANONICAL_SITE_HOST` in wrangler (runtime, not build-inlined). */
export const PRODUCTION_CANONICAL_HOST = "hunnybibletracker.com";

function normalizeSiteUrl(raw: string | undefined): string {
  const trimmed = raw?.trim() || DEFAULT_SITE_URL;
  try {
    const url = new URL(trimmed.endsWith("/") ? trimmed : `${trimmed}/`);
    return url.origin;
  } catch {
    return DEFAULT_SITE_URL;
  }
}

export const siteConfig = {
  name: "Hunny Bible Tracker",
  shortName: "Hunny",
  tagline: "Bible reading, without the overwhelm.",
  description:
    "Start with short, approachable Bible stories, track your progress, and build a gentle Bible reading habit at your own pace.",
  url: normalizeSiteUrl(process.env.NEXT_PUBLIC_SITE_URL),
  supportEmail: "hunnybibletracker@gmail.com",
  googlePlayUrl: "https://play.google.com/store/apps/details?id=com.hunnybibletracker.app",
  androidTesterGroupUrl: "https://groups.google.com/g/hunny-bible-tracker-closed-testers",
  androidTesterOptInUrl: "https://play.google.com/apps/testing/com.hunnybibletracker.app",
  iosStatusLabel: "iOS coming soon",
} as const;

export const navLinks = [
  { href: "/#plans", label: "Plans" },
  { href: "/#progress", label: "Progress" },
  { href: "/#faq", label: "FAQ" },
  { href: "/support", label: "Support" },
] as const;

export function getCanonicalHost(): string {
  return new URL(siteConfig.url).host.toLowerCase();
}

/** Host for middleware redirects — prefers Worker runtime env over build-inlined NEXT_PUBLIC_* */
export function getMiddlewareCanonicalHost(): string {
  const fromWorker = process.env.CANONICAL_SITE_HOST?.trim().toLowerCase();
  if (fromWorker) {
    return fromWorker.replace(/^https?:\/\//, "").split("/")[0] ?? PRODUCTION_CANONICAL_HOST;
  }
  const fromPublic = process.env.NEXT_PUBLIC_SITE_URL?.trim();
  if (fromPublic) {
    try {
      return new URL(fromPublic).host.toLowerCase();
    } catch {
      /* fall through */
    }
  }
  return PRODUCTION_CANONICAL_HOST;
}

export function absoluteUrl(path: string): string {
  const normalizedPath = path.startsWith("/") ? path : `/${path}`;
  return `${siteConfig.url}${normalizedPath}`;
}
