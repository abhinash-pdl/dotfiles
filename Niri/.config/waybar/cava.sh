#!/bin/bash

bar="▁▂▃▄▅▆▇█"
dict="s/;//g"

bar_length=${#bar}

for ((i = 0; i < bar_length; i++)); do
    dict+=";s/$i/${bar:$i:1}/g"
done

config_file="/tmp/bar_cava_config"
cat >"$config_file" <<EOF
[general]
bars = 8           
framerate = 20     

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7

[smoothing]
noise_reduction = 50
EOF

# Trap to ensure cleanup on exit
cleanup() {
    pkill -P $$ 2>/dev/null
    exit 0
}
trap cleanup SIGTERM SIGINT EXIT

pkill -f "cava -p $config_file"

cava -p "$config_file" | while IFS= read -r line; do
    if [ -n "$line" ]; then
        visual_bars=$(echo "$line" | sed -u "$dict")
        echo "{\"text\": \"$visual_bars\"}"
    fi
done