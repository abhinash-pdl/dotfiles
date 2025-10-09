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
    #!/usr/bin/env bash
    # clipboard_history.sh
    # Shows clipboard history using wl-paste and wofi/rofi (falls back to fzf)

    set -u

    HISTORY_DIR="$HOME/.local/share/cliphist"
    LOGFILE="$HISTORY_DIR/clip.log"
    DEBUGLOG="$HISTORY_DIR/clip.debug"
    mkdir -p "$HISTORY_DIR"

    log_debug() {
      printf '[%s] %s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$*" >> "$DEBUGLOG"
    }

    # Read text/plain clipboard (no trailing newline). If not available, cur is empty.
    cur=$(wl-paste --no-newline --type text/plain 2>/dev/null || true)

    # Reject binary data: if NULs present or too large, ignore.
    if printf '%s' "$cur" | grep -q --null-data -P '\x00' 2>/dev/null; then
      log_debug "Clipboard contains NUL bytes — treated as non-text, skipping"
      cur=""
    fi

    MAXLEN=50000
    if [ -n "$cur" ] && [ ${#cur} -gt $MAXLEN ]; then
      log_debug "Clipboard text too large (len=${#cur}), skipping"
      cur=""
    fi

    if [ -n "$cur" ]; then
      : > "$LOGFILE" 2>/dev/null || touch "$LOGFILE"
      last=$(tail -n1 "$LOGFILE" 2>/dev/null || true)
      if [ "$cur" != "$last" ]; then
        printf '%s\n' "$cur" >> "$LOGFILE"
        tail -n 200 "$LOGFILE" > "$HISTORY_DIR/clip.tmp" && mv "$HISTORY_DIR/clip.tmp" "$LOGFILE"
        log_debug "Appended clipboard entry (len=${#cur})"
      else
        log_debug "Skipped duplicate clipboard entry"
      fi
    else
      log_debug "No text/plain clipboard available"
    fi

    if [ ! -f "$LOGFILE" ] || [ ! -s "$LOGFILE" ]; then
      if command -v notify-send >/dev/null 2>&1; then
        notify-send -u low -i edit "Clipboard" "No clipboard history yet"
      else
        echo "No clipboard history yet"
      fi
      exit 0
    fi

    # Prepare temp files and ensure cleanup
    TMP_ORIG=$(mktemp) || exit 1
    MENU_FILE=$(mktemp) || { rm -f "$TMP_ORIG"; exit 1; }
    trap 'rm -f "$TMP_ORIG" "$MENU_FILE"' EXIT

    # Reverse so newest entries come first
    tac "$LOGFILE" > "$TMP_ORIG" 2>/dev/null || cp "$LOGFILE" "$TMP_ORIG"

    # Build numbered preview lines: "<index>\t<preview>"
    nl -ba -w1 -s $'\t' "$TMP_ORIG" | while IFS= read -r line; do
      idx=$(printf '%s' "$line" | cut -f1)
      entry=$(printf '%s' "$line" | cut -f2-)
      preview=$(printf '%s' "$entry" \
        | tr -d '\000' \
        | iconv -f utf-8 -t utf-8 -c 2>/dev/null \
        | perl -pe 's/[\x00-\x09\x0B\x0C\x0E-\x1F]//g' \
        | tr '\n' ' ' | tr -s ' ' | cut -c1-200)
      preview=$(printf '%s' "$preview" | sed -e 's/&/&amp;/g' -e 's/</&lt;/g' -e 's/>/&gt;/g')
      [ -z "$preview" ] && preview='[binary/unprintable]'
      printf '%s\t%s\n' "$idx" "$preview"
    done > "$MENU_FILE"

    selected=''

    try_menu_input() {
      local prog=("$@")
      selected=$("${prog[0]}" "${prog[@]:1}" < "$MENU_FILE" 2>>"$DEBUGLOG") || {
        log_debug "Menu ${prog[0]} failed with exit $?"
        selected=''
        return 1
      }
      return 0
    }

    # If MENU_FILE is valid UTF-8, try GUI menus first
    if iconv -f utf-8 -t utf-8 -c < "$MENU_FILE" >/dev/null 2>&1; then
      if command -v wofi >/dev/null 2>&1; then
        try_menu_input wofi --dmenu --lines 15 --prompt clipboard && log_debug "Used wofi"
      fi
      if [ -z "$selected" ] && command -v rofi >/dev/null 2>&1; then
        try_menu_input rofi -dmenu -lines 15 -p clipboard && log_debug "Used rofi"
      fi
    fi

    # Terminal fallback
    if [ -z "$selected" ] && command -v fzf >/dev/null 2>&1; then
      try_menu_input fzf --height 40% && log_debug "Used fzf"
    fi

    if [ -z "$selected" ]; then
      log_debug "No menu selection made or menu failed to start"
      if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical -i dialog-error "Clipboard" "Could not open menu (check $DEBUGLOG)"
      else
        echo "Could not open menu (check $DEBUGLOG)" >&2
      fi
      exit 1
    fi

    # Extract index and lookup original
    sel_idx=$(printf '%s' "$selected" | awk '{print $1}')
    orig=$(sed -n "${sel_idx}p" "$TMP_ORIG" 2>/dev/null || true)

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
