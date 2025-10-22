if status is-interactive
    # Commands to run in interactive sessions can go here
end
# Import pywal colors\ncat ~/.cache/wal/sequences 2>/dev/null

# Import pywal colors
cat ~/.cache/wal/sequences 2>/dev/null

# Run fastfetch only when inside Kitty terminal
if test "$TERM" = "xterm-kitty"
    fastfetch
end


alias cava='cava -p $HOME/.cache/wal/cava_config'


