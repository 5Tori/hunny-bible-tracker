export const metadata = {
  title: "Terms of Service — Hunny Bible Tracker",
  description: "Terms of Service for Hunny Bible Tracker.",
};

const supportEmail = "hunnybibletracker@gmail.com";

export default function TermsPage() {
  return (
    <main>
      <h1>Terms of Service</h1>
      <p className="muted">Last updated: May 13, 2026</p>

      <p>
        These Terms of Service govern your use of Hunny Bible Tracker. By using
        the app, you agree to these terms.
      </p>

      <h2>Use of the app</h2>
      <p>
        Hunny Bible Tracker is provided for personal Bible reading progress
        tracking. The app helps you track books, chapters, reading plans, and
        reading activity over time.
      </p>
      <p>
        You agree to use the app responsibly and in compliance with applicable
        laws. You are responsible for activity that occurs under your account.
      </p>

      <h2>Accounts</h2>
      <p>
        Some features may require an account, such as sign-in or sync features.
        You are responsible for keeping your account information accurate and
        secure. If you believe your account has been accessed without
        authorization, please contact us.
      </p>

      <h2>Reading data and sync</h2>
      <p>
        The app is designed to work offline first. Some reading progress may be
        stored locally on your device. If you sign in or use sync features, your
        reading progress and related account data may be stored on our servers
        so the app can provide account access and sync.
      </p>

      <h2>No professional or religious advice</h2>
      <p>
        Hunny Bible Tracker is a tracking tool only. It does not provide
        professional, legal, medical, counseling, or religious advice. Any Bible
        reading, interpretation, or faith-related decisions are your own.
      </p>

      <h2>Service changes</h2>
      <p>
        We may update, change, suspend, or discontinue parts of the app over
        time. We may also update these terms as the app evolves. If we make
        changes, we will update the “Last updated” date on this page.
      </p>

      <h2>No warranty</h2>
      <p>
        The app is provided on an “as is” and “as available” basis. We do not
        guarantee that the app will always be available, error-free, or that
        reading progress will never be lost. We recommend signing in and using
        sync features when available if you want progress to be backed up across
        devices.
      </p>

      <h2>Limitation of liability</h2>
      <p>
        To the extent permitted by law, Hunny Bible Tracker and its operators
        will not be liable for indirect, incidental, special, consequential, or
        punitive damages arising from your use of the app.
      </p>

      <h2>Privacy</h2>
      <p>
        Your use of the app is also subject to our Privacy Policy, available at{" "}
        <a href="https://hunny-bible-tracker.vercel.app/privacy">
          https://hunny-bible-tracker.vercel.app/privacy
        </a>
        .
      </p>

      <h2>Contact</h2>
      <p>
        Questions about these terms? Email{" "}
        <a href={`mailto:${supportEmail}`}>{supportEmail}</a>.
      </p>
    </main>
  );
}
