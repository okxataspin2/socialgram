# SocialGram — PowerSync Setup Tutorial (Offline Sync)

PowerSync relays your Supabase tables to a local SQLite database on the phone,
so the app works offline. When back online, changes sync both ways.

**How it works in this app (no code changes needed):**
- User signs in with Supabase → the app passes the Supabase JWT to PowerSync
  (`packages/powersync_repository/lib/src/powersync_repository.dart`)
- PowerSync reads table changes from your Supabase DB via the `powersync`
  publication (already created by `complete_schema.sql`)
- All reads in the app go through the local DB (`database_client.dart` uses
  `.watch()` on ~15 tables)
- Your app's SDK is `powersync 1.18.0` → Sync Streams supported out of the box

> **Note on console terms:** PowerSync renamed "Sync Rules" → **Sync Streams**
> (new YAML format, `edition: 3`). Use Sync Streams — the legacy JSON format
> below is only kept as reference.

---

## Step 1 — Create the replication user in Supabase

PowerSync needs a dedicated Postgres user with replication access. In
**Supabase → SQL Editor → New query**, run:

```sql
do $$
begin
  if not exists (select from pg_roles where rolname = 'powersync') then
    create role powersync replication login password 'CHANGE_ME_STRONG_PASSWORD';
  end if;
end $$;

grant select on all tables in schema public to powersync;
alter default privileges in schema public grant select on tables to powersync;
grant usage on schema public to powersync;

grant select on all tables in schema auth to powersync;
alter default privileges in schema auth grant select on tables to powersync;
grant usage on schema auth to powersync;
```

> ⚠️ Use a strong password and save it — you'll paste it into PowerSync (Step 2).

Your `powersync` publication already exists (created by `complete_schema.sql`).

---

## Step 2 — Create the database connection in PowerSync

In the PowerSync dashboard → your instance → **Connect to a Database** (this is
the form you saw with Postgres/MongoDB/MySQL tabs — choose **Postgres**):

| Field | Value |
|---|---|
| Connection string (URI) | `postgresql://powersync:CHANGE_ME_STRONG_PASSWORD@db.<project-ref>.supabase.co:5432/postgres` |
| Host | `db.<project-ref>.supabase.co` (your ref: `ghvgpkxehccdwgxmojrt`) |
| Port | `5432` |
| Database | `postgres` |
| Username | `powersync` |
| Password | the password from Step 1 |
| SSL mode | `verify-full` (see CA note below) |
| Replication user | `powersync` |

**CA certificate:** if it asks for one, download it from
Supabase → Project Settings → **Database** → Connection string section →
the certificate download link (named something like `supabase-ca.crt` or
`leptos-ca.crt`) and upload it.

> If the console offers a **Supabase**-specific connection option (one-click),
> use that instead — it takes the same connection string and configures
> everything for you.

Click **Test Connection** → should succeed → **Save**.

---

## Step 3 — Configure Client Auth (required!)

This lets your app's Supabase JWT authenticate against PowerSync. Without it
you'll get `401` / `PSYNC_S2105` errors on connect.

1. In the PowerSync dashboard → your instance → **Client Auth**
2. Enable **Use Supabase Auth**
3. Leave the **JWT secret** field **empty** — PowerSync auto-detects your
   Supabase project from the connection string and uses the JWKS URL
   (`https://<ref>.supabase.co/auth/v1/.well-known/jwks.json`) with audience
   `authenticated`
4. **Save and Deploy**

---

## Step 4 — Configure Sync Streams

In the PowerSync dashboard → your instance → **Sync Streams** → edit the YAML
and replace everything with:

```yaml


config:
  edition: 3

streams:
  public_data:
    auto_subscribe: true
    queries:
      - SELECT * FROM profiles
      - SELECT * FROM posts
      - SELECT * FROM post_media
      - SELECT * FROM videos
      - SELECT * FROM images
      - SELECT * FROM comments
      - SELECT * FROM likes
      - SELECT * FROM subscriptions
      - SELECT * FROM stories

  my_roles:
    auto_subscribe: true
    query: SELECT * FROM user_roles WHERE user_id = auth.user_id()

  my_calls:
    auto_subscribe: true
    query: SELECT * FROM calls WHERE caller_id = auth.user_id() OR callee_id = auth.user_id()

  my_conversations:
    auto_subscribe: true
    query: SELECT * FROM conversations WHERE id IN (SELECT conversation_id FROM participants WHERE user_id = auth.user_id())

  my_participants:
    auto_subscribe: true
    query: SELECT * FROM participants WHERE user_id = auth.user_id()

  my_messages:
    auto_subscribe: true
    query: SELECT * FROM messages WHERE conversation_id IN (SELECT conversation_id FROM participants WHERE user_id = auth.user_id())

  my_attachments:
    auto_subscribe: true
    query: SELECT * FROM attachments WHERE message_id IN (SELECT id FROM messages WHERE conversation_id IN (SELECT conversation_id FROM participants WHERE user_id = auth.user_id()))




```



