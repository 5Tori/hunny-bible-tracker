'use client';

import Image from 'next/image';
import { useState } from 'react';

export type GallerySlide = {
  id: string;
  url: string;
  alt: string;
  caption: string | null;
};

type ContentGalleryCarouselProps = {
  slides: GallerySlide[];
  className?: string;
};

export function ContentGalleryCarousel({ slides, className = '' }: ContentGalleryCarouselProps) {
  const [index, setIndex] = useState(0);

  if (slides.length === 0) return null;

  const current = slides[index] ?? slides[0];
  const hasMultiple = slides.length > 1;

  const goPrev = () => {
    setIndex((i) => (i <= 0 ? slides.length - 1 : i - 1));
  };

  const goNext = () => {
    setIndex((i) => (i >= slides.length - 1 ? 0 : i + 1));
  };

  return (
    <div className={`mt-10 ${className}`.trim()}>
      <figure className="overflow-hidden rounded-2xl border border-neutral-200 bg-neutral-50">
        <div className="relative aspect-[4/3] w-full">
          <Image
            src={current.url}
            alt={current.alt}
            fill
            className="object-contain"
            sizes="(max-width: 768px) 100vw, 720px"
            priority
          />
          {hasMultiple ? (
            <>
              <button
                type="button"
                onClick={goPrev}
                className="absolute left-3 top-1/2 flex h-10 w-10 -translate-y-1/2 items-center justify-center rounded-full bg-black/50 text-lg text-white transition hover:bg-black/70"
                aria-label="Previous slide"
              >
                ‹
              </button>
              <button
                type="button"
                onClick={goNext}
                className="absolute right-3 top-1/2 flex h-10 w-10 -translate-y-1/2 items-center justify-center rounded-full bg-black/50 text-lg text-white transition hover:bg-black/70"
                aria-label="Next slide"
              >
                ›
              </button>
              <span className="absolute bottom-3 right-3 rounded-full bg-black/55 px-3 py-1 text-xs font-medium text-white">
                {index + 1} / {slides.length}
              </span>
            </>
          ) : null}
        </div>
        {current.caption ? (
          <figcaption className="px-4 py-3 text-sm text-neutral-600">{current.caption}</figcaption>
        ) : null}
      </figure>

      {hasMultiple ? (
        <div className="mt-3 flex gap-2 overflow-x-auto pb-1">
          {slides.map((slide, slideIndex) => (
            <button
              key={slide.id}
              type="button"
              onClick={() => setIndex(slideIndex)}
              className={
                slideIndex === index
                  ? 'relative h-14 w-14 shrink-0 overflow-hidden rounded-lg ring-2 ring-[#d99a12]'
                  : 'relative h-14 w-14 shrink-0 overflow-hidden rounded-lg border border-neutral-200 opacity-70 hover:opacity-100'
              }
              aria-label={`Go to slide ${slideIndex + 1}`}
            >
              <Image src={slide.url} alt="" fill className="object-cover" sizes="56px" />
            </button>
          ))}
        </div>
      ) : null}
    </div>
  );
}
