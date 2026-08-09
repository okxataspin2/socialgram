# SocialGram — Supabase Setup (Step-by-Step)

Complete walkthrough to connect this project to a Supabase project:
database, storage, auth, realtime, push notifications.

> **Short version:** paste the contents of `supabase/complete_schema.sql` into
> the Supabase **SQL Editor** and click **Run**. That single file resets and
> creates the entire backend — tables, storage buckets + policies, triggers,
> indexes and the PowerSync publication.

---

## 1. What the schema file does

`supabase/complete_schema.sql` is the only database file you need. Structure:

| Section | Contents |
|---|---|
| **STEP 0 (RESET)** | Drops all previous SocialGram tables, enums, functions, storage objects/buckets, PowerSync publication and user accounts — always starts clean, safe to re-run |
| STEP 1 | Extensions (`uuid-ossp`, `http`, `pgcrypto`) |
| STEP 2 | Storage buckets: `avatars`, `posts`, `stories`, `messages` |
| STEP 3 | Storage policies (public avatars/posts, auth-only stories, participant-only messages) |
| STEP 4–13 | All app tables + RLS policies (profiles, posts, media, comments, likes, subscriptions, conversations, participants, messages, attachments, stories, admin) |
| STEP 14–17 | Storage cleanup + profile creation triggers (incl. `handle_new_user` — REQUIRED for signup) |
| STEP 16/18 | Calls table, performance indexes, `powersync` publication |

## 2. Run it

1. Create a project at https://supabase.com/dashboard
2. **SQL Editor** → **New query**
3. Paste `supabase/complete_schema.sql` (or grab it from the repo on GitHub)
4. **Run** — takes ~30 seconds, should end with "Success. No rows returned"

## 3. Auth settings

- **Authentication → Providers → Email**: enable (default)
- Optional: Google provider — add the `WEB_CLIENT_ID` / `IOS_CLIENT_ID` OAuth client IDs from FIREBASE_SETUP.md, and set the site URL to your deployed web app
- **URL Configuration → Site URL**: the URL of your deployed app
- Optional **Redirect URLs**: `io.supabase.flutterquickstart://login-callback/` for deep linking on mobile

## 4. Admin access

Sign up once in the app, then run in SQL Editor:

```sql
UPDATE auth.users
SET raw_app_meta_data = '{"role": "admin"}'
WHERE email = 'your-email@example.com';
```

> `raw_app_meta_data` (NOT `app_metadata`) — newer Supabase versions removed
> the `app_metadata` column from `auth.users`. The schema files referenced
> below already use `raw_app_meta_data`.

## 5. Environment variables

Copy the project values into `packages/env/.env.prod` and `packages/env/.env.dev`:

| Variable | Where to find it |
|---|---|
| `SUPABASE_URL` | Dashboard → Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Dashboard → Settings → API → anon public key |
| `POWERSYNC_URL` | console.powersync.com → your instance |
| `IOS_CLIENT_ID` / `WEB_CLIENT_ID` | Google Cloud Console (see FIREBASE_SETUP.md) |
| `FCM_PROJECT_ID` | Firebase Console → Project settings |
| `CLOUDINARY_CLOUD_NAME` / `CLOUDINARY_UPLOAD_PRESET` | Cloudinary dashboard |
| `ZEGO_APP_ID` / `ZEGO_APP_SIGN` | console.zegocloud.com → your project |

After editing, regenerate the baked-in constants:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 6. Push notifications (optional)

The `send-notification` edge function is deployed with the Supabase CLI —
see `SUPABASE_CLI_SETUP.md` for the deploy steps.

## 7. Troubleshooting

| Symptom | Cause / Fix |
|---|---|
| `Database error saving new user` on signup | `handle_new_user` trigger missing → re-run `complete_schema.sql` |
| "Something went wrong!" on uploads | Storage buckets missing → re-run `complete_schema.sql` |
| `relation ... does not exist` | Partial old setup → just re-run `complete_schema.sql` (STEP 0 wipes it) |
| `column users.app_metadata does not exist` | Use `raw_app_meta_data` |
| Login OK but feed/stories empty | `POWERSYNC_URL` wrong or publication missing → check console.powersync.com |
| Realtime messages don't appear | Enable **Database → Replication** for the `messages` / `conversations` tables |
