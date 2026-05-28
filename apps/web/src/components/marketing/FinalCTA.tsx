import { AndroidTesterCta } from "@/components/public/AndroidTesterCta";
import { siteConfig } from "@/lib/site-config";

export default function FinalCTA() {
  return (
    <section className="hb-section hb-final-section">
      <div className="hb-container">
        <div className="hb-final-card">
          <p className="hb-kicker">Ready when you are</p>
          <h2>Start small. Discover the stories. Keep reading gently.</h2>
          <p>
            Begin with a short plan and build your Bible reading habit one chapter at a time.
          </p>
          <div className="hb-cta-row hb-cta-row--center">
            <AndroidTesterCta variant="hb" />
            <span className="hb-button hb-button--light" aria-disabled="true" role="note">
              {siteConfig.iosStatusLabel}
            </span>
          </div>
        </div>
      </div>
    </section>
  );
}
