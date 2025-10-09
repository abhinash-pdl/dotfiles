#!/usr/bin/env bash
# clipboard_history.sh
# Shows clipboard history using wl-paste and wofi/rofi (falls back to fzf)

HISTORY_DIR="$HOME/.local/share/cliphist"
LOGFILE="$HISTORY_DIR/clip.log"
mkdir -p "$HISTORY_DIR"

# Append current clipboard to history (if not empty)
# only record text clipboard entries
cur=$(wl-paste --no-newline --type text/plain 2>/dev/null || true)
if [ -n "$cur" ]; then
  # ensure file exists
  touch "$LOGFILE"
  # avoid duplicate consecutive entries
  last=$(tail -n1 "$LOGFILE" 2>/dev/null || true)
  if [ "$cur" != "$last" ]; then
    echo "$cur" >> "$LOGFILE"
    # keep last 200 entries
    tail -n 200 "$LOGFILE" > "$HISTORY_DIR/clip.tmp" && mv "$HISTORY_DIR/clip.tmp" "$LOGFILE"
  fi
fi

# ensure logfile exists before showing menu
if [ ! -f "$LOGFILE" ] || [ ! -s "$LOGFILE" ]; then
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u low -i edit "Clipboard" "No clipboard history yet"
  else
    echo "No clipboard history yet"
  fi
  exit 0
fi

if command -v wofi >/dev/null 2>&1; then
  selected=$(tac "$LOGFILE" | wofi --dmenu --lines 15 --prompt "clipboard")
elif command -v rofi >/dev/null 2>&1; then
  selected=$(tac "$LOGFILE" | rofi -dmenu -lines 15 -p clipboard)
elif command -v fzf >/dev/null 2>&1; then
  selected=$(tac "$LOGFILE" | fzf --height 40%)
else
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical -i dialog-error "Clipboard" "No menu program (wofi/rofi/fzf) found"
  else
    echo "No menu program (wofi/rofi/fzf) found" >&2
  fi
  exit 2
fi

if [ -n "$selected" ]; then
  printf '%s' "$selected" | wl-copy --type text/plain
  # prefer notify-send; ensure it exists
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u normal -i edit "Clipboard" "Copied selection to clipboard"
  else
    echo "Copied selection to clipboard"
  fi
fi
