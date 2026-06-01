import { describe, expect, it } from 'vitest';

import {
  OFFLINE_MOCK_AUTH_TOKEN,
  OFFLINE_MOCK_USER,
  isOfflineMockAuthToken,
} from '@/lib/auth/offline-mock-auth';

describe('offline mock auth', () => {
  it('recognizes demo bearer token', () => {
    expect(isOfflineMockAuthToken(OFFLINE_MOCK_AUTH_TOKEN)).toBe(true);
    expect(isOfflineMockAuthToken('other')).toBe(false);
  });

  it('exposes stable demo user', () => {
    expect(OFFLINE_MOCK_USER.email).toBe('demo@local.hunny');
  });
});
