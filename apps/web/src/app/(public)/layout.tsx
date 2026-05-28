import type { Metadata, Viewport } from "next";

import { siteConfig } from "@/lib/site-config";

export const metadata: Metadata = {
  title: {
    default: `${siteConfig.name} — ${siteConfig.tagline}`,
    template: `%s — ${siteConfig.name}`,
  },
  description: siteConfig.description,
  applicationName: siteConfig.name,
  keywords: [
    "Bible reading tracker",
    "Bible reading plan",
    "Bible habit tracker",
    "Christian app",
    "Scripture reading",
    "Bible progress tracker",
    "Bible reading without overwhelm",
  ],
  authors: [{ name: siteConfig.name }],
  alternates: {
    canonical: "/",
  },
  openGraph: {
    type: "website",
    url: siteConfig.url,
    siteName: siteConfig.name,
    title: siteConfig.name,
    description:
      "Bible reading, without the overwhelm. Start small, track your progress, and build a gentle Scripture reading habit.",
  },
  twitter: {
    card: "summary",
    title: siteConfig.name,
    description:
      "Bible reading, without the overwhelm. Start small, track your progress, and build a gentle Scripture reading habit.",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#ffffff",
};

export default function PublicLayout({ children }: { children: React.ReactNode }) {
  return <div className="public-site min-h-screen">{children}</div>;
}
