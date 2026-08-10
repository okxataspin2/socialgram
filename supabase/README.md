# SocialGram — Supabase Setup (Single-File)

Everything needed to connect this app to a Supabase project lives in **one file**:

```
supabase/complete_schema.sql
```

It's fully self-contained and **self-cleaning**: it drops any previous
SocialGram tables, storage, triggers and accounts before recreating the
entire database from scratch. You can run it on a fresh project **or** on an
existing half-configured one.

---

## 1. Create the project

1. Sign in at https://supabase.com/dashboard
2. **New project** → pick a region close to you → create

## 2. Run the schema (one time, ~30 seconds)

1. Open your project → **SQL Editor** → **New query**
2. Open `supabase/complete_schema.sql` from this repo and copy the **entire** contents
   (or open: https://github.com/okxataspin2/socialgram/blob/main/supabase/complete_schema.sql)
3. Paste → **Run**

What it creates:
- `profiles`, `posts`, `post_media`, `videos`, `images`, `comments`, `likes` (reactions),
  `subscriptions` (follows), `conversations`, `participants`, `messages`, `attachments`,
  `stories`, `calls`, `admin_settings`, `admin_audit_logs`, `user_roles`
- Storage buckets: `avatars`, `posts`, `stories`, `messages` + all storage policies
- Triggers: automatic `profiles` creation on signup (`handle_new_user`) — this must
  exist or signup fails with "Database error saving new user"
- Media cleanup triggers, performance indexes, PowerSync publication

## 3. Give yourself admin access

Sign up once in the app (your profile row is created automatically by the trigger),
then in **SQL Editor** run:

```sql
UPDATE auth.users
SET raw_app_meta_data = '{"role": "admin"}'
WHERE email = 'your-email@example.com';
```

> Note: use `raw_app_meta_data` — newer Supabase versions renamed/removed `app_metadata`.

## 4. Copy the app environment

The committed environment files already point at this project's values:
- `packages/env/.env.prod` — used by production builds (web + APK)
- `packages/env/.env.dev` — used by local development (`lib/main_development.dart`)

```
SUPABASE_URL=
SUPABASE_ANON_KEY=
POWERSYNC_URL=          # from the PowerSync project (console.powersync.com)
IOS_CLIENT_ID=          # Google OAuth (iOS)
WEB_CLIENT_ID=          # Google OAuth (web)
FCM_PROJECT_ID=
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_UPLOAD_PRESET=
ZEGO_APP_ID=
ZEGO_APP_SIGN=
```

After editing an env file, regenerate the compiled constants:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## PowerSync

Create a PowerSync instance at https://console.powersync.com and point it at a read-only
Postgres connection for this Supabase project. The `powersync` publication created by the
schema is what `POWERSYNC_URL` consumes for offline sync.

## Troubleshooting

| Symptom | Cause / Fix |
|---|---|
| `Database error saving new user` | Missing `handle_new_user` trigger → re-run `complete_schema.sql` (STEP 0 resets) |
| Uploads fail with "Something went wrong!" | Missing storage buckets/policies → re-run `complete_schema.sql` |
| `relation does not exist` | Old partial setup → re-run `complete_schema.sql` (STEP 0 wipes it) |
| `column users.app_metadata does not exist` | Use `raw_app_meta_data` (see Step 3) |
| Login works, feed empty | PowerSync URL missing/invalid → fix `POWERSYNC_URL` + run `dart run powersync:setup_web` for web |
| "Password reset link sent" but no email arrives | Check **Authentication → Providers → Email** is enabled (default), set **Authentication → URL Configuration → Site URL** to your deployed app URL, and configure **SMTP** (Authentication → Emails → SMTP Settings) — without custom SMTP, Supabase's shared sender can be slow or land in Spam (also check the spam folder) |

> **Why emails can be slow/missing:** Supabase projects without a custom SMTP use Supabase's shared no-reply sender. For reliable delivery set up your own SMTP (Gmail app password, Resend, etc.) in `Authentication → Emails → SMTP Settings`.