import Link from "next/link";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export default async function AdminPage() {
  let userEmail: string | null = null;
  let setupMessage: string | null = null;
  try {
    const supabase = await createSupabaseServerClient();
    const { data } = await supabase.auth.getUser();
    userEmail = data.user?.email ?? null;
  } catch {
    setupMessage = "Configure Supabase environment variables to enable authentication.";
  }

  return <main>
    <h1>Admin Portal / ನಿರ್ವಹಣೆ</h1>
    <p className="muted">Financial and personal information must only be available to authorized roles.</p>
    {setupMessage && <article className="card"><strong>Setup required</strong><p>{setupMessage}</p></article>}
    {userEmail ? (
      <section className="card">
        <h2>Signed in</h2><p>{userEmail}</p>
        <p>Authentication is detected. Admin permissions must also be granted in the database before privileged operations are enabled.</p>
      </section>
    ) : (
      <section className="card">
        <h2>Administrator sign-in</h2>
        <p>Sign-in UI and account provisioning are intentionally not enabled until an administrator invitation flow is configured.</p>
        <p>Do not expose financial operations based on a client-side role check alone. Enforce authorization in PostgreSQL Row Level Security and server-side handlers.</p>
        <Link href="/">Return to public website</Link>
      </section>
    )}
    <h2>Planned admin workspaces</h2>
    <section className="cards">
      <article className="card"><h3>Bookings</h3><p>Availability, devotee details, booking status and receipts.</p></article>
      <article className="card"><h3>Accounting</h3><p>Journal entries, ledgers, expenses and reconciliation.</p></article>
      <article className="card"><h3>Content</h3><p>Events, calendar, photo uploads and publishing approvals.</p></article>
    </section>
  </main>;
}
