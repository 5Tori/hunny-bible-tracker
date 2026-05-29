import type { Metadata } from "next";

import { PageContainer, Prose, SiteFooter, SiteHeader } from "@/components/public/SiteShell";
import { siteConfig } from "@/lib/site-config";

export const metadata: Metadata = {
  title: "Support",
  description:
    "Get help with Hunny Bible Tracker. Contact us, troubleshoot, or request account deletion.",
  alternates: { canonical: "/support" },
};

export default function SupportPage() {
  return (
    <>
      <SiteHeader />
      <PageContainer>
        <p className="mkt-kicker">Help</p>
        <h1 className="mkt-heading mt-3">Support</h1>
        <p className="mkt-lead mt-4 max-w-xl">
          We would love to help. Email is the fastest way to reach us.
        </p>

        <a
          href={`mailto:${siteConfig.supportEmail}`}
          className="mt-8 inline-flex w-full max-w-md items-center justify-between gap-6 rounded-2xl border border-neutral-200 bg-white px-5 py-4 transition hover:border-neutral-300"
        >
          <span>
            <span className="block text-[11px] font-medium uppercase tracking-[0.18em] opacity-80">
              Email us
            </span>
            <span className="block text-base font-medium">
              {siteConfig.supportEmail}
            </span>
          </span>
          <span aria-hidden>→</span>
        </a>

        <div className="mt-12">
          <Prose>
            <h2>Common questions</h2>

            <h3>I missed several days. Did I lose my plan?</h3>
            <p>
              No. Your plan stays exactly where you left it. Open the app and
              continue from your last chapter.
            </p>

            <h3>How do I back up my reading progress?</h3>
            <p>
              In the app, open Settings, sign in, and use backup or restore when
              available for your account.
            </p>

            <h3>Is iOS available?</h3>
            <p>iOS is planned. Android is being prepared first.</p>

            <h2 id="delete-account">Delete your account</h2>
            <p>
              You can permanently delete your Hunny account and server-stored
              reading data at any time.
            </p>

            <h3>Option 1: From inside the app</h3>
            <ul>
              <li>Open the app</li>
              <li>Go to Settings → Account</li>
              <li>Tap Delete account</li>
              <li>Confirm the deletion</li>
            </ul>

            <h3>Option 2: By email</h3>
            <p>
              If you cannot access the app, email{" "}
              <a href={`mailto:${siteConfig.supportEmail}?subject=Account%20deletion%20request`}>
                {siteConfig.supportEmail}
              </a>{" "}
              from the email address used to create your account, with the
              subject line <strong>Account deletion request</strong>.
            </p>

            <h3>What gets deleted</h3>
            <ul>
              <li>Your account email and authentication record</li>
              <li>Backed-up reading progress and plan history</li>
              <li>Anonymous identifiers tied to your account</li>
            </ul>
          </Prose>
        </div>
      </PageContainer>
      <SiteFooter />
    </>
  );
}
