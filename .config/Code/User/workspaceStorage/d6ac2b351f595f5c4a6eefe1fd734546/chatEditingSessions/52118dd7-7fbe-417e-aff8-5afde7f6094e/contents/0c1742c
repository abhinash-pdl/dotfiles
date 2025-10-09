#!/usr/bin/env bash
# wrapper to start wf-recorder in background with a timestamped filename,
# write a pidfile and a logfile, and send notifications.

OUTDIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTDIR"

# state dir for pid/log
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
mkdir -p "$STATE_DIR"
PIDFILE="$STATE_DIR/wf-recorder.pid"
LOGFILE="/tmp/wf-recorder.$(date +%s).log"

FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).mkv"

# if already running (pidfile exists and process alive), exit with info
if [ -f "$PIDFILE" ]; then
	oldpid=$(cat "$PIDFILE" 2>/dev/null || true)
	if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null; then
		echo "wf-recorder already running (pid $oldpid)" >&2
		notify-send "Screen recorder" "Already recording (pid $oldpid) — $FILE"
		exit 0
	else
		rm -f "$PIDFILE" || true
	fi
fi

# Start wf-recorder in background, capture PID and redirect logs
# Conservative invocation: disable dmabuf to avoid some GPU/driver paths,
# use libx264 software encoder and set pixel format to yuv420p.
nohup wf-recorder --no-dmabuf -f "$FILE" -F 'format=yuv420p' -c libx264 -p preset=ultrafast -p crf=20 >"$LOGFILE" 2>&1 &
wf_pid=$!
echo "$wf_pid" > "$PIDFILE"

# short sleep to confirm process started
sleep 0.2
if kill -0 "$wf_pid" 2>/dev/null; then
	notify-send "Screen recording started" "$FILE"
	echo "$wf_pid"
	exit 0
else
	# capture last 50 lines of logfile for debugging
	tail -n 50 "$LOGFILE" 2>/dev/null | sed -n '1,200p' >&2
	notify-send "Screen recording failed" "Could not start wf-recorder — see $LOGFILE"
	rm -f "$PIDFILE" || true
	exit 1
fi
