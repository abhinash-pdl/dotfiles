#!/usr/bin/env bash
# Forward arguments to the real notify-send
/usr/bin/notify-send "$@"

# Check for urgency flag (-u) for critical notifications
urgency=$(echo "$@" | grep -oP '(?<=-u )\S+' || echo normal)

case $urgency in
    critical) paplay /usr/share/sounds/freedesktop/stereo/alert.oga ;;
    normal|*) paplay /usr/share/sounds/freedesktop/stereo/complete.oga ;;
esac
