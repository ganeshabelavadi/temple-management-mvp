
# Temple Management System — MVP scaffold

Bilingual (Kannada + English) temple portal using Next.js, TypeScript, Supabase/PostgreSQL, and GitHub-to-Vercel deployment.

## Scope

- Public pages: home, pooja/seva catalogue placeholder, events, calendar, gallery.
- Admin entry point with Supabase session detection.
- PostgreSQL schema for temple settings, users/roles, devotees, sevas/slots/bookings, payments, double-entry accounts/journals, events, calendar, photo albums/photos and audit log.
- RLS policies and a database posting function that rejects unbalanced journals.
- INR helpers use integer paise and unit tests.
- Seed chart of accounts.

**This is an MVP starter, not a finished production financial system.** Booking forms, payment gateway verification/webhooks, admin CRUD screens, reports, photo upload/publishing APIs, full sign-in/invitation UX, and end-to-end tests remain implementation tasks. Do not accept real money or real devotee information until these flows have been implemented and tested.

## Architecture

- Next.js App Router + TypeScript
- Supabase Auth and PostgreSQL with RLS
- Supabase Storage, private bucket for photos
- GitHub for source control
- Vercel for web deployment

Amounts are stored as integer paise (`amount_paise`). A posted journal must have positive and equal debit/credit totals. Posted journals should never be edited or deleted; corrections should be reversal journals.

## Requirements

- Node.js 20+
- Git
- GitHub account
- Supabase project
- Vercel account (or another Next.js host)

## Run locally

```bash
npm install
cp .env.example .env.local
# Edit .env.local with the Supabase project URL and anon key
npm run dev
```

Open http://localhost:3000.

Without Supabase environment variables, the public pages still render; the admin page explains that setup is required.

## Database setup

Install the Supabase CLI, then:

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

Or paste `supabase/migrations/0001_initial.sql` into the Supabase SQL editor, then run `supabase/seed.sql`.

Review the migration against your actual Supabase project before applying. Create the first owner using a controlled provisioning procedure:
1. Invite/create the person through Supabase Auth.
2. In the SQL editor, insert a `profiles` row.
3. Grant the owner role from the SQL editor using the new auth user UUID.

```sql
insert into public.profiles (id, display_name)
values ('AUTH_USER_UUID', 'Temple Administrator');

insert into public.user_roles (user_id, role)
values ('AUTH_USER_UUID', 'owner');
```

Do not expose owner-role assignment to public sign-up or a normal user API.

## GitHub and deployment

```bash
git init
git add .
git commit -m "Initial temple management MVP"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/temple-management-mvp.git
git push -u origin main
```

In Vercel:
1. Import the GitHub repository.
2. Add `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` as environment variables.
3. Deploy. Each push to `main` will trigger a deployment.
4. Configure a custom domain later if desired.

Never put Supabase service-role keys, payment secrets, webhook secrets or database passwords in `NEXT_PUBLIC_*` variables or commit them to Git.

## Test and quality gates

```bash
npm test
npm run typecheck
npm run lint
npm run build
```

The current tests cover money conversion/formatting only. Add integration tests against a disposable Supabase project before production.

## Accounting posting example

For a verified cash seva payment of ₹501:

- Debit Cash on Hand: 50,100 paise
- Credit Seva Income: 50,100 paise

Create a draft `journals` row and two `journal_lines` rows, then call `select public.post_journal('JOURNAL_UUID');` while authenticated as an owner or treasurer. The database function checks role and balance and writes an audit entry.

**Do not post gateway payments based on a browser redirect.** Verify the provider signature server-side and make webhook processing idempotent before marking a payment verified or posting a journal.

## Production hardening checklist

- [ ] Implement real sign-in, sign-out, password reset and administrator invitation flow.
- [ ] Add role checks to every server action/API route; rely on RLS as a second boundary.
- [ ] Use a server-side payment provider integration and signed webhook verification.
- [ ] Add database transaction/RPC for booking + payment idempotency and slot capacity locking.
- [ ] Prevent modification/deletion of posted journal headers and lines with database triggers.
- [ ] Implement reversal journals and reconciliation reports.
- [ ] Add private image upload, MIME/size validation, signed read URLs and publication approval.
- [ ] Add audit events for sensitive data changes; restrict audit-log modification.
- [ ] Configure backups, restore drills, monitoring, rate limiting and error reporting.
- [ ] Test authorization for every role and anonymous access.
- [ ] Review privacy notices, data retention, donation receipt rules and statutory obligations with the temple's accountant/adviser.
- [ ] Have a qualified accountant validate the chart of accounts and reports before using real books.

## Suggested next increments

1. Complete admin authentication and role provisioning.
2. Implement seva CRUD, slot availability and booking form.
3. Implement verified offline payments and journal posting.
4. Add payment gateway webhooks after provider selection.
5. Build financial reports and reconciliation.
6. Add event/calendar publishing and private photo uploads with approval.
7. Add bilingual content management and automated tests.


## Included validation tests
test

The test suite includes INR paise conversion/formatting, balanced double-entry journal validation, and basic seva booking request schema validation. These are unit tests; they do not replace database integration tests, payment webhook tests, concurrency tests, or authorization tests.
=======
# temple-management-mvp
>>>>>>> 5b87c47558a4f799a130f49f3f6b1c79913044a7
