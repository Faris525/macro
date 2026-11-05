# Macro

An adaptive calorie and macro tracker for bulking, cutting and maintaining, built mobile-first and installed on iPhone as a home-screen web app.

## What it does

- Sets calorie and macro targets from body data and one of five phases (aggressive bulk to aggressive cut), or from your own targets.
- Logs meals by food search, text, voice (keyboard dictation) or photo. With an Anthropic API key, Claude analyses photos and text, and checks restaurant meals against the chain's official nutrition page.
- One-tap saved meals and "Log again", meal history, moving meals between days.
- Morning weigh-ins with a smoothed trend line and adaptive maintenance once there is enough data.
- Reminders that learn your usual meal times.

## Running it

It's a single static page: `index.html` plus the manifest and icons. No build step.

- **Local:** `python3 -m http.server` in this folder, then open http://localhost:8000.
- **Deploy:** Netlify serves the repository root (see `netlify.toml`). Every push to `main` publishes.
- **iPhone:** open the site in Safari → Share → Add to Home Screen. Set up the app from the home-screen icon, not Safari.

## Where data lives

Sign in with email and password, and everything is saved to your account in Supabase (Postgres with row-level security, so each person only sees their own data). The app keeps a copy on the phone, so it opens instantly and works offline; changes sync when you're back online. Without an account, data stays on the phone only.

## Roadmap

1. Move the Anthropic API key to a server function, so it isn't stored on the phone.
2. A restaurant nutrition database for exact chain figures.
3. Push notifications for reminders.
