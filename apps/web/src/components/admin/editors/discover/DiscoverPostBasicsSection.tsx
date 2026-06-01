'use client';

import { FormField } from '@/components/admin/ui/FormField';
import { FormSection } from '@/components/admin/ui/FormSection';
import type { AdminContentInput } from '@/lib/content';

type DiscoverPostBasicsSectionProps = {
  content: AdminContentInput;
  uploading: boolean;
  onChange: (next: AdminContentInput) => void;
  onCoverUpload: (file: File) => void;
  onClearCover: () => void;
};

export function DiscoverPostBasicsSection({
  content,
  uploading,
  onChange,
  onCoverUpload,
  onClearCover,
}: DiscoverPostBasicsSectionProps) {
  const hasCover = Boolean(content.cover_image_url?.trim());

  return (
    <FormSection title="Post details">
      <FormField label="Title" htmlFor="discover_title">
        <input
          id="discover_title"
          value={content.title}
          onChange={(event) => onChange({ ...content, title: event.target.value })}
          placeholder="Post title"
        />
      </FormField>

      <FormField label="Subtitle" htmlFor="discover_subtitle">
        <input
          id="discover_subtitle"
          value={content.subtitle ?? ''}
          onChange={(event) => onChange({ ...content, subtitle: event.target.value })}
        />
      </FormField>

      <FormField label="Summary" htmlFor="discover_summary" hint="Short teaser for Discover cards">
        <textarea
          id="discover_summary"
          value={content.summary ?? ''}
          onChange={(event) => onChange({ ...content, summary: event.target.value })}
          rows={3}
        />
      </FormField>

      <FormField label="Cover image" htmlFor="discover_cover_upload">
        <div className="admin-plan-cover-panel">
          {hasCover ? (
            <img src={content.cover_image_url!} alt="" className="admin-plan-cover-preview" />
          ) : (
            <div className="admin-plan-cover-preview admin-plan-cover-preview-empty" aria-hidden />
          )}
          <div className="admin-plan-cover-panel-actions">
            <div className="admin-upload-box">
              <label
                htmlFor="discover_cover_upload"
                className="admin-btn admin-btn-secondary admin-upload-label"
              >
                {uploading ? 'Uploading…' : hasCover ? 'Replace cover' : 'Upload cover'}
              </label>
              <input
                id="discover_cover_upload"
                type="file"
                accept="image/*"
                className="admin-upload-input-hidden"
                disabled={uploading}
                onChange={(event) => {
                  const file = event.target.files?.[0];
                  event.target.value = '';
                  if (file) onCoverUpload(file);
                }}
              />
            </div>
            {hasCover ? (
              <button type="button" className="admin-btn admin-btn-link" onClick={onClearCover}>
                Remove cover
              </button>
            ) : null}
          </div>
        </div>
      </FormField>
    </FormSection>
  );
}
