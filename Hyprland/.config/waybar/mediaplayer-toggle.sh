#!/usr/bin/env bash
# Wrapper to toggle the player reported by mediaplayer.py
# This script is safe to call from Waybar's on-click. It extracts the
# "player" field from the script's JSON output and runs playerctl -p <player> play-pause.

set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
MP_SCRIPT="$SCRIPT_DIR/mediaplayer.py"

if [ ! -x "$MP_SCRIPT" ] && [ -f "$MP_SCRIPT" ]; then
  # ensure the script is runnable via python3 if not executable
  MP_CMD=(python3 "$MP_SCRIPT")
elif [ -x "$MP_SCRIPT" ]; then
  MP_CMD=("$MP_SCRIPT")
else
  # fallback to calling by path (let shell find python shebang)
  MP_CMD=("$MP_SCRIPT")
fi

# Determine action (play-pause, next, previous). Default to play-pause
ACTION="${1:-play-pause}"

# Read the player name from the script's JSON output. Use python3 for parsing
# to avoid relying on jq being installed.
PLAYER="$(${MP_CMD[@]} | python3 -c 'import sys,json
try:
    obj=json.load(sys.stdin)
    print(obj.get("player",""))
except Exception:
    print("")')"

if [ -n "$PLAYER" ] && [ "$PLAYER" != "null" ]; then
  # Only run valid actions to avoid injection issues
  case "$ACTION" in
    play-pause|pause|play|toggle)
      playerctl -p "$PLAYER" play-pause || true
      ;;
    next|next-track)
      playerctl -p "$PLAYER" next || true
      ;;
    previous|prev|previous-track)
      playerctl -p "$PLAYER" previous || true
      ;;
    *)
      # unknown action: fallback to play-pause
      playerctl -p "$PLAYER" play-pause || true
      ;;
  esac
fi

exit 0
