import type { ReactNode } from "react";

export function MarketingProse({ children }: { children: ReactNode }) {
  return <div className="mkt-prose">{children}</div>;
}
