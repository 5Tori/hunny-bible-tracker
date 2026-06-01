import Link from "next/link";
import type { ReactNode } from "react";

import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingProse } from "@/components/marketing/ui/MarketingProse";
import { BrandLogo } from "@/components/public/BrandLogo";
import { SiteHeaderNav } from "@/components/public/SiteHeaderNav";
import { siteConfig } from "@/lib/site-config";

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-40 border-b border-neutral-200 bg-white/95 backdrop-blur-sm">
      <MarketingContainer>
        <div className="flex h-16 items-center justify-between gap-3">
          <Link href="/" className="flex min-w-0 items-center gap-2.5">
            <BrandLogo className="h-7 w-auto shrink-0" priority />
            <span className="hidden truncate text-base font-semibold tracking-tight text-neutral-900 md:inline">
              {siteConfig.name}
            </span>
          </Link>
          <SiteHeaderNav />
        </div>
      </MarketingContainer>
    </header>
  );
}

export function SiteFooter() {
  return (
    <footer className="border-t border-neutral-200 bg-white">
      <MarketingContainer className="py-12">
        <div className="flex flex-col gap-8 sm:flex-row sm:items-start sm:justify-between">
          <div className="max-w-sm">
            <div className="flex items-center gap-2.5">
              <BrandLogo className="h-6 w-auto shrink-0" />
              <span className="text-sm font-semibold text-neutral-900">
                {siteConfig.name}
              </span>
            </div>
            <p className="mt-3 text-sm leading-relaxed text-neutral-500">
              A gentle Bible reading habit tracker. Start small. Discover the
              stories.
            </p>
          </div>
          <div className="grid grid-cols-2 gap-8 text-sm sm:grid-cols-3">
            <FooterCol title="Product">
              <FooterLink href="/">Home</FooterLink>
              <FooterLink href="/today">Today</FooterLink>
              <FooterLink href="/messages">Messages</FooterLink>
              <FooterLink href="/discover">Discover</FooterLink>
              <FooterLink href="/plans">Plans</FooterLink>
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
                  className="text-neutral-500 transition hover:text-neutral-900"
                >
                  {siteConfig.supportEmail}
                </a>
              </li>
            </FooterCol>
          </div>
        </div>
        <div className="mt-10 flex flex-col gap-2 border-t border-neutral-200 pt-6 text-xs text-neutral-500 sm:flex-row sm:items-center sm:justify-between">
          <p>© {new Date().getFullYear()} {siteConfig.name}. All rights reserved.</p>
          <p>Made with care for readers, beginners, and returners.</p>
        </div>
      </MarketingContainer>
    </footer>
  );
}

function FooterCol({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div>
      <p className="mb-3 text-xs font-medium uppercase tracking-[0.12em] text-neutral-500">
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
        className="text-neutral-500 transition hover:text-neutral-900"
      >
        {children}
      </Link>
    </li>
  );
}

export function PageContainer({ children }: { children: ReactNode }) {
  return (
    <MarketingContainer narrow className="py-14 sm:py-20">
      {children}
    </MarketingContainer>
  );
}

export function Prose({ children }: { children: ReactNode }) {
  return <MarketingProse>{children}</MarketingProse>;
}
