import { neon } from '@neondatabase/serverless';

let sqlClient: ReturnType<typeof neon> | null = null;

export function sql() {
  const url = process.env.DATABASE_URL;
  if (!url?.trim()) {
    throw new Error('DATABASE_URL is not set');
  }
  if (!sqlClient) {
    sqlClient = neon(url.trim());
  }
  return sqlClient;
}
