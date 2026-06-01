'use client';

import { FormSection } from '@/components/admin/ui/FormSection';
import type { AdminContentInput } from '@/lib/content';
import { DISCOVER_GALLERY_ASSET_ROLE } from '@/lib/discover-content';

import { parseDiscoverNumber } from './discover-editor-utils';

type AssetInput = NonNullable<AdminContentInput['assets']>[number];

type DiscoverGallerySectionProps = {
  assets: AssetInput[];
  emphasized: boolean;
  uploading: boolean;
  onAssetChange: (index: number, update: Partial<AssetInput>) => void;
  onMoveAsset: (index: number, direction: -1 | 1) => void;
  onRemoveAsset: (index: number) => void;
  onUploadSlides: (files: FileList) => void;
};

export function DiscoverGallerySection({
  assets,
  emphasized,
  uploading,
  onAssetChange,
  onMoveAsset,
  onRemoveAsset,
  onUploadSlides,
}: DiscoverGallerySectionProps) {
  return (
    <FormSection title="Cartoon slides">
      <p className="admin-muted">
        {emphasized
          ? 'Cartoon category — add images in order. Readers get prev/next slides on the post page.'
          : 'Optional slide sequence. Each image can have a caption.'}
      </p>

      {assets.length === 0 ? (
        <p className="admin-muted">No slides yet — upload one or more images.</p>
      ) : null}

      {assets.map((asset, index) => (
        <div key={`discover-slide-${index}-${asset.url}`} className="item-card content-asset-card">
          <div className="admin-section-header">
            <h3>Slide {index + 1}</h3>
            <span className="admin-table-actions">
              <button
                type="button"
                className="admin-btn admin-btn-link"
                disabled={index === 0}
                onClick={() => onMoveAsset(index, -1)}
              >
                ↑
              </button>
              <button
                type="button"
                className="admin-btn admin-btn-link"
                disabled={index >= assets.length - 1}
                onClick={() => onMoveAsset(index, 1)}
              >
                ↓
              </button>
              <button
                type="button"
                className="admin-btn admin-btn-link"
                onClick={() => onRemoveAsset(index)}
              >
                Remove
              </button>
            </span>
          </div>

          {asset.url ? (
            <img src={asset.url} alt="" className="admin-cover-preview" />
          ) : null}

          <div className="admin-field admin-form-grid-2">
            <div className="admin-field">
              <label htmlFor={`discover_slide_caption_${index}`}>Caption</label>
              <input
                id={`discover_slide_caption_${index}`}
                value={asset.caption ?? ''}
                onChange={(event) => onAssetChange(index, { caption: event.target.value })}
              />
            </div>
            <div className="admin-field">
              <label htmlFor={`discover_slide_alt_${index}`}>Alt text</label>
              <input
                id={`discover_slide_alt_${index}`}
                value={asset.alt_text ?? ''}
                onChange={(event) => onAssetChange(index, { alt_text: event.target.value })}
              />
            </div>
            <div className="admin-field">
              <label htmlFor={`discover_slide_order_${index}`}>Order</label>
              <input
                id={`discover_slide_order_${index}`}
                type="number"
                value={asset.order_index ?? index}
                onChange={(event) =>
                  onAssetChange(index, { order_index: parseDiscoverNumber(event.target.value) ?? index })
                }
              />
            </div>
          </div>
        </div>
      ))}

      <div className="admin-upload-box">
        <label htmlFor="discover_gallery_upload" className="admin-btn admin-btn-secondary admin-upload-label">
          {uploading ? 'Uploading…' : 'Upload slides'}
        </label>
        <input
          id="discover_gallery_upload"
          type="file"
          accept="image/*"
          multiple
          className="admin-upload-input-hidden"
          disabled={uploading}
          onChange={(event) => {
            const files = event.target.files;
            event.target.value = '';
            if (files?.length) onUploadSlides(files);
          }}
        />
        <p className="admin-muted admin-upload-hint">Select multiple images to add several slides at once.</p>
      </div>
    </FormSection>
  );
}

export function createEmptyGallerySlide(orderIndex: number): AssetInput {
  return {
    asset_type: 'image',
    asset_role: DISCOVER_GALLERY_ASSET_ROLE,
    order_index: orderIndex,
    title: '',
    caption: '',
    alt_text: '',
    url: '',
    public_id: '',
    provider: '',
    mime_type: '',
    width: null,
    height: null,
    duration_seconds: null,
    metadata: {},
  };
}
