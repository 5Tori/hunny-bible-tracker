'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';

import { useCatalogList } from '@/components/admin/catalog/useCatalogList';
import { Alert } from '@/components/admin/ui/Alert';
import { Badge } from '@/components/admin/ui/Badge';
import { ButtonLink } from '@/components/admin/ui/Button';
import { DataTable } from '@/components/admin/ui/DataTable';
import { EmptyState } from '@/components/admin/ui/EmptyState';
import { FilterTabs } from '@/components/admin/ui/FilterTabs';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import type { TodayMessageBase } from '@/lib/today-messages';

type TodayFilter = 'active' | 'archived' | 'all';

const FILTER_TABS = [
  { id: 'active' as const, label: 'Active' },
  { id: 'archived' as const, label: 'Archived' },
  { id: 'all' as const, label: 'All' },
] as const;

const COLUMNS = [
  { key: 'message', header: 'Message' },
  { key: 'date', header: 'Date' },
  { key: 'language', header: 'Language' },
  { key: 'status', header: 'Status' },
  { key: 'actions', header: 'Actions' },
];

export default function AdminTodayMessagesPage() {
  const [messages, setMessages] = useState<TodayMessageBase[]>([]);
  const [filter, setFilter] = useState<TodayFilter>('active');
  const { error, setError, load, loading } = useCatalogList();

  const loadMessages = useCallback(async () => {
    setError(null);
    const json = (await load('/api/v1/admin/today-messages')) as { messages?: TodayMessageBase[] } | null;
    if (json) {
      setMessages(json.messages ?? []);
    }
  }, [load, setError]);

  useEffect(() => {
    void loadMessages();
  }, [loadMessages]);

  const filtered = useMemo(() => {
    return messages.filter((message) => {
      const archived = Boolean((message as TodayMessageBase & { is_archived?: boolean }).is_archived);
      if (filter === 'archived') return archived;
      if (filter === 'active') return !archived;
      return true;
    });
  }, [messages, filter]);

  return (
    <>
      <PageHeader
        label="Home content"
        title="Today's messages"
        description="Manage scheduled daily verse/message cards for the mobile Home tab."
        actions={<ButtonLink href="/admin/today-messages/new" variant="primary">New message</ButtonLink>}
      />

      <FilterTabs tabs={FILTER_TABS} value={filter} onChange={setFilter} ariaLabel="Today messages filter" />

      {error ? <Alert tone="error">{error}</Alert> : null}
      {loading ? <p className="admin-muted">Loading messages…</p> : null}

      {!loading && filtered.length === 0 ? (
        <EmptyState
          title="No messages in this view"
          description="Create a daily message for the Home tab."
          action={<ButtonLink href="/admin/today-messages/new" variant="secondary">Create message</ButtonLink>}
        />
      ) : null}

      {!loading && filtered.length > 0 ? (
        <DataTable
          tableClassName="admin-table-today"
          columns={COLUMNS}
          rows={filtered}
          rowKey={(m) => m.id}
          renderCell={(message, key) => {
            switch (key) {
              case 'message':
                return (
                  <span className="admin-table-title-cell">
                    {message.image_url ? (
                      <img src={message.image_url} alt="" className="admin-table-thumb" />
                    ) : null}
                    <span>
                      <strong>{message.verse_reference}</strong>
                      <small className="admin-muted">
                        {message.message || message.verse_text || 'No message text yet'}
                      </small>
                    </span>
                  </span>
                );
              case 'date':
                return message.publish_date;
              case 'language':
                return message.language;
              case 'status':
                return message.is_published ? (
                  <Badge tone="success">Published</Badge>
                ) : (
                  <Badge tone="neutral">Draft</Badge>
                );
              case 'actions':
                return (
                  <Link href={`/admin/today-messages/${message.id}`} className="admin-btn admin-btn-link">
                    Edit
                  </Link>
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
