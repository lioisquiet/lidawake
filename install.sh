#!/usr/bin/env bash
# LidAwake installer — builds the menu-bar "keep awake with lid closed" toggle
# from source and sets up everything it needs on THIS Mac.
#
# Why build (not copy the .app): the binary is chip-specific (arm64 vs Intel)
# and unsigned (copying triggers Gatekeeper quarantine). Building locally avoids
# both. The sudoers rule below is what lets the toggle run pmset without a
# password — it is machine-local and NOT part of the .app, which is why copying
# the app alone never works on a fresh Mac.
#
# Install on any MacBook:
#   1. git clone this repo (or copy main.swift + install.sh) onto the Mac
#   2. run:  ./install.sh
#   3. enter your Mac password once (for the sudoers rule)
#
# Requires: Xcode Command Line Tools (`xcode-select --install`) for swiftc.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
USER_NAME="$(id -un)"
APP="$HOME/Applications/LidAwake.app"

command -v swiftc >/dev/null || {
  echo "swiftc not found — run: xcode-select --install" >&2
  exit 1
}

echo "1/4  building (swiftc)…"
swiftc -O "$HERE/main.swift" -o "$HERE/LidAwake"

echo "2/4  assembling $APP …"
mkdir -p "$APP/Contents/MacOS"
cp -f "$HERE/LidAwake" "$APP/Contents/MacOS/LidAwake"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>LidAwake</string>
  <key>CFBundleIdentifier</key><string>com.cipher.lidawake</string>
  <key>CFBundleExecutable</key><string>LidAwake</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST

echo "3/4  installing passwordless pmset rule (your password, once)…"
SUDOERS_TMP="$(mktemp)"
# the app runs:  sudo -n /usr/bin/pmset -a disablesleep <0|1>
echo "$USER_NAME ALL=(ALL) NOPASSWD: /usr/bin/pmset -a disablesleep *" > "$SUDOERS_TMP"
sudo visudo -cf "$SUDOERS_TMP"                                   # validate syntax first
sudo install -m 440 -o root -g wheel "$SUDOERS_TMP" /etc/sudoers.d/lidawake
rm -f "$SUDOERS_TMP"

echo "4/4  adding to Login Items + launching…"
osascript -e 'tell application "System Events" to delete (every login item whose name is "LidAwake")' >/dev/null 2>&1 || true
osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$APP\", hidden:true}" >/dev/null
open "$APP"

echo
echo "✓ done — look for the sun/moon icon in the menu bar (top-right)."
echo "  sun = staying awake with the lid closed · moon = normal sleep · click to toggle · right-click to quit."
