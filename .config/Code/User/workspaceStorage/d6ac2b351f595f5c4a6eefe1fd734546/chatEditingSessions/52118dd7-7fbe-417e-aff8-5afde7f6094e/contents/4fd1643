#!/usr/bin/env bash
# obs-toggle.sh
# Simple wrapper to start OBS with recording, or stop it by terminating the process.
# Notes:
# - This is intentionally simple: it starts OBS with --startrecording when not running.
# - To stop recording we send SIGTERM to OBS which causes it to exit cleanly and save the recording file.
# - For finer control (pause, stop without closing UI) you'll need obs-websocket + a client.

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
mkdir -p "$STATE_DIR"
PIDFILE="$STATE_DIR/obs.pid"
LOGFILE="/tmp/obs-$(date +%s).log"

OBS_BIN="$(command -v obs 2>/dev/null || true)"
if [ -z "$OBS_BIN" ]; then
  echo "obs binary not found in PATH" >&2
  notify-send "OBS toggle" "obs not found. Install obs-studio first." || true
  exit 2
fi

# If pidfile exists and process alive, stop it
if [ -f "$PIDFILE" ]; then
  pid=$(cat "$PIDFILE" 2>/dev/null || true)
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    notify-send "OBS" "Stopping OBS and recording..." || true
    # Prefer toggling recording via obs-websocket if available in the venv
    VENV_PY="/home/avinas/code/.venv/bin/python"
    WS_TOGGLE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/additional/obs_ws_toggle.py"
    if [ -x "$VENV_PY" ] && [ -f "$WS_TOGGLE" ]; then
      "$VENV_PY" "$WS_TOGGLE" >/dev/null 2>&1 && {
        notify-send "OBS" "Toggled recording via obs-websocket" || true
        # Do not kill OBS process in this case; the websocket toggled recording
        rm -f "$PIDFILE" || true
        exit 0
      }
    fi
      # Fallback: send TERM to the OBS process to stop it and write file
      kill -TERM "$pid" 2>/dev/null || true
    # wait up to 8s for graceful exit
    for i in {1..8}; do
      if kill -0 "$pid" 2>/dev/null; then
        sleep 1
      else
        break
      fi
    done
    if kill -0 "$pid" 2>/dev/null; then
      # force-kill if still alive
      kill -KILL "$pid" 2>/dev/null || true
    fi
    rm -f "$PIDFILE" || true
    # Move the most recently created file in $HOME (likely produced by OBS) into ~/Videos
    VIDEODIR="$HOME/Videos"
    mkdir -p "$VIDEODIR"
    # find the most recently modified regular file in $HOME (exclude hidden and config dirs)
    recent=$(find "$HOME" -maxdepth 1 -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -n1 | cut -d' ' -f2-)
    if [ -n "$recent" ]; then
      mv -v "$recent" "$VIDEODIR/" 2>/dev/null || true
      notify-send "OBS" "Recording stopped and moved to $VIDEODIR/$(basename "$recent")" || true
    else
      notify-send "OBS" "Recording stopped (no recent file found to move)" || true
    fi
    exit 0
  else
    rm -f "$PIDFILE" || true
  fi
fi

# Start OBS and begin recording (use minimize-to-tray and optional collection/profile/scene)
OBS_COLLECTION="${OBS_COLLECTION:-}"
OBS_PROFILE="${OBS_PROFILE:-}"
OBS_SCENE="${OBS_SCENE:-}"

START_ARGS=(--startrecording --minimize-to-tray)
if [ -n "$OBS_COLLECTION" ]; then
  START_ARGS+=(--collection "$OBS_COLLECTION")
fi
if [ -n "$OBS_PROFILE" ]; then
  START_ARGS+=(--profile "$OBS_PROFILE")
fi
if [ -n "$OBS_SCENE" ]; then
  START_ARGS+=(--scene "$OBS_SCENE")
fi

nohup "$OBS_BIN" "${START_ARGS[@]}" >"$LOGFILE" 2>&1 &
obs_pid=$!
echo "$obs_pid" > "$PIDFILE"
sleep 0.5
if kill -0 "$obs_pid" 2>/dev/null; then
  notify-send "OBS" "Started OBS and recording (pid $obs_pid)" || true
  echo "Started OBS pid=$obs_pid, logfile=$LOGFILE"
  exit 0
else
  tail -n 80 "$LOGFILE" 2>/dev/null | sed -n '1,200p' >&2
  notify-send "OBS" "Failed to start OBS (see $LOGFILE)" || true
  rm -f "$PIDFILE" || true
  exit 1
fi
