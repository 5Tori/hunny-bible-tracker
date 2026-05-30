'use client';

import { useMemo, useState } from 'react';

import { PlanCatalogRowActions } from '@/components/admin/catalog/PlanCatalogRowActions';
import { useCatalogList } from '@/components/admin/catalog/useCatalogList';
import { useAdminPlans } from '@/components/admin/hooks/use-admin-swr';
import { Alert } from '@/components/admin/ui/Alert';
import { Badge } from '@/components/admin/ui/Badge';
import { ButtonLink } from '@/components/admin/ui/Button';
import { DataTable } from '@/components/admin/ui/DataTable';
import { EmptyState } from '@/components/admin/ui/EmptyState';
import { FilterTabs } from '@/components/admin/ui/FilterTabs';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import type { PlanTemplateBase } from '@/lib/plans';
import { revalidateAdminPlans } from '@/lib/admin/swr-mutate';
import { planTypeLabel } from '@/lib/plan-taxonomy';

type CatalogFilter = 'all' | 'active' | 'archived';

const FILTER_TABS = [
  { id: 'active' as const, label: 'Active' },
  { id: 'archived' as const, label: 'Archived' },
  { id: 'all' as const, label: 'All' },
] as const;

const COLUMNS = [
  { key: 'title', header: 'Title' },
  { key: 'type', header: 'Type' },
  { key: 'catalog', header: 'Catalog' },
  { key: 'browse', header: 'Browse' },
  { key: 'updated', header: 'Updated' },
  { key: 'actions', header: 'Actions' },
];

export default function AdminPlansPage() {
  const { data, error: swrError, isLoading } = useAdminPlans();
  const plans = data?.plans ?? [];
  const [filter, setFilter] = useState<CatalogFilter>('active');
  const { busyId, setBusyId, error: mutationError, runPatch, runDelete } = useCatalogList();

  const error = swrError?.message ?? mutationError;
  const loading = isLoading && plans.length === 0;

  const filteredPlans = useMemo(() => {
    return plans.filter((plan) => {
      const archived = Boolean(plan.is_archived);
      if (filter === 'archived') return archived;
      if (filter === 'active') return !archived;
      return true;
    });
  }, [plans, filter]);

  const handlePatch = async (planId: string, patch: { is_published?: boolean; is_archived?: boolean }) => {
    setBusyId(planId);
    const ok = await runPatch(`/api/v1/admin/plans/${planId}`, patch, { errorMessage: 'Catalog update failed.' });
    setBusyId(null);
    if (ok) await revalidateAdminPlans();
  };

  const handleDelete = async (plan: PlanTemplateBase) => {
    if (!window.confirm(`Delete "${plan.title}"? This cannot be undone.`)) return;
    setBusyId(plan.id);
    const ok = await runDelete(`/api/v1/admin/plans/${plan.id}`, { errorMessage: 'Delete failed.' });
    setBusyId(null);
    if (ok) await revalidateAdminPlans();
  };

  return (
    <>
      <PageHeader
        title="Plans"
        description="Create and edit templates, control draft vs published, archive, or delete plans."
        actions={<ButtonLink href="/admin/plans/new" variant="primary">New plan</ButtonLink>}
      />

      <FilterTabs tabs={FILTER_TABS} value={filter} onChange={setFilter} ariaLabel="Catalog filter" />

      {error ? <Alert tone="error">{error}</Alert> : null}
      {loading ? <p className="admin-muted">Loading plans…</p> : null}

      {!loading && filteredPlans.length === 0 ? (
        <EmptyState
          title="No plans in this view"
          description="Create a new plan to get started."
          action={
            filter === 'active' ? (
              <ButtonLink href="/admin/plans/new" variant="secondary">Create a plan</ButtonLink>
            ) : undefined
          }
        />
      ) : null}

      {!loading && filteredPlans.length > 0 ? (
        <DataTable
          tableClassName="admin-table-plans"
          columns={COLUMNS}
          rows={filteredPlans}
          rowKey={(plan) => plan.id}
          renderCell={(plan, key) => {
            const busy = busyId === plan.id;
            const archived = Boolean(plan.is_archived);
            const published = Boolean(plan.is_published);
            const builtin = Boolean(plan.is_builtin);

            switch (key) {
              case 'title':
                return (
                  <span className="admin-table-title">
                    {plan.title}
                    {builtin ? <Badge tone="info">Built-in</Badge> : null}
                  </span>
                );
              case 'type':
                return <span className="admin-muted">{planTypeLabel(plan.plan_type)}</span>;
              case 'catalog':
                if (archived) {
                  return (
                    <span className="admin-table-cell-stack">
                      <Badge tone="neutral">Archived</Badge>
                    </span>
                  );
                }
                return published ? <Badge tone="success">Published</Badge> : <Badge tone="neutral">Draft</Badge>;
              case 'browse': {
                const visible = plan.browse_visible !== false;
                return (
                  <span className="admin-table-cell-stack">
                    {visible ? <Badge tone="success">Visible</Badge> : <Badge tone="neutral">Hidden</Badge>}
                    {visible && plan.featured_rank != null ? (
                      <span className="admin-muted">Featured #{plan.featured_rank}</span>
                    ) : null}
                  </span>
                );
              }
              case 'updated':
                return <span className="admin-muted">{new Date(plan.updated_at).toLocaleString()}</span>;
              case 'actions':
                return (
                  <PlanCatalogRowActions
                    plan={plan}
                    busy={busy}
                    onPublish={() => void handlePatch(plan.id, { is_published: true })}
                    onUnpublish={() => void handlePatch(plan.id, { is_published: false })}
                    onArchive={() => void handlePatch(plan.id, { is_archived: true })}
                    onUnarchive={() => void handlePatch(plan.id, { is_archived: false })}
                    onDelete={() => void handleDelete(plan)}
                  />
                );
              default:
                return null;
            }
          }}
        />
      ) : null}
    </>
  );
}
