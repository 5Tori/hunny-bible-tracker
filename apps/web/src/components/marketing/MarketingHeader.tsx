import Link from "next/link";
import { BrandLogo } from "@/components/public/BrandLogo";
import { AndroidTesterCta } from "@/components/public/AndroidTesterCta";
import { navLinks, siteConfig } from "@/lib/site-config";

export default function MarketingHeader() {
  return (
    <header className="hb-header">
      <div className="hb-container hb-header__inner">
        <Link href="/" className="hb-brand" aria-label={siteConfig.name}>
          <BrandLogo className="h-[23px] w-auto shrink-0" priority />
          <span>{siteConfig.name}</span>
        </Link>

        <nav className="hb-nav" aria-label="Primary navigation">
          {navLinks.map((link) => (
            <Link key={link.href} href={link.href} className="hb-nav__link">
              {link.label}
            </Link>
          ))}
          <AndroidTesterCta className="hb-button hb-button--small hb-button--dark" />
        </nav>
      </div>
    </header>
  );
}
