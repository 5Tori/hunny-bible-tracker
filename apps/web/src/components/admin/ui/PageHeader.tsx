import type { ReactNode } from 'react';

type PageHeaderProps = {
  label?: string;
  title: string;
  description?: string;
  actions?: ReactNode;
};

export function PageHeader({ label, title, description, actions }: PageHeaderProps) {
  return (
    <header className="admin-page-header">
      <div>
        {label ? <p className="admin-page-header-label">{label}</p> : null}
        <h1>{title}</h1>
        {description ? <p className="admin-page-header-desc">{description}</p> : null}
      </div>
      {actions ? <div className="admin-actions">{actions}</div> : null}
    </header>
  );
}
