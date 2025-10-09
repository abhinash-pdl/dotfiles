#!/usr/bin/env bash
# Quick helper to (re)start mako and send a test notification.
set -u

echo "Reloading user systemd daemon..."
systemctl --user daemon-reload || echo "daemon-reload failed"

echo "Restarting mako.service..."
if systemctl --user restart mako.service; then
  echo "mako restarted successfully"
else
  echo "mako failed to restart (check journalctl --user -u mako.service)"
fi

sleep 0.5

echo "Sending test notification..."
notify-send "mako test" "If you see this, notifications are working" || echo "notify-send failed"

echo "--- mako.service status ---"
systemctl --user status mako.service --no-pager -l || true

echo "--- recent mako journal ---"
journalctl --user -u mako.service -n 50 --no-pager || true

echo "Done. Run this inside your Hyprland session to confirm notifications are visible."
