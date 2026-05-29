import Link from "next/link";
import type { ReactNode } from "react";

import { AndroidTesterCta } from "@/components/public/AndroidTesterCta";
import { BrandLogo } from "@/components/public/BrandLogo";
import { SiteFooter, SiteHeader } from "@/components/public/SiteShell";

const plans = [
  {
    name: "Joseph's Story",
    verses: "Genesis 37-50",
    minutes: "~5 min / day",
    tone: "Family, forgiveness, faith",
  },
  {
    name: "Jonah's Story",
    verses: "Jonah 1-4",
    minutes: "~4 min / day",
    tone: "Mercy, second chances",
  },
  {
    name: "Zacchaeus' Story",
    verses: "Luke 19",
    minutes: "~3 min / day",
    tone: "Encounter, change of heart",
  },
  {
    name: "Samuel's Childhood",
    verses: "1 Samuel 1-3",
    minutes: "~4 min / day",
    tone: "Listening, calling",
  },
];

const features = [
  {
    title: "Start with a story",
    body: "Short, story-led plans make beginning feel natural. Pick one that sounds interesting and read at your own pace.",
  },
  {
    title: "Track chapter by chapter",
    body: "Mark each chapter complete and watch a quiet record of your reading journey take shape.",
  },
  {
    title: "Works offline",
    body: "Read and track anywhere. No connection required for your core reading progress.",
  },
  {
    title: "Your plan history",
    body: "Finished plans gather like memories, a gentle map of the stories you have walked through.",
  },
  {
    title: "Pick up where you left off",
    body: "Step away for a week or a month. Your plan is waiting, exactly where you stopped.",
  },
  {
    title: "Optional backup",
    body: "Sign in only if you want to back up and restore progress across devices.",
  },
];

const faqs = [
  {
    q: "Is Hunny a full Bible app?",
    a: "Hunny is a Bible reading tracker and a gentle guide into Scripture. It helps you build a habit alongside the Bible you already love.",
  },
  {
    q: "Do I need an account?",
    a: "No. Hunny works fully offline. Accounts are optional and only used to back up and restore your progress across devices.",
  },
  {
    q: "How long are the starter plans?",
    a: "Most starter plans take just a few minutes a day and finish within a couple of weeks.",
  },
  {
    q: "Who is Hunny for?",
    a: "Hunny is for beginners, returning readers, and churchgoers who want a calmer place to begin reading Scripture.",
  },
];

