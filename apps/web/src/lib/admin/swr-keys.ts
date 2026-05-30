/** Stable SWR cache keys for admin list/read endpoints. */
export const ADMIN_SWR_KEYS = {
  overview: '/api/v1/admin/overview',
  messages: '/api/v1/admin/messages',
  todayMessages: '/api/v1/admin/today-messages',
  plans: '/api/v1/admin/plans',
  content: '/api/v1/admin/content',
} as const;

export type AdminSwrKey = (typeof ADMIN_SWR_KEYS)[keyof typeof ADMIN_SWR_KEYS];
