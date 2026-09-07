
if status is-login
    and test (tty) = /dev/tty1
    and not set -q WAYLAND_DISPLAY
    and not set -q DISPLAY

    exec uwsm start niri.desktop
end
if status is-interactive
    # Import pywal colors
    cat ~/.cache/wal/sequences 2>/dev/null

    # Run fastfetch in terminal
    if test "$TERM" = "xterm-kitty" -o "$TERM" = "foot"
        fastfetch
    end
end

# Wrap wal command to fix foot.ini color section
function wal
    command wal $argv
    $HOME/.config/wal/fix-foot-colors.sh
end

# opencode
fish_add_path /home/avinas/.opencode/bin
