# Universal Control Fix

A macOS menu bar tool that monitors and fixes Universal Control between two Macs.

Universal Control frequently drops the connection between Macs. This tool sits in your menu bar, monitors the real connection state via system logs, and can auto-fix common issues.

## What it does

- **Real-time status** in your menu bar based on macOS system logs (`com.apple.universalcontrol`):
  - **UC ✓** (green) — connected to another device
  - **UC ✗** (red) — disconnected
  - **UC ⚡** (orange) — flapping (rapid connect/disconnect cycles — the classic broken state)
  - **UC —** — idle / no recent activity
- **Auto-fix**: Detects flapping and automatically restarts UC processes (rate-limited to once per 2 minutes)
- **Manual fix** — click the icon for three fix levels:
  - **Quick Fix** — sends a reconnect signal (fixes most drops)
  - **Hard Fix** — restarts all UC processes (UniversalControl, rapportd, sharingd, ControlCenter)
  - **Nuclear Fix** — deletes corrupted preference files + restarts everything including Bluetooth
- **Open Displays Settings** shortcut — triggers a device rescan (a known instant-reconnect trick)
- Refreshes every 30 seconds

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

You only need to install on one Mac — fixing one side re-establishes the connection.

## Uninstall

```bash
./uninstall.sh
```

## How it works

### Connection monitoring

The plugin reads macOS unified logs from the `com.apple.universalcontrol` subsystem (`EVNT` category) every 30 seconds. These logs contain `Connected Devices IDS: [...]` entries that reflect the actual connection state — not just whether the process is running.

When the plugin detects **flapping** (more than 3 connect + 3 disconnect events within 30 seconds), it automatically triggers a hard fix. This is rate-limited to once per 2 minutes to avoid restart loops.

### Fix levels

Universal Control uses several system processes to maintain the connection between Macs:

| Process | Role |
|---|---|
| `UniversalControl` | Main UC process |
| `rapportd` | Peer-to-peer device communication |
| `sharingd` | Device discovery |
| `ControlCenter` | System UI toggle state |

- **Quick Fix** sends a `HUP` signal to `UniversalControl`, which triggers reconnection without a full restart.
- **Hard Fix** kills and restarts all four processes.
- **Nuclear Fix** additionally resets Bluetooth and deletes UC preference files. Expect a brief Bluetooth interruption (keyboard/mouse may disconnect momentarily).

## Tips

- Try **Quick Fix** first — it's the fastest and works most of the time
- If Quick Fix doesn't help, use **Hard Fix**
- **Nuclear Fix** is for when nothing else works — expect your Bluetooth keyboard/mouse to briefly disconnect
- Opening **Displays Settings** is a known trick that forces UC to scan for nearby devices

## License

MIT
