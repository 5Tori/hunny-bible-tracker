export type DbQueryStat = {
  durationMs: number;
  sqlPreview: string;
};

export type DbTimingSnapshot = {
  queries: DbQueryStat[];
  totalMs: number;
};

type DbTimingStorage = {
  getStore: () => DbTimingSnapshot | undefined;
  run: <T>(store: DbTimingSnapshot, fn: () => T) => T;
};

let dbTimingStorage: DbTimingStorage | null | undefined;

function getDbTimingStorage(): DbTimingStorage | null {
  if (dbTimingStorage !== undefined) {
    return dbTimingStorage;
  }

  try {
    // Lazy init — avoids hard failures when async_hooks is unavailable.
    const { AsyncLocalStorage } = require('node:async_hooks') as typeof import('node:async_hooks');
    dbTimingStorage = new AsyncLocalStorage<DbTimingSnapshot>();
  } catch {
    dbTimingStorage = null;
  }

  return dbTimingStorage;
}

export function isDbTimingActive(): boolean {
  return getDbTimingStorage()?.getStore() != null;
}

export function getDbTimingSnapshot(): DbTimingSnapshot {
  return getDbTimingStorage()?.getStore() ?? { queries: [], totalMs: 0 };
}

export async function runWithDbTiming<T>(fn: () => Promise<T>): Promise<T> {
  const storage = getDbTimingStorage();
  if (!storage) {
    return fn();
  }

  return storage.run({ queries: [], totalMs: 0 }, fn);
}

export function recordDbQuery(durationMs: number, strings: TemplateStringsArray) {
  const store = getDbTimingStorage()?.getStore();
  if (!store) return;

  const sqlPreview = strings
    .reduce((preview, part, index) => {
      const value = index < strings.length - 1 ? '?' : '';
      return `${preview}${part}${value}`;
    }, '')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, 160);

  store.queries.push({ durationMs, sqlPreview });
  store.totalMs += durationMs;
}
