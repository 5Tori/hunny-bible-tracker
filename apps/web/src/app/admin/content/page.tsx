'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

import { adminFetch, clearAdminSession, getAdminTokenOrRefresh } from '@/lib/admin/client';
import type { ContentWithRelations } from '@/lib/content';

type ContentFilter = 'active' | 'archived' | 'all';

function statusLabel(content: ContentWithRelations) {
  if (content.is_archived) return 'Archived';
  return content.is_published ? 'Published' : 'Draft';
}

export default function AdminContentPage() {
  const router = useRouter();
  const [contents, setContents] = useState<ContentWithRelations[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [filter, setFilter] = useState<ContentFilter>('active');

  const loadContent = useCallback(async () => {
    setLoading(true);
    setError(null);

    const token = await getAdminTokenOrRefresh();
    if (!token) {
      router.push('/admin/login');
      return;
    }

    const response = await adminFetch('/api/v1/admin/content');
    if (response.status === 401 || response.status === 403) {
      await clearAdminSession();
      router.push('/admin/login');
      return;
    }

    if (!response.ok) {
      setError('Unable to load content.');
      setLoading(false);
      return;
    }

    const json = await response.json();
    setContents((json.contents ?? []) as ContentWithRelations[]);
    setLoading(false);
  }, [router]);

  useEffect(() => {
    void loadContent();
  }, [loadContent]);

  const filtered = useMemo(() => {
    return contents.filter((content) => {
      if (filter === 'all') return true;
      if (filter === 'archived') return content.is_archived;
      return !content.is_archived;
    });
  }, [contents, filter]);

  const runDelete = async (content: ContentWithRelations) => {
    const ok = window.confirm(`Delete "${content.title}"? This cannot be undone.`);
    if (!ok) return;

    setBusyId(content.id);
    setError(null);
    try {
      const response = await adminFetch(`/api/v1/admin/content/${content.id}`, {
        method: 'DELETE',
      });

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

      await loadContent();
    } finally {
      setBusyId(null);
    }
  };

  return (
    <main className="admin-plans-page">
      <div className="admin-page-header">
        <div>
          <p className="eyebrow">Reusable content</p>
          <h1>Content catalog</h1>
          <p>Manage messages, videos, essays, and cartoons for Home, Discover, and related plans.</p>
        </div>
        <div className="admin-actions">
          <Link href="/admin/plans" className="btn btn-secondary">
            Plans
          </Link>
          <Link href="/admin/content/new" className="btn btn-primary">
            New content
          </Link>
          <button
            type="button"
            onClick={() => { void clearAdminSession().then(() => router.push('/admin/login')); }}
            className="btn btn-secondary"
          >
            Logout
          </button>
        </div>
      </div>

      <div className="admin-catalog-filters" role="tablist" aria-label="Content filter">
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
      {loading ? <p>Loading content...</p> : null}

      {!loading && filtered.length === 0 ? (
        <div className="empty-state-card">
          <h2>No content in this view</h2>
          <p>Create the first reusable content item, then connect it to Home or Discover later.</p>
          <Link href="/admin/content/new" className="btn btn-secondary">
            Create content
          </Link>
        </div>
      ) : null}

      {!loading && filtered.length > 0 ? (
        <div className="plans-table content-table">
          <div className="plans-table-row plans-table-header content-table-row">
            <span>Content</span>
            <span>Type</span>
            <span>Author</span>
            <span>Status</span>
            <span>Plans</span>
            <span>Actions</span>
          </div>
          {filtered.map((content) => (
            <div key={content.id} className="plans-table-row content-table-row">
              <span className="table-title-cell">
                {content.cover_image_url ? (
                  <img src={content.cover_image_url} alt="" className="table-thumb" />
                ) : null}
                <span>
                  <strong>{content.title}</strong>
                  <small>{content.summary || content.slug}</small>
                </span>
              </span>
              <span>{content.content_type}</span>
              <span>{content.author?.display_name ?? 'None'}</span>
              <span>{statusLabel(content)}</span>
              <span>{content.related_plans.length}</span>
              <span className="plans-table-actions">
                <Link href={`/admin/content/${content.id}`} className="btn btn-link">
                  Edit
                </Link>
                <button
                  type="button"
                  className="btn btn-danger"
                  disabled={busyId === content.id}
                  onClick={() => void runDelete(content)}
                >
                  Delete
                </button>
              </span>
            </div>
          ))}
        </div>
      ) : null}
    </main>
  );
}
