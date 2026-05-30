'use client';

import { useMemo, useState } from 'react';
import Link from 'next/link';

import { useAdminMessages, useAdminTodayMessages } from '@/components/admin/hooks/use-admin-swr';
import { Alert } from '@/components/admin/ui/Alert';
import { Badge } from '@/components/admin/ui/Badge';
import { ButtonLink } from '@/components/admin/ui/Button';
import { DataTable } from '@/components/admin/ui/DataTable';
import { EmptyState } from '@/components/admin/ui/EmptyState';
import { FilterTabs } from '@/components/admin/ui/FilterTabs';
import { PageHeader } from '@/components/admin/ui/PageHeader';

type TodayFilter = 'active' | 'archived' | 'all';

const FILTER_TABS = [
  { id: 'active' as const, label: 'Active' },
  { id: 'archived' as const, label: 'Archived' },
  { id: 'all' as const, label: 'All' },
] as const;

const COLUMNS = [
  { key: 'message', header: 'Message' },
  { key: 'linked', header: 'Linked card' },
  { key: 'date', header: 'Date' },
  { key: 'language', header: 'Language' },
  { key: 'status', header: 'Status' },
  { key: 'actions', header: 'Actions' },
];

export default function AdminTodayMessagesPage() {
  const {
    data: todayData,
    error: todayError,
    isLoading: todayLoading,
  } = useAdminTodayMessages();
  const { data: messageData } = useAdminMessages();
  const [filter, setFilter] = useState<TodayFilter>('active');

  const messages = todayData?.messages ?? [];
  const linkedContentById = useMemo(
    () => new Map((messageData?.messages ?? []).map((item) => [item.id, item])),
    [messageData?.messages],
  );
  const loading = todayLoading && messages.length === 0;

  const filtered = useMemo(() => {
    return messages.filter((message) => {
      const archived = Boolean((message as { is_archived?: boolean }).is_archived);
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
        description="Schedule daily verse cards for the mobile Home tab. Link Today-eligible message cards for deeper content."
        actions={<ButtonLink href="/admin/today-messages/new" variant="primary">New message</ButtonLink>}
      />

      <FilterTabs tabs={FILTER_TABS} value={filter} onChange={setFilter} ariaLabel="Today messages filter" />

      {todayError ? <Alert tone="error">{todayError.message}</Alert> : null}
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
            const linked = message.content_id ? linkedContentById.get(message.content_id) ?? null : null;

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
                        {message.verse_text || 'No verse text yet'}
                      </small>
                    </span>
                  </span>
                );
              case 'linked':
                if (!linked) {
                  return <span className="admin-muted">None</span>;
                }
                return (
                  <span className="admin-table-cell-stack">
                    <Link href={`/admin/content/${linked.id}`} className="admin-btn admin-btn-link">
                      {linked.title}
                    </Link>
                    {linked.is_published ? (
                      <Link href={`/messages/${linked.slug}`} className="admin-muted" target="_blank">
                        /messages/{linked.slug}
                      </Link>
                    ) : (
                      <span className="admin-muted">Card draft</span>
                    )}
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
