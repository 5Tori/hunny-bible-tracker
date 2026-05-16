import { siteConfig } from "@/lib/site-config";

const trustItems = ["Short story-led plans", "Offline-first progress", "No guilt", "Beginner friendly"];

export default function HeroSection() {
  return (
    <section className="hb-hero">
      <div className="hb-hero__glow" aria-hidden />
      <div className="hb-container hb-hero__grid">
        <div className="hb-hero__copy">
          <p className="hb-kicker">Gentle Bible reading tracker</p>
          <h1>Bible reading, without the overwhelm.</h1>
          <p className="hb-lead">
            Start with short, approachable Bible stories, track your progress, and build a
            reading habit at your own pace.
          </p>

          <div className="hb-cta-row">
            <a href={siteConfig.googlePlayUrl} className="hb-button hb-button--dark">
              Get it on Google Play
            </a>
            <span className="hb-button hb-button--soft" aria-disabled="true" role="note">
              {siteConfig.iosStatusLabel}
            </span>
          </div>

          <div className="hb-trust-strip" aria-label="Product highlights">
            {trustItems.map((item) => (
              <span key={item}>
                <i aria-hidden />
                {item}
              </span>
            ))}
          </div>
        </div>

        <div className="hb-hero__visual" aria-label="App preview placeholder">
          <div className="hb-phone hb-phone--hero">
            <div className="hb-phone__screen">
              <div className="hb-phone__topbar">
                <span />
                <span />
              </div>
              <div className="hb-preview-card hb-preview-card--highlight">
                <small>Today’s gentle start</small>
                <strong>Joseph’s Story</strong>
                <p>Begin with one chapter today.</p>
              </div>
              <div className="hb-progress-line">
                <span style={{ width: "46%" }} />
              </div>
              <div className="hb-mini-list">
                <span>Genesis 37</span>
                <span>Genesis 39</span>
                <span>Genesis 40</span>
              </div>
            </div>
          </div>
          <div className="hb-floating-card hb-floating-card--left">
            <strong>46%</strong>
            <span>Plan progress</span>
          </div>
          <div className="hb-floating-card hb-floating-card--right">
            <strong>3</strong>
            <span>Stories ready</span>
          </div>
        </div>
      </div>
    </section>
  );
}
