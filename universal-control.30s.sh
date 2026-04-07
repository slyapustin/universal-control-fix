#!/bin/bash

# <xbar.title>Universal Control Fix</xbar.title>
# <xbar.version>v2.0</xbar.version>
# <xbar.author>Sergey</xbar.author>
# <xbar.desc>Monitor and fix Universal Control between two Macs</xbar.desc>

export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# Handle actions from menu clicks
if [[ "$1" == "soft-fix" ]]; then
    pkill -HUP UniversalControl 2>/dev/null
    sleep 1
    osascript -e 'display notification "Sent reconnect signal to Universal Control" with title "UC Fix" subtitle "Soft Fix"'
    exit 0
fi

if [[ "$1" == "hard-fix" ]]; then
    killall UniversalControl 2>/dev/null
    sudo killall rapportd 2>/dev/null
    killall sharingd 2>/dev/null
    killall ControlCenter 2>/dev/null
    sleep 2
    osascript -e 'display notification "All UC processes restarted" with title "UC Fix" subtitle "Hard Fix"'
    exit 0
fi

if [[ "$1" == "nuclear-fix" ]]; then
    killall UniversalControl 2>/dev/null
    sudo killall rapportd 2>/dev/null
    killall sharingd 2>/dev/null
    killall ControlCenter 2>/dev/null
    sudo pkill bluetoothd 2>/dev/null
    rm -f ~/Library/Preferences/com.apple.universalcontrol.plist 2>/dev/null
    rm -f ~/Library/Preferences/ByHost/com.apple.universalcontrol.* 2>/dev/null
    sleep 3
    osascript -e 'display notification "Nuclear reset complete. UC will reconnect shortly." with title "UC Fix" subtitle "Nuclear Fix"'
    exit 0
fi

if [[ "$1" == "open-displays" ]]; then
    open "x-apple.systempreferences:com.apple.Displays-Settings.extension"
    exit 0
fi

# --- Detect UC connection state from system logs ---

UC_STATE="unknown"
AUTOFIX_FILE="/tmp/uc-autofix-last"

# Use 5-minute window to catch the last connection event (UC logs are sparse)
entries=$(/usr/bin/log show --last 5m \
  --predicate 'subsystem == "com.apple.universalcontrol" AND category == "EVNT" AND eventMessage CONTAINS "Connected Devices IDS:"' \
  --style compact 2>/dev/null)

if [[ -n "$entries" ]]; then
    last_entry=$(echo "$entries" | tail -1)

    # Check for flapping in the last 30 seconds only (recent instability)
    now_epoch=$(date +%s)
    recent_connects=0
    recent_disconnects=0
    while IFS= read -r line; do
        # Extract timestamp and check if within last 30s
        ts=$(echo "$line" | awk '{print $1 " " $2}')
        ts_epoch=$(date -j -f "%Y-%m-%d %H:%M:%S" "${ts%.*}" +%s 2>/dev/null)
        [[ -z "$ts_epoch" ]] && continue
        age=$((now_epoch - ts_epoch))
        if [[ $age -le 30 ]]; then
            if echo "$line" | grep -q 'Connected Devices IDS: \[.\+\]'; then
                recent_connects=$((recent_connects + 1))
            else
                recent_disconnects=$((recent_disconnects + 1))
            fi
        fi
    done <<< "$entries"

    # Flapping = rapid connect/disconnect cycles in last 30s
    if [[ $recent_connects -gt 3 && $recent_disconnects -gt 3 ]]; then
        UC_STATE="flapping"
        connect_count=$recent_connects
        disconnect_count=$recent_disconnects
    elif echo "$last_entry" | grep -q 'Connected Devices IDS: \[.\+\]'; then
        UC_STATE="connected"
    else
        UC_STATE="disconnected"
    fi
else
    # No log entries in last 5 min — check if UC process is even running
    if pgrep -x UniversalControl >/dev/null 2>&1; then
        UC_STATE="idle"
    else
        UC_STATE="not_running"
    fi
fi

# --- Auto-fix flapping ---
# If UC is flapping, auto-trigger a hard fix (max once per 2 minutes to avoid loops)

if [[ "$UC_STATE" == "flapping" ]]; then
    now=$(date +%s)
    last_fix=0
    [[ -f "$AUTOFIX_FILE" ]] && last_fix=$(cat "$AUTOFIX_FILE")
    elapsed=$((now - last_fix))

    if [[ $elapsed -gt 120 ]]; then
        echo "$now" > "$AUTOFIX_FILE"
        killall UniversalControl 2>/dev/null
        sudo killall rapportd 2>/dev/null
        killall sharingd 2>/dev/null
        killall ControlCenter 2>/dev/null
        osascript -e 'display notification "Detected flapping — auto-restarted UC processes" with title "UC Fix" subtitle "Auto Fix"'
    fi
fi

# --- Menu bar display ---

case "$UC_STATE" in
    connected)
        echo "UC ✓ | color=green sfimage=rectangle.connected.to.line.below"
        ;;
    flapping)
        echo "UC ⚡ | color=orange sfimage=rectangle.connected.to.line.below"
        ;;
    disconnected)
        echo "UC ✗ | color=red sfimage=rectangle.connected.to.line.below"
        ;;
    *)
        echo "UC — | sfimage=rectangle.connected.to.line.below"
        ;;
esac

echo "---"

# Fix actions
echo "⚡ Quick Fix (reconnect signal) | bash='$0' param1=soft-fix terminal=false refresh=true"
echo "🔧 Hard Fix (restart all UC processes) | bash='$0' param1=hard-fix terminal=false refresh=true"
echo "☢️ Nuclear Fix (reset prefs + restart all) | bash='$0' param1=nuclear-fix terminal=false refresh=true"

echo "---"

echo "Open Displays Settings (triggers rescan) | bash='$0' param1=open-displays terminal=false"

echo "---"

# Status info
echo "State: $UC_STATE | size=11 color=gray"
if [[ "$UC_STATE" == "flapping" ]]; then
    echo "  Connects: $connect_count | Disconnects: $disconnect_count (last 30s) | size=11"
fi
echo "---"
echo "Auto-fix: flapping detected → hard restart (max 1x per 2min) | size=11 color=gray"
