'use client';

import { FormField } from '@/components/admin/ui/FormField';
import { FormSection } from '@/components/admin/ui/FormSection';

import {
  DISCOVER_BLOCK_TYPES,
  type DiscoverBlockType,
  type DiscoverSectionInput,
  discoverBlockTypeLabel,
  getDiscoverBlockType,
} from '@/lib/discover-blocks';

type DiscoverContentBlocksSectionProps = {
  sections: DiscoverSectionInput[];
  uploading: boolean;
  onSectionChange: (index: number, update: Partial<DiscoverSectionInput>) => void;
  onSectionBlockTypeChange: (index: number, blockType: DiscoverBlockType) => void;
  onAddSection: (blockType: DiscoverBlockType) => void;
  onRemoveSection: (index: number) => void;
  onSectionImageUpload: (index: number, file: File) => void;
  onClearSectionImage: (index: number) => void;
};

function DiscoverImageBlockFields({
  section,
  index,
  uploading,
  onSectionChange,
  onSectionImageUpload,
  onClearSectionImage,
}: {
  section: DiscoverSectionInput;
  index: number;
  uploading: boolean;
  onSectionChange: (index: number, update: Partial<DiscoverSectionInput>) => void;
  onSectionImageUpload: (index: number, file: File) => void;
  onClearSectionImage: (index: number) => void;
}) {
  const hasImage = Boolean(section.image_url?.trim());

  return (
    <>
      <FormField label="Image" htmlFor={`discover_block_upload_${index}`}>
        <div className="admin-plan-cover-panel">
          {hasImage ? (
            <img src={section.image_url!} alt="" className="admin-plan-cover-preview" />
          ) : (
            <div className="admin-plan-cover-preview admin-plan-cover-preview-empty" aria-hidden />
          )}
          <div className="admin-plan-cover-panel-actions">
            <div className="admin-upload-box">
              <label
                htmlFor={`discover_block_upload_${index}`}
                className="admin-btn admin-btn-secondary admin-upload-label"
              >
                {uploading ? 'Uploading…' : hasImage ? 'Replace image' : 'Upload image'}
              </label>
              <input
                id={`discover_block_upload_${index}`}
                type="file"
                accept="image/*"
                className="admin-upload-input-hidden"
                disabled={uploading}
                onChange={(event) => {
                  const file = event.target.files?.[0];
                  event.target.value = '';
                  if (file) onSectionImageUpload(index, file);
                }}
              />
            </div>
            {hasImage ? (
              <button
                type="button"
                className="admin-btn admin-btn-link"
                onClick={() => onClearSectionImage(index)}
              >
                Remove image
              </button>
            ) : null}
          </div>
        </div>
      </FormField>

      {hasImage ? (
        <div className="admin-form-grid-2">
          <FormField label="Image alt text" htmlFor={`discover_block_alt_${index}`}>
            <input
              id={`discover_block_alt_${index}`}
              value={section.image_alt_text ?? ''}
              onChange={(event) => onSectionChange(index, { image_alt_text: event.target.value })}
              placeholder="Describe the image for screen readers"
            />
          </FormField>
          <FormField label="Image caption" htmlFor={`discover_block_caption_${index}`}>
            <input
              id={`discover_block_caption_${index}`}
              value={section.image_caption ?? ''}
              onChange={(event) => onSectionChange(index, { image_caption: event.target.value })}
              placeholder="Optional caption below the image"
            />
          </FormField>
        </div>
      ) : null}
    </>
  );
}

export function DiscoverContentBlocksSection({
  sections,
  uploading,
  onSectionChange,
  onSectionBlockTypeChange,
  onAddSection,
  onRemoveSection,
  onSectionImageUpload,
  onClearSectionImage,
}: DiscoverContentBlocksSectionProps) {
  return (
    <FormSection title="Post content">
      <p className="admin-muted">
        Main article copy lives here — add headings, paragraphs, and images in order. Summary above
        is only for Discover cards.
      </p>

      {sections.length === 0 ? (
        <p className="admin-muted">No blocks yet — add one below.</p>
      ) : null}

      {sections.map((section, index) => {
        const blockType = getDiscoverBlockType(section);

        return (
          <div key={`discover-block-${index}`} className="item-card content-asset-card">
            <div className="admin-section-header">
              <div className="admin-field admin-field-inline">
                <label htmlFor={`discover_block_type_${index}`}>Block type</label>
                <select
                  id={`discover_block_type_${index}`}
                  value={blockType}
                  onChange={(event) =>
                    onSectionBlockTypeChange(index, event.target.value as DiscoverBlockType)
                  }
                >
                  {DISCOVER_BLOCK_TYPES.map((type) => (
                    <option key={type} value={type}>
                      {discoverBlockTypeLabel(type)}
                    </option>
                  ))}
                </select>
              </div>
              <button
                type="button"
                className="admin-btn admin-btn-link"
                onClick={() => onRemoveSection(index)}
              >
                Remove
              </button>
            </div>

            {blockType === 'heading' ? (
              <FormField label="Heading" htmlFor={`discover_block_title_${index}`}>
                <input
                  id={`discover_block_title_${index}`}
                  value={section.title ?? ''}
                  onChange={(event) => onSectionChange(index, { title: event.target.value })}
                  placeholder="Section heading"
                />
              </FormField>
            ) : null}

            {blockType === 'paragraph' ? (
              <FormField label="Paragraph" htmlFor={`discover_block_body_${index}`}>
                <textarea
                  id={`discover_block_body_${index}`}
                  value={section.body ?? ''}
                  onChange={(event) => onSectionChange(index, { body: event.target.value })}
                  rows={6}
                  placeholder="Write one or more paragraphs…"
                />
              </FormField>
            ) : null}

            {blockType === 'image' ? (
              <DiscoverImageBlockFields
                section={section}
                index={index}
                uploading={uploading}
                onSectionChange={onSectionChange}
                onSectionImageUpload={onSectionImageUpload}
                onClearSectionImage={onClearSectionImage}
              />
            ) : null}
          </div>
        );
      })}

      <div className="admin-discover-add-blocks">
        {DISCOVER_BLOCK_TYPES.map((type) => (
          <button
            key={type}
            type="button"
            className="admin-btn admin-btn-secondary"
            onClick={() => onAddSection(type)}
          >
            Add {discoverBlockTypeLabel(type).toLowerCase()}
          </button>
        ))}
      </div>
    </FormSection>
  );
}
