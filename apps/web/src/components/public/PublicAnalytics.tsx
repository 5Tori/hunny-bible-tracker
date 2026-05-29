import Script from "next/script";

import { getGaMeasurementId, getGtmId } from "@/lib/analytics-config";

/**
 * Public marketing site analytics only (not loaded on /admin).
 * Prefer GTM when both are configured — GA4 runs as a tag inside the container.
 */
export function PublicAnalytics() {
  const gtmId = getGtmId();
  if (gtmId) {
    return <GoogleTagManager id={gtmId} />;
  }

  const gaId = getGaMeasurementId();
  if (gaId) {
    return <GoogleAnalytics4 id={gaId} />;
  }

  return null;
}

function GoogleTagManager({ id }: { id: string }) {
  return (
    <>
      <Script id="gtm-init" strategy="afterInteractive">
        {`(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','${id}');`}
      </Script>
      <noscript>
        <iframe
          title="Google Tag Manager"
          src={`https://www.googletagmanager.com/ns.html?id=${id}`}
          height="0"
          width="0"
          style={{ display: "none", visibility: "hidden" }}
        />
      </noscript>
    </>
  );
}

function GoogleAnalytics4({ id }: { id: string }) {
  return (
    <>
      <Script src={`https://www.googletagmanager.com/gtag/js?id=${id}`} strategy="afterInteractive" />
      <Script id="ga4-config" strategy="afterInteractive">
        {`window.dataLayer=window.dataLayer||[];
function gtag(){dataLayer.push(arguments);}
gtag('js',new Date());
gtag('config','${id}');`}
      </Script>
    </>
  );
}
