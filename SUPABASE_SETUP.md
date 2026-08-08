# SocialGram — Supabase Setup Tutorial (Step-by-Step)

Complete walkthrough to connect this project to your own Supabase project:
database, storage, auth, realtime, push notifications.

**Project files you will touch:**

| File | Purpose |
|---|---|
| `supabase/complete_schema.sql` | Full schema (for FRESH projects) |
| `supabase/resume_schema.sql` | Resume script (if you already ran part of the schema) |
| `supabase/fix_admin_policies.sql` | Missing tail after the `app_metadata` error (admin policies + triggers + indexes) |
| `supabase/fix_triggers_tail.sql` | Missing tail after the trailing-comma error (profile/post/story triggers, calls table, indexes, PowerSync publication) |
| `supabase/functions/send-notification/index.ts` | Server-side push notification function |
| `packages/env/.env.dev` | Development keys |
| `packages/env/.env.prod` | Production keys |

---

## Step 1 — Create your Supabase account & project

1. Go to **https://supabase.com/dashboard** and sign up (GitHub is easiest)
2. Click **New project**
3. Fill in:
   - **Organization** — create one (e.g. "SocialGram")
   - **Name** — `socialgram`
   - **Database Password** — generate a strong one and **save it somewhere**. It cannot be recovered.
   - **Region** — closest to your users
4. Click **Create new project** and wait ~2 minutes

> **Write down your project ref:** the short code in the URL, e.g.
> `https://<project-ref>.supabase.co`. You need it in Steps 6 and 9.

---

## Step 2 — Run the database schema

### If this is a FRESH project (nothing ran yet)

1. In the dashboard click **SQL Editor** in the left sidebar
2. Click **New query**
3. Open `supabase/complete_schema.sql` from this repo and copy the **entire** contents
4. Paste → click **Run** → wait for "Success" (~30 seconds)

### If you already ran it and got the `relation "public.participants" does not exist` error

That error was a schema ordering bug (now fixed). Your database already has
STEP 1-3 (extensions, buckets, avatar/post/story policies). Use the resume script:

1. **SQL Editor** → **New query**
2. Open `supabase/resume_schema.sql` from this repo — copy the **entire** contents
3. Paste → **Run**

This creates everything that failed: all tables, policies, triggers, and indexes.

### If you already ran it and got `syntax error at or near ")"` (line ~651)

That was a trailing-comma bug in the profile-creation trigger (now fixed).
Your database already has everything up to the triggers. Use the tail script:

1. **SQL Editor** → **New query**
2. Open `supabase/fix_triggers_tail.sql` from this repo — copy the **entire** contents
3. Paste → **Run**

This adds: signup/update profile triggers, post/story media cleanup, the `calls`
table, performance indexes, and the PowerSync publication.

### What the schema creates

- **4 storage buckets:** `avatars`, `posts`, `stories`, `messages`
- **16 tables:** `profiles`, `posts`, `post_media`, `videos`, `images`, `comments`,
  `likes`, `subscriptions`, `conversations`, `participants`, `messages`,
  `attachments`, `stories`, `admin_settings`, `admin_audit_logs`, `user_roles`
- **~50 RLS policies** (you can only edit your own posts, etc.)
- **Storage security:** `messages` bucket is **private** (participants-only,
  signed URLs for playback); `posts` bucket is **public** (feed renders via
  public URLs)
- **8 performance indexes** for fast chat/messages queries
- **Triggers:** new user → auto-creates their profile; deleting a post/story →
  deletes its media files

---

## Step 3 — Verify storage buckets

1. Left sidebar → **Storage** → **Buckets**
2. Check each bucket:
   - `posts` → **Public must be ON** (your feed uses `getPublicUrl()`, images 404 without this)
   - `messages` → **Public must be OFF** (voice messages use signed URLs)
   - `avatars` / `stories` → either is fine
3. If `posts` shows OFF: click **Edit** → toggle **Public bucket** → **Save**

---

## Step 4 — Enable Realtime (REQUIRED for instant chat)

Your app listens for new messages via `postgres_changes` on the `messages`
table (`packages/database_client/lib/src/database_client.dart`). Supabase does
**not** enable this by default.

1. Left sidebar → **Database** → **Publications**
2. Click **supabase_realtime**
3. Find **messages** → toggle **ON**
4. Keep `insert`, `update`, `delete` selected
5. Click **Save**

> Without this, messages only appear after refreshing. With it, they appear instantly.

---

## Step 5 — Set up authentication

### Email sign-up
1. Left sidebar → **Authentication** → **Providers**
2. Find **Email** → pencil icon → **Enable Sign ups** ON → **Save**

### Google sign-in (requires Firebase project first)
1. Same page → find **Google** → pencil icon
2. From your Firebase project (Project Settings → Your apps → OAuth credentials):
   - **Client ID** → your web client ID (this is also your `WEB_CLIENT_ID`)
   - **Client secret** → from the same Firebase credentials section
