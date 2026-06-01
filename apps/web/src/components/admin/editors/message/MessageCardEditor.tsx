'use client';

import Link from 'next/link';
import { useEffect, useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';

import { MessageCardEditorSection } from '@/components/admin/editors/content/MessageCardEditorSection';
import { AdminMessageCardPreview } from '@/components/admin/editors/message/AdminMessageCardPreview';
import {
  MessageCardImagesSection,
  type MessageImageUploadTarget,
} from '@/components/admin/editors/message/MessageCardImagesSection';
import { VerseReferencePicker } from '@/components/admin/VerseReferencePicker';
import { Alert } from '@/components/admin/ui/Alert';
import { Badge } from '@/components/admin/ui/Badge';
import { Button, ButtonLink } from '@/components/admin/ui/Button';
import { FormField } from '@/components/admin/ui/FormField';
import { FormGrid, FormSection } from '@/components/admin/ui/FormSection';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import type { AdminContentInput, ContentAuthor, ContentWithRelations } from '@/lib/content';
import { adminFetch, clearAdminSession } from '@/lib/admin/client';
import { revalidateAdminMessageCatalog } from '@/lib/admin/swr-mutate';
import {
  buildMessageMetadataPayload,
  buildMessageTags,
  defaultMessageEditorState,
  messageEditorStateFromContent,
  type MessageEditorState,
} from '@/lib/message-admin';
import { validateMessageCardInput } from '@/lib/message-content-validation';
import { normalizeVerseReferenceString } from '@/lib/bible-verse-reference';

interface PlanOption {
  id: string;
  title: string;
  template_key: string;
}

const emptyContent: AdminContentInput = {
  slug: '',
  content_type: 'message',
  language: 'en',
  title: '',
  subtitle: '',
  summary: null,
  body: '',
  cover_image_url: '/messages/sample-card.webp',
  cover_image_public_id: 'messages/sample-card',
  author_id: '',
  author_display_name: '',
  primary_verse_reference: '',
  bible_version: '',
  verse_text: '',
  duration_seconds: null,
  external_url: '',
  is_published: false,
  is_archived: false,
  published_at: '',
  featured_rank: null,
  browse_visible: true,
  metadata: {},
  assets: [],
  sections: [],
  tags: [],
  related_plan_ids: [],
};

function mapContentToForm(content: ContentWithRelations): AdminContentInput {
  return {
    slug: content.slug,
    content_type: 'message',
    language: content.language,
    title: content.title,
    subtitle: content.subtitle ?? '',
    summary: null,
    body: '',
    cover_image_url: content.cover_image_url ?? '',
    cover_image_public_id: content.cover_image_public_id ?? '',
    author_id: content.author_id ?? '',
    author_display_name: content.author?.display_name ?? '',
    primary_verse_reference: content.primary_verse_reference ?? '',
    bible_version: content.bible_version ?? '',
    verse_text: content.verse_text ?? '',
    duration_seconds: null,
    external_url: '',
    is_published: content.is_published,
    is_archived: content.is_archived,
    published_at: content.published_at ?? '',
    featured_rank: content.featured_rank,
    browse_visible: content.browse_visible,
    metadata: content.metadata ?? {},
    assets: [],
    sections: [],
    tags: [],
    related_plan_ids: content.related_plans.map((plan) => plan.id),
  };
}

function preparePayload(content: AdminContentInput, messageState: MessageEditorState): AdminContentInput {
  const canonicalReference =
    normalizeVerseReferenceString(content.primary_verse_reference) ??
    content.primary_verse_reference?.trim() ??
    '';
  const verseReference = canonicalReference;
  const title = verseReference || content.title?.trim() || '';
  const existingMetadata =
    typeof content.metadata === 'object' && content.metadata ? content.metadata : {};

  return {
    ...content,
    content_type: 'message',
    title,
    primary_verse_reference: verseReference,
    summary: null,
    body: null,
    metadata: buildMessageMetadataPayload(messageState, existingMetadata),
    tags: buildMessageTags(messageState),
  };
}

export default function MessageCardEditor({ contentId }: { contentId?: string }) {
  const router = useRouter();
  const [content, setContent] = useState<AdminContentInput>(emptyContent);
  const [messageState, setMessageState] = useState<MessageEditorState>(defaultMessageEditorState());
  const [authors, setAuthors] = useState<ContentAuthor[]>([]);
  const [planOptions, setPlanOptions] = useState<PlanOption[]>([]);
  const [loading, setLoading] = useState(Boolean(contentId));
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState<MessageImageUploadTarget | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    const loadOptions = async () => {
      const [plansResponse, authorsResponse] = await Promise.all([
        fetch('/api/v1/plans?sort=featured'),
        adminFetch('/api/v1/admin/content/authors'),
      ]);

      if (plansResponse.ok) {
        const json = await plansResponse.json();
        setPlanOptions((json.plans ?? []) as PlanOption[]);
      }

      if (authorsResponse.status === 401 || authorsResponse.status === 403) {
        await clearAdminSession();
        router.push('/admin/login');
        return;
      }

      if (authorsResponse.ok) {
        const json = await authorsResponse.json();
        setAuthors((json.authors ?? []) as ContentAuthor[]);
      }
    };

    void loadOptions();
  }, [router]);

  useEffect(() => {
    if (!contentId) {
      setLoading(false);
      return;
    }

    const loadContent = async () => {
      setLoading(true);
      setError(null);
      const response = await adminFetch(`/api/v1/admin/content/${contentId}`);

      if (response.status === 401 || response.status === 403) {
        await clearAdminSession();
        router.push('/admin/login');
        return;
      }

      if (!response.ok) {
        setError('Unable to load message card.');
        setLoading(false);
        return;
      }

      const json = await response.json();
      const loaded = json.content as ContentWithRelations;
      setContent(mapContentToForm(loaded));
      setMessageState(messageEditorStateFromContent(loaded));
      setLoading(false);
    };

    void loadContent();
  }, [contentId, router]);

  const selectedPlans = useMemo(
    () => planOptions.filter((plan) => (content.related_plan_ids ?? []).includes(plan.id)),
    [content.related_plan_ids, planOptions],
  );

  const handleUpload = async (file: File, target: MessageImageUploadTarget) => {
    setUploading(target);
    setError(null);

    try {
      const formData = new FormData();
      formData.append('file', file);
      const response = await adminFetch('/api/v1/admin/content/upload', {
        method: 'POST',
        body: formData,
      });

      if (response.status === 401 || response.status === 403) {
        await clearAdminSession();
        router.push('/admin/login');
        return;
      }

      const body = await response.json().catch(() => ({}));
      if (!response.ok) {
        throw new Error(typeof body.message === 'string' ? body.message : 'Upload failed.');
      }

      const asset = body.asset as { secure_url: string; public_id: string };
      if (target === 'base') {
        setContent((current) => ({
          ...current,
          cover_image_url: asset.secure_url,
          cover_image_public_id: asset.public_id,
        }));
        setSuccess('Base background uploaded.');
      } else {
        setMessageState((current) => ({
          ...current,
          compositeImageUrl: asset.secure_url,
          compositeImagePublicId: asset.public_id,
        }));
        setSuccess('Composite image uploaded.');
      }
    } catch (uploadError) {
      setError((uploadError as Error).message);
    } finally {
      setUploading(null);
    }
  };

  const togglePlan = (planId: string, checked: boolean) => {
    setContent((current) => {
      const currentIds = current.related_plan_ids ?? [];
      return {
        ...current,
        related_plan_ids: checked
          ? [...currentIds, planId]
          : currentIds.filter((id) => id !== planId),
      };
    });
  };

  const submit = async () => {
    setSaving(true);
    setError(null);
    setSuccess(null);

    try {
      const payload = preparePayload(content, messageState);
      const validationError = validateMessageCardInput({
        primary_verse_reference: payload.primary_verse_reference,
        bible_version: payload.bible_version,
        verse_text: payload.verse_text,
        cover_image_url: payload.cover_image_url,
        is_published: payload.is_published,
        messageState,
      });
      if (validationError) {
        throw new Error(validationError);
      }

      const response = await adminFetch(
        contentId ? `/api/v1/admin/content/${contentId}` : '/api/v1/admin/content',
        {
          method: contentId ? 'PUT' : 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload),
        },
      );

      if (response.status === 401 || response.status === 403) {
        await clearAdminSession();
        router.push('/admin/login');
        return;
      }

      const body = await response.json().catch(() => ({}));
      if (!response.ok) {
        throw new Error(typeof body.message === 'string' ? body.message : 'Save failed.');
      }

      await revalidateAdminMessageCatalog();
      setSuccess(contentId ? 'Message card updated.' : 'Message card created.');
      const saved = body.content as ContentWithRelations;
      if (!contentId && saved?.id) {
        router.push(`/admin/messages/${saved.id}`);
      }
    } catch (submitError) {
      setError((submitError as Error).message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <p className="admin-muted">Loading message card…</p>;
  }

  return (
    <>
      <PageHeader
        label="Message Card Library"
        title={contentId ? 'Edit message card' : 'New message card'}
        description="Publish requires verse fields, cover image, primary category, tone, and share intent. Public chips use category, situations, and themes only."
        actions={
          <>
            {contentId && content.is_published && !content.is_archived ? (
              <ButtonLink
                href={`/admin/today-messages/new?content_id=${contentId}`}
                variant="secondary"
              >
                Schedule for Today
              </ButtonLink>
            ) : null}
            <ButtonLink href="/admin/messages" variant="secondary">
              Back to list
            </ButtonLink>
          </>
        }
      />

      {error ? <Alert tone="error">{error}</Alert> : null}
      {success ? <Alert tone="success">{success}</Alert> : null}

      <div className="admin-editor-layout">
        <div className="admin-editor-main">
          <MessageCardImagesSection
            content={content}
            messageState={messageState}
            uploading={uploading}
            onUpload={(file, target) => void handleUpload(file, target)}
            onClearBase={() =>
              setContent((current) => ({
                ...current,
                cover_image_url: '',
                cover_image_public_id: '',
              }))
            }
            onClearComposite={() =>
              setMessageState((current) => ({
                ...current,
                compositeImageUrl: '',
                compositeImagePublicId: '',
              }))
            }
          />

          <FormSection title="Verse">
            <FormField label="Verse reference" htmlFor="primary_verse_reference">
              <VerseReferencePicker
                idPrefix="primary_verse_reference"
                value={content.primary_verse_reference ?? ''}
                onChange={(reference) =>
                  setContent({ ...content, primary_verse_reference: reference })
                }
              />
            </FormField>
            <FormField label="Bible version" htmlFor="bible_version">
              <input
                id="bible_version"
                value={content.bible_version ?? ''}
                onChange={(event) => setContent({ ...content, bible_version: event.target.value })}
                placeholder="NIV"
              />
            </FormField>
            <FormField
              label="Verse text"
              htmlFor="verse_text"
              hint="Required to publish. For a verse range, paste every verse in the selection."
            >
              <textarea
                id="verse_text"
                rows={4}
                value={content.verse_text ?? ''}
                onChange={(event) => setContent({ ...content, verse_text: event.target.value })}
              />
            </FormField>
          </FormSection>

          <MessageCardEditorSection
            messageState={messageState}
            onMessageStateChange={setMessageState}
          />

          <FormSection title="Related plans">
            <div className="admin-checkbox-grid">
              {planOptions.map((plan) => {
                const checked = (content.related_plan_ids ?? []).includes(plan.id);
                return (
                  <label key={plan.id} className="admin-checkbox-row">
                    <input
                      type="checkbox"
                      checked={checked}
                      onChange={(event) => togglePlan(plan.id, event.target.checked)}
                    />
                    <span>{plan.title}</span>
                  </label>
                );
              })}
            </div>
          </FormSection>
        </div>

        <aside className="admin-editor-aside admin-editor-aside-preview">
          <AdminMessageCardPreview
            content={content}
            messageState={messageState}
            contentId={contentId}
          />

          <FormSection title="Publishing">
            <FormField label="Slug" htmlFor="slug">
              <input
                id="slug"
                value={content.slug ?? ''}
                onChange={(event) => setContent({ ...content, slug: event.target.value })}
                placeholder="john-1-1-3"
              />
            </FormField>
            <FormField label="Language" htmlFor="language">
              <select
                id="language"
                value={content.language ?? 'en'}
                onChange={(event) => setContent({ ...content, language: event.target.value })}
              >
                <option value="en">English (en)</option>
                <option value="ko">Korean (ko)</option>
              </select>
            </FormField>
            <FormField label="Author" htmlFor="author_id">
              <select
                id="author_id"
                value={content.author_id ?? ''}
                onChange={(event) => setContent({ ...content, author_id: event.target.value })}
              >
                <option value="">Default author</option>
                {authors.map((author) => (
                  <option key={author.id} value={author.id}>
                    {author.display_name}
                  </option>
                ))}
              </select>
            </FormField>
            <div className="admin-checkbox-row">
              <input
                id="is_published"
                type="checkbox"
                checked={Boolean(content.is_published)}
                onChange={(event) => setContent({ ...content, is_published: event.target.checked })}
              />
              <label htmlFor="is_published">Published</label>
            </div>
            {content.is_published ? (
              <Link
                href={`/messages/${content.slug || 'preview'}`}
                className="admin-btn admin-btn-link"
                target="_blank"
              >
                Preview in library
              </Link>
            ) : null}
          </FormSection>

          {selectedPlans.length > 0 ? (
            <FormSection title="Selected plans">
              {selectedPlans.map((plan) => (
                <p key={plan.id} className="admin-muted">
                  {plan.title}
                </p>
              ))}
            </FormSection>
          ) : null}

          <div className="admin-sticky-actions">
            <Button variant="primary" loading={saving} onClick={() => void submit()}>
              {contentId ? 'Save changes' : 'Create message card'}
            </Button>
            <Button variant="ghost" onClick={() => router.push('/admin/messages')}>
              Cancel
            </Button>
          </div>
        </aside>
      </div>
    </>
  );
}
