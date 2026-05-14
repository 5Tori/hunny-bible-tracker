'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

import { clearAdminToken, getAdminToken, adminFetch } from '@/lib/admin/client';
import type { TodayMessageBase } from '@/lib/today-messages';

export default function AdminTodayMessagesPage() {
  const router = useRouter();
  const [messages, setMessages] = useState<TodayMessageBase[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadMessages = async () => {
      setLoading(true);
      setError(null);

      try {
        const token = getAdminToken();
        if (!token) {
          router.push('/admin/login');
          return;
        }

        const response = await adminFetch('/api/v1/admin/today-messages');

        if (response.status === 401 || response.status === 403) {
          clearAdminToken();
          router.push('/admin/login');
          return;
        }

        if (!response.ok) {
          const hint =
            response.status === 404
              ? ' (404 — API route missing on this deployment, or wrong app URL.)'
              : ` (HTTP ${response.status})`;
          setError(`Unable to load today messages.${hint}`);
          return;
        }

        const json = (await response.json()) as { messages?: TodayMessageBase[] };
        setMessages(json.messages ?? []);
      } catch {
        setError('Unable to load today messages. Check the network tab for the failing request.');
      } finally {
        setLoading(false);
      }
    };

    void loadMessages();
  }, [router]);

  return (
    <main className="admin-plans-page">
      <div className="admin-page-header">
        <div>
          <p className="eyebrow">Home content</p>
          <h1>Today&apos;s messages</h1>
          <p>Manage scheduled daily verse/message cards for the mobile Home tab.</p>
        </div>
        <div className="admin-actions">
          <Link href="/admin/plans" className="btn btn-secondary">
            Plans
          </Link>
          <Link href="/admin/today-messages/new" className="btn btn-primary">
            New message
          </Link>
          <button type="button" onClick={() => { clearAdminToken(); router.push('/admin/login'); }} className="btn btn-secondary">
            Logout
          </button>
        </div>
      </div>

      {error ? <div className="alert alert-error">{error}</div> : null}
      {loading ? <p>Loading messages…</p> : null}

      {!loading && messages.length === 0 ? (
        <div className="empty-state-card">
          <h2>No messages yet</h2>
          <p>Create the first daily message. You can keep it as a draft until the mobile Home API is connected.</p>
          <Link href="/admin/today-messages/new" className="btn btn-secondary">
            Create message
          </Link>
        </div>
      ) : null}

      {!loading && messages.length > 0 ? (
        <div className="plans-table today-table">
          <div className="plans-table-row plans-table-header today-table-row">
            <span>Message</span>
            <span>Date</span>
            <span>Language</span>
            <span>Status</span>
            <span>Edit</span>
          </div>
          {messages.map((message) => (
            <div key={message.id} className="plans-table-row today-table-row">
              <span className="table-title-cell">
                {message.image_url ? <img src={message.image_url} alt="" className="table-thumb" /> : null}
                <span>
                  <strong>{message.verse_reference}</strong>
                  <small>{message.message || message.verse_text || 'No message text yet'}</small>
                </span>
              </span>
              <span>{message.publish_date}</span>
              <span>{message.language}</span>
              <span>{message.is_published ? 'Published' : 'Draft'}</span>
              <span>
                <Link href={`/admin/today-messages/${message.id}`} className="btn btn-link">
                  Edit
                </Link>
              </span>
            </div>
          ))}
        </div>
      ) : null}
    </main>
  );
}
