import type { Metadata } from "next";
import LegalPageLayout from "@/components/legal/LegalPageLayout";
import { siteConfig } from "@/lib/site-config";

export const metadata: Metadata = {
  title: "Support",
  description:
    "Get help with Hunny Bible Tracker, request account deletion, or contact support.",
  alternates: { canonical: "/support" },
};

export default function SupportPage() {
  return (
    <LegalPageLayout
      title="Support"
      description="Need help with Hunny Bible Tracker? We’re here to help."
      lastUpdated="May 15, 2026"
    >
      <p>
        For support, questions, feedback, or account help, email{" "}
        <a href={`mailto:${siteConfig.supportEmail}`}>{siteConfig.supportEmail}</a>.
      </p>

      <h2>Contact</h2>
      <p>
        Email: <a href={`mailto:${siteConfig.supportEmail}`}>{siteConfig.supportEmail}</a>
      </p>

      <h2 id="account-deletion">Account deletion</h2>
      <p>
        You can request deletion of your account by emailing{" "}
        <a href={`mailto:${siteConfig.supportEmail}`}>{siteConfig.supportEmail}</a> with the
        subject “Account Deletion Request”. We will review your request and remove your account and
        associated data within a reasonable time frame.
      </p>

      <h2>Data deletion requests</h2>
      <p>
        You may also request deletion of specific account-related data, such as backed-up reading
        progress, without deleting your entire account. Include the details of your request in your
        email so we can help.
      </p>

      <h2>Common questions</h2>
      <h3>I missed several days. Did I lose my progress?</h3>
      <p>
        No. Hunny is designed to help you return gently. Your progress can remain saved, and you can
        pick up where you left off.
      </p>

      <h3>Do I need an account?</h3>
      <p>
        You can start using the app locally. Sign-in may be used for backup and restore features.
      </p>

      <h3>Is iOS available?</h3>
      <p>iOS is planned. Android is being prepared first.</p>
    </LegalPageLayout>
  );
}
