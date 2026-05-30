import Link from "next/link";

import { MESSAGE_CATEGORIES, getSituationsForCategory } from "@/lib/message-taxonomy";

interface MessageFiltersProps {
  activeCategory?: string;
  activeSituation?: string;
  query?: string;
}

function buildHref(params: { category?: string; situation?: string; q?: string }) {
  const search = new URLSearchParams();
  if (params.category) search.set("category", params.category);
  if (params.situation) search.set("situation", params.situation);
  if (params.q) search.set("q", params.q);
  const value = search.toString();
  return value ? `/messages?${value}` : "/messages";
}

export function MessageFilters({
  activeCategory,
  activeSituation,
  query,
}: MessageFiltersProps) {
  const situations = activeCategory ? getSituationsForCategory(activeCategory) : [];

  return (
    <div className="mt-8 space-y-6">
      <form action="/messages" method="get" className="flex flex-col gap-3 sm:flex-row">
        {activeCategory ? (
          <input type="hidden" name="category" value={activeCategory} />
        ) : null}
        {activeSituation ? (
          <input type="hidden" name="situation" value={activeSituation} />
        ) : null}
        <input
          type="search"
          name="q"
          defaultValue={query ?? ""}
          placeholder="Search by feeling, situation, or verse..."
          className="w-full rounded-xl border border-neutral-200 px-4 py-3 text-sm text-neutral-900 outline-none transition focus:border-neutral-400"
        />
        <button
          type="submit"
          className="rounded-xl bg-neutral-900 px-5 py-3 text-sm font-medium text-white transition hover:bg-black"
        >
          Search
        </button>
      </form>

      <div>
        <p className="text-xs font-medium uppercase tracking-[0.12em] text-neutral-500">
          How are you feeling?
        </p>
        <div className="mt-3 flex flex-wrap gap-2">
          <FilterChip
            href={buildHref({ q: query })}
            active={!activeCategory}
            label="All"
          />
          {MESSAGE_CATEGORIES.map((category) => (
            <FilterChip
              key={category.key}
              href={buildHref({ category: category.key, q: query })}
              active={activeCategory === category.key}
              label={category.label}
            />
          ))}
        </div>
      </div>

      {situations.length > 0 ? (
        <div>
          <p className="text-xs font-medium uppercase tracking-[0.12em] text-neutral-500">
            Situation
          </p>
          <div className="mt-3 flex flex-wrap gap-2">
            <FilterChip
              href={buildHref({ category: activeCategory, q: query })}
              active={!activeSituation}
              label="Any"
            />
            {situations.map((situation) => (
              <FilterChip
                key={situation.key}
                href={buildHref({
                  category: activeCategory,
                  situation: situation.key,
                  q: query,
                })}
                active={activeSituation === situation.key}
                label={situation.label}
              />
            ))}
          </div>
        </div>
      ) : null}
    </div>
  );
}

function FilterChip({
  href,
  label,
  active,
}: {
  href: string;
  label: string;
  active: boolean;
}) {
  return (
    <Link
      href={href}
      className={`rounded-full border px-3 py-1.5 text-sm transition ${
        active
          ? "border-neutral-900 bg-neutral-900 text-white"
          : "border-neutral-200 bg-white text-neutral-700 hover:border-neutral-300"
      }`}
    >
      {label}
    </Link>
  );
}
