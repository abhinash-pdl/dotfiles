#!/usr/bin/env bash
# Quick setup script for Cava + Pywal live color sync
# Usage: bash install.sh

set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

echo "🎨 Installing Cava + Pywal Live Color Sync..."
echo ""

# Check if files exist
if [[ ! -f "$BACKUP_DIR/cava-colors" ]]; then
    echo "❌ Error: cava-colors not found in backup directory"
    exit 1
fi

# Create directories
echo "📁 Creating directories..."
mkdir -p "$HOME_DIR/.config/cava"
mkdir -p "$HOME_DIR/.config/wal/hooks"
mkdir -p "$HOME_DIR/.config/systemd/user"

# Copy files
echo "📋 Copying configuration files..."
cp "$BACKUP_DIR/cava-config.backup" "$HOME_DIR/.config/cava/config"
cp "$BACKUP_DIR/cava-colors" "$HOME_DIR/.config/wal/hooks/cava-colors"
cp "$BACKUP_DIR/watch-cava-colors.sh" "$HOME_DIR/.config/wal/hooks/watch-cava-colors.sh"
cp "$BACKUP_DIR/cava-pywal-watch.service" "$HOME_DIR/.config/systemd/user/cava-pywal-watch.service"

# Make scripts executable
chmod +x "$HOME_DIR/.config/wal/hooks/cava-colors"
chmod +x "$HOME_DIR/.config/wal/hooks/watch-cava-colors.sh"

echo "✓ Files copied"
echo ""

# Setup systemd service
echo "🚀 Setting up systemd service..."
systemctl --user daemon-reload
systemctl --user enable cava-pywal-watch.service
systemctl --user start cava-pywal-watch.service

echo "✓ Service enabled and started"
echo ""

# Verify installation
echo "✅ Verifying installation..."
echo ""

if systemctl --user status cava-pywal-watch.service > /dev/null 2>&1; then
    echo "✓ Service is running"
    echo ""
    echo "Installation complete! 🎉"
    echo ""
    echo "Test it by running:"
    echo "  wal -i /path/to/wallpaper.jpg"
    echo ""
    echo "Watch colors update in Cava live!"
    echo ""
    echo "For more info, see README.md"
else
    echo "❌ Service failed to start"
    echo "Run: journalctl --user -u cava-pywal-watch.service -n 20"
    exit 1
fi
