import { describe, expect, it } from 'vitest';

import {
  messageCompositeImagePath,
  parseCompositeImageUrl,
  resolveMessageCardImages,
} from '@/lib/message-images';

describe('resolveMessageCardImages', () => {
  it('uses composite when present', () => {
    const images = resolveMessageCardImages({
      coverImageUrl: '/messages/backgrounds/base.webp',
      compositeImageUrl: '/messages/composites/john-1-1-3.webp',
    });
    expect(images.displayImageUrl).toBe('/messages/composites/john-1-1-3.webp');
    expect(images.hasCompositeImage).toBe(true);
  });

  it('falls back to cover when composite is missing', () => {
    const images = resolveMessageCardImages({
      coverImageUrl: '/messages/backgrounds/base.webp',
      compositeImageUrl: null,
    });
    expect(images.displayImageUrl).toBe('/messages/backgrounds/base.webp');
    expect(images.hasCompositeImage).toBe(false);
  });
});

describe('messageCompositeImagePath', () => {
  it('normalizes slug', () => {
    expect(messageCompositeImagePath('John-1-1-3')).toBe('/messages/composites/john-1-1-3.webp');
  });
});

describe('parseCompositeImageUrl', () => {
  it('reads camelCase and snake_case', () => {
    expect(parseCompositeImageUrl({ compositeImageUrl: '/a.webp' })).toBe('/a.webp');
    expect(parseCompositeImageUrl({ composite_image_url: '/b.webp' })).toBe('/b.webp');
  });
});
