#!/usr/bin/env bash
# screen_record_toggle.sh - toggles wf-recorder recording in ~/Videos/Screencasts
OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"

# Detect existing wf-recorder PID run by user
pid=$(pgrep -u "$USER" -x wf-recorder || true)
if [ -n "$pid" ]; then
  # stop wf-recorder processes owned by user
  pkill -u "$USER" -x wf-recorder
  notify-send "Screen recording stopped" "Saved to $OUTDIR"
  exit 0
fi

# start recording
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).mkv"
nohup wf-recorder -f "$FILE" >/dev/null 2>&1 &
sleep 0.2
if pgrep -u "$USER" -x wf-recorder >/dev/null 2>&1; then
  notify-send "Screen recording started" "$FILE"
else
  notify-send "Screen recording failed" "Could not start wf-recorder"
fi
