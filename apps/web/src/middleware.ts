import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";

import { getCanonicalHost, LEGACY_WORKER_HOST } from "@/lib/site-config";

function shouldRedirectToCanonicalHost(host: string): boolean {
  if (!host) return false;
  if (host === LEGACY_WORKER_HOST) return true;
  if (host === `www.${getCanonicalHost()}`) return true;
  return false;
}

export function middleware(request: NextRequest) {
  const host = request.headers.get("host")?.split(":")[0]?.toLowerCase() ?? "";

  if (!shouldRedirectToCanonicalHost(host)) {
    return NextResponse.next();
  }

  const canonicalHost = getCanonicalHost();
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
    "/((?!_next/static|_next/image|favicon.ico|icon.png|apple-icon.png|.*\\.(?:svg|png|jpg|jpeg|gif|webp|ico)$).*)",
  ],
};
