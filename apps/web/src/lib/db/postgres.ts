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
let sqlClient: ReturnType<typeof postgres> | null = null;

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

async function getDatabaseConfig(): Promise<DatabaseConfig> {
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

async function getClient() {
  const config = await getDatabaseConfig();
  const url = normalizeDatabaseUrl(config.url);
  const configKey = `${config.viaHyperdrive ? 'hyperdrive' : 'direct'}:${url}`;

  if (!sqlClient || cachedConfigKey !== configKey) {
    // Hyperdrive: use the binding connection string as-is (no client-side ssl).
    // Direct/local pooler: ssl required for Supabase.
    sqlClient = postgres(
      url,
      config.viaHyperdrive
        ? {
            max: 5,
            fetch_types: false,
            prepare: false,
            connect_timeout: 15,
          }
        : {
            max: 1,
            prepare: false,
            connect_timeout: 15,
            ssl: 'require',
          },
    );
    cachedConfigKey = configKey;
  }
  return sqlClient;
}

function makeTagged(executor: SqlExecutor): SqlExecutor {
  return ((strings, ...values) => executor(strings, ...values)) as SqlExecutor;
}

async function runTransaction(fn: (txn: SqlExecutor) => readonly unknown[]) {
  const client = await getClient();
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
    getClient().then((client) => client(strings, ...(values as never[])))) as SqlExecutor,
  {
    transaction: runTransaction,
  },
);

export { sql };
export type SqlLike = SqlExecutor;
