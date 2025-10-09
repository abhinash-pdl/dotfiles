#!/usr/bin/env bash
# screen_record_toggle.sh - toggles wf-recorder recording in ~/Videos/Screencasts
OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"

# Detect existing wf-recorder PID run by user
pid=$(pgrep -u "$USER" -x wf-recorder || true)
if [ -n "$pid" ]; then
  # stop all wf-recorder processes owned by user
  pkill -u "$USER" -x wf-recorder
  notify-send "Screen recording stopped"
  exit 0
fi

# start recording
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).mkv"
wf-recorder -f "$FILE" &
notify-send "Screen recording started" "$FILE"
