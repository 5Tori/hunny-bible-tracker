/**
 * Message card images (two layers per message):
 *
 * - **Base** (`cover_image_url`): background for live verse overlay in the UI.
 * - **Composite** (`metadata.compositeImageUrl`): optional pre-rendered image with text baked in.
 *
 * When composite is missing, consumers fall back to the base image.
 */

export type MessageCardImageSet = {
  /** Base background image URL (required for published messages). */
  coverImageUrl: string | null;
  /** Optional pre-rendered card (image + verse text). */
  compositeImageUrl: string | null;
  /** `compositeImageUrl` when set, otherwise `coverImageUrl`. */
  displayImageUrl: string | null;
  hasCompositeImage: boolean;
};

function normalizeImageUrl(value: string | null | undefined): string | null {
  const trimmed = value?.trim();
  return trimmed || null;
}

/** Default public path for a slug's composite card (file may not exist yet). */
export function messageCompositeImagePath(slug: string): string {
  return `/messages/composites/${slug.trim().toLowerCase()}.webp`;
}

export function resolveMessageCardImages(input: {
  coverImageUrl?: string | null;
  compositeImageUrl?: string | null;
}): MessageCardImageSet {
  const coverImageUrl = normalizeImageUrl(input.coverImageUrl);
  const compositeImageUrl = normalizeImageUrl(input.compositeImageUrl);
  const displayImageUrl = compositeImageUrl ?? coverImageUrl;

  return {
    coverImageUrl,
    compositeImageUrl,
    displayImageUrl,
    hasCompositeImage: compositeImageUrl != null,
  };
}

/** Read composite URL from `contents.metadata` (camelCase or snake_case). */
export function parseCompositeImageUrl(
  raw: Record<string, unknown> | null | undefined,
): string | null {
  const source = raw ?? {};
  return normalizeImageUrl(
    (source.compositeImageUrl as string | undefined) ??
      (source.composite_image_url as string | undefined),
  );
}

export function parseCompositeImagePublicId(
  raw: Record<string, unknown> | null | undefined,
): string | null {
  const source = raw ?? {};
  return normalizeImageUrl(
    (source.compositeImagePublicId as string | undefined) ??
      (source.composite_image_public_id as string | undefined),
  );
}
