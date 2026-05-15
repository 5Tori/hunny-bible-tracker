'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

import { adminFetch, getAdminTokenOrRefresh, clearAdminSession } from '@/lib/admin/client';
import type { PlanTemplateBase } from '@/lib/plans';

type CatalogFilter = 'all' | 'active' | 'archived';

export default function AdminPlansPage() {
  const router = useRouter();
  const [plans, setPlans] = useState<PlanTemplateBase[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<CatalogFilter>('active');
  const [busyId, setBusyId] = useState<string | null>(null);

  const loadPlans = useCallback(async () => {
    setLoading(true);
    setError(null);

    const token = await getAdminTokenOrRefresh();
    if (!token) {
      router.push('/admin/login');
      return;
    }

    const response = await adminFetch('/api/v1/admin/plans');

    if (response.status === 401 || response.status === 403) {
      await clearAdminSession();
      router.push('/admin/login');
      return;
    }

    if (!response.ok) {
      setError('Unable to load admin plans.');
      setLoading(false);
      return;
    }

    const json = await response.json();
    setPlans(json.plans ?? []);
    setLoading(false);
  }, [router]);

  useEffect(() => {
    void loadPlans();
  }, [loadPlans]);

  const filteredPlans = useMemo(() => {
    return plans.filter((plan) => {
      const archived = Boolean(plan.is_archived);
      if (filter === 'archived') return archived;
      if (filter === 'active') return !archived;
      return true;
    });
  }, [plans, filter]);

  const runCatalogPatch = async (planId: string, patch: { is_published?: boolean; is_archived?: boolean }) => {
    setBusyId(planId);
    setError(null);
    try {
      const response = await adminFetch(`/api/v1/admin/plans/${planId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(patch),
      });

      if (response.status === 401 || response.status === 403) {
        await clearAdminSession();
        router.push('/admin/login');
        return;
      }

      const body = await response.json().catch(() => ({}));
      if (!response.ok) {
        setError(typeof body.message === 'string' ? body.message : 'Catalog update failed.');
        return;
      }

      await loadPlans();
    } finally {
      setBusyId(null);
    }
  };

  const runDelete = async (plan: PlanTemplateBase) => {
    const ok = window.confirm(`Delete “${plan.title}”? This cannot be undone.`);
    if (!ok) return;

    setBusyId(plan.id);
    setError(null);
    try {
      const response = await adminFetch(`/api/v1/admin/plans/${plan.id}`, { method: 'DELETE' });

      if (response.status === 401 || response.status === 403) {
        await clearAdminSession();
        router.push('/admin/login');
        return;
      }

      const body = await response.json().catch(() => ({}));
      if (!response.ok) {
        setError(typeof body.message === 'string' ? body.message : 'Delete failed.');
        return;
      }

      await loadPlans();
    } finally {
      setBusyId(null);
    }
  };

  const browseSummary = (plan: PlanTemplateBase) => {
    const visible = plan.browse_visible !== false;
    const rank = plan.featured_rank;
    return (
      <span className="plans-browse-cell">
        {visible ? (
          <span className="plans-badge plans-badge-browse-on">Visible</span>
        ) : (
          <span className="plans-badge plans-badge-hidden">Hidden</span>
        )}
        {visible && rank != null ? (
          <span className="muted">Featured #{rank}</span>
        ) : null}
      </span>
    );
  };

  const catalogLabel = (plan: PlanTemplateBase) => {
    const archived = Boolean(plan.is_archived);
    const published = Boolean(plan.is_published);
    if (archived) {
      return (
        <span className="plans-catalog-status">
          <span className="plans-badge plans-badge-archived">Archived</span>
          <span className="muted">Hidden from catalog</span>
        </span>
      );
    }
    return (
      <span className="plans-catalog-status">
        <span className={published ? 'plans-badge plans-badge-published' : 'plans-badge plans-badge-draft'}>
          {published ? 'Published' : 'Draft'}
        </span>
      </span>
    );
  };

  return (
    <main className="admin-plans-page">
      <div className="admin-page-header">
        <div>
          <h1>Plan catalog</h1>
          <p>Create and edit templates, control draft vs published, archive, or delete plans.</p>
        </div>
        <div className="admin-actions">
          <Link href="/admin/today-messages" className="btn btn-secondary">
            Today messages
          </Link>
          <Link href="/admin/plans/new" className="btn btn-primary">
            New plan
          </Link>
          <button type="button" onClick={() => { void clearAdminSession().then(() => router.push('/admin/login')); }} className="btn btn-secondary">
            Logout
          </button>
        </div>
      </div>

      <div className="admin-catalog-filters" role="tablist" aria-label="Catalog filter">
        {(
          [
            { id: 'active' as const, label: 'Active' },
            { id: 'archived' as const, label: 'Archived' },
            { id: 'all' as const, label: 'All' },
          ] as const
        ).map((tab) => (
          <button
            key={tab.id}
            type="button"
            role="tab"
            aria-selected={filter === tab.id}
            className={filter === tab.id ? 'admin-catalog-filter is-active' : 'admin-catalog-filter'}
            onClick={() => setFilter(tab.id)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {error ? <div className="alert alert-error">{error}</div> : null}
      {loading ? <p>Loading plans…</p> : null}

      {!loading && filteredPlans.length === 0 ? (
        <div>
          <p>No plans in this view.</p>
          {filter === 'active' ? (
            <Link href="/admin/plans/new" className="btn btn-secondary">
              Create a plan
            </Link>
          ) : null}
        </div>
      ) : null}

      {!loading && filteredPlans.length > 0 ? (
        <div className="plans-table">
          <div className="plans-table-row plans-table-header">
            <span>Title</span>
            <span>Catalog</span>
            <span>Browse</span>
            <span>Updated</span>
            <span>Actions</span>
          </div>
          {filteredPlans.map((plan) => {
            const busy = busyId === plan.id;
            const archived = Boolean(plan.is_archived);
            const published = Boolean(plan.is_published);
            const builtin = Boolean(plan.is_builtin);
            return (
              <div key={plan.id} className="plans-table-row">
                <span className="plans-table-title">
                  {plan.title}
                  {builtin ? <span className="plans-badge plans-badge-builtin">Built-in</span> : null}
                </span>
                <span>{catalogLabel(plan)}</span>
                <span>{browseSummary(plan)}</span>
                <span className="muted">{new Date(plan.updated_at).toLocaleString()}</span>
                <span className="plans-table-actions">
                  <Link href={`/admin/plans/${plan.id}`} className="btn btn-link">
                    Edit
                  </Link>
                  {!archived && !published ? (
                    <button
                      type="button"
                      className="btn btn-secondary"
                      disabled={busy}
                      onClick={() => void runCatalogPatch(plan.id, { is_published: true })}
                    >
                      Publish
                    </button>
                  ) : null}
                  {!archived && published ? (
                    <button
                      type="button"
                      className="btn btn-secondary"
                      disabled={busy}
                      onClick={() => void runCatalogPatch(plan.id, { is_published: false })}
                    >
                      Unpublish
                    </button>
                  ) : null}
                  {!archived ? (
                    <button
                      type="button"
                      className="btn btn-secondary"
                      disabled={busy}
                      onClick={() => void runCatalogPatch(plan.id, { is_archived: true })}
                    >
                      Archive
                    </button>
                  ) : (
                    <button
                      type="button"
                      className="btn btn-secondary"
                      disabled={busy}
                      onClick={() => void runCatalogPatch(plan.id, { is_archived: false })}
                    >
                      Unarchive
                    </button>
                  )}
                  <button
                    type="button"
                    className="btn btn-danger"
                    disabled={busy || builtin}
                    title={builtin ? 'Built-in plans cannot be deleted.' : undefined}
                    onClick={() => void runDelete(plan)}
                  >
                    Delete
                  </button>
                </span>
              </div>
            );
          })}
        </div>
      ) : null}
    </main>
  );
}
