import Image from 'next/image';

import type { ContentSection } from '@/lib/content';
import { getDiscoverBlockType } from '@/lib/discover-blocks';

type DiscoverPostSectionsProps = {
  sections: ContentSection[];
  className?: string;
};

export function DiscoverPostSections({ sections, className = '' }: DiscoverPostSectionsProps) {
  if (sections.length === 0) return null;

  return (
    <div className={`space-y-10 ${className}`.trim()}>
      {sections.map((section) => {
        const blockType = getDiscoverBlockType(section);

        return (
          <section key={section.id}>
            {blockType === 'heading' && section.title ? (
              <h2 className="text-xl font-semibold text-neutral-900">{section.title}</h2>
            ) : null}

            {blockType === 'image' && section.image_url ? (
              <>
                <div className="relative aspect-[16/10] w-full overflow-hidden rounded-2xl border border-neutral-200">
                  <Image
                    src={section.image_url}
                    alt={section.image_alt_text ?? ''}
                    fill
                    className="object-cover"
                    sizes="(max-width: 768px) 100vw, 720px"
                  />
                </div>
                {section.image_caption ? (
                  <p className="mt-2 text-sm text-neutral-500">{section.image_caption}</p>
                ) : null}
              </>
            ) : null}

            {blockType === 'paragraph' && section.body
              ? section.body.split('\n\n').map((paragraph) => (
                  <p key={paragraph.slice(0, 48)} className="mkt-lead mt-4 whitespace-pre-wrap">
                    {paragraph}
                  </p>
                ))
              : null}
          </section>
        );
      })}
    </div>
  );
}
