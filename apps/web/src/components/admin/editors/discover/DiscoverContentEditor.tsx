'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

import type { AdminContentInput, ContentAuthor, ContentWithRelations } from '@/lib/content';
import { adminFetch, clearAdminSession } from '@/lib/admin/client';
import { revalidateAdminDiscover } from '@/lib/admin/swr-mutate';
import { Alert } from '@/components/admin/ui/Alert';
import { Button, ButtonLink } from '@/components/admin/ui/Button';
import { PageHeader } from '@/components/admin/ui/PageHeader';
import type { DiscoverContentType } from '@/lib/discover-content';
import { isDiscoverContentType } from '@/lib/discover-content';

import { DiscoverContentBlocksSection } from './DiscoverContentBlocksSection';
import {
  createEmptyGallerySlide,
  DiscoverGallerySection,
} from './DiscoverGallerySection';
import { DiscoverCategoryPicker } from './DiscoverCategoryPicker';
import { DiscoverPostBasicsSection } from './DiscoverPostBasicsSection';
import { DiscoverVideoSection } from './DiscoverVideoSection';
import {
  applyDiscoverBlockTypeChange,
  createDiscoverBlock,
  type DiscoverBlockType,
} from '@/lib/discover-blocks';
import {
  emptyDiscoverContent,
  formatMetadataJson,
  mapDiscoverContentToForm,
  prepareDiscoverPayload,
} from './discover-editor-utils';

interface DiscoverContentEditorProps {
  contentId?: string;
}

interface PlanOption {
  id: string;
  title: string;
  template_key: string;
}

type ContentTagInput = NonNullable<AdminContentInput['tags']>[number];
type ContentSectionInput = NonNullable<AdminContentInput['sections']>[number];
type ContentAssetInput = NonNullable<AdminContentInput['assets']>[number];

