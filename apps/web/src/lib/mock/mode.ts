import { getPublicRuntimeConfig } from '@/lib/public-runtime-config';

function offlineFlag(value: string | undefined): boolean {
  const flag = value?.trim().toLowerCase();
  return flag === '1' || flag === 'true' || flag === 'yes';
}

/** When true, catalog reads use local fixtures instead of Postgres / Hyperdrive. */
export function isOfflineMode(): boolean {
  if (typeof window !== 'undefined') {
    return getPublicRuntimeConfig().offlineMode;
  }
  return (
    offlineFlag(process.env.HUNNY_OFFLINE_MODE) ||
    offlineFlag(process.env.NEXT_PUBLIC_HUNNY_OFFLINE_MODE)
  );
}

export class OfflineModeError extends Error {
  constructor(message = 'Writes are disabled while HUNNY_OFFLINE_MODE is enabled.') {
    super(message);
    this.name = 'OfflineModeError';
  }
}

export function assertOnlineForWrites() {
  if (isOfflineMode()) {
    throw new OfflineModeError();
  }
}
