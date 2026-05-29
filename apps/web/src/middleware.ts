import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

import {
  getMiddlewareCanonicalHost,
  LEGACY_WORKER_HOST,
} from "@/lib/site-config";

function shouldRedirectToCanonicalHost(host: string, canonicalHost: string): boolean {
  if (!host) return false;
  if (host === LEGACY_WORKER_HOST) return true;
  if (host === `www.${canonicalHost}`) return true;
  return false;
}

export function middleware(request: NextRequest) {
  const host = request.headers.get("host")?.split(":")[0]?.toLowerCase() ?? "";

  const canonicalHost = getMiddlewareCanonicalHost();

  if (!shouldRedirectToCanonicalHost(host, canonicalHost)) {
    return NextResponse.next();
  }
  const destination = request.nextUrl.clone();
  destination.protocol = "https:";
  destination.host = canonicalHost;

  return NextResponse.redirect(destination, 301);
}

export const config = {
  matcher: [
    /*
     * Skip static assets and Next internals; apply to public pages, admin, and API paths
     * so workers.dev API calls also consolidate on the custom domain.
     */
    "/((?!_next/static|_next/image|favicon.ico|icon.png|apple-icon.png|android-tester/|.*\\.(?:svg|png|jpg|jpeg|gif|webp|ico)$).*)",
  ],
};
