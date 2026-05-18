export const siteConfig = {
  name: "Hunny Bible Tracker",
  shortName: "Hunny",
  tagline: "Bible reading, without the overwhelm.",
  description:
    "Start with short, approachable Bible stories, track your progress, and build a gentle Bible reading habit at your own pace.",
  url: "https://hunny-bible-tracker.vercel.app",
  supportEmail: "hunnybibletracker@gmail.com",
  googlePlayUrl: "https://play.google.com/store/apps/details?id=com.hunnybibletracker.app",
  iosStatusLabel: "iOS coming soon",
} as const;

export const navLinks = [
  { href: "/#plans", label: "Plans" },
  { href: "/#progress", label: "Progress" },
  { href: "/#faq", label: "FAQ" },
  { href: "/support", label: "Support" },
] as const;
