import Link from "next/link";
import { getMessages, type Locale } from "@/lib/i18n";

export default async function Home({ searchParams }: { searchParams: Promise<{ lang?: string }> }) {
  const params = await searchParams;
  const locale: Locale = params.lang === "kn" ? "kn" : "en";
  const t = getMessages(locale);
  return (
    <main>
      <section className="hero">
        <p className="muted">🪔 Temple community portal</p>
        <h1>{t.welcome}</h1>
        <p>{t.welcomeBody}</p>
        <div className="actions">
          <Link className="button" href="/sevas">{t.viewSevas}</Link>
          <Link className="button secondary" href="/events">{t.upcoming}</Link>
        </div>
        <p className="muted">{t.bilingualNote}</p>
      </section>
      <h2>Explore the temple</h2>
      <section className="cards">
        <article className="card"><h3>🪔 Pooja & Seva</h3><p>Browse offerings and learn how bookings will work.</p><Link href="/sevas">View sevas →</Link></article>
        <article className="card"><h3>📅 Events & Calendar</h3><p>Find festivals, special poojas and temple programmes.</p><Link href="/calendar">View calendar →</Link></article>
        <article className="card"><h3>📷 Photo gallery</h3><p>See approved photographs from temple events.</p><Link href="/gallery">Open gallery →</Link></article>
      </section>
    </main>
  );
}
