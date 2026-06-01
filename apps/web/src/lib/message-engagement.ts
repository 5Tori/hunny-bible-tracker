export interface MessageEngagementCounts {
  heartCount: number;
  shareCount: number;
  saveCount: number;
}

export type MessageEngagementField = keyof MessageEngagementCounts;

function asCount(value: unknown): number {
  const parsed = typeof value === 'number' ? value : Number(value);
  if (!Number.isFinite(parsed) || parsed < 0) return 0;
  return Math.floor(parsed);
}

export function parseMessageEngagement(
  raw: Record<string, unknown> | null | undefined,
): MessageEngagementCounts {
  const source = raw ?? {};
  return {
    heartCount: asCount(source.heartCount ?? source.heart_count),
    shareCount: asCount(source.shareCount ?? source.share_count),
    saveCount: asCount(source.saveCount ?? source.save_count),
  };
}

export function formatEngagementCount(value: number) {
  if (value >= 1_000_000) return `${(value / 1_000_000).toFixed(1)}m`;
  if (value >= 1_000) return `${(value / 1_000).toFixed(1)}k`;
  return String(value);
}
