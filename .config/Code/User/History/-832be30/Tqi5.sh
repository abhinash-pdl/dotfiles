#!/usr/bin/env bash
# clipboard_history.sh
# Shows clipboard history using wl-paste and wofi/rofi (falls back to fzf)

HISTORY_DIR="$HOME/.local/share/cliphist"
mkdir -p "$HISTORY_DIR"

# Append current clipboard to history (if not empty)
# only record text clipboard entries
cur=$(wl-paste --no-newline --type text/plain 2>/dev/null || true)
if [ -n "$cur" ]; then
  # avoid duplicate consecutive entries
  last=$(tail -n1 "$HISTORY_DIR/clip.log" 2>/dev/null || true)
  if [ "$cur" != "$last" ]; then
    echo "$cur" >> "$HISTORY_DIR/clip.log"
    # keep last 200 entries
    tail -n 200 "$HISTORY_DIR/clip.log" > "$HISTORY_DIR/clip.tmp" && mv "$HISTORY_DIR/clip.tmp" "$HISTORY_DIR/clip.log"
  fi
fi

if command -v wofi >/dev/null 2>&1; then
  selected=$(tac "$HISTORY_DIR/clip.log" | wofi --dmenu --lines 15 --prompt "clipboard")
elif command -v rofi >/dev/null 2>&1; then
  selected=$(tac "$HISTORY_DIR/clip.log" | rofi -dmenu -lines 15 -p clipboard)
elif command -v fzf >/dev/null 2>&1; then
  selected=$(tac "$HISTORY_DIR/clip.log" | fzf --height 40%)
else
  echo "No menu program (wofi/rofi/fzf) found" >&2
  exit 2
fi

if [ -n "$selected" ]; then
  printf '%s' "$selected" | wl-copy --type text/plain
  notify-send "Clipboard" "Copied selection to clipboard"
fi
