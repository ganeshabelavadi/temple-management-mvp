export default function SevasPage() {
  return <main>
    <h1>Pooja & Seva / ಪೂಜೆ ಮತ್ತು ಸೇವೆ</h1>
    <p className="muted">The public catalogue is ready for connection to the database. Sample entries below are placeholders, not actual temple rates.</p>
    <section className="cards">
      <article className="card"><h3>Archana / ಅರ್ಚನೆ</h3><p>Temple-admin configured offering.</p><p><strong>Rate: To be configured</strong></p></article>
      <article className="card"><h3>Special Pooja / ವಿಶೇಷ ಪೂಜೆ</h3><p>Available dates and details will be published by the temple.</p><p><strong>Rate: To be configured</strong></p></article>
      <article className="card"><h3>Festival Seva / ಉತ್ಸವ ಸೇವೆ</h3><p>Festival-specific offerings and booking limits.</p><p><strong>Rate: To be configured</strong></p></article>
    </section>
    <p>Online booking and payment are not enabled until the database, availability checks and payment gateway webhook are configured.</p>
  </main>;
}
