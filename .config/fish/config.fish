if status is-interactive
    # Commands to run in interactive sessions can go here
end
# Import pywal colors\ncat ~/.cache/wal/sequences 2>/dev/null


# Import pywal colors
cat ~/.cache/wal/sequences 2>/dev/null

# Run fastfetch when inside Foot terminal
if test "$TERM" = "xterm-kitty" -o "$TERM" = "foot"
    fastfetch
end



# Wrap wal command to fix foot.ini color section
function wal
    command wal $argv
    $HOME/.config/wal/fix-foot-colors.sh
end


fish_add_path /home/avinas/.spicetify

# Created by `pipx` on 2026-03-22 17:42:49
set PATH $PATH /home/avinas/.local/bin
