import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: "Hunny Bible Tracker",
  description:
    "A simple, offline-first Bible reading tracker. Track chapters, reading plans, and your progress.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <header className="site-header">
          <span className="dot" aria-hidden />
          <Link href="/" className="brand">
            Hunny Bible Tracker
          </Link>
        </header>
        {children}
        <footer className="site-footer">
          <Link href="/privacy">Privacy</Link>
          <Link href="/support">Support</Link>
          <Link href="/terms">Terms</Link>
          <span style={{ marginLeft: "auto" }}>
            © {new Date().getFullYear()} Hunny Bible Tracker
          </span>
        </footer>
      </body>
    </html>
  );
}
