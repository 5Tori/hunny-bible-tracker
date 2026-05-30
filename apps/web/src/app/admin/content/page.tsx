'use client';

import { useMemo, useState } from 'react';
import Link from 'next/link';

import { useCatalogList } from '@/components/admin/catalog/useCatalogList';
import { useAdminContent } from '@/components/admin/hooks/use-admin-swr';
import { Alert } from '@/components/admin/ui/Alert';
import { Badge } from '@/components/admin/ui/Badge';
import { ButtonLink } from '@/components/admin/ui/Button';
import { DataTable } from '@/components/admin/ui/DataTable';
import { EmptyState } from '@/components/admin/ui/EmptyState';
import { FilterTabs } from '@/components/admin/ui/FilterTabs';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import { RowActionsMenu } from '@/components/admin/ui/RowActionsMenu';
import type { ContentWithRelations } from '@/lib/content';
import { revalidateAdminContent } from '@/lib/admin/swr-mutate';

type ContentFilter = 'active' | 'archived' | 'all';

const FILTER_TABS = [
  { id: 'active' as const, label: 'Active' },
  { id: 'archived' as const, label: 'Archived' },
  { id: 'all' as const, label: 'All' },
] as const;

const COLUMNS = [
  { key: 'content', header: 'Content' },
  { key: 'type', header: 'Type' },
  { key: 'author', header: 'Author' },
  { key: 'status', header: 'Status' },
  { key: 'plans', header: 'Plans' },
  { key: 'actions', header: 'Actions' },
];

function statusBadge(content: ContentWithRelations) {
  if (content.is_archived) return <Badge tone="neutral">Archived</Badge>;
  if (content.is_published) return <Badge tone="success">Published</Badge>;
  return <Badge tone="neutral">Draft</Badge>;
}

export default function AdminContentPage() {
  const { data, error: swrError, isLoading } = useAdminContent();
  const contents = data?.contents ?? [];
  const [filter, setFilter] = useState<ContentFilter>('active');
  const { busyId, setBusyId, error: mutationError, runDelete } = useCatalogList();

  const error = swrError?.message ?? mutationError;
  const loading = isLoading && contents.length === 0;

  const filtered = useMemo(() => {
    return contents.filter((content) => {
      if (content.content_type === 'message') return false;
      if (filter === 'all') return true;
      if (filter === 'archived') return content.is_archived;
      return !content.is_archived;
    });
  }, [contents, filter]);

  const handleDelete = async (content: ContentWithRelations) => {
    if (!window.confirm(`Delete "${content.title}"? This cannot be undone.`)) return;
    setBusyId(content.id);
    const ok = await runDelete(`/api/v1/admin/content/${content.id}`, { errorMessage: 'Delete failed.' });
    setBusyId(null);
    if (ok) await revalidateAdminContent();
  };

  return (
    <>
      <PageHeader
        label="Discover content"
        title="Other content"
        description="Manage videos, essays, and cartoons. Message cards live under Message cards."
        actions={<ButtonLink href="/admin/content/new" variant="primary">New content</ButtonLink>}
      />

      <FilterTabs tabs={FILTER_TABS} value={filter} onChange={setFilter} ariaLabel="Content filter" />

      {error ? <Alert tone="error">{error}</Alert> : null}
      {loading ? <p className="admin-muted">Loading content…</p> : null}

      {!loading && filtered.length === 0 ? (
        <EmptyState
          title="No content in this view"
          description="Create the first reusable content item."
          action={<ButtonLink href="/admin/content/new" variant="secondary">Create content</ButtonLink>}
        />
      ) : null}

      {!loading && filtered.length > 0 ? (
        <DataTable
          tableClassName="admin-table-content"
          columns={COLUMNS}
          rows={filtered}
          rowKey={(c) => c.id}
          renderCell={(content, key) => {
            const busy = busyId === content.id;
            switch (key) {
              case 'content':
                return (
                  <span className="admin-table-title-cell">
                    {content.cover_image_url ? (
                      <img src={content.cover_image_url} alt="" className="admin-table-thumb" />
                    ) : null}
                    <span>
                      <strong>{content.title}</strong>
                      <small className="admin-muted">{content.summary || content.slug}</small>
                    </span>
                  </span>
                );
              case 'type':
                return content.content_type;
              case 'author':
                return content.author?.display_name ?? 'None';
              case 'status':
                return statusBadge(content);
              case 'plans':
                return String(content.related_plans.length);
              case 'actions':
                return (
                  <span className="admin-table-actions">
                    <Link href={`/admin/content/${content.id}`} className="admin-btn admin-btn-link">
                      Edit
                    </Link>
                    <RowActionsMenu
                      actions={[
                        {
                          id: 'delete',
                          label: 'Delete',
                          tone: 'danger',
                          disabled: busy,
                          onClick: () => void handleDelete(content),
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
