import type { ReactNode } from 'react';

type BadgeTone = 'neutral' | 'success' | 'info' | 'danger' | 'warning';

export function Badge({ tone = 'neutral', children }: { tone?: BadgeTone; children: ReactNode }) {
  return <span className={`admin-badge admin-badge-${tone}`}>{children}</span>;
}
