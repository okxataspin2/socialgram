# What To Run — SocialGram Build & Deploy Commands

> Open a **terminal**: press **Ctrl+Alt+T**. Work from the project folder:
> ```
> cd <your-project-folder>  # e.g. ~/socialgram
> ```

---

## 1. Java is already installed (done)

Only needed in THIS terminal if it says "Java not found":

```
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
```

(New terminals don't need it — it's saved in `~/.bashrc`.)

---

## 2. Test the app on a phone / emulator

```
flutter run -t lib/main_development.dart
```

Press `q` in the terminal to stop. Tell your assistant the output.

---

## 3. Build the Android APK (to install on any phone)

```
flutter build apk --release -t lib/main_development.dart
```

- When done it prints the location: `build/app/outputs/flutter-apk/app-release.apk`
- Copy that file to your phone and install it.

---

## 4. Build the website

```
flutter build web --release -t lib/main_development.dart
```

- When done it prints `build/web`.

⚠️ If this step shows errors about `dart:io`, STOP and ask the assistant — it needs a code fix first.

---

## 5. Upload the website to Netlify (easiest)

1. Go to https://app.netlify.com and sign in (free)
2. Click **Add an app → Deploy from folder** (drag-and-drop)
3. Drag the **`build/web`** folder (inside your project folder) into the drop box
4. Wait a moment — you get a URL like `your-site.netlify.app`

## 5b. Or upload to Cloudflare instead:

1. Go to https://dash.cloudflare.com → **Workers & Pages** → **Create** → **Pages** → **Upload assets**
2. Drag the **`build/web`** folder in
3. You get a URL like `your-site.pages.dev`

---

## Reminders

- After changing any `.env` file, regenerate the code:

```
cd packages/env
dart run build_runner build --delete-conflicting-outputs
cd ../..
```