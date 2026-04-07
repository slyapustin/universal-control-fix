#!/bin/bash

# <xbar.title>Universal Control Fix</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Sergey</xbar.author>
# <xbar.desc>Monitor and fix Universal Control between two Macs</xbar.desc>

export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

UC_RUNNING=$(pgrep -x UniversalControl 2>/dev/null)
RAPPORTD_RUNNING=$(pgrep -x rapportd 2>/dev/null)

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
    # Kill all processes
    killall UniversalControl 2>/dev/null
    sudo killall rapportd 2>/dev/null
    killall sharingd 2>/dev/null
    killall ControlCenter 2>/dev/null
    sudo pkill bluetoothd 2>/dev/null
    # Delete corrupted prefs
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

# Silent keepalive — nudge UC to re-check connections every refresh cycle
pkill -HUP UniversalControl 2>/dev/null

# Menu bar icon — neutral since we can't detect actual connection state
echo "UC | sfimage=rectangle.connected.to.line.below"

echo "---"

# Fix actions (most useful first)
echo "⚡ Quick Fix (reconnect signal) | bash='$0' param1=soft-fix terminal=false"
echo "🔧 Hard Fix (restart all UC processes) | bash='$0' param1=hard-fix terminal=false"
echo "☢️ Nuclear Fix (reset prefs + restart all) | bash='$0' param1=nuclear-fix terminal=false"

echo "---"

echo "Open Displays Settings (triggers rescan) | bash='$0' param1=open-displays terminal=false"

echo "---"

# Process status (informational only — running doesn't mean connected)
echo "Processes | size=11 color=gray"
if [[ -n "$UC_RUNNING" ]]; then
    echo "  UniversalControl: running (PID $UC_RUNNING) | size=11"
else
    echo "  UniversalControl: not running | color=red size=11"
fi
if [[ -n "$RAPPORTD_RUNNING" ]]; then
    echo "  rapportd: running (PID $RAPPORTD_RUNNING) | size=11"
else
    echo "  rapportd: not running | color=red size=11"
fi
