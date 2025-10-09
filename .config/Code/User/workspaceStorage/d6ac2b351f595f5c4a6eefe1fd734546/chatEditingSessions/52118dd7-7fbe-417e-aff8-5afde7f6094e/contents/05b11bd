#!/usr/bin/env bash
# clipboard_history.sh
# Shows clipboard history using wl-paste and wofi/rofi (falls back to fzf)

HISTORY_DIR="$HOME/.local/share/cliphist"
LOGFILE="$HISTORY_DIR/clip.log"
DEBUGLOG="$HISTORY_DIR/clip.debug"
mkdir -p "$HISTORY_DIR"

log_debug() {
  # timestamped debug lines
  printf '[%s] %s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$*" >> "$DEBUGLOG"
}

# Append current clipboard to history (if not empty)
# Try text/plain first, then a generic paste as fallback
cur=$(wl-paste --no-newline --type text/plain 2>/dev/null || true)
if [ -z "$cur" ]; then
  cur=$(wl-paste --no-newline 2>/dev/null || true)
fi

if [ -n "$cur" ]; then
  # ensure file exists
  touch "$LOGFILE"
  # avoid duplicate consecutive entries
  last=$(tail -n1 "$LOGFILE" 2>/dev/null || true)
  if [ "$cur" != "$last" ]; then
    echo "$cur" >> "$LOGFILE"
    # keep last 200 entries
    tail -n 200 "$LOGFILE" > "$HISTORY_DIR/clip.tmp" && mv "$HISTORY_DIR/clip.tmp" "$LOGFILE"
    log_debug "Appended clipboard entry (len=${#cur})"
  else
    log_debug "Skipped duplicate clipboard entry"
  fi
else
  log_debug "No text/plain clipboard available"
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

# Helper to try a menu program and capture selected text. Returns 0 on success, non-zero otherwise.
try_menu() {
  local prog="$1"
  shift
  # run the menu program, keep both stdout and stderr for debugging
  selected=$(tac "$LOGFILE" | "$prog" "$@" 2>>"$DEBUGLOG")
  local rc=$?
  if [ $rc -ne 0 ]; then
    log_debug "Menu $prog failed with exit $rc"
    selected=''
    return $rc
  fi
  return 0
}

# Try available menu programs in order; record which one was used in debug log
if command -v wofi >/dev/null 2>&1; then
  if try_menu wofi --dmenu --lines 15 --prompt "clipboard"; then
    log_debug "Used wofi"
  fi
fi
if [ -z "$selected" ] && command -v rofi >/dev/null 2>&1; then
  if try_menu rofi -dmenu -lines 15 -p clipboard; then
    log_debug "Used rofi"
  fi
fi
if [ -z "$selected" ] && command -v fzf >/dev/null 2>&1; then
  if try_menu fzf --height 40%; then
    log_debug "Used fzf"
  fi
fi

# If nothing selected because menus couldn't run, notify and exit
if [ -z "$selected" ]; then
  log_debug "No menu selection made or menu failed to start"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical -i dialog-error "Clipboard" "Could not open menu (check $DEBUGLOG)"
  else
    echo "Could not open menu (check $DEBUGLOG)" >&2
  fi
  exit 1
fi

# Copy selection back to clipboard
printf '%s' "$selected" | wl-copy --type text/plain
if [ $? -eq 0 ]; then
  log_debug "Copied selection to clipboard (len=${#selected})"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u normal -i edit "Clipboard" "Copied selection to clipboard"
  else
    echo "Copied selection to clipboard"
  fi
else
  log_debug "Failed to copy selection to clipboard"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical -i dialog-error "Clipboard" "Failed to copy selection"
  else
    echo "Failed to copy selection" >&2
  fi
  exit 2
fi
