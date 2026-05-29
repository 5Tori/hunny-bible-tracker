import type { ReactNode } from "react";

export function MarketingContainer({
  children,
  className = "",
  narrow = false,
}: {
  children: ReactNode;
  className?: string;
  narrow?: boolean;
}) {
  return (
    <div
      className={`mx-auto w-full px-6 ${narrow ? "max-w-3xl" : "max-w-[68rem]"} ${className}`}
    >
      {children}
    </div>
  );
}
