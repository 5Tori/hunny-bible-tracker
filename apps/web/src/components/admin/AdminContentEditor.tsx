'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

import type {
  AdminContentInput,
  ContentAuthor,
  ContentWithRelations,
} from '@/lib/content';
import { adminFetch, clearAdminSession } from '@/lib/admin/client';

interface AdminContentEditorProps {
  contentId?: string;
}

interface PlanOption {
  id: string;
  title: string;
  template_key: string;
  total_chapters: number | null;
  estimated_minutes: number | null;
}

type ContentAssetInput = NonNullable<AdminContentInput['assets']>[number];
type ContentTagInput = NonNullable<AdminContentInput['tags']>[number];

const emptyContent: AdminContentInput = {
  slug: '',
  content_type: 'message',
  language: 'en',
  title: '',
  subtitle: '',
  summary: '',
  body: '',
  cover_image_url: '',
  cover_image_public_id: '',
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
  tags: [],
  related_plan_ids: [],
};

function parseNumber(value: string) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function toDateTimeLocal(value: string | null | undefined) {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';
  return date.toISOString().slice(0, 16);
}

function fromDateTimeLocal(value: string) {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';
  return date.toISOString();
}

function formatJson(value: unknown) {
  if (!value || typeof value !== 'object') return '';
  return JSON.stringify(value, null, 2);
}

function mapContentToForm(content: ContentWithRelations): AdminContentInput {
  return {
    slug: content.slug,
    content_type: content.content_type,
    language: content.language,
    title: content.title,
    subtitle: content.subtitle ?? '',
    summary: content.summary ?? '',
    body: content.body ?? '',
    cover_image_url: content.cover_image_url ?? '',
    cover_image_public_id: content.cover_image_public_id ?? '',
    author_id: content.author_id ?? '',
    author_display_name: content.author?.display_name ?? '',
    primary_verse_reference: content.primary_verse_reference ?? '',
    bible_version: content.bible_version ?? '',
    verse_text: content.verse_text ?? '',
    duration_seconds: content.duration_seconds,
    external_url: content.external_url ?? '',
    is_published: content.is_published,
    is_archived: content.is_archived,
    published_at: toDateTimeLocal(content.published_at),
    featured_rank: content.featured_rank,
    browse_visible: content.browse_visible !== false,
    metadata: content.metadata,
    assets: content.assets.map((asset) => ({
      asset_type: asset.asset_type,
      asset_role: asset.asset_role,
      order_index: asset.order_index,
      title: asset.title ?? '',
      caption: asset.caption ?? '',
      alt_text: asset.alt_text ?? '',
      url: asset.url,
      public_id: asset.public_id ?? '',
      provider: asset.provider ?? '',
      mime_type: asset.mime_type ?? '',
      width: asset.width,
      height: asset.height,
      duration_seconds: asset.duration_seconds,
      metadata: asset.metadata,
    })),
    tags: content.tags.map((tag) => ({
      type: tag.type,
      key: tag.key,
      name: tag.name,
      description: tag.description ?? '',
      sort_order: tag.sort_order,
    })),
    related_plan_ids: content.related_plans.map((plan) => plan.id),
  };
}

function preparePayload(content: AdminContentInput, metadataText: string): AdminContentInput {
  return {
    ...content,
    published_at:
      typeof content.published_at === 'string'
        ? fromDateTimeLocal(content.published_at)
        : content.published_at,
    metadata: metadataText.trim() ? metadataText : {},
    assets: (content.assets ?? []).filter((asset) => asset.url.trim()),
    tags: (content.tags ?? []).filter((tag) => tag.name.trim()),
  };
}