export default function DiscoverContentEditor({ contentId }: DiscoverContentEditorProps) {
  const router = useRouter();
  const [content, setContent] = useState<AdminContentInput>(emptyDiscoverContent);
  const [metadataText, setMetadataText] = useState('');
  const [authors, setAuthors] = useState<ContentAuthor[]>([]);
  const [planOptions, setPlanOptions] = useState<PlanOption[]>([]);
  const [loading, setLoading] = useState(Boolean(contentId));
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const category = content.content_type ?? 'essay';
  const isVideo = category === 'video';
  const isCartoon = category === 'cartoon';

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
      const loaded = json.content as ContentWithRelations;
      if (!isDiscoverContentType(loaded.content_type)) {
        router.replace(`/admin/messages/${loaded.id}`);
        return;
      }

      const form = mapDiscoverContentToForm(loaded);
      setContent({
        ...form,
        sections: form.sections?.length ? form.sections : [],
        assets: form.assets?.length ? form.assets : [],
      });
      setMetadataText(formatMetadataJson(form.metadata));
      setLoading(false);
    };

    void loadContent();
  }, [contentId, router]);

  const setSection = (index: number, update: Partial<ContentSectionInput>) => {
    setContent((current) => ({
      ...current,
      sections: (current.sections ?? []).map((section, sectionIndex) =>
        sectionIndex === index ? { ...section, ...update } : section,
      ),
    }));
  };

  const addSection = (blockType: DiscoverBlockType) => {
    setContent((current) => ({
      ...current,
      sections: [
        ...(current.sections ?? []),
        createDiscoverBlock(blockType, current.sections?.length ?? 0),
      ],
    }));
  };

  const setSectionBlockType = (index: number, blockType: DiscoverBlockType) => {
    setContent((current) => ({
      ...current,
      sections: (current.sections ?? []).map((section, sectionIndex) =>
        sectionIndex === index ? applyDiscoverBlockTypeChange(section, blockType) : section,
      ),
    }));
  };

  const clearSectionImage = (index: number) => {
    setSection(index, {
      image_url: '',
      image_public_id: '',
      image_alt_text: '',
      image_caption: '',
    });
  };

  const removeSection = (index: number) => {
    setContent((current) => ({
      ...current,
      sections: (current.sections ?? []).filter((_, sectionIndex) => sectionIndex !== index),
    }));
  };

  const setAsset = (index: number, update: Partial<ContentAssetInput>) => {
    setContent((current) => ({
      ...current,
      assets: (current.assets ?? []).map((asset, assetIndex) =>
        assetIndex === index ? { ...asset, ...update } : asset,
      ),
    }));
  };

  const moveAsset = (index: number, direction: -1 | 1) => {
    setContent((current) => {
      const assets = [...(current.assets ?? [])];
      const target = index + direction;
      if (target < 0 || target >= assets.length) return current;
      [assets[index], assets[target]] = [assets[target], assets[index]];
      return {
        ...current,
        assets: assets.map((asset, assetIndex) => ({ ...asset, order_index: assetIndex })),
      };
    });
  };

  const removeAsset = (index: number) => {
    setContent((current) => ({
      ...current,
      assets: (current.assets ?? [])
        .filter((_, assetIndex) => assetIndex !== index)
        .map((asset, assetIndex) => ({ ...asset, order_index: assetIndex })),
    }));
  };

  const appendGallerySlide = (asset: Partial<ContentAssetInput>) => {
    setContent((current) => ({
      ...current,
      assets: [
        ...(current.assets ?? []),
        {
          ...createEmptyGallerySlide(current.assets?.length ?? 0),
          ...asset,
        },
      ],
    }));
  };

  const handleUpload = async (
    file: File,
    role: { type: 'cover' } | { type: 'slide' } | { type: 'section'; index: number },
  ) => {
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

      const uploaded = body.asset as {
        secure_url: string;
        public_id: string;
        width: number | null;
        height: number | null;
        resource_type: string;
        format: string | null;
      };

      if (role.type === 'cover') {
        setContent((current) => ({
          ...current,
          cover_image_url: uploaded.secure_url,
          cover_image_public_id: uploaded.public_id,
        }));
      } else if (role.type === 'section') {
        setSection(role.index, {
          image_url: uploaded.secure_url,
          image_public_id: uploaded.public_id,
        });
      } else {
        appendGallerySlide({
          asset_type: uploaded.resource_type || 'image',
          url: uploaded.secure_url,
          public_id: uploaded.public_id,
          provider: 'cloudinary',
          mime_type: uploaded.format ? `image/${uploaded.format}` : '',
          width: uploaded.width,
          height: uploaded.height,
        });
      }
      setSuccess('Image uploaded.');
    } catch (uploadError) {
      setError((uploadError as Error).message);
    } finally {
      setUploading(false);
    }
  };

  const handleGalleryFiles = async (files: FileList) => {
    for (const file of Array.from(files)) {
      await handleUpload(file, { type: 'slide' });
    }
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
        { type: 'topic', key: '', name: '', description: '', sort_order: current.tags?.length ?? 0 },
      ],
    }));
  };

  const removeTag = (index: number) => {
    setContent((current) => ({
      ...current,
      tags: (current.tags ?? []).filter((_, tagIndex) => tagIndex !== index),
    }));
  };

  const toggleRelatedPlan = (planId: string, checked: boolean) => {
    setContent((current) => {
      const ids = current.related_plan_ids ?? [];
      return {
        ...current,
        related_plan_ids: checked ? [...ids, planId] : ids.filter((id) => id !== planId),
      };
    });
  };

  const submit = async () => {
    setSaving(true);
    setError(null);
    setSuccess(null);

    try {
      const payload = prepareDiscoverPayload(content, metadataText);
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

      setSuccess(contentId ? 'Discover post updated.' : 'Discover post created.');
      await revalidateAdminDiscover();
      if (!contentId) {
        router.push(`/admin/discover/${body.content.id}`);
      }
    } catch (submitError) {
      setError((submitError as Error).message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <p className="admin-muted">Loading discover post…</p>;
  }

  return (
    <>
      <PageHeader
        label="Discover blog"
        title={contentId ? 'Edit discover post' : 'New discover post'}
        description="Blog-style posts: pick a category (Video, Article, or Cartoon), then build the story with content blocks and optional slides."
        actions={
          <>
            <ButtonLink href="/admin/messages" variant="ghost">
              Message cards
            </ButtonLink>
            <ButtonLink href="/admin/discover" variant="secondary">
              Back to list
            </ButtonLink>
          </>
        }
      />

      <Alert tone="info">
        Message cards are separate. This editor is for long-form Discover posts only (
        <code>video</code>, <code>essay</code>, <code>cartoon</code>).
      </Alert>

      {error ? <Alert tone="error">{error}</Alert> : null}
      {success ? <Alert tone="success">{success}</Alert> : null}

      <div className="admin-editor-layout">
        <div className="admin-editor-main">
          <DiscoverCategoryPicker
            value={category}
            onChange={(next) => setContent({ ...content, content_type: next })}
          />

          <DiscoverPostBasicsSection
            content={content}
            uploading={uploading}
            onChange={setContent}
            onCoverUpload={(file) => void handleUpload(file, { type: 'cover' })}
            onClearCover={() =>
              setContent({ ...content, cover_image_url: '', cover_image_public_id: '' })
            }
          />

          <DiscoverVideoSection
            content={content}
            emphasized={isVideo}
            onChange={setContent}
          />

          <DiscoverContentBlocksSection
            sections={content.sections ?? []}
            uploading={uploading}
            onSectionChange={setSection}
            onSectionBlockTypeChange={setSectionBlockType}
            onAddSection={addSection}
            onRemoveSection={removeSection}
            onSectionImageUpload={(index, file) => void handleUpload(file, { type: 'section', index })}
            onClearSectionImage={clearSectionImage}
          />

          <DiscoverGallerySection
            assets={content.assets ?? []}
            emphasized={isCartoon}
            uploading={uploading}
            onAssetChange={setAsset}
            onMoveAsset={moveAsset}
            onRemoveAsset={removeAsset}
            onUploadSlides={(files) => void handleGalleryFiles(files)}
          />

          <section className="admin-form-section">
            <h2>Author</h2>
            <div className="admin-field admin-form-grid-2">
              <div>
                <label htmlFor="discover_author_id">Existing author</label>
                <select
                  id="discover_author_id"
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
                <label htmlFor="discover_author_name">New author display name</label>
                <input
                  id="discover_author_name"
                  value={content.author_display_name ?? ''}
                  onChange={(event) =>
                    setContent({ ...content, author_display_name: event.target.value })
                  }
                />
              </div>
            </div>
          </section>

          <section className="admin-form-section">
            <h2>Tags</h2>
            {(content.tags ?? []).map((tag, index) => (
              <div key={`tag-${index}`} className="content-tag-row">
                <input
                  aria-label="Tag type"
                  value={tag.type ?? ''}
                  onChange={(event) => setTag(index, { type: event.target.value })}
                  placeholder="topic"
                />
                <input
                  aria-label="Tag name"
                  value={tag.name}
                  onChange={(event) => setTag(index, { name: event.target.value })}
                />
                <button type="button" className="admin-btn admin-btn-link" onClick={() => removeTag(index)}>
                  Remove
                </button>
              </div>
            ))}
            <button type="button" className="admin-btn admin-btn-secondary" onClick={addTag}>
              Add tag
            </button>
          </section>

          <section className="admin-form-section">
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
        </div>

        <aside className="admin-editor-aside">
          <section className="admin-form-section">
            <h2>Publishing</h2>
            <div className="admin-checkbox-row">
              <label htmlFor="discover_browse_visible">Show on Discover</label>
              <input
                id="discover_browse_visible"
                type="checkbox"
                checked={content.browse_visible !== false}
                onChange={(event) => setContent({ ...content, browse_visible: event.target.checked })}
              />
            </div>
            <div className="admin-field">
              <label htmlFor="discover_featured_rank">Featured rank</label>
              <input
                id="discover_featured_rank"
                type="number"
                min={0}
                value={content.featured_rank ?? ''}
                onChange={(event) =>
                  setContent({
                    ...content,
                    featured_rank: event.target.value ? Number(event.target.value) : null,
                  })
                }
              />
            </div>
            <div className="admin-field">
              <label htmlFor="discover_published_at">Published at</label>
              <input
                id="discover_published_at"
                type="datetime-local"
                value={(content.published_at as string | null) ?? ''}
                onChange={(event) => setContent({ ...content, published_at: event.target.value })}
              />
            </div>
            <div className="admin-checkbox-row">
              <label htmlFor="discover_published">Published</label>
              <input
                id="discover_published"
                type="checkbox"
                disabled={Boolean(content.is_archived)}
                checked={Boolean(content.is_published)}
                onChange={(event) => setContent({ ...content, is_published: event.target.checked })}
              />
            </div>
            <div className="admin-checkbox-row">
              <label htmlFor="discover_archived">Archived</label>
              <input
                id="discover_archived"
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
            <div className="admin-field">
              <label htmlFor="discover_metadata">Metadata JSON</label>
              <textarea
                id="discover_metadata"
                value={metadataText}
                onChange={(event) => setMetadataText(event.target.value)}
                rows={5}
              />
            </div>
          </section>

          <div className="admin-sticky-actions">
            <Button variant="primary" loading={saving} onClick={() => void submit()}>
              {contentId ? 'Save post' : 'Create post'}
            </Button>
            <Button variant="ghost" onClick={() => router.push('/admin/discover')}>
              Cancel
            </Button>
          </div>
        </aside>
      </div>
    </>
  );
}
