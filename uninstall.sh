#!/bin/bash
set -e

PLUGIN_DIR="$HOME/.config/swiftbar-plugins"

echo "=== Universal Control Fix — Uninstaller ==="
echo ""

rm -f "$PLUGIN_DIR/universal-control.10s.sh"
echo "✓ Plugin removed"

sudo rm -f /etc/sudoers.d/universal-control-fix
echo "✓ Sudoers entry removed"

echo ""
echo "Done. SwiftBar itself was not removed."
echo "To remove SwiftBar: brew uninstall --cask swiftbar"
echo ""
