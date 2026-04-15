#!/usr/bin/env bash
# Uninstall script for Cava + Pywal live color sync
# Usage: bash uninstall.sh

set -e

HOME_DIR="$HOME"

echo "🔄 Uninstalling Cava + Pywal Live Color Sync..."
echo ""

# Stop and disable service
echo "🛑 Stopping service..."
systemctl --user disable --now cava-pywal-watch.service || true
echo "✓ Service stopped and disabled"
echo ""

# Remove files
echo "🗑️  Removing files..."
rm -f "$HOME_DIR/.config/wal/hooks/cava-colors"
rm -f "$HOME_DIR/.config/wal/hooks/watch-cava-colors.sh"
rm -f "$HOME_DIR/.config/systemd/user/cava-pywal-watch.service"
echo "✓ Files removed"
echo ""

# Reload systemd
echo "🔌 Reloading systemd..."
systemctl --user daemon-reload
echo "✓ Systemd reloaded"
echo ""

echo "✅ Uninstallation complete!"
echo ""
echo "Your cava config is still at: ~/.config/cava/config"
echo "You can restore it to a clean state if needed."
