import Image from 'next/image';

type PlanCoverImageProps = {
  coverImageUrl: string | null;
  title: string;
  className?: string;
  sizes?: string;
  priority?: boolean;
};

export function PlanCoverImage({
  coverImageUrl,
  title,
  className = 'w-full',
  sizes = '(max-width: 768px) 200px, 240px',
  priority = false,
}: PlanCoverImageProps) {
  return (
    <div
      className={`relative aspect-[4/5] overflow-hidden bg-gradient-to-br from-[#fff8eb] via-white to-neutral-100 ${className}`}
    >
      {coverImageUrl ? (
        <Image
          src={coverImageUrl}
          alt={title}
          fill
          className="object-cover"
          sizes={sizes}
          priority={priority}
        />
      ) : (
        <div className="flex h-full flex-col items-center justify-center px-4 text-center">
          <span className="text-[11px] font-medium uppercase tracking-[0.14em] text-[#d99a12]">
            Reading plan
          </span>
        </div>
      )}
    </div>
  );
}
