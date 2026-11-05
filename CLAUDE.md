# Macro: notes for working on this repo

Mobile-first calorie and macro tracker, used by the owner on iPhone as a home-screen web app (Netlify-hosted).

## Structure
- `index.html`: the whole app (HTML, CSS and vanilla JS in one file, no framework, no build step).
- `manifest.webmanifest`, `icon-*.png`: home-screen install.
- `netlify.toml`: static hosting from the repo root; `index.html` is served with `no-cache` so updates reach phones.

## How the code is organised (inside index.html)
- Helpers, units, energy/macro maths (`energyOf`, `targetsOf`, `PHASES`), weight trend (`weightStats`, `adaptiveEstimate`).
- `FOODS`: built-in food list, per 100 g. `parseFoodText` for quick text matching.
- `Store`: persistence. In a plain browser it uses `localStorage` key `macro.v1` (`{profile, days, weights}`); inside Claude's artifact viewer it uses the viewer's `db`. A day is `{date, items[]}`; items carry `mealId`, `mealName`, `t`, `logMins`.
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
Supabase (auth + Postgres with row-level security) replacing localStorage as the source of truth, with local cache for offline use; Anthropic key moved to a Netlify Function.
