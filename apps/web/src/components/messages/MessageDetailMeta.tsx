import Link from 'next/link';
import type { ReactNode } from 'react';

import type { PublicMessageCard } from '@/lib/messages';

function MetaBlock({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div>
      <h3 className="text-xs font-medium uppercase tracking-[0.12em] text-neutral-500">{title}</h3>
      <div className="mt-2">{children}</div>
    </div>
  );
}

function FilterChip({ href, label }: { href: string; label: string }) {
  return (
    <Link
      href={href}
      className="inline-flex rounded-full border border-neutral-200 bg-white px-3 py-1 text-sm text-neutral-700 transition hover:border-neutral-300 hover:text-neutral-900"
    >
      {label}
    </Link>
  );
}

type ClassificationChip = { href: string; label: string; key: string };

function buildClassificationChips(message: PublicMessageCard): ClassificationChip[] {
  const chips: ClassificationChip[] = [];

  if (message.primaryCategoryLabel) {
    chips.push({
      key: `category-${message.primaryCategory}`,
      href: `/messages?category=${message.primaryCategory}`,
      label: message.primaryCategoryLabel,
    });
  }

  message.situations.forEach((key, index) => {
    chips.push({
      key: `situation-${key}`,
      href: `/messages?situation=${key}`,
      label: message.situationLabels[index] ?? key,
    });
  });

  message.themeTags.forEach((key, index) => {
    chips.push({
      key: `theme-${key}`,
      href: `/messages?tag=${key}`,
      label: message.themeTagLabels[index] ?? key,
    });
  });

  return chips;
}

export function MessageDetailMeta({ message }: { message: PublicMessageCard }) {
  const classificationChips = buildClassificationChips(message);
  const hasClassification = classificationChips.length > 0;
  const hasCopy = Boolean(message.context) || Boolean(message.hint);

  if (!hasCopy && !hasClassification) {
    return null;
  }

  const showDividerBeforeClassification =
    hasClassification && (Boolean(message.context) || Boolean(message.hint));

  return (
    <section className="mt-10 w-full text-left lg:mt-0">
      <h2 className="text-lg font-semibold text-neutral-900">About this message</h2>

      {hasCopy ? (
        <div className="mt-6 space-y-6">
          {message.context ? (
            <MetaBlock title="Context">
              <p className="text-[15px] leading-relaxed text-neutral-700">{message.context}</p>
            </MetaBlock>
          ) : null}

          {message.hint ? (
            <MetaBlock title="Hint">
              <p className="text-[15px] leading-relaxed text-neutral-700">{message.hint}</p>
            </MetaBlock>
          ) : null}
        </div>
      ) : null}

      {showDividerBeforeClassification ? (
        <hr className="my-6 border-neutral-200" aria-hidden />
      ) : null}

      {hasClassification ? (
        <div className={`flex flex-wrap gap-2 ${hasCopy ? '' : 'mt-6'}`}>
          {classificationChips.map((chip) => (
            <FilterChip key={chip.key} href={chip.href} label={chip.label} />
          ))}
        </div>
      ) : null}
    </section>
  );
}
