import { AsyncLocalStorage } from 'node:async_hooks';

export type DbQueryStat = {
  durationMs: number;
  sqlPreview: string;
};

export type DbTimingSnapshot = {
  queries: DbQueryStat[];
  totalMs: number;
};

const dbTimingStorage = new AsyncLocalStorage<DbTimingSnapshot>();

export function isDbTimingActive(): boolean {
  return dbTimingStorage.getStore() != null;
}

export function getDbTimingSnapshot(): DbTimingSnapshot {
  return dbTimingStorage.getStore() ?? { queries: [], totalMs: 0 };
}

export async function runWithDbTiming<T>(fn: () => Promise<T>): Promise<T> {
  return dbTimingStorage.run({ queries: [], totalMs: 0 }, fn);
}

export function recordDbQuery(durationMs: number, strings: TemplateStringsArray) {
  const store = dbTimingStorage.getStore();
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
