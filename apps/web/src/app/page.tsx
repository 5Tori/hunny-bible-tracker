import Link from "next/link";

export default function HomePage() {
  return (
    <main>
      <h1>A simple way to track your Bible reading.</h1>
      <p className="lede">
        Hunny Bible Tracker is an offline-first mobile app for following your
        Bible reading progress — chapter by chapter, plan by plan.
      </p>

      <h2>What you can do</h2>
      <ul>
        <li>Track chapter-level reading progress across the whole Bible</li>
        <li>Follow reading plans at your own pace</li>
        <li>See your reading activity over time</li>
        <li>Works offline — sync coming soon</li>
      </ul>

      <div className="cta-row">
        <Link href="/privacy" className="btn">
          Privacy Policy
        </Link>
        <Link href="/support" className="btn">
          Support
        </Link>
        <Link href="/terms" className="btn">
          Terms of Service
        </Link>
      </div>
    </main>
  );
}
