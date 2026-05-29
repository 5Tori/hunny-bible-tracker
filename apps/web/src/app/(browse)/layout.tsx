import type { ReactNode } from "react";

import { AppPromoBanner } from "@/components/browse/AppPromoBanner";

/** DB (Hyperdrive) is only available at Worker runtime, not during CI prerender. */
export const dynamic = "force-dynamic";
import { SiteFooter, SiteHeader } from "@/components/public/SiteShell";

export default function BrowseLayout({ children }: { children: ReactNode }) {
  return (
    <div className="mkt-site min-h-screen">
      <SiteHeader />
      <main>{children}</main>
      <AppPromoBanner />
      <SiteFooter />
    </div>
  );
}