export default function AdminContentEditor({ contentId }: AdminContentEditorProps) {
  const router = useRouter();
  const [content, setContent] = useState<AdminContentInput>(emptyContent);
  const [metadataText, setMetadataText] = useState('');
  const [authors, setAuthors] = useState<ContentAuthor[]>([]);
  const [planOptions, setPlanOptions] = useState<PlanOption[]>([]);
  const [loading, setLoading] = useState(Boolean(contentId));
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
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
        setError('Unable to load content.');
        setLoading(false);
        return;
      }

      const json = await response.json();
      const form = mapContentToForm(json.content as ContentWithRelations);
      setContent(form);
      setMetadataText(formatJson(form.metadata));
      setLoading(false);
    };

    void loadContent();
  }, [contentId, router]);

  const setAsset = (index: number, update: Partial<ContentAssetInput>) => {
    setContent((current) => ({
      ...current,
      assets: (current.assets ?? []).map((asset, assetIndex) =>
        assetIndex === index ? { ...asset, ...update } : asset,
      ),
    }));
  };

  const addAsset = (asset?: Partial<ContentAssetInput>) => {
    setContent((current) => ({
      ...current,
      assets: [
        ...(current.assets ?? []),
        {
          asset_type: asset?.asset_type ?? 'image',
          asset_role: asset?.asset_role ?? 'body',
          order_index: current.assets?.length ?? 0,
          title: asset?.title ?? '',
          caption: asset?.caption ?? '',
          alt_text: asset?.alt_text ?? '',
          url: asset?.url ?? '',
          public_id: asset?.public_id ?? '',
          provider: asset?.provider ?? '',
          mime_type: asset?.mime_type ?? '',
          width: asset?.width ?? null,
          height: asset?.height ?? null,
          duration_seconds: asset?.duration_seconds ?? null,
          metadata: asset?.metadata ?? {},
        },
      ],
    }));
  };

  const removeAsset = (index: number) => {
    setContent((current) => ({
      ...current,
      assets: (current.assets ?? []).filter((_, assetIndex) => assetIndex !== index),
    }));
  };

  const setTag = (index: number, update: Partial<ContentTagInput>) => {
    setContent((current) => ({
      ...current,
      tags: (current.tags ?? []).map((tag, tagIndex) =>
        tagIndex === index ? { ...tag, ...update } : tag,
      ),
    }));
  };

  const addTag = () => {
    setContent((current) => ({
      ...current,
      tags: [
        ...(current.tags ?? []),
        {
          type: 'topic',
          key: '',
          name: '',
          description: '',
          sort_order: current.tags?.length ?? 0,
        },
      ],
    }));
  };

  const removeTag = (index: number) => {
    setContent((current) => ({
      ...current,
      tags: (current.tags ?? []).filter((_, tagIndex) => tagIndex !== index),
    }));
  };

  const handleUpload = async (file: File, role: 'cover' | 'asset') => {
    setUploading(true);
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

      const asset = body.asset as {
        secure_url: string;
        public_id: string;
        width: number | null;
        height: number | null;
        resource_type: string;
        format: string | null;
      };

      if (role === 'cover') {
        setContent((current) => ({
          ...current,
          cover_image_url: asset.secure_url,
          cover_image_public_id: asset.public_id,
        }));
      } else {
        addAsset({
          asset_type: asset.resource_type || 'image',
          asset_role: 'body',
          url: asset.secure_url,
          public_id: asset.public_id,
          provider: 'cloudinary',
          mime_type: asset.format ? `image/${asset.format}` : '',
          width: asset.width,
          height: asset.height,
        });
      }
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
        contentId ? `/api/v1/admin/content/${contentId}` : '/api/v1/admin/content',
        {
          method: contentId ? 'PUT' : 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(preparePayload(content, metadataText)),
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

      setSuccess(contentId ? 'Content updated.' : 'Content created.');
      if (!contentId) {
        router.push(`/admin/content/${body.content.id}`);
      }
    } catch (submitError) {
      setError((submitError as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const toggleRelatedPlan = (planId: string, checked: boolean) => {
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

  if (loading) {
    return <p>Loading content...</p>;
  }

  return (
    <div className="admin-plan-editor">
      <div className="admin-page-header">
        <div>
          <p className="eyebrow">Content</p>
          <h1>{contentId ? 'Edit content' : 'Create content'}</h1>
          <p>Manage reusable content for Home featured content, Discover, and related plan entry points.</p>
        </div>
        <button
          type="button"
          onClick={() => { void clearAdminSession().then(() => router.push('/admin/login')); }}
          className="btn btn-secondary"
        >
          Logout
        </button>
      </div>

      {error ? <div className="alert alert-error">{error}</div> : null}
      {success ? <div className="alert alert-success">{success}</div> : null}

      <section className="form-card">
        <div className="field-row group-grid">
          <div>
            <label htmlFor="content_type">Content type</label>
            <select
              id="content_type"
              value={content.content_type}
              onChange={(event) => setContent({ ...content, content_type: event.target.value })}
            >
              <option value="message">Message</option>
              <option value="video">Video</option>
              <option value="essay">Essay</option>
              <option value="webtoon">Webtoon</option>
            </select>
          </div>
          <div>
            <label htmlFor="language">Language</label>
            <input
              id="language"
              value={content.language ?? 'en'}
              onChange={(event) => setContent({ ...content, language: event.target.value })}
            />
          </div>
          <div>
            <label htmlFor="slug">Slug</label>
            <input
              id="slug"
              value={content.slug ?? ''}
              onChange={(event) => setContent({ ...content, slug: event.target.value })}
              placeholder="auto-generated from title if blank"
            />
          </div>
        </div>

        <div className="field-row">
          <label htmlFor="title">Title</label>
          <input
            id="title"
            value={content.title}
            onChange={(event) => setContent({ ...content, title: event.target.value })}
            placeholder="Content title"
          />
        </div>

        <div className="field-row">
          <label htmlFor="subtitle">Subtitle</label>
          <input
            id="subtitle"
            value={content.subtitle ?? ''}
            onChange={(event) => setContent({ ...content, subtitle: event.target.value })}
            placeholder="Optional subtitle"
          />
        </div>

        <div className="field-row">
          <label htmlFor="summary">Summary</label>
          <textarea
            id="summary"
            value={content.summary ?? ''}
            onChange={(event) => setContent({ ...content, summary: event.target.value })}
            rows={3}
          />
        </div>

        <div className="field-row">
          <label htmlFor="body">Body / explanatory text</label>
          <textarea
            id="body"
            value={content.body ?? ''}
            onChange={(event) => setContent({ ...content, body: event.target.value })}
            rows={7}
          />
        </div>
      </section>

      <section className="form-card">
        <h2>Author and references</h2>
        <div className="field-row group-grid">
          <div>
            <label htmlFor="author_id">Existing author</label>
            <select
              id="author_id"
              value={content.author_id ?? ''}
              onChange={(event) => setContent({ ...content, author_id: event.target.value })}
            >
              <option value="">No author / use typed name</option>
              {authors.map((author) => (
                <option key={author.id} value={author.id}>
                  {author.display_name}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label htmlFor="author_display_name">New author display name</label>
            <input
              id="author_display_name"
              value={content.author_display_name ?? ''}
              onChange={(event) => setContent({ ...content, author_display_name: event.target.value })}
              placeholder="Creates or reuses author by slug"
            />
          </div>
          <div>
            <label htmlFor="duration_seconds">Duration seconds</label>
            <input
              id="duration_seconds"
              type="number"
              min={0}
              value={content.duration_seconds ?? ''}
              onChange={(event) => setContent({ ...content, duration_seconds: parseNumber(event.target.value) })}
            />
          </div>
        </div>

        <div className="field-row group-grid">
          <div>
            <label htmlFor="primary_verse_reference">Primary verse reference</label>
            <input
              id="primary_verse_reference"
              value={content.primary_verse_reference ?? ''}
              onChange={(event) => setContent({ ...content, primary_verse_reference: event.target.value })}
            />
          </div>
          <div>
            <label htmlFor="bible_version">Bible version</label>
            <input
              id="bible_version"
              value={content.bible_version ?? ''}
              onChange={(event) => setContent({ ...content, bible_version: event.target.value })}
              placeholder="NIV, ESV, KJV..."
            />
          </div>
          <div>
            <label htmlFor="external_url">External URL</label>
            <input
              id="external_url"
              value={content.external_url ?? ''}
              onChange={(event) => setContent({ ...content, external_url: event.target.value })}
              placeholder="Video, article, or source URL"
            />
          </div>
        </div>

        <div className="field-row">
          <label htmlFor="verse_text">Verse text</label>
          <textarea
            id="verse_text"
            value={content.verse_text ?? ''}
            onChange={(event) => setContent({ ...content, verse_text: event.target.value })}
            rows={3}
          />
        </div>
      </section>

      <section className="form-card">
        <h2>Cover and assets</h2>
        <div className="field-row">
          <label htmlFor="cover_image_url">Cover image URL</label>
          <input
            id="cover_image_url"
            value={content.cover_image_url ?? ''}
            onChange={(event) => setContent({ ...content, cover_image_url: event.target.value })}
          />
          {content.cover_image_url ? (
            <img src={content.cover_image_url} alt="Content cover preview" className="cover-preview" />
          ) : null}
        </div>

        <div className="field-row">
          <label htmlFor="cover_upload">Upload cover image</label>
          <input
            id="cover_upload"
            type="file"
            accept="image/*"
            onChange={(event) => {
              const file = event.target.files?.[0];
              if (file) void handleUpload(file, 'cover');
            }}
          />
          <p className="muted">Uploaded to Cloudinary folder hunny-bible-tracker/content.</p>
          {uploading ? <p>Uploading...</p> : null}
        </div>

        {(content.assets ?? []).map((asset, index) => (
          <div key={`${asset.url}-${index}`} className="item-card content-asset-card">
            <div className="section-header">
              <h3>Asset {index + 1}</h3>
              <button type="button" className="btn btn-link" onClick={() => removeAsset(index)}>
                Remove asset
              </button>
            </div>
            <div className="field-row group-grid">
              <div>
                <label>Type</label>
                <input value={asset.asset_type ?? ''} onChange={(event) => setAsset(index, { asset_type: event.target.value })} />
              </div>
              <div>
                <label>Role</label>
                <input value={asset.asset_role ?? ''} onChange={(event) => setAsset(index, { asset_role: event.target.value })} />
              </div>
              <div>
                <label>Order</label>
                <input
                  type="number"
                  value={asset.order_index ?? ''}
                  onChange={(event) => setAsset(index, { order_index: parseNumber(event.target.value) })}
                />
              </div>
            </div>
            <div className="field-row">
              <label>URL</label>
              <input value={asset.url} onChange={(event) => setAsset(index, { url: event.target.value })} />
            </div>
            <div className="field-row group-grid">
              <div>
                <label>Title</label>
                <input value={asset.title ?? ''} onChange={(event) => setAsset(index, { title: event.target.value })} />
              </div>
              <div>
                <label>Caption</label>
                <input value={asset.caption ?? ''} onChange={(event) => setAsset(index, { caption: event.target.value })} />
              </div>
              <div>
                <label>Alt text</label>
                <input value={asset.alt_text ?? ''} onChange={(event) => setAsset(index, { alt_text: event.target.value })} />
              </div>
            </div>
          </div>
        ))}

        <div className="actions-row">
          <button type="button" className="btn btn-secondary" onClick={() => addAsset()}>
            Add asset
          </button>
          <label className="btn btn-secondary" htmlFor="asset_upload">
            Upload asset
          </label>
          <input
            id="asset_upload"
            className="visually-hidden"
            type="file"
            accept="image/*"
            onChange={(event) => {
              const file = event.target.files?.[0];
              if (file) void handleUpload(file, 'asset');
            }}
          />
        </div>
      </section>

      <section className="form-card">
        <h2>Tags</h2>
        {(content.tags ?? []).map((tag, index) => (
          <div key={`${tag.type}-${tag.name}-${index}`} className="content-tag-row">
            <input
              aria-label="Tag category"
              value={tag.type ?? ''}
              onChange={(event) => setTag(index, { type: event.target.value })}
              placeholder="topic"
            />
            <input
              aria-label="Tag name"
              value={tag.name}
              onChange={(event) => setTag(index, { name: event.target.value })}
              placeholder="Peace"
            />
            <input
              aria-label="Tag key"
              value={tag.key ?? ''}
              onChange={(event) => setTag(index, { key: event.target.value })}
              placeholder="auto key"
            />
            <button type="button" className="btn btn-link" onClick={() => removeTag(index)}>
              Remove
            </button>
          </div>
        ))}
        <button type="button" className="btn btn-secondary" onClick={addTag}>
          Add tag
        </button>
      </section>

      <section className="form-card">
        <h2>Related plans</h2>
        <div className="content-plan-options">
          {planOptions.map((plan) => {
            const selected = (content.related_plan_ids ?? []).includes(plan.id);
            return (
              <label key={plan.id} className="content-plan-option">
                <input
                  type="checkbox"
                  checked={selected}
                  onChange={(event) => toggleRelatedPlan(plan.id, event.target.checked)}
                />
                <span>
                  <strong>{plan.title}</strong>
                  <small>{plan.template_key}</small>
                </span>
              </label>
            );
          })}
        </div>
      </section>

      <section className="form-card">
        <h2>Publishing</h2>
        <div className="field-row group-grid">
          <div className="checkbox-row">
            <label htmlFor="browse_visible">Browse visible</label>
            <input
              id="browse_visible"
              type="checkbox"
              checked={content.browse_visible !== false}
              onChange={(event) => setContent({ ...content, browse_visible: event.target.checked })}
            />
          </div>
          <div>
            <label htmlFor="featured_rank">Featured rank</label>
            <input
              id="featured_rank"
              type="number"
              min={0}
              value={content.featured_rank ?? ''}
              onChange={(event) => setContent({ ...content, featured_rank: parseNumber(event.target.value) })}
            />
          </div>
          <div>
            <label htmlFor="published_at">Published at</label>
            <input
              id="published_at"
              type="datetime-local"
              value={(content.published_at as string | null) ?? ''}
              onChange={(event) => setContent({ ...content, published_at: event.target.value })}
            />
          </div>
        </div>

        <div className="field-row group-grid">
          <div className="checkbox-row">
            <label htmlFor="is_published">Published</label>
            <input
              id="is_published"
              type="checkbox"
              disabled={Boolean(content.is_archived)}
              checked={Boolean(content.is_published)}
              onChange={(event) => setContent({ ...content, is_published: event.target.checked })}
            />
          </div>
          <div className="checkbox-row">
            <label htmlFor="is_archived">Archived</label>
            <input
              id="is_archived"
              type="checkbox"
              checked={Boolean(content.is_archived)}
              onChange={(event) =>
                setContent({
                  ...content,
                  is_archived: event.target.checked,
                  is_published: event.target.checked ? false : content.is_published,
                })
              }
            />
          </div>
        </div>

        <div className="field-row">
          <label htmlFor="metadata">Metadata JSON</label>
          <textarea
            id="metadata"
            value={metadataText}
            onChange={(event) => setMetadataText(event.target.value)}
            rows={5}
            placeholder='{"series":"Advent"}'
          />
        </div>
      </section>

      <div className="actions-row">
        <button type="button" disabled={saving} onClick={submit} className="btn btn-primary">
          {saving ? 'Saving...' : contentId ? 'Save changes' : 'Create content'}
        </button>
        <button type="button" onClick={() => router.push('/admin/content')} className="btn btn-link">
          Cancel
        </button>
      </div>
    </div>
  );
}
