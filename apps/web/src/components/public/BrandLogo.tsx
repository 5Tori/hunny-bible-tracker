import Image from "next/image";

import { brandConfig } from "@/lib/brand-config";

type BrandLogoProps = {
  className?: string;
  /** LCP hint for header / above-the-fold marks */
  priority?: boolean;
};

/** Hunny hex mark from `assets/brand/favicon.png` (served as `/brand/hunny-mark.png`). */
export function BrandLogo({ className = "h-7 w-auto shrink-0", priority = false }: BrandLogoProps) {
  return (
    <Image
      src={brandConfig.markSrc}
      alt=""
      width={brandConfig.markWidth}
      height={brandConfig.markHeight}
      className={`object-contain ${className}`}
      priority={priority}
      aria-hidden
    />
  );
}
