'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

import type { AdminTodayMessageInput, TodayMessageBase } from '@/lib/today-messages';
import { adminFetch, clearAdminToken } from '@/lib/admin/client';

const emptyForm: AdminTodayMessageInput = {
  publish_date: '',
  language: 'en',
  verse_reference: '',
  verse_text: '',
  message: '',
  image_url: '',
  image_public_id: '',
  is_published: false,
};

function mapToForm(message: TodayMessageBase): AdminTodayMessageInput {
  return {
    publish_date: message.publish_date,
    language: message.language,
    verse_reference: message.verse_reference,
    verse_text: message.verse_text ?? '',
    message: message.message ?? '',
    image_url: message.image_url ?? '',
    image_public_id: message.image_public_id ?? '',
    is_published: message.is_published,
  };
}

interface AdminTodayMessageEditorProps {
  messageId?: string;
}

export default function AdminTodayMessageEditor({ messageId }: AdminTodayMessageEditorProps) {
  const router = useRouter();
  const [form, setForm] = useState<AdminTodayMessageInput>(emptyForm);
  const [loading, setLoading] = useState(Boolean(messageId));
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    if (!messageId) {
      setForm({
        ...emptyForm,
        publish_date: new Date().toISOString().slice(0, 10),
      });
      setLoading(false);
      return;
    }

    const load = async () => {
      setLoading(true);
      setError(null);
      const response = await adminFetch(`/api/v1/admin/today-messages/${messageId}`);

      if (response.status === 401 || response.status === 403) {
        clearAdminToken();
        router.push('/admin/login');
        return;
      }

      if (!response.ok) {
        setError('Unable to load message.');
        setLoading(false);
        return;
      }

      const json = await response.json();
      setForm(mapToForm(json.message as TodayMessageBase));
      setLoading(false);
    };

    void load();
  }, [messageId, router]);

  const handleUpload = async (file: File) => {
    setUploading(true);
    setError(null);
    try {
      const body = new FormData();
      body.append('file', file);
      const response = await adminFetch('/api/v1/admin/today-messages/upload', {
        method: 'POST',
        body,
      });

      if (response.status === 401 || response.status === 403) {
        clearAdminToken();
        router.push('/admin/login');
        return;
      }

      if (!response.ok) {
        const errBody = await response.json().catch(() => ({}));
        throw new Error(typeof errBody.message === 'string' ? errBody.message : 'Image upload failed.');
      }

      const json = await response.json();
      const asset = json.asset as { secure_url: string; public_id: string };
      setForm((current) => ({
        ...current,
        image_url: asset.secure_url,
        image_public_id: asset.public_id,
      }));
      setSuccess('Image uploaded.');
    } catch (uploadError) {
      setError((uploadError as Error).message);
    } finally {
      setUploading(false);
    }
  };

  const submit = async () => {
    setSaving(true);
    setError(null);
    setSuccess(null);

    try {
      const response = await adminFetch(
        messageId ? `/api/v1/admin/today-messages/${messageId}` : '/api/v1/admin/today-messages',
        {
          method: messageId ? 'PUT' : 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(form),
        },
      );

      if (response.status === 401 || response.status === 403) {
        clearAdminToken();
        router.push('/admin/login');
        return;
      }

      if (!response.ok) {
        const body = await response.json().catch(() => ({}));
        const msg = typeof body.message === 'string' ? body.message : 'Save failed.';
        throw new Error(msg);
      }

      const json = await response.json();
      setSuccess(messageId ? 'Message updated.' : 'Message created.');
      if (!messageId && json.message?.id) {
        router.push(`/admin/today-messages/${json.message.id}`);
      }
    } catch (submitError) {
      setError((submitError as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const remove = async () => {
    if (!messageId) return;
    if (!window.confirm('Delete this message? This cannot be undone.')) return;

    setSaving(true);
    setError(null);
    try {
      const response = await adminFetch(`/api/v1/admin/today-messages/${messageId}`, { method: 'DELETE' });
      if (response.status === 401 || response.status === 403) {
        clearAdminToken();
        router.push('/admin/login');
        return;
      }
      if (!response.ok) {
        const body = await response.json().catch(() => ({}));
        throw new Error(typeof body.message === 'string' ? body.message : 'Delete failed.');
      }
      router.push('/admin/today-messages');
    } catch (deleteError) {
      setError((deleteError as Error).message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <p className="admin-shell">Loading message…</p>;
  }

  return (
    <div className="admin-plan-editor">
      <div className="admin-page-header">
        <div>
          <p className="eyebrow">Home content</p>
          <h1>{messageId ? 'Edit today message' : 'New today message'}</h1>
          <p>Schedule a verse card for the mobile Home tab. Verse reference is required.</p>
        </div>
        <div className="admin-actions">
          <Link href="/admin/today-messages" className="btn btn-secondary">
            Back to list
          </Link>
          <button type="button" onClick={() => { clearAdminToken(); router.push('/admin/login'); }} className="btn btn-secondary">
            Logout
          </button>
        </div>
      </div>

      {error ? <div className="alert alert-error">{error}</div> : null}
      {success ? <div className="alert alert-success">{success}</div> : null}

      <section className="form-card">
        <div className="field-row group-grid">
          <div>
            <label htmlFor="publish_date">Publish date</label>
            <input
              id="publish_date"
              type="date"
              value={form.publish_date}
              onChange={(event) => setForm({ ...form, publish_date: event.target.value })}
            />
          </div>
          <div>
            <label htmlFor="language">Language</label>
            <select
              id="language"
              value={form.language ?? 'en'}
              onChange={(event) => setForm({ ...form, language: event.target.value })}
            >
              <option value="en">English (en)</option>
              <option value="ko">Korean (ko)</option>
            </select>
          </div>
        </div>

        <div className="field-row">
          <label htmlFor="verse_reference">Verse reference</label>
          <input
            id="verse_reference"
            value={form.verse_reference}
            onChange={(event) => setForm({ ...form, verse_reference: event.target.value })}
            placeholder="e.g. John 3:16"
          />
        </div>

        <div className="field-row">
          <label htmlFor="verse_text">Verse text (optional)</label>
          <textarea
            id="verse_text"
            value={form.verse_text ?? ''}
            onChange={(event) => setForm({ ...form, verse_text: event.target.value })}
            rows={3}
            placeholder="Only if licensed to display full verse text"
          />
        </div>

        <div className="field-row">
          <label htmlFor="message">Short message (optional)</label>
          <textarea
            id="message"
            value={form.message ?? ''}
            onChange={(event) => setForm({ ...form, message: event.target.value })}
            rows={3}
            placeholder="Reflection or subtitle for the card"
          />
        </div>

        <div className="field-row">
          <label htmlFor="tm_image_upload">Card image</label>
          <input
            id="tm_image_upload"
            type="file"
            accept="image/*"
            onChange={(event) => {
              const file = event.target.files?.[0];
              if (file) void handleUpload(file);
            }}
          />
          <p className="muted">Uploaded to Cloudinary folder hunny-bible-tracker/today-messages.</p>
          {uploading ? <p>Uploading…</p> : null}
          {form.image_url ? (
            <img src={form.image_url} alt="Message preview" className="cover-preview" />
          ) : null}
        </div>

        <div className="field-row checkbox-row">
          <label htmlFor="tm_published">Published</label>
          <input
            id="tm_published"
            type="checkbox"
            checked={Boolean(form.is_published)}
            onChange={(event) => setForm({ ...form, is_published: event.target.checked })}
          />
        </div>
      </section>

      <div className="actions-row">
        <button type="button" disabled={saving} onClick={() => void submit()} className="btn btn-primary">
          {saving ? 'Saving…' : messageId ? 'Save changes' : 'Create message'}
        </button>
        {messageId ? (
          <button type="button" disabled={saving} onClick={() => void remove()} className="btn btn-danger">
            Delete
          </button>
        ) : null}
        <Link href="/admin/today-messages" className="btn btn-link">
          Cancel
        </Link>
      </div>
    </div>
  );
}
