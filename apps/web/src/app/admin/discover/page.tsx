'use client';

import { useMemo, useState } from 'react';
import Link from 'next/link';

import { useCatalogList } from '@/components/admin/catalog/useCatalogList';
import { useAdminDiscover } from '@/components/admin/hooks/use-admin-swr';
import { Alert } from '@/components/admin/ui/Alert';
import { Badge } from '@/components/admin/ui/Badge';
import { ButtonLink } from '@/components/admin/ui/Button';
import { DataTable } from '@/components/admin/ui/DataTable';
import { EmptyState } from '@/components/admin/ui/EmptyState';
import { FilterTabs } from '@/components/admin/ui/FilterTabs';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import { RowActionsMenu } from '@/components/admin/ui/RowActionsMenu';
import { revalidateAdminDiscover } from '@/lib/admin/swr-mutate';
import {
  DISCOVER_CONTENT_TYPES,
  type AdminDiscoverListItem,
  discoverContentTypeLabel,
} from '@/lib/discover-content';

type ArchiveFilter = 'active' | 'archived' | 'all';
type StatusFilter = 'all' | 'published' | 'draft';
type TypeFilter = 'all' | (typeof DISCOVER_CONTENT_TYPES)[number];

const ARCHIVE_TABS = [
  { id: 'active' as const, label: 'Active' },
  { id: 'archived' as const, label: 'Archived' },
  { id: 'all' as const, label: 'All' },
] as const;

const STATUS_FILTERS: Array<{ id: StatusFilter; label: string }> = [
  { id: 'all', label: 'All statuses' },
  { id: 'published', label: 'Published' },
  { id: 'draft', label: 'Draft' },
];

const TYPE_FILTERS: Array<{ id: TypeFilter; label: string }> = [
  { id: 'all', label: 'All categories' },
  ...DISCOVER_CONTENT_TYPES.map((type) => ({
    id: type as TypeFilter,
    label: discoverContentTypeLabel(type),
  })),
];

const COLUMNS = [
  { key: 'item', header: 'Discover item' },
  { key: 'type', header: 'Category' },
  { key: 'status', header: 'Status' },
  { key: 'plans', header: 'Plans' },
  { key: 'actions', header: 'Actions' },
];

function statusBadge(item: AdminDiscoverListItem) {
  if (item.is_archived) return <Badge tone="neutral">Archived</Badge>;
  if (item.is_published) return <Badge tone="success">Published</Badge>;
  return <Badge tone="neutral">Draft</Badge>;
}

