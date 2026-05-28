import type { ReactNode } from 'react';

type AlertTone = 'error' | 'success' | 'info' | 'warning';

export function Alert({ tone, children }: { tone: AlertTone; children: ReactNode }) {
  return <div className={`admin-alert admin-alert-${tone}`}>{children}</div>;
}
