import type { Metadata } from "next";
import LegalPageLayout from "@/components/legal/LegalPageLayout";
import { siteConfig } from "@/lib/site-config";

export const metadata: Metadata = {
  title: "Privacy Policy",
  description:
    "How Hunny Bible Tracker handles reading progress, sign-in data, backup and restore, and third-party services.",
  alternates: { canonical: "/privacy" },
};

export default function PrivacyPage() {
  return (
    <LegalPageLayout
      title="Privacy Policy"
      description="How we handle your reading progress, account information, and app data."
      lastUpdated="May 15, 2026"
    >
      <p>
        This Privacy Policy explains how Hunny Bible Tracker (“Hunny”, “we”, “us”) handles
        information when you use our mobile application and website.
      </p>

      <h2>Offline-first reading progress</h2>
      <p>
        Hunny is designed with an offline-first reading progress experience. Reading progress is
        stored locally on your device by default. The app does not store full Bible text.
      </p>

      <h2>Information the app may store</h2>
      <p>Depending on how you use the app, Hunny may store:</p>
      <ul>
        <li>Reading progress, including chapters marked as read.</li>
        <li>Reading plans you start, archive, restore, or complete.</li>
        <li>Completed plan history and reading activity history.</li>
        <li>Local settings and preferences.</li>
        <li>Your account email and authentication identifier if you choose to sign in.</li>
        <li>Support or feedback messages you choose to send.</li>
      </ul>

      <h2>Sign-in, backup, and restore</h2>
      <p>
        Sign-in may be used for account access, backup, and restore features. If you choose not to
        sign in, your reading progress can remain local to your device.
      </p>

      <h2>Third-party services</h2>
      <p>
        We may use third-party services for authentication, hosting, database infrastructure,
        image hosting, diagnostics, and app operations. These providers process limited data on our
        behalf so we can provide and improve the service.
      </p>

      <h2>Data deletion</h2>
      <p>
        You can request account or data deletion by emailing{" "}
        <a href={`mailto:${siteConfig.supportEmail}`}>{siteConfig.supportEmail}</a>. For account
        deletion, use the subject “Account Deletion Request”.
      </p>

      <h2>Children</h2>
      <p>
        Hunny is intended for general audiences. We do not knowingly collect personal information
        from children without appropriate consent.
      </p>

      <h2>Changes</h2>
      <p>
        We may update this Privacy Policy from time to time. When we do, we will update the “Last
        updated” date above.
      </p>

      <h2>Contact</h2>
      <p>
        Questions about this policy? Email{" "}
        <a href={`mailto:${siteConfig.supportEmail}`}>{siteConfig.supportEmail}</a>.
      </p>
    </LegalPageLayout>
  );
}
