import type { ReactNode } from "react";

import { MarketingProse } from "@/components/marketing/ui/MarketingProse";
import { PageContainer, SiteFooter, SiteHeader } from "@/components/public/SiteShell";

type LegalPageLayoutProps = {
  title: string;
  description?: string;
  lastUpdated: string;
  children: ReactNode;
};

export default function LegalPageLayout({
  title,
  description,
  lastUpdated,
  children,
}: LegalPageLayoutProps) {
  return (
    <>
      <SiteHeader />
      <PageContainer>
        <p className="mkt-kicker">Hunny Bible Tracker</p>
        <h1 className="mkt-heading mt-3">{title}</h1>
        {description ? <p className="mkt-lead mt-4 max-w-2xl">{description}</p> : null}
        <p className="mt-3 text-sm text-neutral-500">Last updated: {lastUpdated}</p>
        <div className="mt-10">
          <MarketingProse>{children}</MarketingProse>
        </div>
      </PageContainer>
      <SiteFooter />
    </>
  );
}
