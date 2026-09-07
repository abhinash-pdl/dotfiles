if status is-login
    systemctl --user import-environment PATH
    if test (tty) = /dev/tty1
        if uwsm check may-start
            # This opens a TUI menu allowing you to choose your compositor
            exec uwsm start select
        end
    end
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
