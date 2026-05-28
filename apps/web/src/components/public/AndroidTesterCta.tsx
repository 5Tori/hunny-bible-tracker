"use client";

import { useEffect, useId, useState } from "react";

import { siteConfig } from "@/lib/site-config";

type AndroidTesterCtaVariant = "store" | "header" | "hb";

const testerSteps = [
  {
    label: "1",
    title: "Join the tester group",
    body: "Join the Google Group first so Google Play can recognize your testing access.",
    href: siteConfig.androidTesterGroupUrl,
    cta: "Join tester group",
  },
  {
    label: "2",
    title: "Opt in on Google Play",
    body: "Tell Google Play you'd like to participate in the closed test.",
    href: siteConfig.androidTesterOptInUrl,
    cta: "Join closed test",
  },
  {
    label: "3",
    title: "Install and explore",
    body: "Install the current test build, try it out, and let me know if anything feels confusing or broken.",
    href: siteConfig.googlePlayUrl,
    cta: "Install app",
  },
] as const;

export function AndroidTesterCta({
  variant = "store",
  className,
}: {
  variant?: AndroidTesterCtaVariant;
  className?: string;
}) {
  const [open, setOpen] = useState(false);
  const titleId = useId();

  useEffect(() => {
    if (!open) return undefined;

    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") setOpen(false);
    };

    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    window.addEventListener("keydown", onKeyDown);

    return () => {
      document.body.style.overflow = previousOverflow;
      window.removeEventListener("keydown", onKeyDown);
    };
  }, [open]);

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className={className ?? getButtonClassName(variant)}
      >
        {variant === "store" ? (
          <>
            <span className="text-honey">
              <PlayIcon />
            </span>
            <span className="text-left leading-tight">
              <span className="block text-[10px] uppercase tracking-[0.15em] opacity-70">
                Join Android test
              </span>
              <span className="block text-sm font-medium">Google Play</span>
            </span>
          </>
        ) : (
          "Get the app"
        )}
      </button>

      {open ? (
        <div
          className="fixed inset-0 z-50 flex items-end justify-center bg-[#211105]/50 px-4 py-5 backdrop-blur-sm sm:items-center sm:p-6"
          role="presentation"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) setOpen(false);
          }}
        >
          <section
            role="dialog"
            aria-modal="true"
            aria-labelledby={titleId}
            className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-3xl border border-border bg-card p-5 text-foreground shadow-card sm:p-7"
          >
            <div className="flex items-start justify-between gap-5">
              <div>
                <p className="text-xs font-medium uppercase tracking-[0.18em] text-honey-ink">
                  Android closed testing
                </p>
                <h2 id={titleId} className="mt-2 font-display text-3xl leading-tight sm:text-4xl">
                  Help test Hunny for Android
                </h2>
                <div className="mt-3 max-w-xl space-y-3 text-sm leading-relaxed text-foreground/70">
                  <p>
                    Hunny is currently in closed testing, and I&apos;d genuinely
                    appreciate your help.
                  </p>
                  <p>
                    It&apos;s a simple Bible reading tracker designed to make
                    Scripture feel less overwhelming and easier to start.
                  </p>
                  <p>Joining only takes a minute.</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setOpen(false)}
                className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-border bg-background text-xl leading-none text-foreground/70 transition hover:text-foreground"
                aria-label="Close tester instructions"
              >
                ×
              </button>
            </div>

            <ol className="mt-7 grid gap-3">
              {testerSteps.map((step) => (
                <li
                  key={step.title}
                  className="grid gap-4 rounded-2xl border border-border bg-cream/50 p-4 sm:grid-cols-[auto_1fr_auto] sm:items-center"
                >
                  <span className="flex h-9 w-9 items-center justify-center rounded-full bg-honey text-sm font-semibold text-[#3b2710]">
                    {step.label}
                  </span>
                  <span>
                    <strong className="block text-base">{step.title}</strong>
                    <span className="mt-1 block text-sm leading-relaxed text-foreground/70">
                      {step.body}
                    </span>
                  </span>
                  <a
                    href={step.href}
                    target="_blank"
                    rel="noreferrer"
                    className="inline-flex min-h-11 items-center justify-center rounded-2xl bg-[#211105] px-4 text-sm font-medium text-white transition hover:bg-[#332010]"
                  >
                    {step.cta}
                  </a>
                </li>
              ))}
            </ol>
          </section>
        </div>
      ) : null}
    </>
  );
}

function getButtonClassName(variant: AndroidTesterCtaVariant) {
  if (variant === "header") {
    return "ml-1 hidden rounded-full bg-[#211105] px-4 py-2 text-sm text-white transition hover:bg-[#332010] sm:inline-flex";
  }

  if (variant === "hb") {
    return "hb-button hb-button--dark";
  }

  return "inline-flex items-center gap-3 rounded-2xl bg-[#211105] px-5 py-3 text-white transition hover:bg-[#332010]";
}

function PlayIcon() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden>
      <path d="M5 3.5v17l15-8.5L5 3.5z" />
    </svg>
  );
}
