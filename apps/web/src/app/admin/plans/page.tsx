'use client';

import Link from 'next/link';
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
import { revalidateAdminPlans } from '@/lib/admin/swr-mutate';
import {
  formatPlanAdminClassification,
  formatPlanMeta,
  planListBlurb,
} from '@/lib/plan-display';
import type { PlanTemplateBase } from '@/lib/plans';

type CatalogFilter = 'all' | 'active' | 'archived';

const FILTER_TABS = [
  { id: 'active' as const, label: 'Active' },
  { id: 'archived' as const, label: 'Archived' },
  { id: 'all' as const, label: 'All' },
] as const;

const COLUMNS = [
  { key: 'plan', header: 'Plan' },
  { key: 'classification', header: 'Classification' },
  { key: 'reading', header: 'Reading' },
  { key: 'catalog', header: 'Catalog' },
  { key: 'browse', header: 'Browse' },
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
        label="Reading plans"
        title="Plans"
        description="Templates for /plans — journey and book plans with covers, taxonomy, and chapter sections. Reading time is derived from chapters on save."
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
            const blurb = planListBlurb(plan);
            const readingMeta = formatPlanMeta(plan);

            switch (key) {
              case 'plan':
                return (
                  <span className="admin-plan-cell">
                    {plan.cover_image_url ? (
                      <img src={plan.cover_image_url} alt="" className="admin-plan-thumb" />
                    ) : (
                      <span className="admin-plan-thumb admin-plan-thumb-empty" aria-hidden />
                    )}
                    <span className="admin-plan-copy">
                      <strong className="admin-plan-title">
                        {plan.title}
                        {builtin ? <Badge tone="info">Built-in</Badge> : null}
                      </strong>
                      {blurb ? <span className="admin-muted">{blurb}</span> : null}
                      <span className="admin-muted admin-plan-key">{plan.template_key}</span>
                    </span>
                  </span>
                );
              case 'classification':
                return (
                  <span className="admin-muted">{formatPlanAdminClassification(plan)}</span>
                );
              case 'reading':
                return <span className="admin-muted">{readingMeta ?? '—'}</span>;
              case 'catalog':
                if (archived) {
                  return <Badge tone="neutral">Archived</Badge>;
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
              case 'actions':
                return (
                  <span className="admin-table-actions">
                    <Link href={`/admin/plans/${plan.id}`} className="admin-btn admin-btn-link">
                      Edit
                    </Link>
                    {published && !archived ? (
                      <Link
                        href={`/plans/${plan.template_key}`}
                        className="admin-btn admin-btn-link"
                        target="_blank"
                      >
                        View
                      </Link>
                    ) : null}
                    <PlanCatalogRowActions
                      plan={plan}
                      busy={busy}
                      showEditLink={false}
                      onPublish={() => void handlePatch(plan.id, { is_published: true })}
                      onUnpublish={() => void handlePatch(plan.id, { is_published: false })}
                      onArchive={() => void handlePatch(plan.id, { is_archived: true })}
                      onUnarchive={() => void handlePatch(plan.id, { is_archived: false })}
                      onDelete={() => void handleDelete(plan)}
                    />
                  </span>
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
