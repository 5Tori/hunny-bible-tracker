'use client';

import useSWR from 'swr';

import type { AdminOverview } from '@/lib/admin/overview';
import { adminSwrFetcher } from '@/lib/admin/swr-fetcher';
import { ADMIN_SWR_KEYS } from '@/lib/admin/swr-keys';
import type { AdminContentListItem, ContentWithRelations } from '@/lib/content';
import type { AdminDiscoverListItem } from '@/lib/discover-content';
import type { PlanTemplateBase } from '@/lib/plans';
import type { TodayMessageBase } from '@/lib/today-messages';

const adminListConfig = {
  revalidateOnFocus: true,
  dedupingInterval: 5_000,
  keepPreviousData: true,
} as const;

export function useAdminOverview() {
  return useSWR<{ overview: AdminOverview }>(
    ADMIN_SWR_KEYS.overview,
    adminSwrFetcher,
    adminListConfig,
  );
}

export function useAdminMessages() {
  return useSWR<{ messages: AdminContentListItem[] }>(
    ADMIN_SWR_KEYS.messages,
    adminSwrFetcher,
    adminListConfig,
  );
}

export function useAdminTodayMessages() {
  return useSWR<{ messages: TodayMessageBase[] }>(
    ADMIN_SWR_KEYS.todayMessages,
    adminSwrFetcher,
    adminListConfig,
  );
}

export function useAdminPlans() {
  return useSWR<{ plans: PlanTemplateBase[] }>(
    ADMIN_SWR_KEYS.plans,
    adminSwrFetcher,
    adminListConfig,
  );
}

export function useAdminContent() {
  return useSWR<{ contents: ContentWithRelations[] }>(
    ADMIN_SWR_KEYS.content,
    adminSwrFetcher,
    adminListConfig,
  );
}

export function useAdminDiscover() {
  return useSWR<{ items: AdminDiscoverListItem[] }>(
    ADMIN_SWR_KEYS.discover,
    adminSwrFetcher,
    adminListConfig,
  );
}
