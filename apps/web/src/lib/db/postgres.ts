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

let cachedUrl: string | null = null;
let sqlClient: ReturnType<typeof postgres> | null = null;

function isPlaceholderDatabaseUrl(url: string): boolean {
  return url.includes('REPLACE_');
}

async function getDatabaseUrl(): Promise<string> {
  const envUrl = process.env.DATABASE_URL?.trim();
  if (envUrl && !isPlaceholderDatabaseUrl(envUrl)) {
    return envUrl;
  }

  try {
    const { env } = await getCloudflareContext({ async: true });
    const hyperdrive = (env as { HYPERDRIVE?: HyperdriveBinding }).HYPERDRIVE;
    const hyperdriveUrl = hyperdrive?.connectionString?.trim();
    if (hyperdriveUrl && !isPlaceholderDatabaseUrl(hyperdriveUrl)) {
      return hyperdriveUrl;
    }
  } catch {
    // next dev / next build — not on the Workers runtime
  }

  if (envUrl) {
    return envUrl;
  }
  throw new Error('DATABASE_URL is not set');
}

async function getClient() {
  const url = await getDatabaseUrl();
  if (!sqlClient || cachedUrl !== url) {
    sqlClient = postgres(url, {
      max: 1,
      prepare: false,
      connect_timeout: 30,
    });
    cachedUrl = url;
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
