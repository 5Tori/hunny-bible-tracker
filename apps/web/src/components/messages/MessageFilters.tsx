'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState, type FormEvent } from 'react';

import {
  MESSAGE_PRIMARY_CATEGORIES,
  getAllSituations,
  getSuggestedSituationsForCategory,
} from '@/lib/message-taxonomy';

interface MessageFiltersProps {
  activeCategory?: string;
  activeSituation?: string;
  query?: string;
  layout?: 'sidebar' | 'inline';
}

function SearchIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      aria-hidden
      className="h-4 w-4"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
    >
      <circle cx="11" cy="11" r="7" />
      <path d="M20 20l-3-3" strokeLinecap="round" />
    </svg>
  );
}

function FilterIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      aria-hidden
      className="h-4 w-4"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
    >
      <path d="M4 7h16M7 12h10M10 17h4" strokeLinecap="round" />
    </svg>
  );
}

const iconButtonSize =
  'flex h-9 w-9 shrink-0 items-center justify-center rounded-full transition';

function iconButtonActiveClass() {
  return `${iconButtonSize} border border-neutral-900 bg-neutral-900 text-white hover:bg-black`;
}

function iconButtonInactiveClass() {
  return `${iconButtonSize} border border-neutral-200 bg-white text-neutral-700 hover:border-neutral-300`;
}

function buildHref(params: { category?: string; situation?: string; q?: string }) {
  const search = new URLSearchParams();
  if (params.category) search.set('category', params.category);
  if (params.situation) search.set('situation', params.situation);
  if (params.q) search.set('q', params.q);
  const value = search.toString();
  return value ? `/messages?${value}` : '/messages';
}

export function MessageFilters({
  activeCategory,
  activeSituation,
  query,
  layout = 'inline',
}: MessageFiltersProps) {
  const router = useRouter();
  const situations = activeCategory
    ? getSuggestedSituationsForCategory(activeCategory)
    : getAllSituations();
  const isSidebar = layout === 'sidebar';
  const hasActiveFilters = Boolean(activeCategory || activeSituation);
  const [filtersOpen, setFiltersOpen] = useState(hasActiveFilters);
  const filterToggleActive = filtersOpen || hasActiveFilters;

  function handleSearchSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    const q = String(formData.get('q') ?? '').trim();
    const category = String(formData.get('category') ?? '').trim();
    const situation = String(formData.get('situation') ?? '').trim();
    const href = buildHref({
      category: category || undefined,
      situation: situation || undefined,
      q: q || undefined,
    });
    router.push(href, { scroll: false });
  }

  const shellClass = isSidebar
    ? 'lg:rounded-2xl lg:border lg:border-neutral-200 lg:bg-white lg:p-5'
    : 'mt-8';

  const filterPanelClass =
    filtersOpen || !isSidebar
      ? 'mt-4 block space-y-6 lg:mt-6'
      : 'hidden space-y-6 lg:mt-6 lg:block';

  return (
    <div className={shellClass}>
      <form onSubmit={handleSearchSubmit}>
        {activeCategory ? <input type="hidden" name="category" value={activeCategory} /> : null}
        {activeSituation ? <input type="hidden" name="situation" value={activeSituation} /> : null}
        <div className="flex items-end gap-2">
          <div className="relative min-w-0 flex-1 border-b border-neutral-200 pb-2 transition-colors focus-within:border-neutral-900">
            <input
              type="search"
              name="q"
              defaultValue={query ?? ''}
              placeholder="Search by feeling, situation, or verse..."
              className="w-full border-0 bg-transparent py-2 pr-11 text-sm text-neutral-900 placeholder:text-neutral-400 outline-none ring-0 focus:ring-0"
            />
            <button
              type="submit"
              aria-label="Search messages"
              className={`absolute right-0 bottom-0 ${iconButtonActiveClass()}`}
            >
              <SearchIcon />
            </button>
          </div>
          {isSidebar ? (
            <button
              type="button"
              aria-label={filtersOpen ? 'Hide filters' : 'Show filters'}
              aria-expanded={filtersOpen}
              aria-controls="message-filter-options"
              onClick={() => setFiltersOpen((open) => !open)}
              className={`lg:hidden ${
                filterToggleActive ? iconButtonActiveClass() : iconButtonInactiveClass()
              }`}
            >
              <FilterIcon />
            </button>
          ) : null}
        </div>
      </form>

      <div id="message-filter-options" className={isSidebar ? filterPanelClass : 'mt-6 space-y-6'}>
        <div>
          <p className="text-xs font-medium uppercase tracking-[0.12em] text-neutral-500">
            How are you feeling?
          </p>
          <div className="mt-3 flex flex-wrap gap-1.5">
            <FilterChip
              href={buildHref({ q: query })}
              active={!activeCategory}
              label="All"
            />
            {MESSAGE_PRIMARY_CATEGORIES.map((category) => (
              <FilterChip
                key={category.key}
                href={buildHref({ category: category.key, q: query })}
                active={activeCategory === category.key}
                label={category.label}
              />
            ))}
          </div>
        </div>

        <div>
          <p className="text-xs font-medium uppercase tracking-[0.12em] text-neutral-500">
            Situation
          </p>
          <div className="mt-3 flex flex-wrap gap-1.5">
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
      </div>
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
      scroll={false}
      className={`inline-flex max-w-full items-center rounded-full border px-2.5 py-1 text-[13px] leading-snug transition ${
        active
          ? 'border-neutral-900 bg-neutral-900 text-white'
          : 'border-neutral-200 bg-white text-neutral-700 hover:border-neutral-300'
      }`}
    >
      {label}
    </Link>
  );
}