3. In Firebase → Google OAuth client → **Authorized redirect URIs**, add:
   `https://<project-ref>.supabase.co/auth/v1/callback`
4. Paste into Supabase → **Save**

---

## Step 6 — Copy your API keys

1. Left sidebar → **Project Settings** (gear icon) → **API**
2. Copy:
   - **Project URL** → `https://<project-ref>.supabase.co`
   - **anon public key** → the long string starting with `eyJ...`
3. **NEVER touch the "service_role" secret key** — it bypasses all security.
   It only goes to the PowerSync console (see PowerSync guide), never in the app.

---

## Step 7 — Put the keys in your app

1. Open `packages/env/.env.dev` and replace the placeholders:

```env
SUPABASE_URL=https://<your-project-ref>.supabase.co
SUPABASE_ANON_KEY=<your anon key starting with eyJ...>
```

2. Do the same in `packages/env/.env.prod` for release builds
3. Regenerate the compiled values:

```bash
cd packages/env
dart run build_runner build --delete-conflicting-outputs
cd ../..
flutter pub get
```

How it flows: `.env.dev` → `EnvDev` (obfuscated at compile time) →
`packages/shared/lib/src/config/app_flavor.dart` → `lib/bootstrap.dart` →
`packages/powersync_repository/lib/src/powersync_repository.dart`
(`Supabase.initialize()`).

---

## Step 8 — Make yourself admin

1. Sign up normally in the app (or create a user in Dashboard → Authentication → Users)
2. **SQL Editor** → **New query**:

```sql
UPDATE auth.users
SET raw_app_meta_data = '{"role": "admin"}'
WHERE email = 'your-email@gmail.com';
```

3. **Run**, then **sign out and sign back in** in the app (the role is read from
   the login JWT, so a fresh login is required).

> Note: `raw_app_meta_data` (not `app_metadata`) — newer Supabase versions
> removed the `app_metadata` column from `auth.users`. The app reads
> `user.appMetadata['role']` from the JWT (`lib/admin/auth/admin_guard.dart`),
> which is generated from `raw_app_meta_data` — so this works with both.

> If you already ran the resume script and hit the
> `column users.app_metadata does not exist` error: the schema files are now
> fixed, and `supabase/fix_admin_policies.sql` contains the remaining steps
> (admin policies + triggers + indexes). Paste and run it.

---

## Step 9 — Deploy the push-notification Edge Function

This sends chat notifications. The Firebase service-account private key lives
**only** here (server-side), never in the app.

1. Install the Supabase CLI (if not installed):

```bash
# macOS/Linux
brew install supabase/tap/supabase
# Windows (PowerShell)
irm https://get.supabase.com/install.ps1 | iex
```

2. In this repo, run:

```bash
cd supabase
supabase login                    # opens browser, sign in
supabase link --project-ref <your-project-ref>
```

3. Store the Firebase service-account key (downloaded from Firebase →
   Project Settings → Service accounts → Generate new private key):

```bash
supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(cat /path/to/service-account.json)"
```

4. Deploy:

```bash
supabase functions deploy send-notification
```

5. Verify: Dashboard → **Edge Functions** → `send-notification` shows *Deployed*.
   Then send a chat message from one device and check the other gets a notification.

---

## Step 10 — Final verification checklist

| Check | Where | Expect |
|---|---|---|
| Schema ran | SQL Editor | No errors |
| 4 buckets | Storage → Buckets | `posts` public ON, `messages` public OFF |
| Realtime | Database → Publications | `messages` in `supabase_realtime` |
| Email + Google | Authentication → Providers | Both enabled |
| Keys in app | `packages/env/.env.dev` | Real URL + `eyJ...` key |
| Admin | SQL Editor | `app_metadata` = admin |
| Function | Edge Functions | `send-notification` deployed + secret set |

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Sign-up fails (profile error) | Re-run Step 2 — the profile trigger is in the schema |
| Feed images 404 | `posts` bucket Public toggle (Step 3) |
| Messages not instant | Realtime publication on `messages` (Step 4) |
| No push notifications | Secret name must be exactly `FCM_SERVICE_ACCOUNT_JSON`; re-deploy the function |
| 401/403 API errors | Wrong anon key in `.env.dev` — make sure it's the `eyJ...` key, not service_role |
| `relation ... does not exist` when re-running | Don't re-run the full schema on an existing DB — use `resume_schema.sql` or a fresh project |

---

## Next guides

- Firebase setup (google-services.json, service account, FCM)
- PowerSync setup (instance URL, connecting to Supabase)
- ZEGOCLOUD calls — already configured (`ZEGO_APP_ID`/`ZEGO_APP_SIGN` in env)
