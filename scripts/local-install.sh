#!/bin/bash
#
# Build OpenInTerminal from source, ad-hoc sign it and install it into
# /Applications, then restart the Finder extension and Finder.
#
# This is the local-development counterpart of build-unsigned.sh: it only
# builds the main app (not the Lite variants) and installs the result.
#
set -euo pipefail
cd "$(dirname "$0")/.."

PRODUCTS="build/Build/Products/Release"
EXT_ENT="OpenInTerminalFinderExtension/OpenInTerminalFinderExtension.entitlements"
APP_ENT="OpenInTerminal/OpenInTerminal.entitlements"
APP="export/OpenInTerminal.app"

echo "==> Building"
xcodebuild -workspace OpenInTerminal.xcworkspace \
  -scheme OpenInTerminal \
  -configuration Release \
  -derivedDataPath build \
  -destination 'generic/platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build > /tmp/openinterminal-build.log 2>&1 || { tail -20 /tmp/openinterminal-build.log; exit 1; }

echo "==> Packaging"
rm -rf export
mkdir -p export
cp -R "$PRODUCTS/OpenInTerminal.app" export/
mkdir -p "$APP/Contents/Library/LoginItems"
cp -R "$PRODUCTS/OpenInTerminalHelper.app" "$APP/Contents/Library/LoginItems/"

echo "==> Ad-hoc signing"
find "$APP" -type f -name "*.dylib" -print0 | while IFS= read -r -d '' d; do codesign --force --sign - "$d"; done
find "$APP" -type d -name "*.framework" -print0 | while IFS= read -r -d '' fw; do codesign --force --sign - "$fw"; done
find "$APP" -type d -name "*.appex" -print0 | while IFS= read -r -d '' ext; do codesign --force --sign - --entitlements "$EXT_ENT" "$ext"; done
find "$APP" -mindepth 1 -type d -name "*.app" -print0 | while IFS= read -r -d '' sub; do codesign --force --sign - "$sub"; done
codesign --force --sign - --entitlements "$APP_ENT" "$APP"
codesign --verify --deep --strict "$APP"

echo "==> Stopping running instances"
pkill -f "OpenInTerminal.app/Contents/MacOS/OpenInTerminal" 2>/dev/null || true
pkill -f "OpenInTerminalFinderExtension" 2>/dev/null || true
sleep 1

echo "==> Installing into /Applications"
rm -rf /Applications/OpenInTerminal.app
cp -R "$APP" /Applications/
xattr -dr com.apple.quarantine /Applications/OpenInTerminal.app 2>/dev/null || true
codesign --verify --deep --strict /Applications/OpenInTerminal.app

echo "==> Starting app"
open -a /Applications/OpenInTerminal.app
sleep 2

echo "==> Restarting Finder extension"
pluginkit -e use -i wang.jianing.app.OpenInTerminal.OpenInTerminalFinderExtension >/dev/null 2>&1 || true
killall Finder 2>/dev/null || true

echo "==> Done"
