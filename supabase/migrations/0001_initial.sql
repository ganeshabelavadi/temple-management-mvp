-- Temple Management MVP schema for Supabase/PostgreSQL.
-- Apply with: supabase db push (after linking your Supabase project).
create extension if not exists pgcrypto;

create type public.app_role as enum ('owner', 'treasurer', 'seva_manager', 'content_editor', 'viewer');
create type public.booking_status as enum ('pending', 'confirmed', 'cancelled', 'completed');
create type public.payment_status as enum ('pending', 'verified', 'failed', 'refunded');
create type public.account_type as enum ('asset', 'liability', 'fund_balance', 'income', 'expense');
create type public.journal_status as enum ('draft', 'posted', 'reversed');
create type public.content_status as enum ('draft', 'published', 'archived');

create table public.temple_settings (
  id uuid primary key default gen_random_uuid(),
  temple_name text not null default 'Temple Name To Be Decided',
  default_locale text not null default 'en' check (default_locale in ('en','kn')),
  currency char(3) not null default 'INR',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  phone text,
  locale text not null default 'en' check (locale in ('en','kn')),
  created_at timestamptz not null default now()
);

create table public.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.app_role not null,
  granted_by uuid references auth.users(id),
  granted_at timestamptz not null default now(),
  primary key (user_id, role)
);

