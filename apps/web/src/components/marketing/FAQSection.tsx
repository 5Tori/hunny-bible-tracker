const faqs = [
  {
    question: "Is Hunny Bible Tracker a Bible reader?",
    answer:
      "Hunny is mainly a Bible reading tracker. It helps you choose reading plans, track chapters, and build a reading habit. It does not store full Bible text in the app.",
  },
  {
    question: "Do I need an account?",
    answer:
      "You can start using the app locally. Sign-in may be used for backup and restore features.",
  },
  {
    question: "Who is this app for?",
    answer:
      "Hunny is designed for people who want to read the Bible more consistently but feel unsure where to start.",
  },
  {
    question: "Does it work offline?",
    answer:
      "The app is designed with an offline-first reading progress experience.",
  },
  {
    question: "Is iOS available?",
    answer: "iOS is planned. Android is being prepared first.",
  },
];

export default function FAQSection() {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.question,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.answer,
      },
    })),
  };

  return (
    <section id="faq" className="hb-section">
      <div className="hb-container hb-faq-layout">
        <div className="hb-section-header hb-section-header--left">
          <p className="hb-kicker">FAQ</p>
          <h2>Questions before you begin.</h2>
          <p>Simple answers for new readers, returning readers, and early testers.</p>
        </div>

        <div className="hb-faq-list">
          {faqs.map((faq) => (
            <details key={faq.question} className="hb-faq-item">
              <summary>{faq.question}</summary>
              <p>{faq.answer}</p>
            </details>
          ))}
        </div>
      </div>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
    </section>
  );
}
