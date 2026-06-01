'use client';

import { FormSection } from '@/components/admin/ui/FormSection';
import { MESSAGE_CARD_ASPECT_CLASS } from '@/components/messages/message-card-visual';
import type { AdminContentInput } from '@/lib/content';
import type { MessageEditorState } from '@/lib/message-admin';

export type MessageImageUploadTarget = 'base' | 'composite';

type MessageCardImagesSectionProps = {
  content: AdminContentInput;
  messageState: MessageEditorState;
  uploading: MessageImageUploadTarget | null;
  onUpload: (file: File, target: MessageImageUploadTarget) => void;
  onClearBase: () => void;
  onClearComposite: () => void;
};

function ImagePreview({ url }: { url: string | null | undefined }) {
  if (!url?.trim()) {
    return (
      <div
        className={`admin-message-image-preview admin-message-image-preview-empty ${MESSAGE_CARD_ASPECT_CLASS}`}
        aria-hidden
      />
    );
  }

  return (
    <img src={url} alt="" className={`admin-message-image-preview ${MESSAGE_CARD_ASPECT_CLASS}`} />
  );
}

function ImagePanel({
  title,
  description,
  uploadId,
  uploading,
  hasImage,
  onFileSelected,
  onClear,
  previewUrl,
}: {
  title: string;
  description: string;
  uploadId: string;
  uploading: boolean;
  hasImage: boolean;
  onFileSelected: (file: File) => void;
  onClear: () => void;
  previewUrl: string | null | undefined;
}) {
  const uploadLabel = uploading
    ? 'Uploading…'
    : hasImage
      ? 'Replace image'
      : 'Upload image';

  return (
    <div className="admin-message-image-panel">
      <div className="admin-message-image-panel-header">
        <h3 className="admin-message-image-panel-title">{title}</h3>
        <p className="admin-muted">{description}</p>
      </div>
      <div className="admin-message-image-panel-body">
        <ImagePreview url={previewUrl} />
        <div className="admin-message-image-panel-actions">
          <div className="admin-upload-box">
            <label htmlFor={uploadId} className="admin-btn admin-btn-secondary admin-upload-label">
              {uploadLabel}
            </label>
            <input
              id={uploadId}
              type="file"
              accept="image/*"
              className="admin-upload-input-hidden"
              disabled={uploading}
              onChange={(event) => {
                const file = event.target.files?.[0];
                event.target.value = '';
                if (file) onFileSelected(file);
              }}
            />
            <p className="admin-muted admin-upload-hint">PNG, JPG, or WebP · portrait 9:16 recommended</p>
          </div>
          {hasImage ? (
            <button type="button" className="admin-btn admin-btn-link" disabled={uploading} onClick={onClear}>
              Remove image
            </button>
          ) : null}
        </div>
      </div>
    </div>
  );
}

export function MessageCardImagesSection({
  content,
  messageState,
  uploading,
  onUpload,
  onClearBase,
  onClearComposite,
}: MessageCardImagesSectionProps) {
  const hasBase = Boolean(content.cover_image_url?.trim());
  const hasComposite = Boolean(messageState.compositeImageUrl?.trim());

  return (
    <FormSection title="Card images">
      <p className="admin-muted">
        Upload two optional layers: a <strong>base background</strong> (required to publish) and an
        optional <strong>composite</strong> with verse text already on the image. The library shows the
        composite when present; otherwise the base with a live verse overlay.
      </p>

      <div className="admin-message-image-panels">
        <ImagePanel
          title="1. Base background"
          description="Required to publish."
          uploadId="message_cover_upload_base"
          uploading={uploading === 'base'}
          hasImage={hasBase}
          onFileSelected={(file) => onUpload(file, 'base')}
          onClear={onClearBase}
          previewUrl={content.cover_image_url}
        />

        <ImagePanel
          title="2. Composite (optional)"
          description="Pre-rendered card; overrides the live overlay in the library."
          uploadId="message_cover_upload_composite"
          uploading={uploading === 'composite'}
          hasImage={hasComposite}
          onFileSelected={(file) => onUpload(file, 'composite')}
          onClear={onClearComposite}
          previewUrl={messageState.compositeImageUrl || null}
        />
      </div>
    </FormSection>
  );
}
