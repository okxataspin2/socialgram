#!/usr/bin/env bash
set -euo pipefail

# Portable Flutter web build for any static host (Netlify, Vercel,
# Cloudflare Pages, Render, ...). Publishes to ./build/web.
#
# Usage: bash scripts/portable_web_build.sh [--dev|--prod]
#   --prod (default): uses lib/main_production.dart and packages/env/.env.prod
#   --dev:            uses lib/main_development.dart and packages/env/.env.dev

TARGET="lib/main_production.dart"
if [ "${1:-}" = "--dev" ]; then
  TARGET="lib/main_development.dart"
fi

echo ">> Installing Flutter (stable) if missing..."
if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -d "$HOME/flutter" ]; then
    git clone --branch stable --depth 1 \
      https://github.com/flutter/flutter.git "$HOME/flutter"
  fi
  export PATH="$PATH:$HOME/flutter/bin"
fi

flutter config --no-analytics
echo ">> Resolving dependencies..."
flutter pub get
echo ">> Preparing PowerSync web workers..."
dart run powersync:setup_web
echo ">> Building web ($TARGET)..."
flutter build web --release -t "$TARGET"
echo ">> Build finished: ./build/web"
