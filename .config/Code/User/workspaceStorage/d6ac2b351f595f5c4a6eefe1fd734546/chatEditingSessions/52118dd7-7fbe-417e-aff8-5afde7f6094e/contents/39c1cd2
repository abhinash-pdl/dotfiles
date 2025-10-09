#!/usr/bin/env bash
# screen_record_toggle.sh - toggles wf-recorder recording in ~/Videos/Screencasts
OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"

# Detect existing wf-recorder PID run by user
if command -v systemctl >/dev/null 2>&1 && systemctl --user --no-pager status wf-recorder.service >/dev/null 2>&1; then
  # service exists; toggle it
  if systemctl --user is-active --quiet wf-recorder.service; then
    systemctl --user stop wf-recorder.service
    notify-send "Screen recording stopped" "Saved to $OUTDIR"
    exit 0
  else
    systemctl --user start wf-recorder.service
    sleep 0.2
    if systemctl --user is-active --quiet wf-recorder.service; then
      notify-send "Screen recording started" "Using systemd user service"
      exit 0
    else
      notify-send "Screen recording failed" "Could not start wf-recorder.service"
      # fallback to starting directly
    fi
  fi
fi

# Fallback when systemd user is not available or service not installed
pid=$(pgrep -u "$USER" -x wf-recorder || true)
if [ -n "$pid" ]; then
  pkill -u "$USER" -x wf-recorder
  notify-send "Screen recording stopped" "Saved to $OUTDIR"
  exit 0
fi

FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).mkv"
nohup wf-recorder -f "$FILE" >/dev/null 2>&1 &
sleep 0.2
if pgrep -u "$USER" -x wf-recorder >/dev/null 2>&1; then
  notify-send "Screen recording started" "$FILE"
else
  notify-send "Screen recording failed" "Could not start wf-recorder"
fi
