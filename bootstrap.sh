#!/usr/bin/env bash
# LidAwake — one-command bootstrap for a fresh Mac.
#
# Run it with (note the Homebrew-style form — keeps your terminal as stdin so
# the password / Xcode prompts work; a plain `curl | bash` would break sudo):
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lioisquiet/lidawake/main/bootstrap.sh)"
#
# Does EVERYTHING: ensures the Swift compiler (Xcode Command Line Tools), clones
# the repo, then builds + installs the menu-bar app (app bundle, passwordless
# pmset rule, Login Item) and launches it.
set -euo pipefail

REPO="https://github.com/lioisquiet/lidawake.git"

echo "LidAwake — one-command install"

# 1. ensure the Swift compiler (ships with the Xcode Command Line Tools).
if ! command -v swiftc >/dev/null 2>&1; then
  echo "→ Xcode Command Line Tools are needed (one-time)."
  echo "  A system dialog will appear — click \"Install\" and accept."
  xcode-select --install 2>/dev/null || true
  printf "  waiting for the tools to finish installing"
  until command -v swiftc >/dev/null 2>&1 && xcode-select -p >/dev/null 2>&1; do
    printf "."
    sleep 5
  done
  echo " ✓"
fi

# 2. fetch a fresh copy.
DIR="$(mktemp -d)"
trap 'rm -rf "$DIR"' EXIT
echo "→ fetching LidAwake…"
git clone --depth 1 -q "$REPO" "$DIR/lidawake"

# 3. build + install + launch (asks for your Mac password once).
cd "$DIR/lidawake"
./install.sh
