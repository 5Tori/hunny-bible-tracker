/** GA4 measurement ID (e.g. G-8RSLHM5PHV). Ignored when GTM is set — configure GA4 inside GTM instead. */
export function getGaMeasurementId(): string | null {
  const id = process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID?.trim();
  return id || null;
}

/** GTM container ID (e.g. GTM-XXXXXXX). When set, only GTM loads (no direct gtag). */
export function getGtmId(): string | null {
  const id = process.env.NEXT_PUBLIC_GTM_ID?.trim();
  return id || null;
}

/** Google Search Console HTML tag verification content value. */
export function getGoogleSiteVerification(): string | null {
  const token = process.env.NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION?.trim();
  return token || null;
}

export function shouldLoadPublicAnalytics(): boolean {
  return Boolean(getGtmId() || getGaMeasurementId());
}