create table public.devotees (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  phone text,
  email text,
  gothra text,
  nakshatra text,
  preferred_locale text not null default 'en' check (preferred_locale in ('en','kn')),
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.sevas (
  id uuid primary key default gen_random_uuid(),
  name_en text not null,
  name_kn text not null,
  description_en text,
  description_kn text,
  amount_paise bigint not null check (amount_paise >= 0),
  duration_minutes integer check (duration_minutes is null or duration_minutes > 0),
  capacity integer check (capacity is null or capacity > 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.seva_slots (
  id uuid primary key default gen_random_uuid(),
  seva_id uuid not null references public.sevas(id),
  starts_at timestamptz not null,
  ends_at timestamptz,
  capacity integer not null default 1 check (capacity > 0),
  is_open boolean not null default true,
  created_at timestamptz not null default now(),
  check (ends_at is null or ends_at > starts_at),
  unique (seva_id, starts_at)
);

create table public.seva_bookings (
  id uuid primary key default gen_random_uuid(),
  receipt_number bigint generated always as identity unique,
  seva_id uuid not null references public.sevas(id),
  slot_id uuid references public.seva_slots(id),
  devotee_id uuid not null references public.devotees(id),
  booking_date date not null,
  amount_paise bigint not null check (amount_paise >= 0),
  status public.booking_status not null default 'pending',
  sankalpa_notes text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index seva_bookings_date_idx on public.seva_bookings(booking_date);
create index seva_bookings_devotee_idx on public.seva_bookings(devotee_id);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid references public.seva_bookings(id),
  amount_paise bigint not null check (amount_paise > 0),
  method text not null check (method in ('cash','bank_transfer','upi_manual','gateway')),
  status public.payment_status not null default 'pending',
  provider_reference text unique,
  idempotency_key text unique,
  received_at timestamptz,
  verified_by uuid references auth.users(id),
  verified_at timestamptz,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
create index payments_status_idx on public.payments(status);

create table public.accounts (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name_en text not null,
  name_kn text not null,
  type public.account_type not null,
  parent_id uuid references public.accounts(id),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.journals (
  id uuid primary key default gen_random_uuid(),
  journal_number bigint generated always as identity unique,
  journal_date date not null default current_date,
  description text not null,
  source_type text,
  source_id uuid,
  status public.journal_status not null default 'draft',
  created_by uuid references auth.users(id),
  posted_by uuid references auth.users(id),
  posted_at timestamptz,
  reversal_of uuid references public.journals(id),
  created_at timestamptz not null default now(),
  check ((status <> 'posted') or (posted_by is not null and posted_at is not null))
);
create unique index journals_source_unique on public.journals(source_type, source_id)
  where source_type is not null and source_id is not null and status = 'posted';

create table public.journal_lines (
  id uuid primary key default gen_random_uuid(),
  journal_id uuid not null references public.journals(id) on delete restrict,
  account_id uuid not null references public.accounts(id),
  debit_paise bigint not null default 0 check (debit_paise >= 0),
  credit_paise bigint not null default 0 check (credit_paise >= 0),
  memo text,
  check ((debit_paise > 0 and credit_paise = 0) or (credit_paise > 0 and debit_paise = 0))
);
create index journal_lines_journal_idx on public.journal_lines(journal_id);
create index journal_lines_account_idx on public.journal_lines(account_id);

create table public.events (
  id uuid primary key default gen_random_uuid(),
  title_en text not null,
  title_kn text not null,
  description_en text,
  description_kn text,
  starts_at timestamptz not null,
  ends_at timestamptz,
  venue text,
  status public.content_status not null default 'draft',
  created_by uuid references auth.users(id),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  check (ends_at is null or ends_at > starts_at)
);
create index events_public_idx on public.events(status, starts_at);

create table public.calendar_entries (
  id uuid primary key default gen_random_uuid(),
  title_en text not null,
  title_kn text not null,
  entry_date date not null,
  description_en text,
  description_kn text,
  event_id uuid references public.events(id) on delete set null,
  status public.content_status not null default 'draft',
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
create index calendar_entries_public_idx on public.calendar_entries(status, entry_date);

create table public.photo_albums (
  id uuid primary key default gen_random_uuid(),
  title_en text not null,
  title_kn text not null,
  description_en text,
  description_kn text,
  event_id uuid references public.events(id) on delete set null,
  status public.content_status not null default 'draft',
  cover_photo_id uuid,
  created_by uuid references auth.users(id),
  published_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.photos (
  id uuid primary key default gen_random_uuid(),
  album_id uuid not null references public.photo_albums(id) on delete cascade,
  storage_path text not null unique,
  caption_en text,
  caption_kn text,
  alt_text text,
  sort_order integer not null default 0,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
alter table public.photo_albums add constraint photo_album_cover_fk
  foreign key (cover_photo_id) references public.photos(id) on delete set null;

create table public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid references auth.users(id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Role checks are performed in PostgreSQL, not trusted from client-side UI.
create or replace function public.has_role(required_roles public.app_role[])
returns boolean language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = auth.uid() and role = any(required_roles)
  );
$$;
revoke all on function public.has_role(public.app_role[]) from public;
grant execute on function public.has_role(public.app_role[]) to authenticated;

-- Validate a journal before posting. Posting is a privileged operation; no direct client update grants.
create or replace function public.post_journal(p_journal_id uuid)
returns void language plpgsql security definer set search_path = public
as $$
declare
  v_debits bigint;
  v_credits bigint;
  v_status public.journal_status;
begin
  if not public.has_role(array['owner','treasurer']::public.app_role[]) then
    raise exception 'Only owner or treasurer can post journals';
  end if;

  select status into v_status from public.journals where id = p_journal_id for update;
  if not found then raise exception 'Journal not found'; end if;
  if v_status <> 'draft' then raise exception 'Only draft journals can be posted'; end if;

  select coalesce(sum(debit_paise),0), coalesce(sum(credit_paise),0)
    into v_debits, v_credits
    from public.journal_lines where journal_id = p_journal_id;

  if v_debits <= 0 or v_debits <> v_credits then
    raise exception 'Journal must have equal, positive debit and credit totals';
  end if;

  update public.journals
     set status = 'posted', posted_by = auth.uid(), posted_at = now()
   where id = p_journal_id;

  insert into public.audit_log(actor_id, action, entity_type, entity_id, details)
  values (auth.uid(), 'journal.posted', 'journal', p_journal_id,
          jsonb_build_object('debits_paise',v_debits,'credits_paise',v_credits));
end;
$$;
revoke all on function public.post_journal(uuid) from public;
grant execute on function public.post_journal(uuid) to authenticated;

-- Lock down all tables by default; grant public reads only through explicit RLS policies.
alter table public.temple_settings enable row level security;
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.devotees enable row level security;
alter table public.sevas enable row level security;
alter table public.seva_slots enable row level security;
alter table public.seva_bookings enable row level security;
alter table public.payments enable row level security;
alter table public.accounts enable row level security;
alter table public.journals enable row level security;
alter table public.journal_lines enable row level security;
alter table public.events enable row level security;
alter table public.calendar_entries enable row level security;
alter table public.photo_albums enable row level security;
alter table public.photos enable row level security;
alter table public.audit_log enable row level security;

create policy "public can read temple settings" on public.temple_settings for select using (true);
create policy "admins manage temple settings" on public.temple_settings for all to authenticated
  using (public.has_role(array['owner']::public.app_role[]))
  with check (public.has_role(array['owner']::public.app_role[]));

create policy "users read own profile" on public.profiles for select to authenticated using (id = auth.uid() or public.has_role(array['owner']::public.app_role[]));
create policy "users update own profile" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "owner manages profiles" on public.profiles for all to authenticated using (public.has_role(array['owner']::public.app_role[])) with check (public.has_role(array['owner']::public.app_role[]));
create policy "users see own roles; owner manages roles" on public.user_roles for select to authenticated
  using (user_id = auth.uid() or public.has_role(array['owner']::public.app_role[]));
create policy "owner manages roles" on public.user_roles for all to authenticated
  using (public.has_role(array['owner']::public.app_role[])) with check (public.has_role(array['owner']::public.app_role[]));

create policy "public reads active sevas" on public.sevas for select using (is_active = true);
create policy "seva managers manage sevas" on public.sevas for all to authenticated
  using (public.has_role(array['owner','seva_manager']::public.app_role[]))
  with check (public.has_role(array['owner','seva_manager']::public.app_role[]));
create policy "public reads open slots" on public.seva_slots for select using (is_open = true);
create policy "seva managers manage slots" on public.seva_slots for all to authenticated
  using (public.has_role(array['owner','seva_manager']::public.app_role[]))
  with check (public.has_role(array['owner','seva_manager']::public.app_role[]));

create policy "public reads published events" on public.events for select using (status = 'published');
create policy "content editors manage events" on public.events for all to authenticated
  using (public.has_role(array['owner','content_editor','seva_manager']::public.app_role[]))
  with check (public.has_role(array['owner','content_editor','seva_manager']::public.app_role[]));
create policy "public reads published calendar" on public.calendar_entries for select using (status = 'published');
create policy "content editors manage calendar" on public.calendar_entries for all to authenticated
  using (public.has_role(array['owner','content_editor','seva_manager']::public.app_role[]))
  with check (public.has_role(array['owner','content_editor','seva_manager']::public.app_role[]));
create policy "public reads published albums" on public.photo_albums for select using (status = 'published');
create policy "content editors manage albums" on public.photo_albums for all to authenticated
  using (public.has_role(array['owner','content_editor']::public.app_role[]))
  with check (public.has_role(array['owner','content_editor']::public.app_role[]));
create policy "public reads photos in published albums" on public.photos for select using (
  exists(select 1 from public.photo_albums a where a.id = album_id and a.status = 'published')
);
create policy "content editors manage photos" on public.photos for all to authenticated
  using (public.has_role(array['owner','content_editor']::public.app_role[]))
  with check (public.has_role(array['owner','content_editor']::public.app_role[]));

-- Personal, booking and accounting data: no public access.
create policy "authorized staff read devotees" on public.devotees for select to authenticated
  using (public.has_role(array['owner','treasurer','seva_manager','viewer']::public.app_role[]));
create policy "authorized staff create devotees" on public.devotees for insert to authenticated
  with check (public.has_role(array['owner','treasurer','seva_manager']::public.app_role[]));
create policy "authorized staff update devotees" on public.devotees for update to authenticated
  using (public.has_role(array['owner','treasurer','seva_manager']::public.app_role[]))
  with check (public.has_role(array['owner','treasurer','seva_manager']::public.app_role[]));

create policy "authorized staff read bookings" on public.seva_bookings for select to authenticated
  using (public.has_role(array['owner','treasurer','seva_manager','viewer']::public.app_role[]));
create policy "authorized staff manage bookings" on public.seva_bookings for all to authenticated
  using (public.has_role(array['owner','treasurer','seva_manager']::public.app_role[]))
  with check (public.has_role(array['owner','treasurer','seva_manager']::public.app_role[]));

create policy "authorized staff read payments" on public.payments for select to authenticated
  using (public.has_role(array['owner','treasurer','seva_manager','viewer']::public.app_role[]));
create policy "treasurer manages payments" on public.payments for all to authenticated
  using (public.has_role(array['owner','treasurer']::public.app_role[]))
  with check (public.has_role(array['owner','treasurer']::public.app_role[]));

create policy "staff read accounts" on public.accounts for select to authenticated
  using (public.has_role(array['owner','treasurer','viewer']::public.app_role[]));
create policy "owner manages accounts" on public.accounts for all to authenticated
  using (public.has_role(array['owner']::public.app_role[]))
  with check (public.has_role(array['owner']::public.app_role[]));
create policy "staff read journals" on public.journals for select to authenticated
  using (public.has_role(array['owner','treasurer','viewer']::public.app_role[]));
create policy "treasurer creates draft journals" on public.journals for insert to authenticated
  with check (public.has_role(array['owner','treasurer']::public.app_role[]) and status = 'draft');
create policy "staff read journal lines" on public.journal_lines for select to authenticated
  using (public.has_role(array['owner','treasurer','viewer']::public.app_role[]));
create policy "treasurer creates journal lines" on public.journal_lines for insert to authenticated
  with check (public.has_role(array['owner','treasurer']::public.app_role[]) and
    exists(select 1 from public.journals j where j.id = journal_id and j.status = 'draft'));
create policy "authorized staff read audit log" on public.audit_log for select to authenticated
  using (public.has_role(array['owner','treasurer']::public.app_role[]));

-- Do not grant anonymous/authenticated broad table privileges. Supabase defaults vary by project;
-- explicit grants below pair with RLS. Revisit if your project has customized default privileges.
grant select on public.temple_settings, public.sevas, public.seva_slots, public.events,
  public.calendar_entries, public.photo_albums, public.photos to anon, authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.user_roles to authenticated;
grant select, insert, update on public.devotees to authenticated;
grant select, insert, update, delete on public.seva_bookings to authenticated;
grant select, insert, update, delete on public.payments to authenticated;
grant select, insert, update, delete on public.accounts to authenticated;
grant select, insert, update on public.journals to authenticated;
grant select, insert on public.journal_lines to authenticated;
grant select, insert, update, delete on public.events, public.calendar_entries, public.photo_albums, public.photos to authenticated;
grant select on public.audit_log to authenticated;

-- Storage bucket is private. Public viewing is mediated by published-album policies in application/API.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('temple-event-photos','temple-event-photos',false,10485760,array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

create policy "authorized editors upload temple photos" on storage.objects for insert to authenticated
  with check (bucket_id = 'temple-event-photos' and public.has_role(array['owner','content_editor']::public.app_role[]));
create policy "authorized editors update temple photos" on storage.objects for update to authenticated
  using (bucket_id = 'temple-event-photos' and public.has_role(array['owner','content_editor']::public.app_role[]))
  with check (bucket_id = 'temple-event-photos' and public.has_role(array['owner','content_editor']::public.app_role[]));
create policy "authorized editors delete temple photos" on storage.objects for delete to authenticated
  using (bucket_id = 'temple-event-photos' and public.has_role(array['owner','content_editor']::public.app_role[]));