export default function AdminDiscoverContentPage() {
  const { data, error: swrError, isLoading } = useAdminDiscover();
  const items = data?.items ?? [];
  const [archiveFilter, setArchiveFilter] = useState<ArchiveFilter>('active');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');
  const [typeFilter, setTypeFilter] = useState<TypeFilter>('all');
  const { busyId, setBusyId, error: mutationError, runDelete } = useCatalogList();

  const error = swrError?.message ?? mutationError;
  const loading = isLoading && items.length === 0;

  const filtered = useMemo(() => {
    return items.filter((item) => {
      if (archiveFilter === 'archived' && !item.is_archived) return false;
      if (archiveFilter === 'active' && item.is_archived) return false;

      if (statusFilter === 'published' && (!item.is_published || item.is_archived)) return false;
      if (statusFilter === 'draft' && (item.is_published || item.is_archived)) return false;

      if (typeFilter !== 'all' && item.content_type !== typeFilter) return false;

      return true;
    });
  }, [items, archiveFilter, statusFilter, typeFilter]);

  const handleDelete = async (item: AdminDiscoverListItem) => {
    if (!window.confirm(`Delete "${item.title}"? This cannot be undone.`)) return;
    setBusyId(item.id);
    const ok = await runDelete(`/api/v1/admin/content/${item.id}`, { errorMessage: 'Delete failed.' });
    setBusyId(null);
    if (ok) await revalidateAdminDiscover();
  };

  return (
    <>
      <PageHeader
        label="Discover (long-form)"
        title="Discover content"
        description={
          'Blog-style posts for /discover — Video, Article, or Cartoon categories. ' +
          'Mix blocks and slides in one post. Message cards are separate.'
        }
        actions={
          <>
            <ButtonLink href="/admin/messages" variant="secondary">
              Message cards
            </ButtonLink>
            <ButtonLink href="/admin/discover/new" variant="primary">
              New discover item
            </ButtonLink>
          </>
        }
      />

      <Alert tone="info">
        <strong>Message cards</strong> (<code>content_type = message</code>) are edited at{' '}
        <Link href="/admin/messages">/admin/messages</Link> and scheduled on Today. This catalog is
        only for video, essay, and cartoon.
      </Alert>

      <FilterTabs tabs={ARCHIVE_TABS} value={archiveFilter} onChange={setArchiveFilter} ariaLabel="Archive filter" />

      <div className="admin-filter-row">
        <label className="admin-filter-field" htmlFor="discover_status_filter">
          <span className="admin-muted">Status</span>
          <select
            id="discover_status_filter"
            value={statusFilter}
            onChange={(event) => setStatusFilter(event.target.value as StatusFilter)}
          >
            {STATUS_FILTERS.map((option) => (
              <option key={option.id} value={option.id}>
                {option.label}
              </option>
            ))}
          </select>
        </label>
        <label className="admin-filter-field" htmlFor="discover_type_filter">
          <span className="admin-muted">Category</span>
          <select
            id="discover_type_filter"
            value={typeFilter}
            onChange={(event) => setTypeFilter(event.target.value as TypeFilter)}
          >
            {TYPE_FILTERS.map((option) => (
              <option key={option.id} value={option.id}>
                {option.label}
              </option>
            ))}
          </select>
        </label>
      </div>

      {error ? <Alert tone="error">{error}</Alert> : null}
      {loading ? <p className="admin-muted">Loading discover content…</p> : null}

      {!loading && filtered.length === 0 ? (
        <EmptyState
          title="No discover items in this view"
          description="Create a video, essay, or cartoon for the public Discover page."
          action={
            <ButtonLink href="/admin/discover/new" variant="secondary">
              Create discover item
            </ButtonLink>
          }
        />
      ) : null}

      {!loading && filtered.length > 0 ? (
        <DataTable
          tableClassName="admin-table-discover"
          columns={COLUMNS}
          rows={filtered}
          rowKey={(item) => item.id}
          renderCell={(item, key) => {
            const busy = busyId === item.id;
            switch (key) {
              case 'item':
                return (
                  <span className="admin-discover-cell">
                    {item.cover_image_url ? (
                      <img src={item.cover_image_url} alt="" className="admin-discover-thumb" />
                    ) : (
                      <span className="admin-discover-thumb admin-discover-thumb-empty" aria-hidden />
                    )}
                    <span className="admin-discover-copy">
                      <strong>{item.title}</strong>
                      {item.summary ? (
                        <span className="admin-muted">{item.summary}</span>
                      ) : (
                        <span className="admin-muted admin-discover-slug">{item.slug}</span>
                      )}
                    </span>
                  </span>
                );
              case 'type':
                return <Badge tone="info">{discoverContentTypeLabel(item.content_type)}</Badge>;
              case 'status':
                return statusBadge(item);
              case 'plans':
                return String(item.related_plan_count);
              case 'actions':
                return (
                  <span className="admin-table-actions">
                    <Link href={`/admin/discover/${item.id}`} className="admin-btn admin-btn-link">
                      Edit
                    </Link>
                    {item.is_published && !item.is_archived ? (
                      <Link
                        href={`/content/${item.slug}`}
                        className="admin-btn admin-btn-link"
                        target="_blank"
                      >
                        View
                      </Link>
                    ) : null}
                    <RowActionsMenu
                      actions={[
                        {
                          id: 'delete',
                          label: 'Delete',
                          tone: 'danger',
                          disabled: busy,
                          onClick: () => void handleDelete(item),
                        },
                      ]}
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
