/**
 * Client-safe Cloudinary URL helpers (no Node `postgres` / `crypto` imports).
 * Use from `'use client'` components for previews.
 *
 * Cloudinary chains transformation *steps* with `/` and parameters within a step with `,`.
 * Text overlay modifiers must live in the same step as `l_text`, not separate `/` segments.
 */

function cloudinaryCloudName(): string | null {
  return (
    process.env.NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME?.trim() ||
    process.env.CLOUDINARY_CLOUD_NAME?.trim() ||
    null
  );
}

function encodeCloudinaryText(value: string) {
  return encodeURIComponent(value)
    .replace(/%2C/g, '%252C')
    .replace(/%2F/g, '%252F');
}

function truncateCloudinaryText(value: string, maxLength: number) {
  const normalized = value.replace(/\s+/g, ' ').trim();
  if (normalized.length <= maxLength) return normalized;
  return `${normalized.slice(0, maxLength - 1).trimEnd()}…`;
}

/** Join parameters for a single Cloudinary transformation step. */
function cloudinaryStep(...params: string[]) {
  return params.join(',');
}

/** Chain multiple transformation steps in apply order. */
function cloudinaryChain(...steps: string[]) {
  return steps.join('/');
}

export function buildTodayMessageShareImageUrl(options: {
  imagePublicId: string | null;
  verseText: string | null;
  verseReference: string;
  bibleVersion: string | null;
}) {
  const imagePublicId = options.imagePublicId?.trim();
  if (!imagePublicId) return null;

  const cloudName = cloudinaryCloudName();
  if (!cloudName) return null;

  const referenceLabel = options.bibleVersion
    ? `${options.verseReference} · ${options.bibleVersion}`
    : options.verseReference;
  const verseText = truncateCloudinaryText(
    options.verseText?.trim() || options.verseReference,
    420,
  );

  // Mirrors mobile `_drawTodayMessageShareImage` (1080×1350, bottom-left copy, gradient scrim).
  const transformations = cloudinaryChain(
    cloudinaryStep('c_fill', 'g_auto', 'w_1080', 'h_1350'),
    cloudinaryStep('e_brightness:-12'),
    cloudinaryStep('e_gradient_fade:pad', 'x_0.5', 'y_1.1'),
    cloudinaryStep(
      `l_text:Arial_66_bold:${encodeCloudinaryText(`"${verseText}"`)}`,
      'co_rgb:ffffff',
      'c_fit,w_912',
      'fl_layer_apply,g_south_west,x_84,y_210',
    ),
    cloudinaryStep(
      `l_text:Arial_32_bold:${encodeCloudinaryText(referenceLabel.toUpperCase())}`,
      'co_rgb:ffffff',
      'o_78',
      'c_fit,w_912',
      'fl_layer_apply,g_south_west,x_84,y_112',
    ),
    cloudinaryStep('f_png', 'q_auto'),
  );

  return `https://res.cloudinary.com/${cloudName}/image/upload/${transformations}/${imagePublicId}`;
}
