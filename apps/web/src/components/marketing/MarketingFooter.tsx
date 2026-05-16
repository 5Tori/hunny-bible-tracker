import Link from "next/link";
import { siteConfig } from "@/lib/site-config";

export default function MarketingFooter() {
  const year = new Date().getFullYear();

  return (
    <footer className="hb-footer">
      <div className="hb-container hb-footer__inner">
        <div className="hb-footer__brand">
          <Link href="/" className="hb-brand" aria-label={siteConfig.name}>
            <span className="hb-brand__mark" aria-hidden>
              <span />
              <span />
              <span />
            </span>
            <span>{siteConfig.name}</span>
          </Link>
          <p>
            A gentle Bible reading tracker. Start small, return often, and build a
            rhythm of Scripture over time.
          </p>
        </div>
        <div className="hb-footer__links" aria-label="Footer navigation">
          <Link href="/privacy">Privacy</Link>
          <Link href="/support">Support</Link>
          <Link href="/terms">Terms</Link>
          <a href={`mailto:${siteConfig.supportEmail}`}>Contact</a>
        </div>
      </div>
      <div className="hb-container hb-footer__bottom">
        © {year} {siteConfig.name}. All rights reserved.
      </div>
    </footer>
  );
}
