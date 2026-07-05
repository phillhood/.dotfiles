#!/usr/bin/env bash
set -u
bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
# Catppuccin Macchiato gradient, indexed by bar height (0 = quiet .. 7 = loud)
colors=('#8aadf4' '#7dc4e4' '#91d7e3' '#8bd5ca' '#a6da95' '#eed49f' '#f5a97f' '#ed8796')
config_file="/tmp/waybar_cava_config"
cat > "$config_file" <<EOF
[general]
bars = 36
framerate = 24
autosens = 1
lower_cutoff_freq = 30
higher_cutoff_freq = 10000

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
channels = mono
mono_option = average
EOF

trap 'kill 0 2>/dev/null || true' EXIT
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
        out+="<span foreground='${colors[n]}'>${bars[n]}</span>"
    done
    printf '%s\n' "$out"
}

# fast check for "only zeros" (silence) using parameter expansion — no regex, no external tools
is_silence() {
    local l="${1//;/}"   # remove semicolons
    # remove all 0 characters; if result is empty => only zeros
    [[ -z "${l//0/}" ]]
}

# Emit a waybar JSON line: bar text plus a class CSS uses to fade in/out.
emit() {
    printf '{"text":"%s","class":"%s"}\n' "$1" "$2"
}

# Run cava and process its stdout
cava -p "$config_file" 2>/dev/null | while IFS= read -r line || [[ -n "$line" ]]; do
    # silence detection (cheap)
    if is_silence "$line"; then
        if (( pause_start == 0 )); then
            pause_start=$SECONDS
        fi

        # after 2s of continuous silence, mark silent so CSS fades it out
        if (( SECONDS - pause_start >= 2 )); then
            emit "$(convert_to_bars "$line")" "silent"
        else
            emit "$(convert_to_bars "$line")" "active"
        fi
        continue
    fi

    # audio returned — reset timer and fade back in
    pause_start=0
    emit "$(convert_to_bars "$line")" "active"
done
