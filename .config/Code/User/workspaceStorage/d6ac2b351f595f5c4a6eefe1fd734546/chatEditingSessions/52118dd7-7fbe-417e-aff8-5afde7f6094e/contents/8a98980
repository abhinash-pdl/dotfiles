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

# Reject binary data. If wl-paste returned NULs, treat as non-text and skip.
if printf '%s' "$cur" | grep -q --null-data -P '\x00' 2>/dev/null; then
  log_debug "Clipboard contains NUL bytes — treated as non-text, skipping"
  cur=""
fi

# Limit size to avoid appending huge binary/text blobs (e.g., images). 50000 chars ~= 50KB
MAXLEN=50000
if [ -n "$cur" ]; then
  if [ ${#cur} -gt $MAXLEN ]; then
    log_debug "Clipboard text too large (len=${#cur}), skipping"
    cur=""
  fi
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

# Build a sanitized, truncated preview menu to avoid GUI crashes with huge/binary entries.
TMP_ORIG=$(mktemp)
MENU_FILE=$(mktemp)
# tac so newest entries appear first in the menu
tac "$LOGFILE" > "$TMP_ORIG"

# Build numbered preview lines: "<index>\t<preview>"
nl -ba -w1 -s $'\t' "$TMP_ORIG" | while IFS=$'\t' read -r idx entry; do
  # force UTF-8, drop NULs, remove control chars, collapse whitespace and truncate to 200 chars
  preview=$(printf '%s' "$entry" \
    | tr -d '\000' \
    | iconv -f utf-8 -t utf-8 -c 2>/dev/null \
    | perl -pe 's/[\x00-\x09\x0B\x0C\x0E-\x1F]//g' \
    | tr '\n' ' ' | tr -s ' ' | cut -c1-200)
  # escape characters that can break Pango/GTK markup in wofi/rofi
  preview=$(printf '%s' "$preview" | sed -e 's/&/&amp;/g' -e 's/</&lt;/g' -e 's/>/&gt;/g')
  # ensure preview is non-empty (use a placeholder)
  [ -z "$preview" ] && preview='[binary/unprintable]'
  printf '%s\t%s\n' "$idx" "$preview"
done > "$MENU_FILE"

# Helper to try a menu program and capture selected line from MENU_FILE. Returns 0 on success.
try_menu_input() {
  local prog="$1"; shift
  selected=$(cat "$MENU_FILE" | "$prog" "$@" 2>>"$DEBUGLOG")
  local rc=$?
  if [ $rc -ne 0 ]; then
    log_debug "Menu $prog failed with exit $rc"
    selected=''
    return $rc
  fi
  return 0
}

# Try available menu programs in order; record which one was used in debug log
# If MENU_FILE contains invalid UTF-8, skip GUI menus (they'll show many GTK/Pango warnings)
if iconv -f utf-8 -t utf-8 -c "$MENU_FILE" >/dev/null 2>&1; then
  if command -v wofi >/dev/null 2>&1; then
    if try_menu_input wofi --dmenu --lines 15 --prompt "clipboard"; then
      log_debug "Used wofi"
    fi
  fi
  if [ -z "$selected" ] && command -v rofi >/dev/null 2>&1; then
    if try_menu_input rofi -dmenu -lines 15 -p clipboard; then
      log_debug "Used rofi"
    fi
  fi
fi

# Always try fzf as a robust terminal fallback (works when GUI menus fail)
if [ -z "$selected" ] && command -v fzf >/dev/null 2>&1; then
  if try_menu_input fzf --height 40%; then
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
  rm -f "$TMP_ORIG" "$MENU_FILE"
  exit 1
fi

# Parse selected line: extract index (first token) and look up original content
# Menu lines are "<index>\t<preview>"; some menus may replace tabs with spaces, so use awk to get first token
sel_idx=$(printf '%s' "$selected" | awk '{print $1}')
orig=$(sed -n "${sel_idx}p" "$TMP_ORIG" 2>/dev/null || true)

# cleanup temp files
rm -f "$TMP_ORIG" "$MENU_FILE"

if [ -z "$orig" ]; then
  log_debug "Failed to look up original clipboard content for selection index $sel_idx"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical -i dialog-error "Clipboard" "Failed to retrieve clipboard entry"
  else
    echo "Failed to retrieve clipboard entry" >&2
  fi
  exit 2
fi

# Copy full original content back to clipboard
printf '%s' "$orig" | wl-copy --type text/plain
if [ $? -eq 0 ]; then
  log_debug "Copied selection to clipboard (len=${#orig})"
  if command -v notify-send >/dev/null 2>&1; then
    # show a short notification; keep it brief to avoid display issues
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
