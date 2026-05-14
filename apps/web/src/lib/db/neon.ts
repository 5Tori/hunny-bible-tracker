import { neon } from '@neondatabase/serverless';

let sqlClient: ReturnType<typeof neon> | null = null;

function getSqlClient() {
  const url = process.env.DATABASE_URL;
  if (!url?.trim()) {
    throw new Error('DATABASE_URL is not set');
  }

  if (!sqlClient) {
    sqlClient = neon(url.trim());
  }

  return sqlClient;
}

function sqlProxy(...args: any[]) {
  const client = getSqlClient() as any;
  if (args.length === 0) {
    return client;
  }
  return client(...args);
}

const sql = new Proxy(sqlProxy, {
  get(_target, property) {
    const client = getSqlClient() as any;
    const value = client[property];
    return typeof value === 'function' ? value.bind(client) : value;
  },
}) as any;

export { sql };
