'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

import { useAdminAuth } from '@/components/admin/hooks/use-admin-auth';
import { adminFetch } from '@/lib/admin/client';
import { revalidateAdminPlans } from '@/lib/admin/swr-mutate';
import type { AdminPlanInput } from '@/lib/plans';

import {
  calculatePlanTotalChapters,
  emptyPlan,
  mapPlanToForm,
  normalizeSections,
} from './plan-editor-utils';

export function usePlanEditor(planId?: string) {
  const router = useRouter();
  const { handleAdminResponse } = useAdminAuth();
  const [plan, setPlan] = useState<AdminPlanInput>(emptyPlan);
  const [tagsString, setTagsString] = useState('');
  const [loading, setLoading] = useState(Boolean(planId));
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [estimatedTotalMinutes, setEstimatedTotalMinutes] = useState<number | null>(null);

  const calculatedTotalChapters = calculatePlanTotalChapters(plan.sections);

  useEffect(() => {
    if (!planId) return;

    const loadPlan = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await adminFetch(`/api/v1/admin/plans/${planId}`);
        const ok = await handleAdminResponse(response);
        if (!ok) {
          setLoading(false);
          return;
        }

        if (!response.ok) {
          const body = await response.json().catch(() => ({}));
          const detail =
            typeof body.message === 'string'
              ? body.message
              : typeof body.error === 'string'
                ? body.error
                : null;
          setError(detail ? `Unable to load plan: ${detail}` : 'Unable to load plan');
          setLoading(false);
          return;
        }

        const json = await response.json();
        const mapped = mapPlanToForm(json.plan);
        const chapters = calculatePlanTotalChapters(mapped.sections);
        setPlan(mapped);
        setTagsString((json.plan.tags as Array<{ name: string }>).map((tag) => tag.name).join(', '));
        setEstimatedTotalMinutes(
          mapped.estimated_minutes != null && mapped.estimated_minutes > 0 && chapters > 0
            ? mapped.estimated_minutes * chapters
            : null,
        );
      } catch (loadError) {
        setError((loadError as Error).message || 'Unable to load plan');
      } finally {
        setLoading(false);
      }
    };

    void loadPlan();
  }, [planId, handleAdminResponse]);

  const updateSection = (index: number, update: Partial<AdminPlanInput['sections'][number]>) => {
    setPlan((current) => ({
      ...current,
      sections: current.sections.map((section, sectionIndex) =>
        sectionIndex === index ? { ...section, ...update } : section,
      ),
    }));
  };

  const updateSectionItem = (
    sectionIndex: number,
    itemIndex: number,
    update: Partial<AdminPlanInput['sections'][number]['items'][number]>,
  ) => {
    setPlan((current) => ({
      ...current,
      sections: current.sections.map((section, sIndex) => {
        if (sIndex !== sectionIndex) return section;
        return {
          ...section,
          items: section.items.map((item, iIndex) => (iIndex === itemIndex ? { ...item, ...update } : item)),
        };
      }),
    }));
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
          items: [{ book_key: '', start_chapter: 1, end_chapter: 1, order_index: 0 }],
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
    setPlan((current) => ({
      ...current,
      sections: current.sections.map((section, sIndex) => {
        if (sIndex !== sectionIndex) return section;
        return {
          ...section,
          items: [
            ...section.items,
            { book_key: '', start_chapter: 1, end_chapter: 1, order_index: section.items.length },
          ],
        };
      }),
    }));
  };

  const removeItem = (sectionIndex: number, itemIndex: number) => {
    setPlan((current) => ({
      ...current,
      sections: current.sections.map((section, sIndex) => {
        if (sIndex !== sectionIndex) return section;
        return { ...section, items: section.items.filter((_, iIndex) => iIndex !== itemIndex) };
      }),
    }));
  };

  const clearCover = () => {
    setPlan((current) => ({
      ...current,
      cover_image_url: '',
      cover_image_public_id: '',
    }));
    setSuccess('Cover removed.');
  };

  const handleUpload = async (file: File) => {
    setUploading(true);
    setError(null);
    try {
      const formData = new FormData();
      formData.append('file', file);
      const response = await adminFetch('/api/v1/admin/plans/upload', { method: 'POST', body: formData });
      const ok = await handleAdminResponse(response);
      if (!ok) return;

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
      setSuccess('Cover image uploaded.');
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
        estimated_total_minutes: estimatedTotalMinutes,
        sections: normalizeSections(plan.sections),
        total_chapters: calculatedTotalChapters,
        tags: tagsString
          .split(',')
          .map((tag) => tag.trim())
          .filter(Boolean),
      };

      const response = await adminFetch(planId ? `/api/v1/admin/plans/${planId}` : '/api/v1/admin/plans', {
        method: planId ? 'PUT' : 'POST',
        body: JSON.stringify(payload),
        headers: { 'Content-Type': 'application/json' },
      });

      const ok = await handleAdminResponse(response);
      if (!ok) return;

      if (!response.ok) {
        const body = await response.json().catch(() => ({}));
        throw new Error(body.error || 'Save failed');
      }

      const json = await response.json();
      const saved = json.plan as {
        estimated_minutes: number | null;
      };
      const chapters = calculatePlanTotalChapters(plan.sections);
      if (saved.estimated_minutes != null && saved.estimated_minutes > 0 && chapters > 0) {
        setEstimatedTotalMinutes(saved.estimated_minutes * chapters);
      }
      setSuccess(planId ? 'Plan updated.' : 'Plan created.');
      await revalidateAdminPlans();
      if (!planId) {
        router.push(`/admin/plans/${json.plan.id}`);
      }
    } catch (submitError) {
      setError((submitError as Error).message);
    } finally {
      setSaving(false);
    }
  };

  return {
    plan,
    setPlan,
    tagsString,
    setTagsString,
    loading,
    saving,
    uploading,
    error,
    success,
    calculatedTotalChapters,
    estimatedTotalMinutes,
    setEstimatedTotalMinutes,
    updateSection,
    updateSectionItem,
    addSection,
    removeSection,
    addItem,
    removeItem,
    handleUpload,
    clearCover,
    submit,
  };
}
