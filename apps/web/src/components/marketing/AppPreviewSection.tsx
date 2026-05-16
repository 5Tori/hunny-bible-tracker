const previews = [
  {
    title: "Home",
    lines: ["Today’s Message", "Continue Joseph’s Story", "A quiet moment for Scripture"],
  },
  {
    title: "Plans",
    lines: ["Joseph", "Jonah", "Zacchaeus"],
  },
  {
    title: "Progress",
    lines: ["12 chapters read", "2 plans completed", "Pick up where you left off"],
  },
];

export default function AppPreviewSection() {
  return (
    <section className="hb-section hb-section--soft">
      <div className="hb-container">
        <div className="hb-section-header">
          <p className="hb-kicker">App preview</p>
          <h2>A calm, focused reading experience.</h2>
          <p>
            These are CSS-only screenshot placeholders. Replace them with real mobile
            app screenshots when your store assets are ready.
          </p>
        </div>

        <div className="hb-preview-grid">
          {previews.map((preview) => (
            <div className="hb-phone" key={preview.title} aria-label={`Screenshot placeholder — ${preview.title}`}>
              <div className="hb-phone__screen">
                <div className="hb-phone__topbar">
                  <span />
                  <span />
                </div>
                <div className="hb-preview-card hb-preview-card--highlight">
                  <small>Screenshot placeholder</small>
                  <strong>{preview.title}</strong>
                </div>
                <div className="hb-mini-list">
                  {preview.lines.map((line) => (
                    <span key={line}>{line}</span>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
