import type { Metadata } from "next";

import { ContentCard } from "@/components/browse/ContentCard";
import {
  DiscoverFilters,
  parseDiscoverType,
} from "@/components/browse/DiscoverFilters";
import { MarketingContainer } from "@/components/marketing/ui/MarketingContainer";
import { MarketingSection } from "@/components/marketing/ui/MarketingSection";
import { getPublishedContentsForBrowse } from "@/lib/content";
import { PUBLIC_CATALOG_REVALIDATE_SECONDS } from "@/lib/http/public-cache";

export const revalidate = PUBLIC_CATALOG_REVALIDATE_SECONDS;

export const metadata: Metadata = {
  title: "Discover",
  description:
    "Videos, essays, cartoons, and messages to explore Scripture with Hunny Bible Tracker.",
  alternates: { canonical: "/discover" },
};

interface PageProps {
  searchParams: Promise<{ type?: string }>;
}

export default async function DiscoverPage({ searchParams }: PageProps) {
  const params = await searchParams;
  const typeFilter = parseDiscoverType(params.type);

  const contents = await getPublishedContentsForBrowse({
    language: "en",
    type: typeFilter === "all" ? undefined : typeFilter,
    sort: "featured",
    limit: 48,
  });

  return (
    <MarketingSection className="!py-12 md:!py-16">
      <MarketingContainer>
        <p className="mkt-kicker">Discover</p>
        <h1 className="mkt-heading mt-3">Explore Scripture</h1>
        <p className="mkt-lead mt-4 max-w-2xl">
          Videos, essays, cartoons, and short messages curated for gentle reading.
        </p>

        <div className="mt-8">
          <DiscoverFilters active={typeFilter} />
        </div>

        {contents.length === 0 ? (
          <p className="mt-12 text-neutral-600">Nothing published in this category yet.</p>
        ) : (
          <div className="mt-10 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {contents.map((content) => (
              <ContentCard key={content.id} content={content} />
            ))}
          </div>
        )}
      </MarketingContainer>
    </MarketingSection>
  );
}
