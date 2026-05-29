import Link from "next/link";

import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import { BrandLogo } from "@/components/public/BrandLogo";
import { AndroidTesterCta } from "@/components/public/AndroidTesterCta";
import { AppStoreDownloadButton } from "@/components/public/StoreDownloadButtons";

export function HeroSection() {
  return (
    <MarketingSection className="!pt-14 md:!pt-20">
      <MarketingContainer>
        <div className="grid items-center gap-14 lg:grid-cols-[1.05fr_0.95fr] lg:gap-16">
          <div>
            <p className="mkt-kicker">A gentle Bible reading habit tracker</p>
            <h1 className="mkt-heading mt-5 text-balance">
              Bible reading,
              <br />
              without the overwhelm.
            </h1>
            <p className="mkt-lead mt-6 max-w-xl">
              Start with a short story-led plan, track your progress one chapter at
              a time, and build a gentle reading habit at your own pace.
            </p>

            <div id="download" className="mt-8 flex flex-wrap items-center gap-3">
              <AndroidTesterCta />
              <AppStoreDownloadButton />
            </div>

            <p className="mt-5 text-sm text-neutral-500">
              Short story-led plans · Simple progress · Pick up anytime
            </p>

            <div className="mt-8 flex flex-wrap gap-4 text-sm">
              <Link
                href="/today"
                className="font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
              >
                Read today&apos;s message →
              </Link>
              <Link
                href="/discover"
                className="font-medium text-neutral-900 underline underline-offset-4 hover:text-[#d99a12]"
              >
                Browse discover →
              </Link>
            </div>
          </div>

          <PhoneMockup />
        </div>
      </MarketingContainer>
    </MarketingSection>
  );
}

function PhoneMockup() {
  return (
    <div className="mx-auto w-full max-w-sm">
      <div className="rounded-[2rem] border border-neutral-200 bg-white p-3 shadow-sm">
        <div className="relative mx-auto aspect-[9/19] w-full max-w-[280px] rounded-[1.75rem] border border-neutral-300 bg-neutral-900 p-2">
          <div className="relative h-full w-full overflow-hidden rounded-[1.35rem] bg-white">
            <div className="absolute left-1/2 top-2 h-4 w-20 -translate-x-1/2 rounded-full bg-neutral-900" />
            <div className="flex h-full flex-col px-4 pt-10 pb-5">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-[10px] font-medium uppercase tracking-[0.14em] text-[#d99a12]">
                    Today&apos;s reading
                  </p>
                  <p className="mt-1 text-base font-semibold text-neutral-900">
                    Joseph&apos;s Story
                  </p>
                </div>
                <BrandLogo className="h-6 w-auto shrink-0" />
              </div>

              <div className="mt-4 rounded-xl border border-neutral-200 p-3">
                <div className="flex items-center justify-between text-xs text-neutral-500">
                  <span>Chapter 37</span>
                  <span>Day 1 of 14</span>
                </div>
                <div className="mt-2 h-1 w-full overflow-hidden rounded-full bg-neutral-100">
                  <div className="h-full w-[8%] rounded-full bg-[#d99a12]" />
                </div>
                <p className="mt-2 text-[11px] leading-relaxed text-neutral-600">
                  Joseph, a young dreamer, sees a story that will change his family.
                </p>
                <div className="mt-2 rounded-lg bg-neutral-900 py-1.5 text-center text-[11px] font-medium text-white">
                  Mark chapter as read
                </div>
              </div>

              <div className="mt-3 grid grid-cols-7 gap-1">
                {Array.from({ length: 14 }).map((_, index) => (
                  <div
                    key={index}
                    className={`aspect-square rounded-sm ${
                      index === 0
                        ? "bg-[#d99a12]"
                        : index < 3
                          ? "bg-[#d99a12]/35"
                          : "bg-neutral-100"
                    }`}
                  />
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
