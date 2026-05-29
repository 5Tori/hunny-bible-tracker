import Link from "next/link";
import { BrandLogo } from "@/components/public/BrandLogo";
import { siteConfig } from "@/lib/site-config";

export default function MarketingFooter() {
  const year = new Date().getFullYear();

  return (
    <footer className="hb-footer">
      <div className="hb-container hb-footer__inner">
        <div className="hb-footer__brand">
          <Link href="/" className="hb-brand" aria-label={siteConfig.name}>
            <BrandLogo className="h-[23px] w-auto shrink-0" />
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
