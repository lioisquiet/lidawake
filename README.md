# LidAwake 🌙☀️

**Keep your Mac awake with the lid closed — one click from the menu bar.**

No Terminal incantations, no System Settings spelunking, no background daemon. Just a tiny
menu-bar icon you tap to flip between *stay awake* and *normal sleep*.

![platform](https://img.shields.io/badge/platform-macOS-black?logo=apple)
![language](https://img.shields.io/badge/Swift-AppKit-orange?logo=swift&logoColor=white)
![license](https://img.shields.io/badge/license-MIT-blue)
![size](https://img.shields.io/badge/code-~80%20lines-brightgreen)

- ☀️ **sun** = staying awake — close the lid and everything keeps running
- 🌙 **moon** = normal sleep

Click to flip. Right-click to quit. The icon is a monochrome template glyph, so it adapts to
light/dark menu bars automatically.

> If this saves you a Terminal command, a ⭐ is appreciated — it helps others find it.

## Why you'd want this

- 📥 Keep a **long download / upload / backup** running while the laptop is shut and in a bag.
- 🖥️ Run **clamshell with an external display** without it dozing when you don't want it to.
- 🛠️ Leave a **local build, render, or dev server** going with the lid down.
- 🎧 Keep **audio / a call / a sync** alive when you close the lid for a second.

…then **one click back to moon** so it sleeps normally and saves battery. The icon always shows
which mode you're in.

## Install — 3 steps

**1.** Open **Terminal** (press `⌘ Space`, type `Terminal`, hit Return).

**2.** Paste this line and press Return:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/lioisquiet/lidawake/main/bootstrap.sh)"
```

**3.** Type your Mac password **once** when asked (you won't see it as you type — that's normal —
just press Return).

That's it. The ☀️/🌙 icon appears in the menu bar and starts automatically at login. **Click it to
toggle.** One command does everything: it installs the Swift compiler if missing, builds the app,
sets up the passwordless `pmset` rule, and launches.

### Or, from a clone

```sh
git clone https://github.com/lioisquiet/lidawake.git
cd lidawake
./install.sh
```

(Needs the Xcode Command Line Tools — `xcode-select --install` — for the Swift compiler. The
one-command installer handles that for you.)

## FAQ

**Will it drain my battery?** Preventing sleep uses more power than sleeping — that's the point.
Flip it back to 🌙 when you're done; the icon shows the state at a glance so you never forget.

**Is it safe / what does it actually do?** It only toggles Apple's own `pmset -a disablesleep`,
the documented clamshell-sleep switch. No kernel extensions, no telemetry, no daemon beyond the
menu-bar app itself. ~80 lines of Swift you can read in a minute.

**Why not just `caffeinate`?** `caffeinate` keeps the Mac awake but, by default, **not** with the
lid closed — `disablesleep` is the clamshell-specific switch. LidAwake wraps it in a one-click
visual toggle so you don't memorize flags or leave a Terminal open.

**Heat?** Running hard in clamshell can get warm — keep it on a hard surface (not a soft bag)
under sustained load.

## Why a build script instead of a prebuilt `.app`?

Three reasons copying a `.app` between Macs doesn't work — all handled by `install.sh`:

1. **Chip** — the binary is architecture-specific (Apple Silicon vs Intel). Building from source
   compiles for whatever Mac you're on.
2. **Gatekeeper** — an unsigned app copied from another machine gets quarantined ("can't be
   opened"). A locally built one isn't.
3. **The sudoers rule** — `/etc/sudoers.d/lidawake` is what lets the toggle run `pmset` without a
   password. It's machine-local and *not* inside the app, so a copied app silently fails. The
   installer sets it up (validated with `visudo -c`).

## How it works

- `main.swift` — ~80 lines of AppKit: an `LSUIElement` menu-bar app that reads `pmset -g` to show
  the current state and runs `sudo -n pmset -a disablesleep <0|1>` to flip it.
- `install.sh` — builds it (`swiftc`), assembles `~/Applications/LidAwake.app`, installs the
  sudoers rule, adds a Login Item, and launches it.
- `bootstrap.sh` — the one-command entry point: ensures the Swift compiler, clones, runs the
  installer.

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

## Contributing

Issues and PRs welcome — it's intentionally tiny and dependency-free. Ideas: a menu with a timer
("stay awake for 1h"), a packaged signed release, an Intel test pass.

## License

[MIT](LICENSE) — do whatever you like.
