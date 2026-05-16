import Link from "next/link";
import { navLinks, siteConfig } from "@/lib/site-config";

export default function MarketingHeader() {
  return (
    <header className="hb-header">
      <div className="hb-container hb-header__inner">
        <Link href="/" className="hb-brand" aria-label={siteConfig.name}>
          <span className="hb-brand__mark" aria-hidden>
            <span />
            <span />
            <span />
          </span>
          <span>{siteConfig.shortName}</span>
        </Link>

        <nav className="hb-nav" aria-label="Primary navigation">
          {navLinks.map((link) => (
            <Link key={link.href} href={link.href} className="hb-nav__link">
              {link.label}
            </Link>
          ))}
          <a href={siteConfig.googlePlayUrl} className="hb-button hb-button--small hb-button--dark">
            Get the app
          </a>
        </nav>
      </div>
    </header>
  );
}
