# SocialGram — Firebase Setup Tutorial (Push Notifications + Google Sign-In)

Firebase provides two things in this app:
1. **FCM push notifications** — chat messages trigger notifications via the
   `send-notification` Supabase Edge Function
2. **Google OAuth client IDs** — for "Sign in with Google" (used by
   `GoogleSignIn` in `main_development.dart` and the Supabase Google provider)
3. **Remote config** — optional flags (initialized in `lib/bootstrap.dart`)

---

## Step 1 — Create the Firebase project

1. Go to **https://console.firebase.google.com** → **Add project**
2. Name it `socialgram` → continue (Google Analytics optional, skip if you want)
3. Wait for creation → **Continue**

> **Write down your Project ID** (top-left under the project name), e.g.
> `socialgram-abc12`. That's your `FCM_PROJECT_ID`.

---

## Step 2 — Add your Android app (REQUIRED for push)

1. In the project, click the **Android icon** (`< />`)
2. **Android package name:** `com.emilzulufov.flutter_instagram_offline_first_clone`
   (exact — matches `android/app/build.gradle` line 53)
3. Click **Register app**
4. Download **google-services.json**
5. Move it into your project: `android/app/google-services.json`
   (the folder already has the Gradle plugin wired up — `build.gradle` line 5 —
   so no build changes needed)

## Step 3 — Add your iOS app (later, for iOS builds)

1. Click **Add app** → **iOS icon**
2. Bundle ID = your iOS bundle ID (check `ios/Runner.xcodeproj` → Build Settings →
   PRODUCT_BUNDLE_IDENTIFIER)
3. Download **GoogleService-Info.plist** → move to `ios/Runner/`
4. Optional: the generated `firebase_options.dart` step can be skipped — this
   app uses the native config files via `Firebase.initializeApp()` in
   `lib/bootstrap.dart:57`

---

## Step 4 — Google sign-in client IDs

Firebase auto-created OAuth credentials for you:

1. Firebase console → **Project Settings** (gear) → **General** tab → **Your apps**
2. Under each app you'll see its **OAuth client ID**
3. Copy them into `packages/env/.env.dev`:

```env
IOS_CLIENT_ID=<the iOS client id (e.g. ...-apps.googleusercontent.com)>
WEB_CLIENT_ID=<the web/android client id>
```

- `IOS_CLIENT_ID` = the one labeled **iOS** (used by `GoogleSignIn(clientId: ...)`)
- `WEB_CLIENT_ID` = the **Android** or **Web** one (used as
  `serverClientId` + in the Supabase Google provider)

4. Regenerate:

```bash
cd packages/env
dart run build_runner build --delete-conflicting-outputs
cd ../..
```

5. **Supabase side:** Supabase → Authentication → Providers → **Google** →
   paste `WEB_CLIENT_ID` as **Client ID** and the matching **Client secret**
   (Project Settings → Your apps → the same credential → Client secret) → Save
6. Add the Supabase callback to the Google OAuth client:
   Google Cloud Console → Credentials → your Web client → **Authorized redirect
   URIs** → add `https://<your-project-ref>.supabase.co/auth/v1/callback`

---

## Step 5 — Service account (for the push Edge Function)

This is the **server-side secret**. It must never be in the app or repo.

1. Firebase → **Project Settings** → **Service accounts** tab
2. **Generate new private key** → downloads `service-account.json`
3. Store it in Supabase function secrets:

```bash
cd supabase
supabase login
supabase link --project-ref <your-project-ref>
supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(cat /path/to/service-account.json)"
```

4. Deploy the function (already written in `supabase/functions/send-notification/`):

```bash
supabase functions deploy send-notification
```

> ⚠️ If you previously leaked this key (it was found in the repo and removed),
> **rotate it**: Firebase → Service accounts → Generate new private key →
> this makes the old key invalid. Then redo steps 3-4.

---

## Step 6 — FCM project ID in the app

```env
FCM_PROJECT_ID=<your firebase project id>
```

Then rebuild env (`build_runner` command from Step 4).

---

## Step 7 — Verify push notifications

1. Build & run on a real phone (push doesn't work on emulators reliably)
2. Sign in with **two different accounts** (two devices, or use the app + the
   web version)
3. Account A sends a chat message to B → B gets a notification with a preview
4. The notification payload comes from `lib/notifications/push_service.dart`,
   which calls the Edge Function — server logs at Supabase → Edge Functions →
   `send-notification` → Invocations

**If no notification arrives, check in order:**
1. `google-services.json` exists in `android/app/`
2. Supabase secret name is exactly `FCM_SERVICE_ACCOUNT_JSON`
3. Function deployed (`supabase functions list`)
4. The receiver's device registered a push token (look for
   `FirebaseMessaging` token logs; the app stores it in `profiles.push_token`)
5. The phone's notification permission was granted

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Build fails with "No matching client found" | `google-services.json` doesn't match the package name — re-download after registering the exact package |
| Google sign-in error 12500/10 | `WEB_CLIENT_ID`/`IOS_CLIENT_ID` wrong or swapped |
| Push token is null | `google-services.json` missing or wrong app registered |
| Function returns 401 | Service account key invalid/expired — regenerate and `supabase secrets set` again |
| Notifications only when app open | Android 13+ needs notification permission — check the system prompt was accepted |

---

## Free tier notes

- FCM: unlimited push notifications (no cost)
- Firebase Remote Config: free, 2.5K concurrent users default (plenty)

## Remaining placeholder keys after this guide

| Key | Status |
|---|---|
| `POWERSYNC_URL` | PowerSync guide |
| `IOS_CLIENT_ID`, `WEB_CLIENT_ID`, `FCM_PROJECT_ID` | This guide, steps 4 + 6 |
| `CLOUDINARY_*` | Already filled (unsigned preset — no secret needed) |
| `ZEGO_*` | Already filled |
