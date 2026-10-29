#!/bin/bash
pkill -x SnapButton 2>/dev/null || true
rm -rf /Applications/SnapButton.app
echo "👋 SnapButton removed."
