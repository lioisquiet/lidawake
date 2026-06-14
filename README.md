# LidAwake

A tiny macOS menu-bar toggle that keeps your Mac **awake with the lid closed** —
one click, no Terminal, no settings dialogs.

- ☀️ **sun** = staying awake (closing the lid keeps everything running)
- 🌙 **moon** = normal sleep

Click the icon to flip. Right-click to quit. The icon is a monochrome template
glyph, so it adapts to light/dark menu bars automatically.

Under the hood it just toggles `pmset -a disablesleep`, the same thing power
users run by hand — wrapped in a one-click menu-bar item.

## Install — one command

Paste this into Terminal. It does everything on a fresh Mac (installs the Swift
compiler if missing, clones, builds, sets up the menu-bar app + login item):

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lioisquiet/lidawake/main/bootstrap.sh)"
```

Enter your Mac password **once** when prompted (it installs a passwordless
`pmset` rule so the toggle never asks again). The sun/moon icon then appears in
the menu bar, set to start at login.

### Or, from a clone

```sh
git clone https://github.com/lioisquiet/lidawake.git
cd lidawake
./install.sh
```

(Needs the Xcode Command Line Tools — `xcode-select --install` — for the Swift
compiler. The one-command installer handles that for you.)

## Why a build script instead of a prebuilt app?

Three reasons copying a `.app` between Macs doesn't work, all handled by
`install.sh`:

1. **Chip** — the binary is architecture-specific (Apple Silicon vs Intel).
   Building from source compiles for whatever Mac you're on.
2. **Gatekeeper** — an unsigned app copied from another machine gets quarantined
   ("can't be opened"). A locally built one isn't.
3. **The sudoers rule** — `/etc/sudoers.d/lidawake` is what lets the toggle run
   `pmset` without a password. It's machine-local and *not* inside the app, so a
   copied app silently fails to toggle. The installer sets it up.

## How it works

- `main.swift` — ~80 lines of Cocoa: an `LSUIElement` menu-bar app that reads
  `pmset -g` to show the current state and runs `sudo -n pmset -a disablesleep
  <0|1>` to flip it.
- `install.sh` — builds it (`swiftc`), assembles `~/Applications/LidAwake.app`,
  installs the sudoers rule (validated with `visudo -c`), adds a Login Item, and
  launches it.

## Verify it's working

```sh
pmset -g | grep SleepDisabled    # 1 = staying awake, 0 = normal
```

Clicking the icon should flip that value.

## Uninstall

```sh
osascript -e 'tell application "System Events" to delete (every login item whose name is "LidAwake")'
rm -rf ~/Applications/LidAwake.app
sudo rm -f /etc/sudoers.d/lidawake
sudo pmset -a disablesleep 0       # back to normal sleep
```

## License

MIT
