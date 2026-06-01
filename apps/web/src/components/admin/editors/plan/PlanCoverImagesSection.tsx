'use client';

import { FormSection } from '@/components/admin/ui/FormSection';

type PlanCoverImagesSectionProps = {
  coverImageUrl: string | null | undefined;
  title: string;
  uploading: boolean;
  onUpload: (file: File) => void;
  onClear: () => void;
};

function CoverPreview({ url, title }: { url: string | null | undefined; title: string }) {
  if (!url?.trim()) {
    return (
      <div className="admin-plan-cover-preview admin-plan-cover-preview-empty" aria-hidden>
        <span className="admin-muted">No cover</span>
      </div>
    );
  }

  return <img src={url} alt={title} className="admin-plan-cover-preview" />;
}

export function PlanCoverImagesSection({
  coverImageUrl,
  title,
  uploading,
  onUpload,
  onClear,
}: PlanCoverImagesSectionProps) {
  const hasCover = Boolean(coverImageUrl?.trim());
  const uploadLabel = uploading ? 'Uploading…' : hasCover ? 'Replace cover' : 'Upload cover';

  return (
    <FormSection title="Cover image">
      <p className="admin-muted">
        Portrait cover for <code>/plans</code> (4:5). Upload only — URL is set automatically after upload.
      </p>
      <div className="admin-plan-cover-panel">
        <CoverPreview url={coverImageUrl} title={title || 'Plan cover'} />
        <div className="admin-plan-cover-panel-actions">
          <div className="admin-upload-box">
            <label htmlFor="plan_cover_upload" className="admin-btn admin-btn-secondary admin-upload-label">
              {uploadLabel}
            </label>
            <input
              id="plan_cover_upload"
              type="file"
              accept="image/*"
              className="admin-upload-input-hidden"
              disabled={uploading}
              onChange={(event) => {
                const file = event.target.files?.[0];
                event.target.value = '';
                if (file) onUpload(file);
              }}
            />
            <p className="admin-muted admin-upload-hint">PNG, JPG, or WebP · 4:5 portrait recommended</p>
          </div>
          {hasCover ? (
            <button type="button" className="admin-btn admin-btn-link" disabled={uploading} onClick={onClear}>
              Remove cover
            </button>
          ) : null}
        </div>
      </div>
    </FormSection>
  );
}
