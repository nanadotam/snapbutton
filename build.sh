#!/bin/bash
# Builds SnapButton.app and SnapButton.dmg into ./dist
set -euo pipefail
cd "$(dirname "$0")"
APP=dist/SnapButton.app
rm -rf dist build && mkdir -p build "$APP/Contents/MacOS" "$APP/Contents/Resources"

# Artwork
swift scripts/art.swift build
mkdir build/AppIcon.iconset
for s in 16 32 128 256 512; do
  sips -z $s $s build/icon_1024.png --out build/AppIcon.iconset/icon_${s}x${s}.png >/dev/null
  sips -z $((s*2)) $((s*2)) build/icon_1024.png --out build/AppIcon.iconset/icon_${s}x${s}@2x.png >/dev/null
done
iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
cp build/icon_1024.png assets/icon.png

# Universal binary (Apple Silicon + Intel)
for arch in arm64 x86_64; do
  swiftc -O -target $arch-apple-macos13 src/main.swift -o build/SnapButton-$arch
done
lipo -create build/SnapButton-* -output "$APP/Contents/MacOS/SnapButton"
cp src/Info.plist "$APP/Contents/"
codesign --force --deep -s - "$APP"

# Drag-to-Applications DMG
create-dmg --volname "SnapButton" --background build/dmg_bg.png --window-size 640 400 \
  --icon-size 112 --icon SnapButton.app 170 205 --app-drop-link 470 205 \
  --hide-extension SnapButton.app --no-internet-enable dist/SnapButton.dmg "$APP" >/dev/null
(cd dist && ditto -c -k --keepParent SnapButton.app SnapButton.zip)
echo "Built dist/SnapButton.dmg and dist/SnapButton.zip"
