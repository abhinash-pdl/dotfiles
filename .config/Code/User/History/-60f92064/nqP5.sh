#!/usr/bin/env bash
# screen_record_toggle.sh - toggles wf-recorder recording in ~/Videos/Screencasts
OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"

# Detect existing wf-recorder PID run by user
if command -v systemctl >/dev/null 2>&1; then
  # Prefer wf-recorder.service when available
  if systemctl --user --no-pager status wf-recorder.service >/dev/null 2>&1; then
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
      # capture journal output for a helpful error message
      err=$(journalctl --user -u wf-recorder.service -n 20 --no-pager 2>/dev/null | tail -n 10 | sed -n '1,400p')
      notify-send "Screen recording failed" "Could not start wf-recorder.service: $(echo "$err" | head -n1)"
      # fallback to starting directly
    fi
  fi
  fi

  # Next preference: ffmpeg/pipewire service
  if systemctl --user --no-pager status ffrec.service >/dev/null 2>&1; then
    if systemctl --user is-active --quiet ffrec.service; then
      systemctl --user stop ffrec.service
      notify-send "Screen recording stopped" "Saved to $OUTDIR (ffrec)"
      exit 0
    else
      systemctl --user start ffrec.service
      sleep 0.2
      if systemctl --user is-active --quiet ffrec.service; then
        notify-send "Screen recording started" "Using ffmpeg/pipewire service"
        exit 0
      else
        err=$(journalctl --user -u ffrec.service -n 20 --no-pager 2>/dev/null | tail -n 10 | sed -n '1,400p')
        notify-send "Screen recording failed" "Could not start ffrec.service: $(echo "$err" | head -n1)"
        # fallback to direct nohup ffmpeg below
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

# direct ffmpeg fallback: if ffmpeg available, start a nohup ffmpeg pipewire record
if command -v ffmpeg >/dev/null 2>&1; then
  FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S)-ffmpeg.mkv"
  nohup ffmpeg -y -f pipewire -i default -c:v libx264 -preset ultrafast -crf 20 -pix_fmt yuv420p "$FILE" >/tmp/ffrec.$$.log 2>&1 &
  sleep 0.2
  if pgrep -u "$USER" -f ffmpeg >/dev/null 2>&1; then
    notify-send "Screen recording started" "$FILE"
    exit 0
  else
    notify-send "Screen recording failed" "Could not start ffmpeg (see /tmp/ffrec.$$.log)"
    exit 1
  fi
fi

FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).mkv"
nohup wf-recorder -f "$FILE" >/tmp/wf-recorder.$$.log 2>&1 &
sleep 0.2
if pgrep -u "$USER" -x wf-recorder >/dev/null 2>&1; then
  notify-send "Screen recording started" "$FILE"
else
  notify-send "Screen recording failed" "Could not start wf-recorder — see /tmp/wf-recorder.$$.log"
fi
