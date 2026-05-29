"use client";

import Image from "next/image";
import { useEffect, useId, useState } from "react";

import { siteConfig } from "@/lib/site-config";
import {
  GooglePlayDownloadButtonShell,
  GooglePlayStoreBadgeIcon,
  StoreDownloadLabel,
} from "@/components/public/StoreDownloadButtons";

type AndroidTesterCtaVariant = "store" | "header" | "hb";

/** Display aspect from optimized exports (long edge 720px). */
const STEP_IMAGE_WIDTH = 341;
const STEP_IMAGE_HEIGHT = 720;

const testerSteps = [
  {
    label: "1",
    title: "Join tester group",
    body: "Open the Google Group and tap Join.",
    image: "/android-tester/step-1.png",
    href: siteConfig.androidTesterGroupUrl,
    cta: "Join group",
  },
  {
    label: "2",
    title: "Opt in on Play",
    body: "On Google Play, become a tester.",
    image: "/android-tester/step-2.png",
    href: siteConfig.androidTesterOptInUrl,
    cta: "Join test",
  },
  {
    label: "3",
    title: "Install the app",
    body: "Install Hunny from the Play Store.",
    image: "/android-tester/step-3.png",
    href: siteConfig.googlePlayUrl,
    cta: "Install",
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
      {variant === "store" ? (
        <GooglePlayDownloadButtonShell
          onClick={() => setOpen(true)}
          className={className}
        >
          <GooglePlayStoreBadgeIcon />
          <StoreDownloadLabel caption="Join Android test" store="Google Play" />
        </GooglePlayDownloadButtonShell>
      ) : (
        <button
          type="button"
          onClick={() => setOpen(true)}
          className={className ?? getButtonClassName(variant)}
        >
          Get the app
        </button>
      )}

      {open ? (
        <div
          className="fixed inset-0 z-50 flex items-end justify-center bg-neutral-900/40 px-4 py-5 sm:items-center sm:p-6"
          role="presentation"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) setOpen(false);
          }}
        >
          <section
            role="dialog"
            aria-modal="true"
            aria-labelledby={titleId}
            className="max-h-[92vh] w-full max-w-2xl overflow-y-auto rounded-2xl border border-neutral-200 bg-white p-5 text-neutral-900 shadow-lg sm:p-7 lg:max-w-6xl"
          >
            <div className="flex items-start justify-between gap-5">
              <div>
                <p className="mkt-kicker">Android closed testing</p>
                <h2 id={titleId} className="mt-2 text-2xl font-semibold leading-tight sm:text-3xl">
                  Help test Hunny for Android
                </h2>
                <div className="mt-3 max-w-xl space-y-3 text-sm leading-relaxed text-neutral-600">
                  <p>
                    Hunny is currently in closed testing, and I&apos;d genuinely appreciate your
                    help.
                  </p>
                  <p>
                    It&apos;s a simple Bible reading tracker designed to make Scripture feel less
                    overwhelming and easier to start.
                  </p>
                  <p>Joining only takes a minute — follow the three steps below.</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setOpen(false)}
                className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-neutral-200 bg-white text-xl leading-none text-neutral-500 transition hover:text-neutral-900"
                aria-label="Close tester instructions"
              >
                ×
              </button>
            </div>

            <ol className="mt-7 grid gap-4 lg:grid-cols-3 lg:gap-5">
              {testerSteps.map((step) => (
                <li
                  key={step.title}
                  className="rounded-2xl border border-neutral-200 bg-white p-4 lg:p-5"
                >
                  <div className="flex items-start gap-3 lg:flex-col lg:items-center lg:text-center">
                    <div className="flex min-w-0 flex-1 flex-col lg:w-full">
                      <div className="flex items-center gap-2 lg:justify-center">
                        <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-neutral-900 text-sm font-semibold text-white">
                          {step.label}
                        </span>
                        <strong className="text-base leading-snug">{step.title}</strong>
                      </div>
                      <p className="mt-2 text-sm leading-snug text-neutral-600">{step.body}</p>
                      <a
                        href={step.href}
                        target="_blank"
                        rel="noreferrer"
                        className="mt-3 inline-flex min-h-10 w-full items-center justify-center rounded-xl bg-neutral-900 px-4 text-sm font-medium text-white transition hover:bg-black sm:w-auto lg:hidden"
                      >
                        {step.cta}
                      </a>
                    </div>
                    <Image
                      src={step.image}
                      alt=""
                      width={STEP_IMAGE_WIDTH}
                      height={STEP_IMAGE_HEIGHT}
                      className="w-[min(38vw,140px)] shrink-0 rounded-xl border border-neutral-200 bg-white object-contain sm:w-[148px] lg:mx-auto lg:mt-1 lg:w-full lg:max-w-[220px]"
                      sizes="(max-width: 1024px) 148px, 220px"
                    />
                  </div>
                  <a
                    href={step.href}
                    target="_blank"
                    rel="noreferrer"
                    className="mt-4 hidden min-h-10 w-full items-center justify-center rounded-xl bg-neutral-900 px-4 text-sm font-medium text-white transition hover:bg-black lg:inline-flex"
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
    return "ml-1 hidden rounded-lg bg-neutral-900 px-4 py-2 text-sm text-white transition hover:bg-black sm:inline-flex";
  }

  if (variant === "hb") {
    return "hb-button hb-button--dark";
  }

  return "";
}
