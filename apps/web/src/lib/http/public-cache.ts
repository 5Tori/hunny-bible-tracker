import { NextResponse } from 'next/server';

/** ISR + CDN cache window for public catalog surfaces (5 minutes). */
export const PUBLIC_CATALOG_REVALIDATE_SECONDS = 300;

export const PUBLIC_CATALOG_CACHE_CONTROL =
  'public, s-maxage=300, stale-while-revalidate=600';

export function jsonWithPublicCache<T>(
  body: T,
  init?: ResponseInit,
): NextResponse {
  const headers = new Headers(init?.headers);
  headers.set('Cache-Control', PUBLIC_CATALOG_CACHE_CONTROL);
  return NextResponse.json(body, { ...init, headers });
}
