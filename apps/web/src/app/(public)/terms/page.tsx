import type { Metadata } from "next";
import LegalPageLayout from "@/components/legal/LegalPageLayout";
import { siteConfig } from "@/lib/site-config";

export const metadata: Metadata = {
  title: "Terms of Service",
  description: "Terms that apply when using Hunny Bible Tracker.",
  alternates: { canonical: "/terms" },
};

export default function TermsPage() {
  return (
    <LegalPageLayout
      title="Terms of Service"
      description="The terms that apply when you use Hunny Bible Tracker."
      lastUpdated="May 15, 2026"
    >
      <p>
        By using Hunny Bible Tracker (“Hunny”), you agree to these Terms of Service. If you do not
        agree, please do not use the app.
      </p>

      <h2>Use of the app</h2>
      <p>
        Hunny is provided for personal Bible reading tracking. It helps you choose reading plans,
        track chapter progress, and build a gentle rhythm of Scripture.
      </p>

      <h2>Not professional advice</h2>
      <p>
        Hunny is not a replacement for pastoral, professional, theological, medical, legal, or other
        professional advice. For spiritual guidance, please consult trusted leaders or your faith
        community.
      </p>

      <h2>Your account</h2>
      <p>
        If you choose to sign in, you are responsible for activity that occurs under your account.
        Please keep your account access secure.
      </p>

      <h2>Service changes</h2>
      <p>
        We may add, change, or remove features over time as we improve the app. We may also update
        these terms when needed.
      </p>

      <h2>Availability and disclaimer</h2>
      <p>
        Hunny is provided on an “as is” and “as available” basis without warranties of any kind, to
        the fullest extent allowed by law.
      </p>

      <h2>Contact</h2>
      <p>
        Questions about these terms? Email{" "}
        <a href={`mailto:${siteConfig.supportEmail}`}>{siteConfig.supportEmail}</a>.
      </p>
    </LegalPageLayout>
  );
}
