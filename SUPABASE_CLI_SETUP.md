# SocialGram — Supabase CLI Setup (Push Notifications)

Deploying the `send-notification` Edge Function requires the Supabase CLI.
This guide covers installing it and deploying the function.

> **Why not the SQL Editor?** The SQL Editor can only run database queries.
> Edge Functions are built and deployed server-side — that requires either the
> CLI, or the GitHub integration. This guide uses the CLI (already installed
> on this machine, v2.112.0).

---

## Step 1 — Install the CLI (done already)

The binary was installed to `~/.local/bin/supabase` (no brew needed):

```bash
# Verify it works (in a NEW terminal, or after running: source ~/.bashrc)
supabase --version
```

If the command is not found, add the path first:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## Step 2 — Login

```bash
supabase login
```

- Opens your browser → sign in to Supabase → click **Authorize**
- Terminal shows something like `You are now logged in` / `Login successful`

---

## Step 3 — Link to your project

```bash
cd <path-to-this-project>/supabase
supabase link --project-ref <your-project-ref>
```

- `<your-project-ref>` = the short code in your Supabase project URL
  (e.g. `pofxlnklnvggzazbcsjv` from `https://pofxlnklnvggzazbcsjv.supabase.co`)
- If you have several projects, it may ask you to select one — choose the
  project the app uses
- Expected output: `Finished supabase link.`

---

## Step 4 — Store the Firebase key as a secret

The Firebase service-account JSON (downloaded from Firebase → Project Settings →
Service accounts → Generate new private key) is given to Supabase as a secret.
The app never sees this key — only the Edge Function uses it, server-side.

```bash
supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(cat /path/to/service-account.json)"
```

- Replace `/path/to/service-account.json` with the real file location
  (e.g. `/home/rhythmthebillio/socialgram-abc12-firebase-adminsdk-xxxx.json`)
- Expected output: `Secrets are updated`

> ⚠️ Keep this file OUTSIDE the app project and NEVER commit it to git.

---

## Step 5 — Deploy the function

```bash
supabase functions deploy send-notification
```

- Expected output: upload logs + `Deployed Function send-notification`

---

## Step 6 — Verify

1. Supabase dashboard → **Edge Functions**
2. `send-notification` should show status **Deployed**
3. Final test: send a chat message from one device → other device gets a
   notification (requires two signed-in devices)

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `command not found: supabase` | `export PATH="$HOME/.local/bin:$PATH"` (add to `~/.bashrc` to persist) |
| `supabase login` says already logged in | Skip — go to Step 3 |
| `link` asks for a token/access | Run `supabase login` first |
| `secrets set` error | The service-account.json path is wrong, or you're not linked |
| `functions deploy` fails with auth error | Re-run `supabase link --project-ref <ref>` in the `supabase` folder |
| Wrong project | `supabase link --project-ref` again with the correct ref |
| Function deployed but no notifications | Check Step 4 secret name is EXACTLY `FCM_SERVICE_ACCOUNT_JSON`; then re-deploy |
