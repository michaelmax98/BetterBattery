#!/bin/bash
# Builds a standalone BetterBattery.app into ./build
# Version can be overridden: VERSION=1.2.0 ./build-app.sh
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${VERSION:-1.0.0}"

# Universal binary so the app runs on both Apple silicon and Intel Macs.
# Each slice is built separately and merged with lipo, which works with just
# the Command Line Tools (a multi-arch `swift build` needs full Xcode).
ARCHS=(arm64 x86_64)
SLICES=()
for arch in "${ARCHS[@]}"; do
  swift build -c release --arch "$arch"
  SLICES+=(".build/${arch}-apple-macosx/release/BetterBattery")
done

APP="build/BetterBattery.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

lipo -create "${SLICES[@]}" -output "$APP/Contents/MacOS/BetterBattery"
cp "Support/Info.plist" "$APP/Contents/Info.plist"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$APP/Contents/Info.plist"

if [ -f "Support/AppIcon.icns" ]; then
  cp "Support/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
fi

# Ad-hoc sign so macOS runs the locally built bundle without complaint.
codesign --force --sign - "$APP" >/dev/null 2>&1 || true

echo "Built $APP (version $VERSION)"
