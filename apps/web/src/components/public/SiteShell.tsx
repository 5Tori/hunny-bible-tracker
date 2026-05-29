import Link from "next/link";
import type { ReactNode } from "react";

import { BrandLogo } from "@/components/public/BrandLogo";
import { AndroidTesterCta } from "@/components/public/AndroidTesterCta";
import { siteConfig } from "@/lib/site-config";

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-40 border-b border-border/60 bg-background/80 backdrop-blur-md">
      <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8">
        <Link href="/" className="flex items-center gap-2.5">
          <BrandLogo className="h-7 w-auto shrink-0" priority />
          <span className="font-display text-lg tracking-normal text-foreground">
            {siteConfig.name}
          </span>
        </Link>
        <nav className="flex items-center gap-1 text-sm">
          <Link
            href="/support"
            className="rounded-full px-3 py-2 text-muted-foreground transition hover:text-foreground"
          >
            Support
          </Link>
          <AndroidTesterCta variant="header" />
        </nav>
      </div>
    </header>
  );
}

export function SiteFooter() {
  return (
    <footer className="mt-24 border-t border-border/60 bg-cream/40">
      <div className="mx-auto max-w-6xl px-5 py-12 sm:px-8">
        <div className="flex flex-col gap-8 sm:flex-row sm:items-start sm:justify-between">
          <div className="max-w-sm">
            <div className="flex items-center gap-2.5">
              <BrandLogo className="h-6 w-auto shrink-0" />
              <span className="font-display text-base">Hunny Bible Tracker</span>
            </div>
            <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
              A gentle Bible reading habit tracker. Start small. Discover the
              stories.
            </p>
          </div>
          <div className="grid grid-cols-2 gap-8 text-sm sm:grid-cols-3">
            <FooterCol title="Product">
              <FooterLink href="/">Home</FooterLink>
              <FooterLink href="/support">Support</FooterLink>
            </FooterCol>
            <FooterCol title="Legal">
              <FooterLink href="/privacy">Privacy</FooterLink>
              <FooterLink href="/terms">Terms</FooterLink>
            </FooterCol>
            <FooterCol title="Contact">
              <li>
                <a
                  href={`mailto:${siteConfig.supportEmail}`}
                  className="text-muted-foreground transition hover:text-foreground"
                >
                  {siteConfig.supportEmail}
                </a>
              </li>
            </FooterCol>
          </div>
        </div>
        <div className="mt-10 flex flex-col gap-2 border-t border-border/60 pt-6 text-xs text-muted-foreground sm:flex-row sm:items-center sm:justify-between">
          <p>© {new Date().getFullYear()} Hunny Bible Tracker. All rights reserved.</p>
          <p>Made with care for readers, beginners, and returners.</p>
        </div>
      </div>
    </footer>
  );
}

function FooterCol({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div>
      <p className="mb-3 text-xs font-medium uppercase tracking-[0.16em] text-foreground/70">
        {title}
      </p>
      <ul className="space-y-2">{children}</ul>
    </div>
  );
}

function FooterLink({ href, children }: { href: string; children: ReactNode }) {
  return (
    <li>
      <Link
        href={href}
        className="text-muted-foreground transition hover:text-foreground"
      >
        {children}
      </Link>
    </li>
  );
}

export function PageContainer({ children }: { children: ReactNode }) {
  return (
    <main className="mx-auto max-w-3xl px-5 py-14 sm:px-8 sm:py-20">
      {children}
    </main>
  );
}

export function Prose({ children }: { children: ReactNode }) {
  return (
    <div className="space-y-5 text-[15px] leading-relaxed text-foreground/80 [&_a]:text-honey-ink [&_a]:underline [&_a]:underline-offset-2 [&_h2]:mt-10 [&_h2]:text-xl [&_h2]:text-foreground [&_h3]:mt-6 [&_h3]:text-base [&_h3]:font-medium [&_h3]:text-foreground [&_p]:leading-relaxed [&_strong]:text-foreground [&_ul]:list-disc [&_ul]:space-y-1.5 [&_ul]:pl-5">
      {children}
    </div>
  );
}
