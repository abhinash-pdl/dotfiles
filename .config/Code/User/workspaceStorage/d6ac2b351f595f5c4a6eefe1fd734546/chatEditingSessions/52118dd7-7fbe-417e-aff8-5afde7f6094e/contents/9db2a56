#!/usr/bin/env bash
# screen_record_toggle.sh - toggles wf-recorder recording in ~/Videos/Screencasts
OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
PIDFILE="$STATE_DIR/wf-recorder.pid"

# prefer stopping/starting systemd-managed wf-recorder service if present
if command -v systemctl >/dev/null 2>&1 && systemctl --user --no-pager status wf-recorder.service >/dev/null 2>&1; then
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
    fi
    # if starting failed, continue to wrapper fallback
  fi
fi

# If a pidfile exists, assume it's our background wf-recorder and toggle stop
if [ -f "$PIDFILE" ]; then
  pid=$(cat "$PIDFILE" 2>/dev/null || true)
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid" && rm -f "$PIDFILE"
    notify-send "Screen recording stopped" "Saved to $OUTDIR"
    exit 0
  else
    rm -f "$PIDFILE" || true
  fi
fi

# Try ffrec.service (ffmpeg fallback) if available
if command -v systemctl >/dev/null 2>&1 && systemctl --user --no-pager status ffrec.service >/dev/null 2>&1; then
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
    fi
  fi
fi

# Fallback: use the wrapper to start wf-recorder in background
WRAPPER="${HOME}/.config/hypr/additional/wf-recorder-start.sh"
if [ -x "$WRAPPER" ]; then
  "$WRAPPER"
  exit $?
fi

# Final fallback: try direct nohup wf-recorder if wrapper missing
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).mkv"
nohup wf-recorder -f "$FILE" >/tmp/wf-recorder.$$.log 2>&1 &
sleep 0.2
if pgrep -u "$USER" -x wf-recorder >/dev/null 2>&1; then
  notify-send "Screen recording started" "$FILE"
else
  notify-send "Screen recording failed" "Could not start wf-recorder — see /tmp/wf-recorder.$$.log"
fi