export default function HomePage() {
  const faqJsonLd = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.q,
      acceptedAnswer: { "@type": "Answer", text: faq.a },
    })),
  };

  return (
    <div className="min-h-screen bg-background">
      <SiteHeader />

      <main>
        <section className="relative overflow-hidden">
          <div className="pointer-events-none absolute inset-x-0 -top-32 h-[480px] bg-honey-gradient" />
          <div className="relative mx-auto max-w-6xl px-5 pt-14 pb-20 sm:px-8 sm:pt-20 sm:pb-28">
            <div className="grid items-center gap-12 lg:grid-cols-[1.05fr_1fr]">
              <div>
                <span className="inline-flex items-center gap-2 rounded-full border border-honey/40 bg-white/70 px-3 py-1 text-xs font-medium text-honey-ink shadow-soft">
                  <span className="h-1.5 w-1.5 rounded-full bg-honey" />
                  A gentle Bible reading habit tracker
                </span>
                <h1 className="mt-5 text-balance font-display text-[40px] leading-[1.05] text-foreground sm:text-6xl">
                  Bible reading,
                  <br />
                  <span className="text-honey-ink">without the overwhelm.</span>
                </h1>
                <p className="mt-6 max-w-xl text-pretty text-[17px] leading-relaxed text-foreground/70 sm:text-lg">
                  Start with a short story-led plan, track your progress one
                  chapter at a time, and build a gentle reading habit at your own
                  pace.
                </p>

                <div id="download" className="mt-8 flex flex-wrap items-center gap-3">
                  <AndroidTesterCta />
                  <StoreButton
                    store="App Store"
                    caption="Coming soon to"
                    href="#"
                    icon={<AppleIcon />}
                    disabled
                  />
                </div>

                <p className="mt-5 text-sm text-muted-foreground">
                  Short story-led plans · Simple progress · Pick up anytime
                </p>
              </div>

              <div className="relative mx-auto w-full max-w-sm">
                <PhoneMockup />
              </div>
            </div>
          </div>
        </section>

        <section className="mx-auto max-w-3xl px-5 py-16 text-center sm:px-8 sm:py-24">
          <p className="text-xs font-medium uppercase tracking-[0.2em] text-honey-ink">
            The quiet idea
          </p>
          <h2 className="mt-4 text-balance text-3xl leading-tight sm:text-4xl">
            The Bible can feel big, or hard to know where to begin.
            <br />
            <span className="text-foreground/60">
              A single story is a wonderful place to start.
            </span>
          </h2>
          <p className="mx-auto mt-6 max-w-xl text-pretty text-foreground/70">
            Hunny opens Scripture through short, approachable stories that help
            you read the next chapter, and the one after that.
          </p>
        </section>

        <section id="plans" className="mx-auto max-w-6xl px-5 sm:px-8">
          <div className="flex items-end justify-between gap-6">
            <div>
              <p className="text-xs font-medium uppercase tracking-[0.2em] text-honey-ink">
                Starter plans
              </p>
              <h2 className="mt-2 text-3xl sm:text-4xl">Begin with a story.</h2>
            </div>
            <p className="hidden max-w-xs text-sm text-muted-foreground sm:block">
              Each plan is short enough to finish and meaningful enough to stay
              with you.
            </p>
          </div>

          <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {plans.map((plan) => (
              <article
                key={plan.name}
                className="group relative overflow-hidden rounded-2xl border border-border bg-card p-5 shadow-soft transition hover:shadow-card"
              >
                <div className="flex items-center justify-between">
                  <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-honey-soft">
                    <BrandLogo className="h-5 w-auto shrink-0" />
                  </div>
                  <span className="text-[11px] font-medium uppercase tracking-wider text-muted-foreground">
                    Plan
                  </span>
                </div>
                <h3 className="mt-5 font-display text-xl">{plan.name}</h3>
                <p className="mt-1 text-sm text-muted-foreground">{plan.verses}</p>
                <div className="mt-5 flex items-center justify-between border-t border-border pt-4 text-xs text-foreground/70">
                  <span>{plan.minutes}</span>
                  <span className="text-right text-muted-foreground">{plan.tone}</span>
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="mx-auto mt-24 max-w-6xl px-5 sm:px-8">
          <div className="max-w-2xl">
            <p className="text-xs font-medium uppercase tracking-[0.2em] text-honey-ink">
              What's inside
            </p>
            <h2 className="mt-2 text-3xl sm:text-4xl">
              A calm space to build a rhythm of Scripture.
            </h2>
          </div>

          <div className="mt-10 grid gap-px overflow-hidden rounded-3xl border border-border bg-border sm:grid-cols-2 lg:grid-cols-3">
            {features.map((feature) => (
              <div key={feature.title} className="bg-card p-7">
                <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-honey-soft text-honey-ink">
                  <DotIcon />
                </div>
                <h3 className="mt-5 text-lg">{feature.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-foreground/70">
                  {feature.body}
                </p>
              </div>
            ))}
          </div>
        </section>

        <section className="mx-auto mt-24 max-w-6xl px-5 sm:px-8">
          <div className="overflow-hidden rounded-3xl bg-honey-gradient-strong p-8 text-honey-ink shadow-card sm:p-14">
            <div className="max-w-2xl">
              <p className="text-xs font-medium uppercase tracking-[0.2em] opacity-80">
                Our promise
              </p>
              <h2 className="mt-3 font-display text-3xl leading-tight text-[#3b2710] sm:text-4xl">
                A gentle rhythm of Scripture, at your pace.
              </h2>
              <ul className="mt-6 grid gap-3 text-[15px] text-[#3b2710]/85 sm:grid-cols-2">
                {[
                  "Start small with a story you are drawn to",
                  "Track each chapter as you go",
                  "See your reading journey quietly grow",
                  "Come back anytime. Your plan is waiting",
                ].map((item) => (
                  <li key={item} className="flex items-start gap-2.5">
                    <CheckIcon /> <span>{item}</span>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </section>

        <section className="mx-auto mt-24 max-w-6xl px-5 sm:px-8">
          <div className="grid gap-4 sm:grid-cols-3">
            {[
              {
                n: "01",
                t: "Pick a story",
                d: "Choose a short plan that sounds interesting.",
              },
              {
                n: "02",
                t: "Read a little",
                d: "Open a chapter in your own Bible. Then mark it complete.",
              },
              {
                n: "03",
                t: "Keep going",
                d: "Watch your progress build. Finish a plan. Choose the next story.",
              },
            ].map((step) => (
              <div
                key={step.n}
                className="rounded-2xl border border-border bg-card p-6 shadow-soft"
              >
                <span className="font-display text-3xl text-honey-ink">
                  {step.n}
                </span>
                <h3 className="mt-3 text-lg">{step.t}</h3>
                <p className="mt-1.5 text-sm leading-relaxed text-foreground/70">
                  {step.d}
                </p>
              </div>
            ))}
          </div>
        </section>

        <section id="faq" className="mx-auto mt-24 max-w-3xl px-5 sm:px-8">
          <h2 className="text-3xl sm:text-4xl">Questions, gently answered.</h2>
          <div className="mt-8 divide-y divide-border rounded-2xl border border-border bg-card">
            {faqs.map((faq) => (
              <details key={faq.q} className="group p-5 sm:p-6">
                <summary className="flex cursor-pointer items-start justify-between gap-6 text-left text-[15px] font-medium text-foreground">
                  {faq.q}
                  <span className="mt-1 text-honey-ink transition group-open:rotate-45">
                    +
                  </span>
                </summary>
                <p className="mt-3 text-sm leading-relaxed text-foreground/70">
                  {faq.a}
                </p>
              </details>
            ))}
          </div>
        </section>

        <section className="mx-auto mt-24 max-w-3xl px-5 text-center sm:px-8">
          <BrandLogo className="mx-auto h-10 w-auto shrink-0" />
          <h2 className="mt-5 text-balance font-display text-3xl leading-tight sm:text-5xl">
            Let your reading journey grow.
          </h2>
          <p className="mx-auto mt-4 max-w-lg text-foreground/70">
            Start with a story. Track your progress, one chapter at a time.
            Build a gentle rhythm of Scripture at your own pace.
          </p>
          <div className="mt-8 flex flex-wrap justify-center gap-3">
            <AndroidTesterCta />
            <Link
              href="/support"
              className="inline-flex items-center justify-center rounded-2xl border border-border bg-card px-5 py-3 text-sm font-medium text-foreground transition hover:bg-muted"
            >
              Contact support
            </Link>
          </div>
        </section>
      </main>

      <SiteFooter />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqJsonLd) }}
      />
    </div>
  );
}

function StoreButton({
  store,
  caption,
  href,
  icon,
  disabled,
}: {
  store: string;
  caption: string;
  href: string;
  icon: ReactNode;
  disabled?: boolean;
}) {
  return (
    <a
      href={href}
      aria-disabled={disabled}
      className={`inline-flex items-center gap-3 rounded-2xl px-5 py-3 ${
        disabled
          ? "pointer-events-none bg-[#827d75] text-white"
          : "bg-[#211105] text-white transition hover:bg-[#332010]"
      }`}
    >
      <span className="text-honey">{icon}</span>
      <span className="text-left leading-tight">
        <span className="block text-[10px] uppercase tracking-[0.15em] opacity-70">
          {caption}
        </span>
        <span className="block text-sm font-medium">{store}</span>
      </span>
    </a>
  );
}

function PhoneMockup() {
  return (
    <div className="relative">
      <div
        className="absolute -inset-6 rounded-[3rem] bg-honey/20 blur-2xl"
        aria-hidden
      />
      <div className="relative mx-auto aspect-[9/19] w-[280px] rounded-[2.5rem] border border-foreground/10 bg-foreground p-2 shadow-card sm:w-[320px]">
        <div className="relative h-full w-full overflow-hidden rounded-[2rem] bg-cream">
          <div className="absolute left-1/2 top-2 h-5 w-24 -translate-x-1/2 rounded-full bg-foreground/90" />
          <div className="flex h-full flex-col px-5 pt-12 pb-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-[10px] uppercase tracking-[0.2em] text-honey-ink/80">
                  Today's reading
                </p>
                <p className="mt-1 font-display text-lg">Joseph's Story</p>
              </div>
              <BrandLogo className="h-7 w-auto shrink-0" />
            </div>

            <div className="mt-4 rounded-2xl bg-white p-4 shadow-soft">
              <div className="flex items-center justify-between">
                <span className="text-xs font-medium text-foreground/70">
                  Chapter 37
                </span>
                <span className="text-[10px] text-muted-foreground">Day 1 of 14</span>
              </div>
              <div className="mt-3 h-1.5 w-full overflow-hidden rounded-full bg-honey-soft">
                <div className="h-full w-[8%] rounded-full bg-honey" />
              </div>
              <p className="mt-3 text-[12px] leading-relaxed text-foreground/70">
                Joseph, a young dreamer, sees a story that will change his family.
              </p>
              <button className="mt-3 w-full rounded-xl bg-[#211105] py-2 text-[12px] font-medium text-white">
                Mark chapter as read
              </button>
            </div>

            <div className="mt-4 grid grid-cols-7 gap-1.5">
              {Array.from({ length: 14 }).map((_, index) => (
                <div
                  key={index}
                  className={`aspect-square rounded-md ${
                    index === 0
                      ? "bg-honey"
                      : index < 3
                        ? "bg-honey/40"
                        : "bg-foreground/5"
                  }`}
                />
              ))}
            </div>

            <div className="mt-auto rounded-2xl bg-white/70 p-3 text-center">
              <p className="text-[11px] text-foreground/70">
                <span className="text-honey-ink">Just your reading,</span> at
                your pace.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function AppleIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M16.4 12.7c0-2.4 2-3.6 2.1-3.6-1.1-1.6-2.9-1.9-3.5-1.9-1.5-.2-2.9.9-3.7.9-.8 0-1.9-.9-3.2-.9-1.6 0-3.2 1-4 2.5-1.7 3-.4 7.4 1.2 9.8.8 1.2 1.8 2.5 3 2.5 1.2 0 1.7-.8 3.1-.8s1.9.8 3.2.8c1.3 0 2.2-1.2 3-2.4.9-1.4 1.3-2.7 1.3-2.8-.1 0-2.5-1-2.5-3.1zM14.2 5.2c.7-.8 1.1-2 1-3.2-1 .1-2.2.7-2.9 1.5-.6.7-1.2 1.9-1.1 3 1.1.1 2.3-.5 3-1.3z" />
    </svg>
  );
}

function DotIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" aria-hidden>
      <circle cx="8" cy="8" r="3.2" />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg
      width="18"
      height="18"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.4"
      strokeLinecap="round"
      strokeLinejoin="round"
      className="mt-0.5 shrink-0"
      aria-hidden
    >
      <path d="M20 6 9 17l-5-5" />
    </svg>
  );
}
