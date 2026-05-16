const plans = [
  {
    title: "Joseph’s Story",
    label: "Genesis journey",
    description: "Dreams, betrayal, waiting, and forgiveness in a story that keeps moving.",
    meta: "Story-led · Beginner friendly",
  },
  {
    title: "Jonah’s Story",
    label: "Short book",
    description: "A compact, surprising story about running, returning, and mercy.",
    meta: "4 chapters · Easy start",
  },
  {
    title: "Zacchaeus’ Story",
    label: "One encounter",
    description: "A short moment with Jesus that turns into a meaningful new beginning.",
    meta: "Mini plan · Quick read",
  },
];

export default function PlansSection() {
  return (
    <section id="plans" className="hb-section hb-section--warm">
      <div className="hb-container">
        <div className="hb-section-header">
          <p className="hb-kicker">Story-led plans</p>
          <h2>Start with a story that draws you in.</h2>
          <p>
            Read Joseph, Jonah, Zacchaeus, and other short plans before moving into
            longer reading journeys. Later, explore stories like Samuel’s childhood.
          </p>
        </div>

        <div className="hb-plan-grid">
          {plans.map((plan, index) => (
            <article className="hb-plan-card" key={plan.title}>
              <div className="hb-plan-card__number">0{index + 1}</div>
              <p className="hb-plan-card__label">{plan.label}</p>
              <h3>{plan.title}</h3>
              <p>{plan.description}</p>
              <span>{plan.meta}</span>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
