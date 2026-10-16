// =====================================================================
// CirclesFundMe — shared config
// Fill these in once you've created your Supabase project (see SETUP.md).
// Both index.html and admin.html load this file.
// =====================================================================

const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";      // e.g. https://abcdefgh.supabase.co
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_PUBLIC_KEY";

// Fallback WhatsApp link used only if the site_settings table hasn't
// loaded yet (slow connection) or Supabase isn't configured at all.
const FALLBACK_WHATSAPP_LINK = "https://chat.whatsapp.com/REPLACE_WITH_YOUR_INVITE_CODE";

// Whether Supabase looks configured at all — both the public site and the
// admin page check this before trying to talk to Supabase, so the public
// site still works (on its hardcoded defaults) even before you've set this up.
const SUPABASE_CONFIGURED =
  typeof SUPABASE_URL === "string" &&
  SUPABASE_URL.startsWith("https://") &&
  !SUPABASE_URL.includes("YOUR_SUPABASE");
