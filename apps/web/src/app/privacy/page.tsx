export const metadata = {
  title: "Privacy Policy — Hunny Bible Tracker",
  description:
    "Privacy Policy for Hunny Bible Tracker, including data collection, use, sync, third-party services, and account deletion information.",
};

const supportEmail = "hunnybibletracker@gmail.com";

export default function PrivacyPage() {
  return (
    <main>
      <h1>Privacy Policy</h1>
      <p className="muted">Last updated: May 14, 2026</p>

      <p>
        Hunny Bible Tracker is a Bible reading progress tracker. This Privacy
        Policy explains what information we collect, how we use it, and how you
        can contact us about your data.
      </p>

      <p>
        The app is designed to work offline first. Some reading data may remain
        only on your device unless you choose to sign in or use sync features.
      </p>

      <h2>Information we collect</h2>
      <p>Depending on how you use the app, we may collect:</p>
      <ul>
        <li>
          Account information, such as your email address, when you sign in or
          create an account
        </li>
        <li>
          Bible reading progress, including books and chapters you mark as read
        </li>
        <li>Reading plan activity and progress</li>
        <li>Reading activity history, such as dates associated with progress</li>
        <li>
          Local settings and preferences, such as language, timezone, and app
          preferences
        </li>
        <li>
          Basic technical information needed to operate, secure, troubleshoot,
          and improve the app
        </li>
      </ul>

      <p>
        Your reading progress may reflect personal religious interests. We treat
        this information as personal data and use it only to provide and improve
        the app.
      </p>

      <h2>Information we do not collect</h2>
      <ul>
        <li>We do not store the full text of the Bible on our servers.</li>
        <li>We do not collect payment card information.</li>
        <li>We do not collect precise location data.</li>
        <li>We do not collect your contacts, photos, or health data.</li>
        <li>We do not sell your personal information.</li>
        <li>We do not use third-party advertising tracking.</li>
      </ul>

      <h2>How we use information</h2>
      <p>We use information to:</p>
      <ul>
        <li>Provide the app and its Bible reading tracking features</li>
        <li>Save and display your reading progress</li>
        <li>Provide account access and authentication</li>
        <li>Sync your progress across devices, if sync is enabled</li>
        <li>Respond to support and account deletion requests</li>
        <li>Maintain app security, troubleshoot issues, and improve the app</li>
      </ul>

      <h2>Third-party services</h2>
      <p>
        We may use trusted third-party services to operate the app and website,
        including services for authentication, hosting, database storage, and app
        delivery. These may include Firebase or Google services for sign-in and
        authentication, Neon for database storage, Vercel for website and API
        hosting, Apple App Store, and Google Play.
      </p>

      <h2>Data storage and retention</h2>
      <p>
        Offline reading progress may be stored locally on your device. If you
        sign in or use sync features, some account and reading progress data may
        be stored on our servers so the app can provide account access and sync.
      </p>
      <p>
        We keep personal data only as long as needed to provide the app, comply
        with legal obligations, resolve disputes, enforce agreements, and
        maintain security. When you request account deletion, we will delete or
        anonymize account data associated with your account unless we are
        required or permitted to retain limited information for legitimate
        reasons such as security, fraud prevention, or legal compliance.
      </p>

      <h2>Account and data deletion</h2>
      <p>
        You can request deletion of your account and associated data at any
        time. To make a request, email us at{" "}
        <a href={`mailto:${supportEmail}?subject=Account%20Deletion%20Request`}>
          {supportEmail}
        </a>{" "}
        with the subject “Account Deletion Request”. Please send the request
        from the email address associated with your account, if possible.
      </p>
      <p>
        You can also visit the account deletion instructions at{" "}
        <a href="https://hunny-bible-tracker.vercel.app/support#account-deletion">
          https://hunny-bible-tracker.vercel.app/support#account-deletion
        </a>{" "}
        .
      </p>
      <p>
        If you want to delete specific app data without deleting your account,
        visit the data deletion instructions at{" "}
        <a href="https://hunny-bible-tracker.vercel.app/support#data-deletion">
          https://hunny-bible-tracker.vercel.app/support#data-deletion
        </a>
        .
      </p>

      <h2>Children’s privacy</h2>
      <p>
        Hunny Bible Tracker is not directed to children under 13. We do not
        knowingly collect personal information from children under 13. If you
        believe a child has provided personal information to us, please contact
        us so we can review and delete it where appropriate.
      </p>

      <h2>Changes to this policy</h2>
      <p>
        We may update this Privacy Policy from time to time. If we make changes,
        we will update the “Last updated” date on this page.
      </p>

      <h2>Contact us</h2>
      <p>
        If you have questions about this Privacy Policy or your data, contact us
        at <a href={`mailto:${supportEmail}`}>{supportEmail}</a>.
      </p>
    </main>
  );
}
