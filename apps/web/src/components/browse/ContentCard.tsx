import Image from "next/image";
import Link from "next/link";

import type { ContentWithRelations } from "@/lib/content";

const typeLabels: Record<string, string> = {
  video: "Video",
  essay: "Essay",
  cartoon: "Cartoon",
  message: "Message",
};

export function ContentCard({ content }: { content: ContentWithRelations }) {
  const typeLabel = typeLabels[content.content_type] ?? content.content_type;

  return (
    <Link
      href={`/content/${content.slug}`}
      className="group flex flex-col overflow-hidden rounded-2xl border border-neutral-200 bg-white transition hover:border-neutral-300"
    >
      <div className="relative aspect-[16/10] bg-neutral-100">
        {content.cover_image_url ? (
          <Image
            src={content.cover_image_url}
            alt=""
            fill
            className="object-cover transition group-hover:scale-[1.02]"
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
          />
        ) : (
          <div className="flex h-full items-center justify-center text-sm text-neutral-400">
            {typeLabel}
          </div>
        )}
        <span className="absolute left-3 top-3 rounded-full bg-white/95 px-2.5 py-0.5 text-[11px] font-medium uppercase tracking-wide text-[#d99a12]">
          {typeLabel}
        </span>
      </div>
      <div className="flex flex-1 flex-col p-5">
        <h2 className="text-base font-semibold leading-snug text-neutral-900 group-hover:text-black">
          {content.title}
        </h2>
        {content.subtitle ? (
          <p className="mt-1 text-sm text-neutral-500">{content.subtitle}</p>
        ) : null}
        {content.summary ? (
          <p className="mt-2 line-clamp-2 text-sm leading-relaxed text-neutral-600">
            {content.summary}
          </p>
        ) : null}
        {content.author?.display_name ? (
          <p className="mt-auto pt-4 text-xs text-neutral-500">
            {content.author.display_name}
          </p>
        ) : null}
      </div>
    </Link>
  );
}
