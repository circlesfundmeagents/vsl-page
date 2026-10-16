-- =====================================================================
-- CirclesFundMe — Supabase schema
-- Run this once in your Supabase project's SQL Editor (SQL Editor tab).
-- Safe to re-run: uses "if not exists" / "or replace" everywhere.
-- =====================================================================

-- 1. SIGNUPS (form submissions from the public site)
create table if not exists signups (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  email text not null,
  whatsapp text not null,
  vehicle_type text,
  vehicle_type_other text,
  wants_cng boolean default false,
  wants_ambassador boolean default false,
  verified boolean default false,   -- admin ticks this on after confirming it's a real signup; only verified rows show in the "X just joined" popup
  created_at timestamptz default now()
);

-- 2. TESTIMONIALS (text + video)
create table if not exists testimonials (
  id uuid primary key default gen_random_uuid(),
  kind text not null default 'text' check (kind in ('text','video')),
  name text not null,
  role text,                         -- e.g. "Tricycle Owner, Lagos"
  quote text,                        -- for text testimonials
  video_url text,                    -- for video testimonials (mp4 or hosted link)
  video_poster_url text,             -- thumbnail/poster for video testimonials
  rating int default 5 check (rating between 1 and 5),
  is_active boolean default true,    -- show/hide this one testimonial
  sort_order int default 0,
  created_at timestamptz default now()
);

-- 3. FAQS
create table if not exists faqs (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  answer text not null,
  is_active boolean default true,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- 4. PARTNERS (trusted financial partner logos)
create table if not exists partners (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  logo_url text not null,
  is_active boolean default true,
  sort_order int default 0,
  created_at timestamptz default now()
);

-- 5. VEHICLE TYPES (dropdown options on the signup form)
create table if not exists vehicle_types (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  is_active boolean default true,
  sort_order int default 0
);

-- 6. SITE SETTINGS (key/value store — video poster, video src, section toggles, etc.)
create table if not exists site_settings (
  key text primary key,
  value text
);

-- Seed the settings the site reads on load. Safe to re-run (upsert).
insert into site_settings (key, value) values
  ('video_poster_url', 'assets/bus.png'),
  ('video_src_url', 'assets/your-vsl-video.mp4'),
  ('whatsapp_channel_link', 'https://chat.whatsapp.com/REPLACE_WITH_YOUR_INVITE_CODE'),
  ('show_testimonials_section', 'true')
on conflict (key) do nothing;

-- Seed default vehicle types (edit/add more from the admin page any time)
insert into vehicle_types (label, sort_order) values
  ('Tricycle (Keke)', 1),
  ('Commercial Bus', 2),
  ('Sedan / Car', 3),
  ('Heavy Duty Truck', 4)
on conflict do nothing;

-- Seed the 6 partner logos already on the site, so the admin page has
-- something to start from. Replace logo_url with real hosted image URLs
-- once you upload your own (Supabase Storage, or any public image URL).
insert into partners (name, logo_url, sort_order) values
  ('Zenith Bank', 'assets/partner-1.png', 1),
  ('Partner 2', 'assets/partner-2.png', 2),
  ('Briscoe', 'assets/partner-3.png', 3),
  ('Partner 4', 'assets/partner-4.png', 4),
  ('Kasali Oduola Chambers', 'assets/partner-5.png', 5),
  ('Paystack', 'assets/partner-6.png', 6)
on conflict do nothing;

-- Seed the current FAQs so the admin page has something to start from.
insert into faqs (question, answer, sort_order) values
  ('Is the program suitable for women?', 'Yes! CirclesFundMe is open to any driver ready to save regularly. It doesn''t matter if you''re a man or a woman.', 1),
  ('How long before I qualify for financing?', 'You need to save consistently on the platform for a minimum of 3 months to become a verified member of the cooperative and access financing.', 2),
  ('Do I need to be part of a group to join?', 'Yes — financing requires a group guarantee. You must be in a group of 5 registered members, and everyone in the group must also be a verified member with at least 3 months of consistent savings.', 3),
  ('What vehicles can I finance?', 'Tricycles, commercial buses, cars, and heavy duty trucks used to earn money. CNG conversion can also be added to your plan.', 4),
  ('I don''t have collateral. Is that okay?', 'No problem. Instead of collateral, we look at your savings record, your group guarantee, and your income.', 5)
on conflict do nothing;

-- =====================================================================
-- ROW LEVEL SECURITY
-- The public site uses the anon (public) key, so RLS must allow:
--   - anon can INSERT into signups, but cannot read/update/delete them
--   - anon can SELECT active rows from testimonials, faqs, partners, vehicle_types
--   - anon can SELECT site_settings
--   - only an authenticated user (your admin login) can do everything else
-- =====================================================================

alter table signups enable row level security;
alter table testimonials enable row level security;
alter table faqs enable row level security;
alter table partners enable row level security;
alter table vehicle_types enable row level security;
alter table site_settings enable row level security;

-- SIGNUPS: public can insert, nobody public can read
drop policy if exists "public can insert signups" on signups;
create policy "public can insert signups" on signups
  for insert to anon with check (true);

drop policy if exists "admin can do everything on signups" on signups;
create policy "admin can do everything on signups" on signups
  for all to authenticated using (true) with check (true);

-- TESTIMONIALS: public can read active rows, admin can do everything
drop policy if exists "public can read active testimonials" on testimonials;
create policy "public can read active testimonials" on testimonials
  for select to anon using (is_active = true);

drop policy if exists "admin can do everything on testimonials" on testimonials;
create policy "admin can do everything on testimonials" on testimonials
  for all to authenticated using (true) with check (true);

-- FAQS
drop policy if exists "public can read active faqs" on faqs;
create policy "public can read active faqs" on faqs
  for select to anon using (is_active = true);

drop policy if exists "admin can do everything on faqs" on faqs;
create policy "admin can do everything on faqs" on faqs
  for all to authenticated using (true) with check (true);

-- PARTNERS
drop policy if exists "public can read active partners" on partners;
create policy "public can read active partners" on partners
  for select to anon using (is_active = true);

drop policy if exists "admin can do everything on partners" on partners;
create policy "admin can do everything on partners" on partners
  for all to authenticated using (true) with check (true);

-- VEHICLE TYPES
drop policy if exists "public can read active vehicle types" on vehicle_types;
create policy "public can read active vehicle types" on vehicle_types
  for select to anon using (is_active = true);

drop policy if exists "admin can do everything on vehicle types" on vehicle_types;
create policy "admin can do everything on vehicle types" on vehicle_types
  for all to authenticated using (true) with check (true);

-- SITE SETTINGS: public can read all, admin can write
drop policy if exists "public can read site settings" on site_settings;
create policy "public can read site settings" on site_settings
  for select to anon using (true);

drop policy if exists "admin can write site settings" on site_settings;
create policy "admin can write site settings" on site_settings
  for all to authenticated using (true) with check (true);

-- =====================================================================
-- Done. Next steps (see SETUP.md for the full walkthrough):
--   1. Project Settings -> API: copy your Project URL and anon public key
--      into assets/config.js
--   2. Authentication -> Users: add yourself as a user (email + password)
--      so you can log into admin.html
--   3. Replace the placeholder whatsapp_channel_link value above with your
--      real WhatsApp community invite link (or edit it from the admin page)
-- =====================================================================
