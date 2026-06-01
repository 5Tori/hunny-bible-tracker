'use client';

import Link from 'next/link';
import { useEffect, useMemo, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';

import { useAdminAuth } from '@/components/admin/hooks/use-admin-auth';
import { useAdminMessages } from '@/components/admin/hooks/use-admin-swr';
import { Alert } from '@/components/admin/ui/Alert';
import { Badge } from '@/components/admin/ui/Badge';
import { Button, ButtonLink } from '@/components/admin/ui/Button';
import { FormField } from '@/components/admin/ui/FormField';
import { FormGrid, FormSection } from '@/components/admin/ui/FormSection';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import { adminFetch } from '@/lib/admin/client';
import { revalidateAdminTodayCatalog } from '@/lib/admin/swr-mutate';
import { messageCategoryLabel } from '@/lib/message-admin';
import { parseMessageMetadata } from '@/lib/message-metadata';
import type { AdminTodayMessageInput, TodayMessageBase } from '@/lib/today-messages';
import type { ContentWithRelations } from '@/lib/content';
import { monthKeyFromDate } from '@/lib/today-schedule-ui';

const emptyForm: AdminTodayMessageInput = {
  content_id: '',
  publish_date: '',
  language: 'en',
  verse_reference: '',
  bible_version: '',
  verse_text: '',
  image_url: '',
  image_public_id: '',
  hint_title: '',
  hint_summary: '',
  is_published: false,
};

interface ContentOption {
  id: string;
  slug: string;
  title: string;
  content_type: string;
  language: string;
  is_published: boolean;
  is_archived: boolean;
  cover_image_url?: string | null;
  summary?: string | null;
  metadata?: Record<string, unknown>;
}

function mapToForm(message: TodayMessageBase): AdminTodayMessageInput {
  return {
    content_id: message.content_id ?? '',
    publish_date: message.publish_date,
    language: message.language,
    verse_reference: '',
    bible_version: '',
    verse_text: '',
    image_url: '',
    image_public_id: '',
    hint_title: '',
    hint_summary: '',
    is_published: message.is_published,
  };
}

export default function TodayMessageEditor({ messageId }: { messageId?: string }) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { handleAdminResponse } = useAdminAuth();
  const [form, setForm] = useState<AdminTodayMessageInput>(emptyForm);
  const [preview, setPreview] = useState<ContentWithRelations | null>(null);
  const [loading, setLoading] = useState(Boolean(messageId));
  const [saving, setSaving] = useState(false);
  const { data: messageCatalogData } = useAdminMessages();
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const presetPublishDate = searchParams.get('publish_date')?.trim() || null;
  const presetLanguage = searchParams.get('language')?.trim() || null;
  const lockPublishDate = !messageId && Boolean(presetPublishDate);
  const lockLanguage = !messageId && Boolean(presetLanguage);

  const scheduleBackHref = useMemo(() => {
    const params = new URLSearchParams();
    const month = form.publish_date ? monthKeyFromDate(form.publish_date) : '';
    if (month) params.set('month', month);
    if (form.publish_date) params.set('date', form.publish_date);
    const query = params.toString();
    return query ? `/admin/today-messages?${query}` : '/admin/today-messages';
  }, [form.publish_date]);

  const contentOptions = useMemo(() => {
    const contents = (messageCatalogData?.messages ?? []) as ContentOption[];
    return contents
      .filter((item) => {
        if (item.is_archived || item.content_type !== 'message' || !item.is_published) return false;
      })
      .sort((a, b) => a.title.localeCompare(b.title));
  }, [messageCatalogData?.messages]);

  const selectedOption = useMemo(
    () => contentOptions.find((item) => item.id === form.content_id) ?? null,
    [contentOptions, form.content_id],
  );

  const previewMetadata = useMemo(
    () => (preview ? parseMessageMetadata(preview.metadata) : null),
    [preview],
  );

  const languageMismatchWarning = useMemo(() => {
    if (!selectedOption || !form.language) return null;
    if (selectedOption.language === form.language) return null;
    return `Linked message language (${selectedOption.language}) differs from slot language (${form.language}).`;
  }, [selectedOption, form.language]);

  useEffect(() => {
    if (messageId) return;

    const publishDate =
      presetPublishDate || new Date().toISOString().slice(0, 10);
    const contentId = searchParams.get('content_id')?.trim() || '';
    const language = presetLanguage || 'en';

    setForm({
      ...emptyForm,
      publish_date: publishDate,
      content_id: contentId,
      language,
    });
    setLoading(false);
  }, [messageId, presetLanguage, presetPublishDate, searchParams]);

  useEffect(() => {
    if (!messageId) return;

    const loadMessage = async () => {
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

    void loadMessage();
  }, [messageId, handleAdminResponse]);

  useEffect(() => {
    const contentId = form.content_id?.trim();
    if (!contentId) {
      setPreview(null);
      return;
    }

    const loadPreview = async () => {
      const response = await adminFetch(`/api/v1/admin/content/${contentId}`);
      const ok = await handleAdminResponse(response);
      if (!ok || !response.ok) {
        setPreview(null);
        return;
      }
      const json = await response.json();
      setPreview(json.content as ContentWithRelations);
    };

    void loadPreview();
  }, [form.content_id, handleAdminResponse]);

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
          body: JSON.stringify({
            content_id: form.content_id,
            publish_date: form.publish_date,
            language: form.language,
          }),
        },
      );
      const ok = await handleAdminResponse(response);
      if (!ok) return;
      if (!response.ok) {
        const body = await response.json().catch(() => ({}));
        throw new Error(typeof body.message === 'string' ? body.message : 'Save failed.');
      }
      const json = await response.json();
      setSuccess(messageId ? 'Today slot updated.' : 'Today slot created.');
      await revalidateAdminTodayCatalog();
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
    if (!window.confirm('Delete this today slot? This cannot be undone.')) return;
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
    await revalidateAdminTodayCatalog();
    router.push(scheduleBackHref);
  };

  if (loading) {
    return <p className="admin-muted">Loading today slot…</p>;
  }

  return (
    <>
      <PageHeader
        label="Home content"
        title={messageId ? 'Edit today slot' : 'New today slot'}
        description="Pick a message card. Verse, image, context, and hint come from the linked message."
        actions={
          <ButtonLink href={scheduleBackHref} variant="secondary">
            Back to schedule
          </ButtonLink>
        }
      />

      {error ? <Alert tone="error">{error}</Alert> : null}
      {success ? <Alert tone="success">{success}</Alert> : null}
      {languageMismatchWarning ? <Alert tone="warning">{languageMismatchWarning}</Alert> : null}

      <div className="admin-editor-layout">
        <div className="admin-editor-main">
          <FormSection title="Message card">
            <FormField
              label="Today message"
              htmlFor="content_id"
              hint="Required. Only Today-eligible message cards appear here."
            >
              <select
                id="content_id"
                value={form.content_id ?? ''}
                onChange={(e) => setForm({ ...form, content_id: e.target.value })}
              >
                <option value="">Select a message card</option>
                {contentOptions.map((item) => (
                  <option key={item.id} value={item.id}>
                    {item.title} · {item.slug}
                    {item.is_published ? '' : ' (draft)'}
                  </option>
                ))}
              </select>
            </FormField>
          </FormSection>

          <FormSection title="Publishing">
            <FormGrid columns={2}>
              <FormField
                label="Publish date"
                htmlFor="publish_date"
                hint={lockPublishDate ? 'Set from calendar selection.' : undefined}
              >
                <input
                  id="publish_date"
                  type="date"
                  value={form.publish_date}
                  readOnly={lockPublishDate}
                  disabled={lockPublishDate}
                  onChange={(e) => setForm({ ...form, publish_date: e.target.value })}
                />
              </FormField>
              <FormField
                label="Language"
                htmlFor="language"
                hint={lockLanguage ? 'Set from schedule filter.' : undefined}
              >
                <select
                  id="language"
                  value={form.language ?? 'en'}
                  disabled={lockLanguage}
                  onChange={(e) => setForm({ ...form, language: e.target.value })}
                >
                  <option value="en">English (en)</option>
                  <option value="ko">Korean (ko)</option>
                </select>
              </FormField>
            </FormGrid>
          </FormSection>
        </div>

        <aside className="admin-editor-aside">
          {preview ? (
            <FormSection title="Preview from message">
              {preview.cover_image_url ? (
                <img src={preview.cover_image_url} alt="" className="admin-cover-preview" />
              ) : null}
              <p className="admin-linked-card-title">
                {preview.primary_verse_reference}
                {preview.bible_version ? ` · ${preview.bible_version}` : ''}
              </p>
              {preview.verse_text ? <p className="admin-muted">{preview.verse_text}</p> : null}
              {previewMetadata?.context ? (
                <p className="admin-muted" style={{ marginTop: 12 }}>
                  {previewMetadata.context}
                </p>
              ) : null}
              {previewMetadata?.hint ? (
                <p className="admin-muted" style={{ marginTop: 8 }}>
                  <em>{previewMetadata.hint}</em>
                </p>
              ) : null}
              {previewMetadata?.primaryCategory ? (
                <p className="admin-muted" style={{ marginTop: 8 }}>
                  {messageCategoryLabel(previewMetadata.primaryCategory)}
                </p>
              ) : null}
              <div className="admin-linked-card-actions">
                {preview.is_published ? (
                  <Badge tone="success">Published</Badge>
                ) : (
                  <Badge tone="neutral">Draft</Badge>
                )}
                <Link href={`/admin/messages/${preview.id}`} className="admin-btn admin-btn-link">
                  Edit message
                </Link>
                {preview.is_published ? (
                  <Link
                    href={`/messages/${preview.slug}`}
                    className="admin-btn admin-btn-link"
                    target="_blank"
                  >
                    View library
                  </Link>
                ) : null}
              </div>
            </FormSection>
          ) : selectedOption ? (
            <FormSection title="Preview from message">
              <p className="admin-muted">Loading message preview…</p>
            </FormSection>
          ) : (
            <FormSection title="Preview from message">
              <p className="admin-muted">Select a message card to preview verse, image, context, and hint.</p>
            </FormSection>
          )}

          <FormSection title="Status">
            {preview ? (
              preview.is_published ? (
                <Badge tone="success">Linked card is published — slot is live on Home</Badge>
              ) : (
                <Badge tone="neutral">Linked card is draft — slot stays hidden until published</Badge>
              )
            ) : selectedOption ? (
              selectedOption.is_published ? (
                <Badge tone="success">Selected card is published</Badge>
              ) : (
                <Badge tone="neutral">Selected card is draft</Badge>
              )
            ) : (
              <p className="admin-muted">Select a message card to see live status.</p>
            )}
          </FormSection>

          <div className="admin-sticky-actions">
            <Button variant="primary" loading={saving} onClick={() => void submit()}>
              {messageId ? 'Save changes' : 'Create today slot'}
            </Button>
            {messageId ? (
              <Button variant="danger" disabled={saving} onClick={() => void remove()}>
                Delete
              </Button>
            ) : null}
            <Link href={scheduleBackHref} className="admin-btn admin-btn-ghost">
              Cancel
            </Link>
          </div>
        </aside>
      </div>
    </>
  );
}
