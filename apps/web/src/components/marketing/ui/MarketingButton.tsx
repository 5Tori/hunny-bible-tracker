import Link from "next/link";
import type { ComponentProps, ReactNode } from "react";

const base =
  "inline-flex min-h-11 items-center justify-center rounded-xl px-5 text-sm font-medium transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-900";

const variants = {
  primary: `${base} bg-neutral-900 text-white hover:bg-black`,
  secondary: `${base} border border-neutral-200 bg-white text-neutral-900 hover:bg-neutral-50`,
  ghost: `${base} text-neutral-600 hover:text-neutral-900`,
} as const;

export function MarketingButton({
  children,
  variant = "primary",
  className = "",
  href,
  ...props
}: {
  children: ReactNode;
  variant?: keyof typeof variants;
  className?: string;
  href?: string;
} & Omit<ComponentProps<"button">, "children">) {
  const classes = `${variants[variant]} ${className}`;

  if (href) {
    return (
      <Link href={href} className={classes}>
        {children}
      </Link>
    );
  }

  return (
    <button type="button" className={classes} {...props}>
      {children}
    </button>
  );
}
