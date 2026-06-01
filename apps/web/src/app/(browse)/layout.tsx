import type { ReactNode } from "react";

import { AppPromoBanner } from "@/components/browse/AppPromoBanner";
import { OfflineDevBanner } from "@/components/dev/OfflineDevBanner";
import { SiteFooter, SiteHeader } from "@/components/public/SiteShell";

export default function BrowseLayout({ children }: { children: ReactNode }) {
  return (
    <div className="mkt-site min-h-screen">
      <OfflineDevBanner />
      <SiteHeader />
      <main>{children}</main>
      <AppPromoBanner />
      <SiteFooter />
    </div>
  );
}
