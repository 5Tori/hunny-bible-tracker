import Link from 'next/link';
import { Fragment } from 'react';

import type { PublicMessageCard } from '@/lib/messages';

type Chip = { key: string; href: string; label: string };

function buildCategorySituationChips(message: PublicMessageCard): Chip[] {
  const chips: Chip[] = [];

  if (message.primaryCategory && message.primaryCategoryLabel) {
    chips.push({
      key: `category-${message.primaryCategory}`,
      href: `/messages?category=${message.primaryCategory}`,
      label: message.primaryCategoryLabel,
    });
  }

  message.situations.forEach((key, index) => {
    const label = message.situationLabels[index] ?? key;
    chips.push({
      key: `situation-${key}`,
      href: `/messages?situation=${key}`,
      label,
    });
  });

  return chips;
}

const linkClassName =
  'text-neutral-600 underline-offset-2 transition hover:text-neutral-900 hover:underline';

export function MessageCardClassification({
  message,
  className = '',
}: {
  message: PublicMessageCard;
  className?: string;
}) {
  const chips = buildCategorySituationChips(message);

  if (chips.length === 0) {
    return null;
  }

  return (
    <p
      className={`text-[11px] leading-snug text-neutral-500 lg:text-xs ${className}`.trim()}
    >
      {chips.map((chip, index) => (
        <Fragment key={chip.key}>
          {index > 0 ? <span aria-hidden>, </span> : null}
          <Link href={chip.href} scroll={false} className={linkClassName}>
            {chip.label}
          </Link>
        </Fragment>
      ))}
    </p>
  );
}
