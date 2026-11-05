# Macro: notes for working on this repo

Mobile-first calorie and macro tracker, used by the owner on iPhone as a home-screen web app (Netlify-hosted).

## Structure
- `index.html`: the whole app (HTML, CSS and vanilla JS in one file, no framework, no build step).
- `manifest.webmanifest`, `icon-*.png`: home-screen install.
- `brand/`: logo sources (`icon.svg`, `wordmark.svg`, `mark.svg`). The logo is "macro" in Bricolage Grotesque 800 (outlined, no font loading) where the m is a fork: a blue handle rises from the middle stem. The wordmark is inlined in `index.html` as `LOGO_WORD`; icons are rendered from `brand/icon.svg`.
- `netlify.toml`: static hosting from the repo root; `index.html` is served with `no-cache` so updates reach phones.

## How the code is organised (inside index.html)
- Helpers, units, energy/macro maths (`energyOf`, `targetsOf`, `PHASES`), weight trend (`weightStats`, `adaptiveEstimate`).
- `FOODS`: built-in food list, per 100 g. `parseFoodText` for quick text matching.
- `Store`: persistence, three modes:
  - `cloud` (normal): Supabase account via `Cloud` (supabase-js 2.117.3 from jsDelivr). Offline-first: changes go to a per-account cache in `localStorage` (`macro.cloud.<userId>`), are marked dirty (`Cloud.dirty`), and are flushed to Supabase; unsent changes survive restarts. `Cloud.pull()` runs on start and when the app returns to the front.
  - `device`: no account (`macro.nocloud`), data in `localStorage` `macro.v1`. Signing in later offers to import it.
  - `account`: only inside Claude's artifact viewer (its `db`); not used by the Netlify app.
  - A day is `{date, items[]}`; items carry `mealId`, `mealName`, `t`, `logMins`.
- Supabase project `acfprojdjumrfmicbtsp` (eu-west-1). Tables `profiles(user_id, data jsonb)`, `days(user_id, date, items jsonb)`, `weights(user_id, date, kg)`, all with row-level security (own rows only, `authenticated` role only). Email + password sign-in; email confirmation is off. The publishable key in `index.html` is meant to be public.
- AI: `apiSample` calls the Anthropic Messages API directly from the browser with the user's own key (`localStorage` `macro.apikey`, header `anthropic-dangerous-direct-browser-access`), optionally with the `web_search` tool for official restaurant figures. Without a key, analysis is simulated and must stay clearly labelled as simulated.
- Screens: `renderToday`, `renderLog` (+ review), `renderHistory`, `renderWeight`, `renderReminders`, `renderAdjust`, `renderYou`, onboarding. Hash routes: `#today #log #history #weight #you #reminders #adjust`.
- `syncToday()` rolls the view to the new date when the app resumes after midnight (iOS keeps the app suspended in memory).

## Rules
- Phone first: test at 390×844, no horizontal scrolling, safe-area insets respected.
- Dark, simple style (system font, flat cards, one blue accent). Keep it plain and usable.
- Never present estimates as official figures: badges are Official (· checked when verified online), Label, Database, AI estimate, Simulated.
- Validate inputs with the existing `V` limits; keep user data when settings change.
- Escape all user and AI text with `esc()` before inserting into HTML.

## Next planned work
- Move the Anthropic API key from the phone to a server function (Supabase Edge Function with a secret), so analysis works for any signed-in user.
- Custom SMTP before inviting other users (needed for password reset and email confirmation).
