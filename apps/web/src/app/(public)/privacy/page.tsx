import type { Metadata } from "next";
import Link from "next/link";

import { PageContainer, Prose, SiteFooter, SiteHeader } from "@/components/public/SiteShell";
import { siteConfig } from "@/lib/site-config";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description:
    "How Hunny Bible Tracker handles your data: offline-first, minimal collection, optional account backup.",
  alternates: { canonical: "/privacy" },
};

export default function PrivacyPage() {
  return (
    <>
      <SiteHeader />
      <PageContainer>
        <p className="mkt-kicker">Legal</p>
        <h1 className="mkt-heading mt-3">Privacy Policy</h1>
        <p className="mt-3 text-sm text-neutral-500">
          Last updated: May 18, 2026
        </p>

        <div className="mt-10">
          <Prose>
            <p>
              Hunny Bible Tracker (&quot;Hunny&quot;, &quot;we&quot;, &quot;our&quot;)
              is built to be a calm, private place to track your Bible reading.
              This policy explains what we collect, why, and the choices you have.
            </p>

            <h2>The short version</h2>
            <ul>
              <li>Hunny works offline. Your reading data lives on your device by default.</li>
              <li>We do not sell your data. We do not run ad networks.</li>
              <li>If you choose to sign in, we back up your progress so you can restore it on another device.</li>
              <li>You can request account and data deletion at any time.</li>
            </ul>

            <h2>Data stored locally on your device</h2>
            <p>
              The following stays on your device unless you enable backup:
              chapter progress, plan progress, completed plan history, and app
              preferences.
            </p>

            <h2>Data we collect if you sign in</h2>
            <ul>
              <li>Email address for authentication and account recovery</li>
              <li>An application user ID</li>
              <li>Your reading progress and completed plans for backup and restore</li>
            </ul>

            <h2>Support and feedback</h2>
            <p>
              If you send feedback or contact support, we store the message and
              contact information needed to respond.
            </p>

            <h2>Third-party services</h2>
            <p>
              We use trusted providers for authentication, hosting, database
              infrastructure, image hosting, diagnostics, and app operations.
              These providers process limited data on our behalf.
            </p>

            <h2>Your rights</h2>
            <p>
              You may request access to, correction of, or deletion of your
              account data at any time. See the{" "}
              <Link href="/support">Support page</Link> for account deletion
              instructions.
            </p>

            <h2>Contact</h2>
            <p>
              Questions about privacy? Email{" "}
              <a href={`mailto:${siteConfig.supportEmail}`}>
                {siteConfig.supportEmail}
              </a>.
            </p>
          </Prose>
        </div>
      </PageContainer>
      <SiteFooter />
    </>
  );
}
