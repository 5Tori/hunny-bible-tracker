import type { Metadata } from "next";
import Link from "next/link";

import { PageContainer, Prose, SiteFooter, SiteHeader } from "@/components/public/SiteShell";
import { siteConfig } from "@/lib/site-config";

export const metadata: Metadata = {
  title: "Terms of Service",
  description: "The terms that apply when you use Hunny Bible Tracker.",
  alternates: { canonical: "/terms" },
};

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-background">
      <SiteHeader />
      <PageContainer>
        <p className="text-xs font-medium uppercase tracking-[0.2em] text-honey-ink">
          Legal
        </p>
        <h1 className="mt-3 font-display text-4xl sm:text-5xl">
          Terms of Service
        </h1>
        <p className="mt-3 text-sm text-muted-foreground">
          Last updated: May 18, 2026
        </p>

        <div className="mt-10">
          <Prose>
            <p>
              These Terms govern your use of Hunny Bible Tracker
              (&quot;Hunny&quot;, the &quot;Service&quot;). By using Hunny, you agree
              to these Terms.
            </p>

            <h2>The Service</h2>
            <p>
              Hunny is a Bible reading habit tracker. It helps you choose
              reading plans, track chapter progress, and build a personal
              reading rhythm at your own pace.
            </p>

            <h2>Your account</h2>
            <p>
              Accounts are optional and used for backup and restore. You are
              responsible for keeping your sign-in credentials secure. You may
              delete your account at any time through the app or by contacting{" "}
              <Link href="/support">Support</Link>.
            </p>

            <h2>Acceptable use</h2>
            <ul>
              <li>Do not attempt to disrupt, reverse-engineer, or abuse the Service.</li>
              <li>Do not use the Service to violate any law.</li>
              <li>Do not attempt to access another user&apos;s data.</li>
            </ul>

            <h2>Content and Scripture</h2>
            <p>
              Scripture excerpts and related content are provided for reading
              support and remain subject to their respective translation,
              publisher, or rights holder terms.
            </p>

            <h2>Disclaimer of warranties</h2>
            <p>
              The Service is provided as is without warranties of any kind. We
              do not guarantee that the Service will be uninterrupted or
              error-free.
            </p>

            <h2>Contact</h2>
            <p>
              Questions? Email{" "}
              <a href={`mailto:${siteConfig.supportEmail}`}>
                {siteConfig.supportEmail}
              </a>.
            </p>
          </Prose>
        </div>
      </PageContainer>
      <SiteFooter />
    </div>
  );
}
