import { getCloudflareContext } from '@opennextjs/cloudflare';
import postgres from 'postgres';

import { recordDbQuery } from '@/lib/perf/db-timing';
import { isOfflineMode } from '@/lib/mock/mode';

export type SqlExecutor = {
  <T = unknown>(
    strings: TemplateStringsArray,
    ...values: unknown[]
  ): Promise<T>;
};

type SqlClient = SqlExecutor & {
  transaction: (
    fn: (txn: SqlExecutor) => readonly unknown[],
  ) => Promise<void>;
};

type HyperdriveBinding = {
  connectionString: string;
};

let localSqlClient: ReturnType<typeof postgres> | null = null;
let localConfigKey: string | null = null;
let hyperdriveSqlClient: ReturnType<typeof postgres> | null = null;
let hyperdriveConfigKey: string | null = null;
let hyperdriveClientCreatedAt = 0;

const HYPERDRIVE_CLIENT_MAX_AGE_MS = 5 * 60_000;

function isPlaceholderDatabaseUrl(url: string): boolean {
  return url.includes('REPLACE_');
}

function normalizeDatabaseUrl(url: string): string {
  const trimmed = url.trim();
  if (trimmed.includes(':6543/') && !trimmed.includes('pgbouncer=true')) {
    return `${trimmed}${trimmed.includes('?') ? '&' : '?'}pgbouncer=true`;
  }
  return trimmed;
}

type DatabaseConfig = {
  url: string;
  viaHyperdrive: boolean;
};

let resolvedConfig: DatabaseConfig | null = null;

async function resolveDatabaseConfig(): Promise<DatabaseConfig> {
  if (resolvedConfig) {
    return resolvedConfig;
  }

  try {
    const { env } = await getCloudflareContext({ async: true });
    const hyperdrive = (env as { HYPERDRIVE?: HyperdriveBinding }).HYPERDRIVE;
    const hyperdriveUrl = hyperdrive?.connectionString?.trim();
    if (hyperdriveUrl && !isPlaceholderDatabaseUrl(hyperdriveUrl)) {
      resolvedConfig = { url: hyperdriveUrl, viaHyperdrive: true };
      return resolvedConfig;
    }
  } catch {
    // next dev / next build — not on the Workers runtime
  }

  const envUrl = process.env.DATABASE_URL?.trim();
  if (envUrl && !isPlaceholderDatabaseUrl(envUrl)) {
    resolvedConfig = { url: envUrl, viaHyperdrive: false };
    return resolvedConfig;
  }

  throw new Error('DATABASE_URL is not set');
}

function createPostgresClient(url: string, viaHyperdrive: boolean) {
  return postgres(normalizeDatabaseUrl(url), {
    max: 1,
    fetch_types: false,
    prepare: false,
    connect_timeout: viaHyperdrive ? 4 : 5,
    idle_timeout: viaHyperdrive ? 120 : 20,
    max_lifetime: viaHyperdrive ? 600 : 60 * 30,
    ...(viaHyperdrive ? {} : { ssl: 'require' as const }),
  });
}

function resetHyperdriveClient() {
  hyperdriveSqlClient?.end({ timeout: 1 }).catch(() => {});
  hyperdriveSqlClient = null;
  hyperdriveConfigKey = null;
  hyperdriveClientCreatedAt = 0;
}

function isConnectionError(error: unknown): boolean {
  const message = error instanceof Error ? error.message : String(error);
  return (
    message.includes('CONNECTION_CLOSED') ||
    message.includes('Connection terminated') ||
    message.includes('connection timeout') ||
    message.includes('CONNECT_TIMEOUT') ||
    message.includes('ECONNRESET') ||
    message.includes('ECONNREFUSED')
  );
}

async function warmHyperdriveClient(client: ReturnType<typeof postgres>) {
  await client`select 1 as ok`;
}

function getLocalClient(config: DatabaseConfig) {
  const url = normalizeDatabaseUrl(config.url);
  const configKey = `direct:${url}`;
  if (!localSqlClient || localConfigKey !== configKey) {
    localSqlClient?.end({ timeout: 1 }).catch(() => {});
    localSqlClient = createPostgresClient(url, false);
    localConfigKey = configKey;
  }
  return localSqlClient;
}

async function getHyperdriveClient(config: DatabaseConfig) {
  const url = normalizeDatabaseUrl(config.url);
  const configKey = `hyperdrive:${url}`;
  const clientAge = Date.now() - hyperdriveClientCreatedAt;
  const clientExpired =
    !hyperdriveSqlClient ||
    hyperdriveConfigKey !== configKey ||
    clientAge > HYPERDRIVE_CLIENT_MAX_AGE_MS;

  if (clientExpired) {
    resetHyperdriveClient();
    const client = createPostgresClient(url, true);
    try {
      await warmHyperdriveClient(client);
    } catch (error) {
      client.end({ timeout: 1 }).catch(() => {});
      throw error;
    }
    hyperdriveSqlClient = client;
    hyperdriveConfigKey = configKey;
    hyperdriveClientCreatedAt = Date.now();
  }

  return hyperdriveSqlClient!;
}

async function getClient(config: DatabaseConfig) {
  return config.viaHyperdrive ? getHyperdriveClient(config) : getLocalClient(config);
}

function makeTagged(executor: SqlExecutor): SqlExecutor {
  return ((strings, ...values) => executor(strings, ...values)) as SqlExecutor;
}

async function runQuery<T>(
  strings: TemplateStringsArray,
  values: unknown[],
): Promise<T> {
  if (isOfflineMode()) {
    throw new Error(
      'Database access is disabled while HUNNY_OFFLINE_MODE is enabled. Public catalog reads should use mock fixtures.',
    );
  }

  const config = await resolveDatabaseConfig();

  for (let attempt = 0; attempt < 2; attempt++) {
    const queryStarted = performance.now();
    try {
      const client = await getClient(config);
      const result = (await client(strings, ...(values as never[]))) as T;
      recordDbQuery(performance.now() - queryStarted, strings);
      return result;
    } catch (error) {
      recordDbQuery(performance.now() - queryStarted, strings);
      if (attempt === 0 && config.viaHyperdrive && isConnectionError(error)) {
        resetHyperdriveClient();
        continue;
      }
      throw error;
    }
  }

  throw new Error('SQL query failed');
}

async function runTransaction(fn: (txn: SqlExecutor) => readonly unknown[]) {
  const config = await resolveDatabaseConfig();
  const client = await getClient(config);
  await client.begin(async (txn) => {
    const txnSql = makeTagged(txn as unknown as SqlExecutor);
    const batch = fn(txnSql);
    for (const query of batch) {
      if (query != null) {
        await query;
      }
    }
  });
}

const sql: SqlClient = Object.assign(
  ((strings: TemplateStringsArray, ...values: unknown[]) =>
    runQuery(strings, values)) as SqlExecutor,
  {
    transaction: runTransaction,
  },
);

export { sql };
export type SqlLike = SqlExecutor;

type PostgresClient = ReturnType<typeof postgres>;

/** Hyperdrive-safe UUID list filters (avoid ANY/unnest single-element binding bugs). */
export async function queryByUuidIds<T>(
  ids: string[],
  querySingle: (id: string) => Promise<T[]>,
  queryMultiple: (pg: PostgresClient, ids: string[]) => Promise<T[]>,
): Promise<T[]> {
  if (ids.length === 0) {
    return [];
  }
  if (ids.length === 1) {
    return querySingle(ids[0]!);
  }
  const config = await resolveDatabaseConfig();
  const pg = await getClient(config);
  return queryMultiple(pg, ids);
}
