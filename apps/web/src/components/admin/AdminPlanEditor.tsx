'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

import type { AdminPlanInput, PlanTemplateWithRelations } from '@/lib/plans';
import { adminFetch, clearAdminSession } from '@/lib/admin/client';
import { BookKeyCombobox } from '@/components/admin/BookKeyCombobox';
import { BookChapterRangeSelects } from '@/components/admin/BookChapterRangeSelects';
import { clampPlanItemChapters } from '@/lib/bible-books';
import {
  DIFFICULTY_OPTIONS,
  PLAN_TYPE_OPTIONS,
  TESTAMENT_SCOPE_OPTIONS,
  normalizeDifficulty,
  normalizePlanType,
  normalizeTestamentScope,
} from '@/lib/plan-taxonomy';

interface AdminPlanEditorProps {
  planId?: string;
}

const emptyPlan: AdminPlanInput = {
  title: '',
  subtitle: '',
  short_description: '',
  description: '',
  cover_image_url: '',
  cover_image_public_id: '',
  plan_type: '',
  testament_scope: 'whole_bible',
  difficulty: '',
  estimated_minutes: null,
  estimated_days: null,
  total_chapters: null,
  primary_book_key: '',
  primary_character: '',
  is_published: false,
  is_archived: false,
  browse_visible: true,
  featured_rank: null,
  sections: [
    {
      section_key: 'section_0',
      title: '',
      description: '',
      order_index: 0,
      items: [
        {
          book_key: '',
          start_chapter: 1,
          end_chapter: 1,
          order_index: 0,
        },
      ],
    },
  ],
  tags: [],
};

function parseNumber(value: string) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function calculatePlanTotalChapters(sections: AdminPlanInput['sections']) {
  return sections.reduce((sum, section) => {
    return (
      sum +
      section.items.reduce((sectionSum, item) => {
        const start = Math.max(1, Math.floor(Number(item.start_chapter) || 1));
        const end = Math.max(start, Math.floor(Number(item.end_chapter) || start));
        return sectionSum + (end - start + 1);
      }, 0)
    );
  }, 0);
}

function normalizeSections(sections: AdminPlanInput['sections']) {
  if (!sections || sections.length === 0) {
    return emptyPlan.sections;
  }
  return sections.map((section, sectionIndex) => ({
    section_key: section.section_key || `section_${sectionIndex}`,
    title: section.title || '',
    description: section.description || '',
    order_index: section.order_index ?? sectionIndex,
    items:
      section.items?.length > 0
        ? section.items.map((item, itemIndex) => {
            const base = {
              book_key: item.book_key || '',
              start_chapter: item.start_chapter ?? 1,
              end_chapter: item.end_chapter ?? 1,
              order_index: item.order_index ?? itemIndex,
            };
            const clamped = clampPlanItemChapters({
              book_key: base.book_key,
              start_chapter: base.start_chapter,
              end_chapter: base.end_chapter,
            });
            return {
              ...base,
              start_chapter: clamped.start_chapter,
              end_chapter: clamped.end_chapter,
            };
          })
        : [
            {
              book_key: '',
              start_chapter: 1,
              end_chapter: 1,
              order_index: 0,
            },
          ],
  }));
}

function mapPlanToForm(plan: PlanTemplateWithRelations): AdminPlanInput {
  return {
    title: plan.title,
    subtitle: plan.subtitle,
    short_description: plan.short_description,
    description: plan.description,
    cover_image_url: plan.cover_image_url,
    cover_image_public_id: plan.cover_image_public_id,
    plan_type: normalizePlanType(plan.plan_type ?? '') || '',
    testament_scope: normalizeTestamentScope(plan.testament_scope ?? '') || '',
    difficulty: normalizeDifficulty(plan.difficulty ?? '') || '',
    estimated_minutes: plan.estimated_minutes,
    estimated_days: plan.estimated_days,
    total_chapters: plan.total_chapters,
    primary_book_key: plan.primary_book_key,
    primary_character: plan.primary_character,
    is_published: plan.is_published,
    is_archived: Boolean(plan.is_archived),
    browse_visible: plan.browse_visible !== false,
    featured_rank: plan.featured_rank ?? null,
    sections: normalizeSections(plan.sections),
    tags: plan.tags.map((tag) => tag.name),
  };
}

