'use client';

import { MessageCardClassification } from '@/components/messages/MessageCardClassification';
import {
  formatMessageReference,
  MessageCardVisual,
} from '@/components/messages/message-card-visual';
import type { AdminContentInput } from '@/lib/content';
import { buildAdminMessagePreview, type MessageEditorState } from '@/lib/message-admin';

/** Matches `/messages` grid tile: visual + classification (same component sizes as `MessageCardTile`). */
export function AdminMessageCardPreview({
  content,
  messageState,
  contentId,
}: {
  content: AdminContentInput;
  messageState: MessageEditorState;
  contentId?: string;
}) {
  const message = buildAdminMessagePreview(content, messageState, contentId);
  const shareTitle = formatMessageReference(message) || message.title;

  return (
    <div className="admin-message-library-preview">
      <p className="admin-muted admin-message-library-preview-label">
        Library list preview
      </p>
      <article className="admin-message-library-preview-tile flex flex-col">
        <div className="block w-full" aria-label={shareTitle}>
          <MessageCardVisual message={message} variant="tile" />
        </div>
        <MessageCardClassification message={message} className="mt-2.5" />
      </article>
    </div>
  );
}
