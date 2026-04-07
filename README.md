# Universal Control Fix

A macOS menu bar tool that monitors and fixes Universal Control between two Macs.

Universal Control frequently drops the connection between Macs. This tool sits in your menu bar and lets you fix it with one click.

## What it does

- Shows **UC ✓** (green) or **UC ✗** (red) in your menu bar based on process status
- Refreshes every 10 seconds
- Click for three fix levels:
  - **Quick Fix** — sends a reconnect signal (fixes most drops)
  - **Hard Fix** — restarts all UC processes (UniversalControl, rapportd, sharingd, ControlCenter)
  - **Nuclear Fix** — deletes corrupted preference files + restarts everything including Bluetooth
- **Open Displays Settings** shortcut — triggers a device rescan (a known instant-reconnect trick)

## Requirements

- macOS with [Homebrew](https://brew.sh) installed

## Install

```bash
git clone https://github.com/slyapustin/universal-control-fix.git
cd universal-control-fix
./install.sh
```

The installer will:
1. Install [SwiftBar](https://github.com/swiftbar/SwiftBar) (menu bar plugin framework)
2. Copy the plugin to `~/.config/swiftbar-plugins/`
3. Configure passwordless sudo for UC process restarts (will ask for your password once)
4. Launch SwiftBar

## Uninstall

```bash
./uninstall.sh
```

## How it works

Universal Control uses several system processes to maintain the connection between Macs:

| Process | Role |
|---|---|
| `UniversalControl` | Main UC process |
| `rapportd` | Peer-to-peer device communication |
| `sharingd` | Device discovery |
| `ControlCenter` | System UI toggle state |

When UC drops, restarting these processes forces macOS to re-establish the connection. The "Quick Fix" sends a `HUP` signal to `UniversalControl` which triggers reconnection without a full restart.

## Tips

- Try **Quick Fix** first — it's the fastest and works most of the time
- If Quick Fix doesn't help, use **Hard Fix**
- **Nuclear Fix** is for when nothing else works — it deletes UC preference files and restarts Bluetooth
- You only need this on one Mac — fixing one side re-establishes the connection
- Opening **Displays Settings** is a known trick that forces UC to scan for nearby devices

## License

MIT
