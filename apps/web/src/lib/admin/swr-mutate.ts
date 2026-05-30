import { mutate } from 'swr';

import { ADMIN_SWR_KEYS } from '@/lib/admin/swr-keys';

export function revalidateAdminOverview() {
  return mutate(ADMIN_SWR_KEYS.overview);
}

export function revalidateAdminMessages() {
  return mutate(ADMIN_SWR_KEYS.messages);
}

export function revalidateAdminTodayMessages() {
  return mutate(ADMIN_SWR_KEYS.todayMessages);
}

export function revalidateAdminPlans() {
  return mutate(ADMIN_SWR_KEYS.plans);
}

export function revalidateAdminContent() {
  return mutate(ADMIN_SWR_KEYS.content);
}

/** Invalidate list caches affected by message card edits. */
export function revalidateAdminMessageCatalog() {
  return Promise.all([revalidateAdminMessages(), revalidateAdminOverview()]);
}

/** Invalidate caches affected by Today slot edits. */
export function revalidateAdminTodayCatalog() {
  return Promise.all([revalidateAdminTodayMessages(), revalidateAdminOverview()]);
}