What this does:
- **`public_data`** → profiles/posts/comments/likes/subscriptions/stories sync
  for everyone (like Instagram's public feed)
- **`my_*`** streams → each user only syncs their own conversations, messages,
  attachments, calls, and role — `auth.user_id()` is the logged-in user's ID
  from the Supabase JWT
- **`auto_subscribe: true`** → everything syncs upfront on connect, exactly
  like the app expects (its `watch()` queries just read the local DB) — **no
  client code changes needed**

Then:
1. Click **Validate** — should report no errors (it validates against your
   live Postgres DB)
2. Click **Deploy**

> Legacy alternative (only if your console still says **Sync Rules**):
> ```json
> {
>   "bucket_definitions": {
>     "global": {
>       "data": [
>         { "query": "SELECT id FROM profiles" },
>         { "query": "SELECT id FROM posts" },
>         { "query": "SELECT id FROM post_media" },
>         { "query": "SELECT id FROM videos" },
>         { "query": "SELECT id FROM images" },
>         { "query": "SELECT id FROM comments" },
>         { "query": "SELECT id FROM likes" },
>         { "query": "SELECT id FROM subscriptions" },
>         { "query": "SELECT id FROM stories" },
>         { "query": "SELECT id FROM calls WHERE caller_id = auth_user_id() OR callee_id = auth_user_id()" },
>         { "query": "SELECT id FROM conversations WHERE id IN (SELECT conversation_id FROM participants WHERE user_id = auth_user_id())" },
>         { "query": "SELECT id FROM participants WHERE user_id = auth_user_id()" },
>         { "query": "SELECT id FROM messages WHERE conversation_id IN (SELECT conversation_id FROM participants WHERE user_id = auth_user_id())" },
>         { "query": "SELECT id FROM attachments WHERE message_id IN (SELECT id FROM messages WHERE conversation_id IN (SELECT conversation_id FROM participants WHERE user_id = auth_user_id()))" },
>         { "query": "SELECT id FROM user_roles WHERE user_id = auth_user_id()" }
>       ]
>     }
>   }
> }
> ```

---

## Step 5 — Put the instance URL in the app

1. In the instance page, copy the **Instance URL** (e.g.
   `https://socialgram-xxxx.powersync.journeyapps.com`)
2. Open `packages/env/.env.dev`, replace line 3:

```env
POWERSYNC_URL=https://socialgram-xxxx.powersync.journeyapps.com
```

3. Do the same in `packages/env/.env.prod`
4. Regenerate (required after every env change):

```bash
cd packages/env
dart run build_runner build --delete-conflicting-outputs
cd ../..
```

---

## Step 6 — Verify it works

1. `flutter run` → sign in
2. Watch console logs — the connector logs the session on connect
   (`powersync_repository.dart` prints `Session: ...`)
3. Turn on **Airplane mode** → the app still shows posts/messages (local DB)
4. Post something while offline → it queues → when back online it uploads
   (handled by `uploadData()` in `powersync_repository.dart:88`)

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `401` / `PSYNC_S2105` on connect | Client Auth not configured — Step 3 (enable Use Supabase Auth, leave secret empty) |
| `Test Connection` fails | Wrong password from Step 1, or SSL/CA cert wrong |
| Nothing syncs | `SELECT pubname FROM pg_publication;` → must include `powersync` |
| `relation ... does not exist` in sync logs | Table name typo in streams YAML |
| Validate errors on `auth.user_id()` | Client Auth not enabled (Step 3) — the function needs it |
| Messages missing for one user | Check `my_messages` query columns match (`conversation_id`, `id`) |

---

## Free tier limits

- 10 GB sync data/month (plenty for a starter app)
- 1,000,000 sync records/month
- 30-day data retention

## Remaining keys in `.env.dev` after this guide

| Key | Needed for | Setup |
|---|---|---|
| `POWERSYNC_URL` | Offline sync | This guide, Step 5 |
| `IOS_CLIENT_ID`, `WEB_CLIENT_ID`, `FCM_PROJECT_ID` | Google sign-in + push | Firebase guide |
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` | Done | — |
| `CLOUDINARY_*`, `ZEGO_*` | Already filled | — |
