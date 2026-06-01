'use client';

import Link from 'next/link';

import type { PlanTemplateBase } from '@/lib/plans';

import { RowActionsMenu, type RowAction } from '../ui/RowActionsMenu';

type PlanCatalogRowActionsProps = {
  plan: PlanTemplateBase;
  busy: boolean;
  showEditLink?: boolean;
  onPublish: () => void;
  onUnpublish: () => void;
  onArchive: () => void;
  onUnarchive: () => void;
  onDelete: () => void;
};

export function PlanCatalogRowActions({
  plan,
  busy,
  showEditLink = true,
  onPublish,
  onUnpublish,
  onArchive,
  onUnarchive,
  onDelete,
}: PlanCatalogRowActionsProps) {
  const archived = Boolean(plan.is_archived);
  const published = Boolean(plan.is_published);
  const builtin = Boolean(plan.is_builtin);

  const menuActions: RowAction[] = [];
  if (!archived && !published) {
    menuActions.push({ id: 'publish', label: 'Publish', tone: 'success', disabled: busy, onClick: onPublish });
  }
  if (!archived && published) {
    menuActions.push({ id: 'unpublish', label: 'Unpublish', disabled: busy, onClick: onUnpublish });
  }
  if (!archived) {
    menuActions.push({ id: 'archive', label: 'Archive', disabled: busy, onClick: onArchive });
  } else {
    menuActions.push({ id: 'unarchive', label: 'Unarchive', disabled: busy, onClick: onUnarchive });
  }
  menuActions.push({
    id: 'delete',
    label: 'Delete',
    tone: 'danger',
    disabled: busy || builtin,
    onClick: onDelete,
  });

  return (
    <>
      {showEditLink ? (
        <Link href={`/admin/plans/${plan.id}`} className="admin-btn admin-btn-link">
          Edit
        </Link>
      ) : null}
      <RowActionsMenu actions={menuActions} />
    </>
  );
}
