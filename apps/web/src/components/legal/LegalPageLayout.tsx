import MarketingFooter from "@/components/marketing/MarketingFooter";
import MarketingHeader from "@/components/marketing/MarketingHeader";

type LegalPageLayoutProps = {
  title: string;
  description?: string;
  lastUpdated: string;
  children: React.ReactNode;
};

export default function LegalPageLayout({
  title,
  description,
  lastUpdated,
  children,
}: LegalPageLayoutProps) {
  return (
    <>
      <MarketingHeader />
      <main className="hb-legal-page">
        <div className="hb-container">
          <article className="hb-legal-card">
            <p className="hb-kicker">Hunny Bible Tracker</p>
            <h1>{title}</h1>
            {description ? <p className="hb-legal-card__description">{description}</p> : null}
            <p className="hb-legal-card__updated">Last updated: {lastUpdated}</p>
            <div className="hb-legal-content">{children}</div>
          </article>
        </div>
      </main>
      <MarketingFooter />
    </>
  );
}
