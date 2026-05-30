import { getCloudflareContext } from '@opennextjs/cloudflare';
import postgres from 'postgres';

import { recordDbQuery } from '@/lib/perf/db-timing';

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

const HYPERDRIVE_CLIENT_MAX_AGE_MS = 30_000;

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

async function resolveDatabaseConfig(): Promise<DatabaseConfig> {
  try {
    const { env } = await getCloudflareContext({ async: true });
    const hyperdrive = (env as { HYPERDRIVE?: HyperdriveBinding }).HYPERDRIVE;
    const hyperdriveUrl = hyperdrive?.connectionString?.trim();
    if (hyperdriveUrl && !isPlaceholderDatabaseUrl(hyperdriveUrl)) {
      return { url: hyperdriveUrl, viaHyperdrive: true };
    }
  } catch {
    // next dev / next build — not on the Workers runtime
  }

  const envUrl = process.env.DATABASE_URL?.trim();
  if (envUrl && !isPlaceholderDatabaseUrl(envUrl)) {
    return { url: envUrl, viaHyperdrive: false };
  }

  throw new Error('DATABASE_URL is not set');
}

function createPostgresClient(url: string, viaHyperdrive: boolean) {
  return postgres(normalizeDatabaseUrl(url), {
    max: 1,
    fetch_types: false,
    prepare: false,
    connect_timeout: 5,
    idle_timeout: viaHyperdrive ? 10 : 20,
    max_lifetime: viaHyperdrive ? 30 : 60 * 30,
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
    hyperdriveSqlClient = createPostgresClient(url, true);
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
