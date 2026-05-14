export const metadata = {
  title: "Support — Hunny Bible Tracker",
  description:
    "Support, account deletion, and data deletion information for Hunny Bible Tracker.",
};

const supportEmail = "hunnybibletracker@gmail.com";
const accountDeletionSubject = "Account Deletion Request";
const dataDeletionSubject = "Data Deletion Request";
const accountDeletionMailto = `mailto:${supportEmail}?subject=${encodeURIComponent(
  accountDeletionSubject,
)}&body=${encodeURIComponent(
  [
    "I would like to delete my Hunny Bible Tracker account and associated data.",
    "",
    "Account email:",
    "Reason (optional):",
  ].join("\n"),
)}`;
const dataDeletionMailto = `mailto:${supportEmail}?subject=${encodeURIComponent(
  dataDeletionSubject,
)}&body=${encodeURIComponent(
  [
    "I would like to delete my Hunny Bible Tracker data without deleting my account.",
    "",
    "Account email:",
    "Data to delete (for example: reading progress, reading activity, or synced app data):",
    "Reason (optional):",
  ].join("\n"),
)}`;

export default function SupportPage() {
  return (
    <main>
      <h1>Support</h1>
      <p>
        Need help with Hunny Bible Tracker? You can contact us by email for app
        support, privacy questions, account deletion requests, or data deletion
        requests.
      </p>

      <div className="cta-row" aria-label="Deletion request links">
        <a className="btn primary" href="#account-deletion">
          Request account deletion
        </a>
        <a className="btn" href="#data-deletion">
          Request data deletion
        </a>
      </div>

      <h2>Contact</h2>
      <p>
        Email us at <a href={`mailto:${supportEmail}`}>{supportEmail}</a>.
      </p>
      <p>
        Please include a brief description of the issue, the device you are
        using, and the email address associated with your account if your
        request is account-related.
      </p>

      <h2>Common support topics</h2>
      <ul>
        <li>Questions about Bible reading progress</li>
        <li>Questions about reading plans or activity history</li>
        <li>Sign-in or account access issues</li>
        <li>Sync-related questions, if sync is enabled</li>
        <li>Privacy, data access, or data deletion requests</li>
      </ul>

      <section id="account-deletion" className="anchored-section">
        <h2>Account deletion</h2>
        <p>
          Use this option if you want to delete your Hunny Bible Tracker account
          and associated account data.
        </p>
        <p>
          This request includes deletion or anonymization of account information
          and server-side app data associated with your account, including synced
          reading progress if sync has been enabled.
        </p>
        <p>
          To request account deletion, email{" "}
          <a href={accountDeletionMailto}>{supportEmail}</a> with the subject
          line:
        </p>
        <p>
          <strong>{accountDeletionSubject}</strong>
        </p>
        <p>
          Please send the request from the email address associated with your
          account, if possible. If you cannot access that email address, include
          enough information for us to verify that the account belongs to you.
        </p>
        <p>
          After we verify your request, we will delete or anonymize account data
          associated with your account unless we are required or permitted to
          retain limited information for legitimate reasons such as security,
          fraud prevention, or legal compliance. We aim to complete verified
          deletion requests within 30 days.
        </p>
        <p>
          <a className="btn primary" href={accountDeletionMailto}>
            Email account deletion request
          </a>
        </p>
      </section>

      <section id="data-deletion" className="anchored-section">
        <h2>Data deletion</h2>
        <p>
          Use this option if you want to delete specific Hunny Bible Tracker app
          data without deleting your account.
        </p>
        <p>
          You can request deletion of server-side data associated with your
          account, such as synced reading progress, reading activity, reading
          plan progress, or other app data stored for sync.
        </p>
        <p>
          To request data deletion, email{" "}
          <a href={dataDeletionMailto}>{supportEmail}</a> with the subject line:
        </p>
        <p>
          <strong>{dataDeletionSubject}</strong>
        </p>
        <p>
          In your request, include the email address associated with your account
          and describe the data you want deleted. If the data exists only on
          your device and has not been synced, you can remove it by deleting the
          app or clearing the app's local data on your device.
        </p>
        <p>
          After we verify your request, we will delete or anonymize the requested
          server-side data unless we are required or permitted to retain limited
          information for legitimate reasons such as security, fraud prevention,
          or legal compliance. We aim to complete verified deletion requests
          within 30 days.
        </p>
        <p>
          <a className="btn primary" href={dataDeletionMailto}>
            Email data deletion request
          </a>
        </p>
      </section>

      <h2>Privacy Policy</h2>
      <p>
        You can read our Privacy Policy at{" "}
        <a href="https://hunny-bible-tracker.vercel.app/privacy">
          https://hunny-bible-tracker.vercel.app/privacy
        </a>
        .
      </p>
    </main>
  );
}
