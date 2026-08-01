#!/usr/bin/env bash
set -u
bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
config_file="${TMPDIR:-/tmp}/waybar_cava_${UID}_$$.conf"

if ! command -v cava >/dev/null 2>&1; then
    exit 0
fi

cat > "$config_file" <<EOF
[general]
bars = 16
framerate = 60
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
pause_start=0

convert_to_bars() {
    local line="$1"
    local IFS=';'
    local -a nums
    read -ra nums <<< "$line"
    local out=""
    local n
    for n in "${nums[@]}"; do

        if (( n < 0 || n > 7 )); then
            n=0
        fi
        out+="${bars[n]}"
    done
    printf '%s\n' "$out"
}

# Fast check for silence using parameter expansion, no external tools.
is_silence() {
    local l="${1//;/}"
    [[ -z "${l//0/}" ]]
}

cava -p "$config_file" 2>/dev/null | while IFS= read -r line || [[ -n "$line" ]]; do
    if is_silence "$line"; then
        if (( pause_start == 0 )); then
            pause_start=$SECONDS
        fi

        # hide after 2 seconds of continuous silence
        if (( SECONDS - pause_start >= 2 )); then
            echo ""
        else
            convert_to_bars "$line"
        fi
        continue
    fi

    pause_start=0
    convert_to_bars "$line"
done
