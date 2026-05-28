import type { ReactNode } from 'react';

export function FormSection({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="admin-form-section">
      <h2>{title}</h2>
      {children}
    </section>
  );
}

export function FormGrid({ columns = 2, children }: { columns?: 2 | 3; children: ReactNode }) {
  return <div className={columns === 3 ? 'admin-form-grid-3' : 'admin-form-grid-2'}>{children}</div>;
}
