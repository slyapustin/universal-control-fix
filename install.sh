#!/bin/bash
set -e

PLUGIN_DIR="$HOME/.config/swiftbar-plugins"

echo "=== Universal Control Fix — Installer ==="
echo ""

# 1. Install SwiftBar
if [[ -d "/Applications/SwiftBar.app" ]]; then
    echo "✓ SwiftBar already installed"
else
    echo "→ Installing SwiftBar..."
    brew install --cask swiftbar
    echo "✓ SwiftBar installed"
fi

# 2. Create plugin directory
mkdir -p "$PLUGIN_DIR"

# 3. Copy plugin
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/universal-control.10s.sh" "$PLUGIN_DIR/"
chmod +x "$PLUGIN_DIR/universal-control.10s.sh"
echo "✓ Plugin installed to $PLUGIN_DIR"

# 4. Set up passwordless sudo for UC process kills
echo ""
echo "→ Setting up passwordless sudo for UC fix commands..."
echo "  (you may be prompted for your password)"
sudo tee /etc/sudoers.d/universal-control-fix > /dev/null <<'SUDOERS'
%admin ALL=(root) NOPASSWD: /usr/bin/killall rapportd
%admin ALL=(root) NOPASSWD: /usr/bin/pkill bluetoothd
SUDOERS
sudo chmod 0440 /etc/sudoers.d/universal-control-fix
sudo visudo -f /etc/sudoers.d/universal-control-fix -c
echo "✓ Sudoers configured"

# 5. Configure SwiftBar plugin directory and launch
defaults write com.ameba.SwiftBar PluginDirectory "$PLUGIN_DIR"
echo "✓ SwiftBar plugin directory set to $PLUGIN_DIR"

echo ""
echo "→ Launching SwiftBar..."
open -a SwiftBar

echo ""
echo "=== Done! ==="
echo "You should see 'UC' in your menu bar."
echo "Click it for fix options when Universal Control drops."
echo ""
