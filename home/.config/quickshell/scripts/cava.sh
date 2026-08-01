#!/usr/bin/env bash
set -u

config_file="${TMPDIR:-/tmp}/quickshell_cava_${UID}_$$.conf"

cat > "$config_file" <<EOF
[general]
bars = 10
framerate = 30
autosens = 1

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

trap 'rm -f "$config_file"' EXIT

cava -p "$config_file" 2>/dev/null | while IFS=';' read -ra levels; do
    clean=()
    for level in "${levels[@]}"; do
        [[ -z "$level" ]] && continue
        (( level < 0 || level > 7 )) && level=0
        clean+=("$level")
    done

    while (( ${#clean[@]} < 10 )); do
        clean+=(0)
    done

    (IFS=,; printf '%s\n' "${clean[*]:0:10}")
done
