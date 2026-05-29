import type { Metadata, Viewport } from "next";

import { PublicAnalytics } from "@/components/public/PublicAnalytics";
import { WebsiteJsonLd } from "@/components/public/WebsiteJsonLd";
import { getGoogleSiteVerification } from "@/lib/analytics-config";
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
    locale: "en_US",
    title: siteConfig.name,
    description:
      "Bible reading, without the overwhelm. Start small, track your progress, and build a gentle Scripture reading habit.",
    images: [
      {
        url: "/icon.png",
        width: 512,
        height: 512,
        alt: siteConfig.name,
      },
    ],
  },
  twitter: {
    card: "summary",
    title: siteConfig.name,
    description:
      "Bible reading, without the overwhelm. Start small, track your progress, and build a gentle Scripture reading habit.",
    images: ["/icon.png"],
  },
  robots: {
    index: true,
    follow: true,
  },
  ...(getGoogleSiteVerification()
    ? { verification: { google: getGoogleSiteVerification()! } }
    : {}),
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#ffffff",
};

export default function PublicLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="public-site min-h-screen">
      <PublicAnalytics />
      <WebsiteJsonLd />
      {children}
    </div>
  );
}
