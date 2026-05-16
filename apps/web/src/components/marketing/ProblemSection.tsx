const points = [
  "Start with one approachable story",
  "Read at your own pace",
  "Come back without feeling behind",
];

export default function ProblemSection() {
  return (
    <section className="hb-section hb-section--tight">
      <div className="hb-container hb-split-card">
        <div>
          <p className="hb-kicker">The problem</p>
          <h2>The Bible can feel overwhelming when you don’t know where to begin.</h2>
        </div>
        <div>
          <p className="hb-section-lead">
            Hunny helps you start with short, approachable reading plans—one story at a time.
          </p>
          <div className="hb-check-list">
            {points.map((point) => (
              <span key={point}>
                <i aria-hidden>✓</i>
                {point}
              </span>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
