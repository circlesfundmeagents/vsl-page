# CirclesFundMe — Setup Guide

This site works right out of the box with the content already built into the HTML
(every section has sensible defaults). Connecting Supabase makes four things
dynamic: the signup form, the admin page, the "just joined" popup, and the
ability to edit testimonials/FAQs/partners/vehicle types/video without touching code.

You do **not** need to redo any of this if you skip it — the public site still
looks and works fine without Supabase, it just won't save real signups anywhere
or let you manage content from admin.html.

---

## 1. Create your Supabase project

1. Go to [supabase.com](https://supabase.com) → **New project**.
2. Pick a name, a database password (save it somewhere), and a region close to Nigeria (e.g. nearest available — Supabase doesn't currently have a Lagos region, pick the closest one).
3. Wait ~2 minutes for it to finish provisioning.

## 2. Run the database schema

1. In your Supabase project, open **SQL Editor** (left sidebar).
2. Open `supabase-schema.sql` from this folder, copy all of it, paste it into the SQL Editor.
3. Click **Run**. This creates all 6 tables, seeds your current FAQs/partners/vehicle types, and sets up Row Level Security so the public site can only insert signups and read "active" content — never see or edit anyone else's data.

## 3. Get your API keys

1. In Supabase: **Project Settings → API**.
2. Copy the **Project URL** and the **anon public** key (not the `service_role` key — never put that one in a public file).
3. Open `assets/config.js` in this project and paste them in:

```js
const SUPABASE_URL = "https://xxxxxxxx.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOi....";
```

That one file is shared by both `index.html` and `admin.html`.

## 4. Create your admin login

1. In Supabase: **Authentication → Users → Add user**.
2. Enter your email and a password. This is what you'll use to log into `admin.html`.
3. You can add more admin users the same way later.

## 5. Set your WhatsApp link and video

Easiest way: open `admin.html` in a browser, log in, go to **Site Settings**, and fill in:
- **WhatsApp community link** — your real invite link (e.g. `https://chat.whatsapp.com/ABC123...`)
- **Hero video thumbnail URL** and **Hero video file URL** — can be any public image/video URL, or a path to a file in `assets/` if you've uploaded one there

(You can also just edit these three rows directly in the `site_settings` table in Supabase, or run an UPDATE query — whichever is easiest for you.)

## 6. Hosting images and videos

The `logo_url` / `video_poster_url` / `video_url` fields just need a public URL. Two easy options:
- **Supabase Storage**: in Supabase, go to **Storage → New bucket**, make it public, upload your file, and copy its public URL into the admin page.
- Any other public image host works too.

---

## Deploying to GitHub Pages

If you haven't already, push this whole folder to a GitHub repo and turn on Pages
(**Settings → Pages → Source: GitHub Actions** if you're using the included
`.github/workflows/deploy.yml`, or "Deploy from a branch" if you'd rather keep
it simple). Once Supabase is configured as above, the live GitHub Pages site
will automatically talk to Supabase — there's nothing GitHub-specific to set up
beyond hosting the static files. `assets/config.js` ships with your site, so
double-check you're using the **anon public** key there (that key is meant to be
public; it's Row Level Security, not secrecy, that keeps your data safe).

---

## Using the admin page day to day

Open `admin.html` (e.g. `https://yoursite.com/admin.html`), log in, and you can:

- **Signups** — see everyone who filled the form. Tick "Verified" on real people you want showing in the "just joined" popup on the public site.
- **Testimonials** — add text or video testimonials, toggle any single one on/off, or turn off the *entire* testimonials section with one switch at the top of the page.
- **FAQs** — add, edit visibility, delete, reorder with the sort number.
- **Partners** — manage the logos in the "Backed by trusted financial partners" strip.
- **Vehicle Types** — manage the options in the signup form's vehicle dropdown.
- **Site Settings** — change the hero video, its thumbnail, and your WhatsApp link any time, no code required.

Changes made in the admin page show up on the public site on the *next* page
load (there's no cache to clear).

---

## A note on security

`admin.html` has no extra password gate of its own beyond Supabase Auth login —
that's intentional and sufficient, since every write action is also checked
server-side by Supabase's Row Level Security policies (an unauthenticated
visitor literally cannot write to any table except inserting a signup, no
matter what they do in the browser). Just don't share your Supabase admin
login, and you're covered.
