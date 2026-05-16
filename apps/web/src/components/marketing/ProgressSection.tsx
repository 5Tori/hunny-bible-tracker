const progressItems = [
  {
    title: "Chapter progress",
    body: "Mark chapters as you read and see each plan move forward.",
  },
  {
    title: "Completed plans",
    body: "Keep a simple history of the stories and journeys you’ve finished.",
  },
  {
    title: "Reading journey",
    body: "Watch your habit build slowly through small, consistent steps.",
  },
  {
    title: "Gentle return",
    body: "Pick up where you left off without pressure or streak shame.",
  },
];

export default function ProgressSection() {
  return (
    <section id="progress" className="hb-section">
      <div className="hb-container hb-progress-layout">
        <div className="hb-section-header hb-section-header--left">
          <p className="hb-kicker">Progress</p>
          <h2>Track your progress, one chapter at a time.</h2>
          <p>
            See what you’ve read, what you’ve finished, and how your reading habit is
            growing over time.
          </p>
        </div>

        <div className="hb-progress-grid">
          {progressItems.map((item) => (
            <article className="hb-feature-card" key={item.title}>
              <span className="hb-feature-card__icon" aria-hidden />
              <h3>{item.title}</h3>
              <p>{item.body}</p>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
