#!/bin/bash
# SnapButton installer — downloads the app, puts it in Applications, and opens it.
set -e
echo "📸 Installing SnapButton..."
TMP=$(mktemp -d)
curl -fsSL -o "$TMP/SnapButton.zip" https://github.com/nanadotam/snapbutton/releases/latest/download/SnapButton.zip
pkill -x SnapButton 2>/dev/null || true
rm -rf /Applications/SnapButton.app
ditto -x -k "$TMP/SnapButton.zip" /Applications
xattr -dr com.apple.quarantine /Applications/SnapButton.app 2>/dev/null || true
rm -rf "$TMP"
open /Applications/SnapButton.app
echo "✅ Done! Look for the camera icon at the top of your screen, next to the Wi-Fi."
