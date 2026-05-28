'use client';

import { useEffect, useRef, useState } from 'react';

export type RowAction = {
  id: string;
  label: string;
  onClick: () => void;
  disabled?: boolean;
  tone?: 'default' | 'success' | 'danger';
};

export function RowActionsMenu({ actions }: { actions: RowAction[] }) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    const onDoc = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener('mousedown', onDoc);
    return () => document.removeEventListener('mousedown', onDoc);
  }, [open]);

  if (actions.length === 0) return null;

  return (
    <div className="admin-dropdown" ref={ref}>
      <button type="button" className="admin-btn admin-btn-secondary" onClick={() => setOpen((v) => !v)}>
        More
      </button>
      {open ? (
        <ul className="admin-dropdown-menu" role="menu">
          {actions.map((action) => (
            <li key={action.id} role="none">
              <button
                type="button"
                role="menuitem"
                className={[
                  'admin-dropdown-item',
                  action.tone === 'danger' ? 'admin-dropdown-item-danger' : '',
                  action.tone === 'success' ? 'admin-dropdown-item-success' : '',
                ]
                  .filter(Boolean)
                  .join(' ')}
                disabled={action.disabled}
                onClick={() => {
                  setOpen(false);
                  action.onClick();
                }}
              >
                {action.label}
              </button>
            </li>
          ))}
        </ul>
      ) : null}
    </div>
  );
}
