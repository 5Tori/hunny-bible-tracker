import type {
  ContentAuthor,
  ContentAsset,
  ContentBase,
  ContentRelatedPlan,
  ContentSection,
  ContentTag,
  ContentWithRelations,
  PublishedContentSortMode,
} from '@/lib/content';
import type { PlanTemplateBase, PublishedPlanSortMode } from '@/lib/plans';
import { isOfflineMode } from '@/lib/mock/mode';
import { getSupabaseAnonClient, isSupabaseAnonConfigured } from '@/lib/supabase/server-anon';

export function isCatalogRpcAvailable() {
  return !isOfflineMode() && isSupabaseAnonConfigured();
}

export async function callCatalogRpc<T>(
  fn: string,
  args: Record<string, unknown>,
): Promise<T | null> {
  const client = getSupabaseAnonClient();
  const { data, error } = await client.rpc(fn, args);
  if (error) {
    throw new Error(`catalog rpc ${fn} failed: ${error.message}`);
  }
  return (data ?? null) as T | null;
}

export function parseRpcContentWithRelations(value: unknown): ContentWithRelations | null {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return null;
  }

  const row = value as Record<string, unknown>;
  if (typeof row.id !== 'string' || typeof row.slug !== 'string') {
    return null;
  }

  const content = row as unknown as ContentBase;

  return {
    ...content,
    metadata: (content.metadata ?? {}) as Record<string, unknown>,
    author: (row.author as ContentAuthor | null) ?? null,
    assets: Array.isArray(row.assets) ? (row.assets as ContentAsset[]) : [],
    sections: Array.isArray(row.sections) ? (row.sections as ContentSection[]) : [],
    tags: Array.isArray(row.tags) ? (row.tags as ContentTag[]) : [],
    related_plans: Array.isArray(row.related_plans)
      ? (row.related_plans as ContentRelatedPlan[])
      : [],
  };
}

export async function fetchDiscoverContentListRpc(options?: {
  sort?: PublishedContentSortMode;
  type?: string | null;
  language?: string | null;
  tag?: string | null;
  limit?: number;
}) {
  const language = (options?.language?.trim().toLowerCase() || 'en').slice(0, 16);
  const type = options?.type?.trim().toLowerCase() || null;
  const tag = options?.tag?.trim().toLowerCase() || null;
  const limit = Math.min(Math.max(options?.limit ?? 20, 1), 50);

  const payload = await callCatalogRpc<unknown[]>('mobile_content_list', {
    p_language: language,
    p_sort: options?.sort === 'new' ? 'new' : 'featured',
    p_type: type,
    p_tag: tag,
    p_limit: limit,
  });

  if (!Array.isArray(payload)) {
    return [];
  }

  return payload
    .map((row) => parseRpcContentWithRelations(row))
    .filter((row): row is ContentWithRelations => row != null);
}

export async function fetchContentDetailRpc(identifier: string, language?: string | null) {
  const normalizedIdentifier = identifier.trim();
  const normalizedLanguage = (language?.trim().toLowerCase() || 'en').slice(0, 16);
  if (!normalizedIdentifier) return null;

  const payload = await callCatalogRpc<unknown>('mobile_content_detail', {
    p_identifier: normalizedIdentifier,
    p_language: normalizedLanguage,
  });

  return parseRpcContentWithRelations(payload);
}

export async function fetchPlanCatalogRpc(sort: PublishedPlanSortMode = 'featured') {
  const payload = await callCatalogRpc<PlanTemplateBase[]>('mobile_plan_catalog', {
    p_sort: sort,
  });

  return Array.isArray(payload) ? payload : [];
}

export async function fetchMessageListRpc(options?: {
  language?: string | null;
  category?: string | null;
  situation?: string | null;
  tag?: string | null;
  tone?: string | null;
  q?: string | null;
  limit?: number;
}) {
  const language = (options?.language?.trim().toLowerCase() || 'en').slice(0, 16);
  const normalizeKey = (value?: string | null) => {
    const trimmed = value?.trim().toLowerCase();
    return trimmed ? trimmed : null;
  };

  const payload = await callCatalogRpc<unknown[]>('mobile_message_list', {
    p_language: language,
    p_category: normalizeKey(options?.category),
    p_situation: normalizeKey(options?.situation),
    p_tag: normalizeKey(options?.tag),
    p_tone: normalizeKey(options?.tone),
    p_q: options?.q?.trim() || null,
    p_limit: options?.limit ?? 48,
  });

  return Array.isArray(payload) ? payload : [];
}

export async function fetchMessageDetailRpc(slug: string, language?: string | null) {
  const normalizedSlug = slug.trim();
  const normalizedLanguage = (language?.trim().toLowerCase() || 'en').slice(0, 16);
  if (!normalizedSlug) return null;

  return callCatalogRpc<unknown>('mobile_message_detail', {
    p_identifier: normalizedSlug,
    p_language: normalizedLanguage,
  });
}

export async function fetchTodayMessageLatestRpc(options?: { date?: string; language?: string }) {
  const language = (options?.language?.trim().toLowerCase() || 'en').slice(0, 16);
  const date = options?.date?.trim() || new Date().toISOString().slice(0, 10);

  return callCatalogRpc<Record<string, unknown>>('mobile_today_message_latest', {
    p_language: language,
    p_date: date,
  });
}
