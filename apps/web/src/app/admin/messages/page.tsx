'use client';

import { useMemo, useState } from 'react';
import Link from 'next/link';

import { useCatalogList } from '@/components/admin/catalog/useCatalogList';
import { useAdminMessages } from '@/components/admin/hooks/use-admin-swr';
import { Alert } from '@/components/admin/ui/Alert';
import { Badge } from '@/components/admin/ui/Badge';
import { ButtonLink } from '@/components/admin/ui/Button';
import { DataTable } from '@/components/admin/ui/DataTable';
import { EmptyState } from '@/components/admin/ui/EmptyState';
import { FilterTabs } from '@/components/admin/ui/FilterTabs';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import { RowActionsMenu } from '@/components/admin/ui/RowActionsMenu';
import type { AdminContentListItem } from '@/lib/content';
import { revalidateAdminMessageCatalog } from '@/lib/admin/swr-mutate';
import { messageCategoryLabel } from '@/lib/message-admin';
import { MESSAGE_CATEGORIES } from '@/lib/message-taxonomy';
import { parseMessageMetadata } from '@/lib/message-metadata';

type ArchiveFilter = 'active' | 'archived' | 'all';
type StatusFilter = 'all' | 'published' | 'draft' | 'today_eligible';

const ARCHIVE_TABS = [
  { id: 'active' as const, label: 'Active' },
  { id: 'archived' as const, label: 'Archived' },
  { id: 'all' as const, label: 'All' },
] as const;

const STATUS_FILTERS: Array<{ id: StatusFilter; label: string }> = [
  { id: 'all', label: 'All statuses' },
  { id: 'published', label: 'Published' },
  { id: 'draft', label: 'Draft' },
  { id: 'today_eligible', label: 'Today-eligible' },
];

const COLUMNS = [
  { key: 'content', header: 'Message card' },
  { key: 'category', header: 'Category' },
  { key: 'status', header: 'Status' },
  { key: 'today', header: 'Today' },
  { key: 'plans', header: 'Plans' },
  { key: 'actions', header: 'Actions' },
];

function statusBadge(message: AdminContentListItem) {
  if (message.is_archived) return <Badge tone="neutral">Archived</Badge>;
  if (message.is_published) return <Badge tone="success">Published</Badge>;
  return <Badge tone="neutral">Draft</Badge>;
}

export default function AdminMessagesPage() {
  const { data, error: swrError, isLoading } = useAdminMessages();
  const messages = data?.messages ?? [];
  const [archiveFilter, setArchiveFilter] = useState<ArchiveFilter>('active');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('all');
  const [categoryFilter, setCategoryFilter] = useState('');
  const { busyId, setBusyId, error: mutationError, runDelete } = useCatalogList();

  const error = swrError?.message ?? mutationError;
  const loading = isLoading && messages.length === 0;

  const filtered = useMemo(() => {
    return messages.filter((message) => {
      const metadata = parseMessageMetadata(message.metadata);

      if (archiveFilter === 'archived' && !message.is_archived) return false;
      if (archiveFilter === 'active' && message.is_archived) return false;

      if (statusFilter === 'published' && (!message.is_published || message.is_archived)) return false;
      if (statusFilter === 'draft' && (message.is_published || message.is_archived)) return false;
      if (statusFilter === 'today_eligible' && (!metadata.isTodayEligible || message.is_archived)) {
        return false;
      }

      if (categoryFilter && metadata.primaryCategory !== categoryFilter) return false;

      return true;
    });
  }, [messages, archiveFilter, statusFilter, categoryFilter]);

  const handleDelete = async (message: AdminContentListItem) => {
    if (!window.confirm(`Delete "${message.title}"? This cannot be undone.`)) return;
    setBusyId(message.id);
    const ok = await runDelete(`/api/v1/admin/content/${message.id}`, { errorMessage: 'Delete failed.' });
    setBusyId(null);
    if (ok) await revalidateAdminMessageCatalog();
  };

  return (
    <>
      <PageHeader
        label="Message Card Library"
        title="Message cards"
        description="Manage published message cards for /messages and Today-eligible Home scheduling."
        actions={<ButtonLink href="/admin/messages/new" variant="primary">New message card</ButtonLink>}
      />

      <FilterTabs tabs={ARCHIVE_TABS} value={archiveFilter} onChange={setArchiveFilter} ariaLabel="Archive filter" />

      <div className="admin-filter-row">
        <label className="admin-filter-field" htmlFor="message_status_filter">
          <span className="admin-muted">Status</span>
          <select
            id="message_status_filter"
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
        <label className="admin-filter-field" htmlFor="message_category_filter">
          <span className="admin-muted">Category</span>
          <select
            id="message_category_filter"
            value={categoryFilter}
            onChange={(event) => setCategoryFilter(event.target.value)}
          >
            <option value="">All categories</option>
            {MESSAGE_CATEGORIES.map((category) => (
              <option key={category.key} value={category.key}>
                {category.label}
              </option>
            ))}
          </select>
        </label>
      </div>

      {error ? <Alert tone="error">{error}</Alert> : null}
      {loading ? <p className="admin-muted">Loading message cards…</p> : null}

      {!loading && filtered.length === 0 ? (
        <EmptyState
          title="No message cards in this view"
          description="Create a message card for the public library or Today scheduling."
          action={<ButtonLink href="/admin/messages/new" variant="secondary">Create message card</ButtonLink>}
        />
      ) : null}

      {!loading && filtered.length > 0 ? (
        <DataTable
          tableClassName="admin-table-messages"
          columns={COLUMNS}
          rows={filtered}
          rowKey={(message) => message.id}
          renderCell={(message, key) => {
            const busy = busyId === message.id;
            const metadata = parseMessageMetadata(message.metadata);

            switch (key) {
              case 'content':
                return (
                  <span className="admin-table-title-cell">
                    {message.cover_image_url ? (
                      <img src={message.cover_image_url} alt="" className="admin-table-thumb" />
                    ) : null}
                    <span>
                      <strong>{message.title}</strong>
                      <small className="admin-muted">{message.summary || message.slug}</small>
                    </span>
                  </span>
                );
              case 'category':
                return (
                  <span className="admin-muted">{messageCategoryLabel(metadata.primaryCategory)}</span>
                );
              case 'status':
                return statusBadge(message);
              case 'today':
                return metadata.isTodayEligible && !message.is_archived ? (
                  <Badge tone="info">Eligible</Badge>
                ) : (
                  <span className="admin-muted">—</span>
                );
              case 'plans':
                return String(message.related_plan_count);
              case 'actions':
                return (
                  <span className="admin-table-actions">
                    <Link href={`/admin/content/${message.id}`} className="admin-btn admin-btn-link">
                      Edit
                    </Link>
                    {message.is_published && !message.is_archived ? (
                      <Link href={`/messages/${message.slug}`} className="admin-btn admin-btn-link" target="_blank">
                        View
                      </Link>
                    ) : null}
                    {metadata.isTodayEligible && !message.is_archived ? (
                      <Link
                        href={`/admin/today-messages/new?content_id=${message.id}`}
                        className="admin-btn admin-btn-link"
                      >
                        Schedule
                      </Link>
                    ) : null}
                    <RowActionsMenu
                      actions={[
                        {
                          id: 'delete',
                          label: 'Delete',
                          tone: 'danger',
                          disabled: busy,
                          onClick: () => void handleDelete(message),
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