export default function AdminPlanEditor({ planId }: AdminPlanEditorProps) {
  const router = useRouter();
  const [plan, setPlan] = useState<AdminPlanInput>(emptyPlan);
  const [tagsString, setTagsString] = useState('');
  const [loading, setLoading] = useState(Boolean(planId));
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const calculatedTotalChapters = calculatePlanTotalChapters(plan.sections);

  useEffect(() => {
    if (!planId) return;

    const loadPlan = async () => {
      setLoading(true);
      setError(null);

      const response = await adminFetch(`/api/v1/admin/plans/${planId}`);
      if (response.status === 401 || response.status === 403) {
        await clearAdminSession();
        router.push('/admin/login');
        return;
      }

      if (!response.ok) {
        setError('Unable to load plan');
        setLoading(false);
        return;
      }

      const json = await response.json();
      setPlan(mapPlanToForm(json.plan));
      setTagsString((json.plan.tags as Array<{ name: string }>).map((tag) => tag.name).join(', '));
      setLoading(false);
    };

    loadPlan();
  }, [planId, router]);

  const updateSection = (index: number, update: Partial<AdminPlanInput['sections'][number]>) => {
    setPlan((current) => {
      const nextSections = current.sections.map((section, sectionIndex) =>
        sectionIndex === index ? { ...section, ...update } : section,
      );
      return { ...current, sections: nextSections };
    });
  };

  const updateSectionItem = (
    sectionIndex: number,
    itemIndex: number,
    update: Partial<AdminPlanInput['sections'][number]['items'][number]>,
  ) => {
    setPlan((current) => {
      const nextSections = current.sections.map((section, sIndex) => {
        if (sIndex !== sectionIndex) return section;
        const nextItems = section.items.map((item, iIndex) => (iIndex === itemIndex ? { ...item, ...update } : item));
        return { ...section, items: nextItems };
      });
      return { ...current, sections: nextSections };
    });
  };

  const addSection = () => {
    setPlan((current) => ({
      ...current,
      sections: [
        ...current.sections,
        {
          section_key: `section_${current.sections.length}`,
          title: '',
          description: '',
          order_index: current.sections.length,
          items: [
            {
              book_key: '',
              start_chapter: 1,
              end_chapter: 1,
              order_index: 0,
            },
          ],
        },
      ],
    }));
  };

  const removeSection = (index: number) => {
    setPlan((current) => ({
      ...current,
      sections: current.sections.filter((_, sectionIndex) => sectionIndex !== index),
    }));
  };

  const addItem = (sectionIndex: number) => {
    setPlan((current) => {
      const nextSections = current.sections.map((section, sIndex) => {
        if (sIndex !== sectionIndex) return section;
        return {
          ...section,
          items: [
            ...section.items,
            {
              book_key: '',
              start_chapter: 1,
              end_chapter: 1,
              order_index: section.items.length,
            },
          ],
        };
      });
      return { ...current, sections: nextSections };
    });
  };

  const removeItem = (sectionIndex: number, itemIndex: number) => {
    setPlan((current) => {
      const nextSections = current.sections.map((section, sIndex) => {
        if (sIndex !== sectionIndex) return section;
        return {
          ...section,
          items: section.items.filter((_, iIndex) => iIndex !== itemIndex),
        };
      });
      return { ...current, sections: nextSections };
    });
  };

  const handleUpload = async (file: File) => {
    setUploading(true);
    setError(null);

    try {
      const formData = new FormData();
      formData.append('file', file);
      const response = await adminFetch('/api/v1/admin/plans/upload', {
        method: 'POST',
        body: formData,
      });

      if (response.status === 401 || response.status === 403) {
        await clearAdminSession();
        router.push('/admin/login');
        return;
      }

      if (!response.ok) {
        const body = await response.json().catch(() => ({}));
        throw new Error(body.error || 'Cover upload failed');
      }

      const json = await response.json();
      setPlan((current) => ({
        ...current,
        cover_image_url: json.asset.secure_url,
        cover_image_public_id: json.asset.public_id,
      }));
      setSuccess('Cover image uploaded successfully.');
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
      const payload = {
        ...plan,
        total_chapters: calculatedTotalChapters,
        tags: tagsString
          .split(',')
          .map((tag) => tag.trim())
          .filter(Boolean),
      };

      const response = await adminFetch(planId ? `/api/v1/admin/plans/${planId}` : '/api/v1/admin/plans', {
        method: planId ? 'PUT' : 'POST',
        body: JSON.stringify(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (response.status === 401 || response.status === 403) {
        await clearAdminSession();
        router.push('/admin/login');
        return;
      }

      if (!response.ok) {
        const body = await response.json().catch(() => ({}));
        throw new Error(body.error || 'Save failed');
      }

      const json = await response.json();
      setSuccess(planId ? 'Plan updated successfully.' : 'Plan created successfully.');
      if (!planId) {
        router.push(`/admin/plans/${json.plan.id}`);
      }
    } catch (submitError) {
      setError((submitError as Error).message);
    } finally {
      setSaving(false);
    }
  };

  const logout = () => {
    void clearAdminSession().then(() => router.push('/admin/login'));
  };

  if (loading) {
    return <p>Loading plan...</p>;
  }

  return (
    <div className="admin-plan-editor">
      <div className="admin-page-header">
        <div>
          <h1>{planId ? 'Edit Plan' : 'Create New Plan'}</h1>
          <p>Manage plan content, sections, chapters, tags, and publish state.</p>
        </div>
        <button type="button" onClick={logout} className="btn btn-secondary">
          Logout
        </button>
      </div>

      {error ? <div className="alert alert-error">{error}</div> : null}
      {success ? <div className="alert alert-success">{success}</div> : null}

      <section className="form-card">
        <div className="field-row">
          <label htmlFor="title">Title</label>
          <input
            id="title"
            value={plan.title}
            onChange={(event) => setPlan({ ...plan, title: event.target.value })}
            placeholder="Plan title"
          />
        </div>

        <div className="field-row">
          <label htmlFor="subtitle">Subtitle</label>
          <input
            id="subtitle"
            value={plan.subtitle ?? ''}
            onChange={(event) => setPlan({ ...plan, subtitle: event.target.value })}
            placeholder="Optional subtitle"
          />
        </div>

        <div className="field-row">
          <label htmlFor="short_description">Short description</label>
          <textarea
            id="short_description"
            value={plan.short_description ?? ''}
            onChange={(event) => setPlan({ ...plan, short_description: event.target.value })}
            placeholder="One-sentence summary"
          />
        </div>

        <div className="field-row">
          <label htmlFor="description">Full description</label>
          <textarea
            id="description"
            value={plan.description ?? ''}
            onChange={(event) => setPlan({ ...plan, description: event.target.value })}
            placeholder="Longer plan details and context"
            rows={4}
          />
        </div>

        <div className="field-row">
          <label htmlFor="cover_image_url">Cover image URL</label>
          <input
            id="cover_image_url"
            value={plan.cover_image_url ?? ''}
            onChange={(event) => setPlan({ ...plan, cover_image_url: event.target.value })}
            placeholder="https://..."
          />
          {plan.cover_image_url ? (
            <img src={plan.cover_image_url} alt="Plan cover preview" className="cover-preview" />
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
              if (file) {
                handleUpload(file);
              }
            }}
          />
          <p className="muted">Images are uploaded to Cloudinary. Neon stores only the URL and public ID.</p>
          {uploading ? <p>Uploading cover...</p> : null}
        </div>

        <div className="field-row">
          <label htmlFor="plan_type">Plan type</label>
          <select
            id="plan_type"
            className="chapter-range-select"
            value={plan.plan_type ?? ''}
            onChange={(event) => setPlan({ ...plan, plan_type: event.target.value })}
            required
          >
            {PLAN_TYPE_OPTIONS.map((option) => (
              <option key={option.value || 'unset'} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>

        <div className="field-row group-grid">
          <div>
            <label htmlFor="testament_scope">Testament scope</label>
            <select
              id="testament_scope"
              className="chapter-range-select"
              value={plan.testament_scope ?? ''}
              onChange={(event) => setPlan({ ...plan, testament_scope: event.target.value })}
            >
              {TESTAMENT_SCOPE_OPTIONS.map((option) => (
                <option key={option.value || 'unset'} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label htmlFor="difficulty">Difficulty</label>
            <select
              id="difficulty"
              className="chapter-range-select"
              value={plan.difficulty ?? ''}
              onChange={(event) => setPlan({ ...plan, difficulty: event.target.value })}
            >
              {DIFFICULTY_OPTIONS.map((option) => (
                <option key={option.value || 'unset'} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="field-row group-grid">
          <div>
            <label htmlFor="estimated_minutes">Estimated minutes</label>
            <input
              id="estimated_minutes"
              type="number"
              value={plan.estimated_minutes ?? ''}
              onChange={(event) => setPlan({ ...plan, estimated_minutes: parseNumber(event.target.value) })}
              placeholder="Optional"
            />
          </div>
          <div>
            <label htmlFor="estimated_days">Estimated days</label>
            <input
              id="estimated_days"
              type="number"
              value={plan.estimated_days ?? ''}
              onChange={(event) => setPlan({ ...plan, estimated_days: parseNumber(event.target.value) })}
              placeholder="Optional"
            />
          </div>
          <div>
            <label htmlFor="total_chapters">Total chapters</label>
            <input id="total_chapters" type="number" value={calculatedTotalChapters} readOnly />
            <p className="muted">Automatically calculated from section items.</p>
          </div>
        </div>

        <div className="field-row">
          <label htmlFor="primary_book_key">Primary book key</label>
          <BookKeyCombobox
            id="primary_book_key"
            value={plan.primary_book_key ?? ''}
            onChange={(bookKey) => setPlan({ ...plan, primary_book_key: bookKey })}
            allowEmpty
          />
        </div>

        <div className="field-row">
          <label htmlFor="primary_character">Primary character</label>
          <input
            id="primary_character"
            value={plan.primary_character ?? ''}
            onChange={(event) => setPlan({ ...plan, primary_character: event.target.value })}
            placeholder="Optional"
          />
        </div>

        <div className="field-row">
          <label htmlFor="tags">Tags</label>
          <input
            id="tags"
            value={tagsString}
            onChange={(event) => setTagsString(event.target.value)}
            placeholder="comma-separated tags"
          />
        </div>

        <div className="field-row group-grid">
          <div className="checkbox-row">
            <label htmlFor="browse_visible">Show in browse catalog</label>
            <input
              id="browse_visible"
              type="checkbox"
              checked={plan.browse_visible !== false}
              onChange={(event) => setPlan({ ...plan, browse_visible: event.target.checked })}
            />
          </div>
          <div>
            <label htmlFor="featured_rank">Featured rank</label>
            <input
              id="featured_rank"
              type="number"
              min={0}
              value={plan.featured_rank ?? ''}
              onChange={(event) => {
                const v = parseNumber(event.target.value);
                setPlan({ ...plan, featured_rank: v === null ? null : v });
              }}
              placeholder="Lower = earlier in Featured sort"
            />
            <p className="muted">Leave empty if this plan should not be pinned in the Featured ordering.</p>
          </div>
        </div>

        {plan.is_archived ? (
          <div className="alert alert-warning">
            This plan is archived and hidden from the public catalog. Unarchive it from the Plan templates list
            before you can publish it again.
          </div>
        ) : null}

        <div className="field-row checkbox-row">
          <label htmlFor="published">Published</label>
          <input
            id="published"
            type="checkbox"
            disabled={Boolean(plan.is_archived)}
            checked={Boolean(plan.is_published)}
            onChange={(event) => setPlan({ ...plan, is_published: event.target.checked })}
          />
        </div>
      </section>

      <section className="form-card">
        <h2>Sections</h2>
        {plan.sections.map((section, sectionIndex) => (
          <div key={section.section_key || sectionIndex} className="section-card">
            <div className="section-header">
              <h3>Section {sectionIndex + 1}</h3>
              <button type="button" onClick={() => removeSection(sectionIndex)} className="btn btn-link">
                Remove section
              </button>
            </div>
            <div className="field-row">
              <label>Section title</label>
              <input
                value={section.title}
                onChange={(event) => updateSection(sectionIndex, { title: event.target.value })}
                placeholder="Section title"
              />
            </div>
            <div className="field-row">
              <label>Section description</label>
              <textarea
                value={section.description ?? ''}
                onChange={(event) => updateSection(sectionIndex, { description: event.target.value })}
                placeholder="Optional section description"
                rows={2}
              />
            </div>

            <div className="items-grid">
              {section.items.map((item, itemIndex) => (
                <div key={`${section.section_key}-${itemIndex}`} className="item-card">
                  <div className="section-header">
                    <h4>Item {itemIndex + 1}</h4>
                    <button type="button" onClick={() => removeItem(sectionIndex, itemIndex)} className="btn btn-link">
                      Remove item
                    </button>
                  </div>
                  <div className="field-row">
                    <label htmlFor={`book_key-${sectionIndex}-${itemIndex}`}>Book key</label>
                    <BookKeyCombobox
                      id={`book_key-${sectionIndex}-${itemIndex}`}
                      value={item.book_key}
                      onChange={(bookKey) => {
                        const clamped = clampPlanItemChapters({
                          book_key: bookKey,
                          start_chapter: item.start_chapter,
                          end_chapter: item.end_chapter,
                        });
                        updateSectionItem(sectionIndex, itemIndex, {
                          book_key: bookKey,
                          start_chapter: clamped.start_chapter,
                          end_chapter: clamped.end_chapter,
                        });
                      }}
                    />
                  </div>
                  <BookChapterRangeSelects
                    bookKey={item.book_key}
                    startChapter={item.start_chapter}
                    endChapter={item.end_chapter}
                    startId={`start-chapter-${sectionIndex}-${itemIndex}`}
                    endId={`end-chapter-${sectionIndex}-${itemIndex}`}
                    onChange={(next) => updateSectionItem(sectionIndex, itemIndex, next)}
                  />
                </div>
              ))}
            </div>
            <button type="button" onClick={() => addItem(sectionIndex)} className="btn btn-secondary">
              Add item
            </button>
          </div>
        ))}

        <button type="button" onClick={addSection} className="btn btn-secondary">
          Add section
        </button>
      </section>

      <div className="actions-row">
        <button type="button" disabled={saving} onClick={submit} className="btn btn-primary">
          {saving ? 'Saving…' : planId ? 'Save changes' : 'Create plan'}
        </button>
        <button type="button" onClick={() => router.push('/admin/plans')} className="btn btn-link">
          Cancel
        </button>
      </div>
    </div>
  );
}
