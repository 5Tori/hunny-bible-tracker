import { getCloudflareContext } from '@opennextjs/cloudflare';
import postgres from 'postgres';

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

let cachedConfigKey: string | null = null;
let localSqlClient: ReturnType<typeof postgres> | null = null;
let hyperdriveSqlClient: ReturnType<typeof postgres> | null = null;
let hyperdriveConfigKey: string | null = null;

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

function getDatabaseConfig(): DatabaseConfig {
  try {
    const { env } = getCloudflareContext();
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

function createPostgresClient(config: DatabaseConfig, url: string) {
  return postgres(
    url,
    config.viaHyperdrive
      ? {
          max: 1,
          fetch_types: false,
          prepare: false,
          connect_timeout: 10,
        }
      : {
          max: 1,
          prepare: false,
          connect_timeout: 15,
          ssl: 'require',
        },
  );
}

function resetHyperdriveClient() {
  hyperdriveSqlClient = null;
  hyperdriveConfigKey = null;
}

function isConnectionError(error: unknown): boolean {
  const message = error instanceof Error ? error.message : String(error);
  return (
    message.includes('CONNECTION_CLOSED') ||
    message.includes('Connection terminated') ||
    message.includes('connection timeout') ||
    message.includes('ECONNRESET')
  );
}

function getClient() {
  const config = getDatabaseConfig();
  const url = normalizeDatabaseUrl(config.url);

  if (config.viaHyperdrive) {
    const configKey = `hyperdrive:${url}`;
    if (!hyperdriveSqlClient || hyperdriveConfigKey !== configKey) {
      hyperdriveSqlClient = createPostgresClient(config, url);
      hyperdriveConfigKey = configKey;
    }
    return hyperdriveSqlClient;
  }

  const configKey = `direct:${url}`;
  if (!localSqlClient || cachedConfigKey !== configKey) {
    localSqlClient = createPostgresClient(config, url);
    cachedConfigKey = configKey;
  }
  return localSqlClient;
}

function makeTagged(executor: SqlExecutor): SqlExecutor {
  return ((strings, ...values) => executor(strings, ...values)) as SqlExecutor;
}

async function runQuery<T>(
  strings: TemplateStringsArray,
  values: unknown[],
): Promise<T> {
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      const client = getClient();
      return (await client(strings, ...(values as never[]))) as T;
    } catch (error) {
      if (attempt === 0 && getDatabaseConfig().viaHyperdrive && isConnectionError(error)) {
        resetHyperdriveClient();
        continue;
      }
      throw error;
    }
  }
  throw new Error('SQL query failed');
}

async function runTransaction(fn: (txn: SqlExecutor) => readonly unknown[]) {
  const client = getClient();
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
