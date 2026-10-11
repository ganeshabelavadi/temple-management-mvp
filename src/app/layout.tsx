import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  title: "Temple Management",
  description: "Temple pooja, seva bookings, events, calendar and community updates."
};

export default async function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <header className="site-header">
          <Link className="brand" href="/">🪔 Temple Management</Link>
          <nav className="nav" aria-label="Main navigation">
            <Link href="/">Home</Link>
            <Link href="/sevas">Pooja & Seva</Link>
            <Link href="/events">Events</Link>
            <Link href="/calendar">Calendar</Link>
            <Link href="/gallery">Gallery</Link>
            <Link href="/admin">Admin</Link>
            <Link href="/?lang=kn" lang="kn">ಕನ್ನಡ</Link>
            <Link href="/?lang=en">English</Link>
          </nav>
        </header>
        {children}
        <footer>Temple name to be configured · Bilingual community portal</footer>
      </body>
    </html>
  );
}
