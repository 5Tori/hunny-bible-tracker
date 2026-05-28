'use client';

import Link from 'next/link';
import { useEffect, useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';

import { useAdminAuth } from '@/components/admin/hooks/use-admin-auth';
import { Alert } from '@/components/admin/ui/Alert';
import { Button, ButtonLink } from '@/components/admin/ui/Button';
import { FormField } from '@/components/admin/ui/FormField';
import { FormGrid, FormSection } from '@/components/admin/ui/FormSection';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import { buildTodayMessageShareImageUrl } from '@/lib/cloudinary-share-url';
import { adminFetch } from '@/lib/admin/client';
import type { AdminTodayMessageInput, TodayMessageBase } from '@/lib/today-messages';

const emptyForm: AdminTodayMessageInput = {
  content_id: '',
  publish_date: '',
  language: 'en',
  verse_reference: '',
  bible_version: '',
  verse_text: '',
  message: '',
  image_url: '',
  image_public_id: '',
  hint_title: '',
  hint_summary: '',
  article_title: '',
  article_body: '',
  primary_related_plan_template_id: '',
  is_published: false,
};

interface PlanOption {
  id: string;
  title: string;
  template_key: string;
}

function mapToForm(message: TodayMessageBase): AdminTodayMessageInput {
  return {
    content_id: message.content_id ?? '',
    publish_date: message.publish_date,
    language: message.language,
    verse_reference: message.verse_reference,
    bible_version: message.bible_version ?? '',
    verse_text: message.verse_text ?? '',
    message: message.message ?? '',
    image_url: message.image_url ?? '',
    image_public_id: message.image_public_id ?? '',
    hint_title: message.hint_title ?? '',
    hint_summary: message.hint_summary ?? '',
    article_title: message.article_title ?? '',
    article_body: message.article_body ?? '',
    primary_related_plan_template_id: message.primary_related_plan_template_id ?? '',
    is_published: message.is_published,
  };
}

export default function TodayMessageEditor({ messageId }: { messageId?: string }) {
  const router = useRouter();
  const { handleAdminResponse } = useAdminAuth();
  const [form, setForm] = useState<AdminTodayMessageInput>(emptyForm);
  const [loading, setLoading] = useState(Boolean(messageId));
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [planOptions, setPlanOptions] = useState<PlanOption[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const sharePreviewUrl = useMemo(() => {
    if (!form.image_public_id || !form.verse_reference.trim()) return null;
    return buildTodayMessageShareImageUrl({
      imagePublicId: form.image_public_id,
      verseReference: form.verse_reference.trim(),
      verseText: form.verse_text?.trim() || form.message?.trim() || null,
      bibleVersion: form.bible_version?.trim() || null,
    });
  }, [form.image_public_id, form.verse_reference, form.verse_text, form.message, form.bible_version]);

  useEffect(() => {
    void fetch('/api/v1/plans?sort=featured')
      .then((r) => (r.ok ? r.json() : null))
      .then((json) => setPlanOptions((json?.plans ?? []) as PlanOption[]));
  }, []);

  useEffect(() => {
    if (!messageId) {
      setForm({ ...emptyForm, publish_date: new Date().toISOString().slice(0, 10) });
      setLoading(false);
      return;
    }

    const load = async () => {
      setLoading(true);
      const response = await adminFetch(`/api/v1/admin/today-messages/${messageId}`);
      const ok = await handleAdminResponse(response);
      if (!ok) return;
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
  }, [messageId, handleAdminResponse]);

  const handleUpload = async (file: File) => {
    setUploading(true);
    setError(null);
    try {
      const body = new FormData();
      body.append('file', file);
      const response = await adminFetch('/api/v1/admin/today-messages/upload', { method: 'POST', body });
      const ok = await handleAdminResponse(response);
      if (!ok) return;
      if (!response.ok) {
        const errBody = await response.json().catch(() => ({}));
        throw new Error(typeof errBody.message === 'string' ? errBody.message : 'Image upload failed.');
      }
      const json = await response.json();
      const asset = json.asset as { secure_url: string; public_id: string };
      setForm((current) => ({ ...current, image_url: asset.secure_url, image_public_id: asset.public_id }));
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
      const ok = await handleAdminResponse(response);
      if (!ok) return;
      if (!response.ok) {
        const body = await response.json().catch(() => ({}));
        throw new Error(typeof body.message === 'string' ? body.message : 'Save failed.');
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
    const response = await adminFetch(`/api/v1/admin/today-messages/${messageId}`, { method: 'DELETE' });
    const ok = await handleAdminResponse(response);
    if (!ok) {
      setSaving(false);
      return;
    }
    if (!response.ok) {
      setError('Delete failed.');
      setSaving(false);
      return;
    }
    router.push('/admin/today-messages');
  };

  if (loading) {
    return <p className="admin-muted">Loading message…</p>;
  }

  return (
    <>
      <PageHeader
        label="Home content"
        title={messageId ? 'Edit today message' : 'New today message'}
        description="Schedule a verse card for the mobile Home tab."
        actions={<ButtonLink href="/admin/today-messages" variant="secondary">Back to list</ButtonLink>}
      />

      {error ? <Alert tone="error">{error}</Alert> : null}
      {success ? <Alert tone="success">{success}</Alert> : null}

      <div className="admin-editor-layout">
        <div className="admin-editor-main">
          <FormSection title="Message">
            <FormGrid columns={2}>
              <FormField label="Publish date" htmlFor="publish_date">
                <input
                  id="publish_date"
                  type="date"
                  value={form.publish_date}
                  onChange={(e) => setForm({ ...form, publish_date: e.target.value })}
                />
              </FormField>
              <FormField label="Language" htmlFor="language">
                <select
                  id="language"
                  value={form.language ?? 'en'}
                  onChange={(e) => setForm({ ...form, language: e.target.value })}
                >
                  <option value="en">English (en)</option>
                  <option value="ko">Korean (ko)</option>
                </select>
              </FormField>
            </FormGrid>
            <FormGrid columns={2}>
              <FormField label="Verse reference" htmlFor="verse_reference">
                <input
                  id="verse_reference"
                  value={form.verse_reference}
                  onChange={(e) => setForm({ ...form, verse_reference: e.target.value })}
                  placeholder="John 3:16"
                />
              </FormField>
              <FormField label="Bible version" htmlFor="bible_version">
                <input
                  id="bible_version"
                  value={form.bible_version ?? ''}
                  onChange={(e) => setForm({ ...form, bible_version: e.target.value })}
                />
              </FormField>
            </FormGrid>
            <FormField label="Verse text" htmlFor="verse_text">
              <textarea
                id="verse_text"
                rows={3}
                value={form.verse_text ?? ''}
                onChange={(e) => setForm({ ...form, verse_text: e.target.value })}
              />
            </FormField>
            <FormField label="Short message" htmlFor="message">
              <textarea
                id="message"
                rows={3}
                value={form.message ?? ''}
                onChange={(e) => setForm({ ...form, message: e.target.value })}
              />
            </FormField>
            <FormGrid columns={2}>
              <FormField label="Hint title" htmlFor="hint_title">
                <input
                  id="hint_title"
                  value={form.hint_title ?? ''}
                  onChange={(e) => setForm({ ...form, hint_title: e.target.value })}
                />
              </FormField>
              <FormField label="Related plan" htmlFor="primary_related_plan_template_id">
                <select
                  id="primary_related_plan_template_id"
                  value={form.primary_related_plan_template_id ?? ''}
                  onChange={(e) =>
                    setForm({ ...form, primary_related_plan_template_id: e.target.value })
                  }
                >
                  <option value="">No related plan</option>
                  {planOptions.map((plan) => (
                    <option key={plan.id} value={plan.id}>
                      {plan.title} ({plan.template_key})
                    </option>
                  ))}
                </select>
              </FormField>
            </FormGrid>
            <FormField label="Hint summary" htmlFor="hint_summary">
              <textarea
                id="hint_summary"
                rows={3}
                value={form.hint_summary ?? ''}
                onChange={(e) => setForm({ ...form, hint_summary: e.target.value })}
              />
            </FormField>
            <FormField label="Article title" htmlFor="article_title">
              <input
                id="article_title"
                value={form.article_title ?? ''}
                onChange={(e) => setForm({ ...form, article_title: e.target.value })}
              />
            </FormField>
            <FormField label="Article body" htmlFor="article_body">
              <textarea
                id="article_body"
                rows={8}
                value={form.article_body ?? ''}
                onChange={(e) => setForm({ ...form, article_body: e.target.value })}
              />
            </FormField>
          </FormSection>
        </div>
        <aside className="admin-editor-aside">
          <FormSection title="Image">
            <div className="admin-upload-box">
              <input
                id="tm_image_upload"
                type="file"
                accept="image/*"
                onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (file) void handleUpload(file);
                }}
              />
              {uploading ? <p className="admin-muted">Uploading…</p> : null}
            </div>
            {form.image_url ? (
              <img src={form.image_url} alt="Card preview" className="admin-cover-preview" />
            ) : null}
            {sharePreviewUrl ? (
              <>
                <p className="admin-muted" style={{ marginTop: 12 }}>
                  Share card preview
                </p>
                <img src={sharePreviewUrl} alt="Share preview" className="admin-share-preview" />
              </>
            ) : null}
            <div className="admin-checkbox-row" style={{ marginTop: 16 }}>
              <input
                id="tm_published"
                type="checkbox"
                checked={Boolean(form.is_published)}
                onChange={(e) => setForm({ ...form, is_published: e.target.checked })}
              />
              <label htmlFor="tm_published">Published</label>
            </div>
          </FormSection>
          <div className="admin-sticky-actions">
            <Button variant="primary" loading={saving} onClick={() => void submit()}>
              {messageId ? 'Save changes' : 'Create message'}
            </Button>
            {messageId ? (
              <Button variant="danger" disabled={saving} onClick={() => void remove()}>
                Delete
              </Button>
            ) : null}
            <Link href="/admin/today-messages" className="admin-btn admin-btn-ghost">
              Cancel
            </Link>
          </div>
        </aside>
      </div>
    </>
  );
}
