#!/bin/zsh
# Weekly re-sign + install of KabirSpanish onto Kabir's iPhone.
# Runs under launchd every 6 days (before the 7-day free-tier provisioning
# profile expires). Requires:
#   - Mac awake at trigger time (launchd will skip if asleep and run on wake)
#   - iPhone paired, reachable (connected via USB or on same Wi-Fi), unlocked
#   - Apple ID still signed in to Xcode (free-tier 2FA session has to be live)
#
# Logs go to ~/Library/Logs/KabirSpanishReinstall.log

set -u
LOGFILE="$HOME/Library/Logs/KabirSpanishReinstall.log"
PROJECT_DIR="/Users/ashish/Documents/spanish recordings/project verbs/ios"
DEVICE_ID="8FB8DED9-E57F-505F-9800-AC1E3DE86A55"
APP_PATH="$PROJECT_DIR/build/Build/Products/Debug-iphoneos/KabirSpanish.app"

exec >> "$LOGFILE" 2>&1
echo
echo "===== $(date '+%Y-%m-%d %H:%M:%S') reinstall-weekly starting ====="

cd "$PROJECT_DIR" || { echo "ERR: cd failed"; exit 2; }

# Ensure xcode + devicectl are on PATH (launchd uses a minimal PATH)
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin"

# 1. Device must be reachable
state=$(xcrun devicectl list devices 2>/dev/null | awk -v d="$DEVICE_ID" '$0 ~ d {print $(NF-1)" "$NF}')
echo "device state: $state"
if ! echo "$state" | grep -qE "connected|available"; then
  echo "SKIP: device not reachable; will retry on next schedule"
  exit 0
fi

# 2. Clean rebuild (forces fresh signing against the latest Xcode-managed profile)
echo "cleaning old build…"
rm -rf build

echo "building…"
if ! xcodebuild -project KabirSpanish.xcodeproj \
                -scheme KabirSpanish \
                -configuration Debug \
                -destination 'generic/platform=iOS' \
                -allowProvisioningUpdates \
                -derivedDataPath build; then
  echo "ERR: build failed. Most likely cause: Apple ID 2FA session expired."
  echo "FIX: open Xcode → Settings → Accounts → re-sign in to varikagoel18@gmail.com, then run this script manually."
  exit 3
fi

# 3. Install
echo "installing to device $DEVICE_ID…"
if ! xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH"; then
  echo "ERR: install failed (phone locked? USB dropped? Wi-Fi off?)"
  exit 4
fi

echo "===== $(date '+%Y-%m-%d %H:%M:%S') reinstall complete ====="
