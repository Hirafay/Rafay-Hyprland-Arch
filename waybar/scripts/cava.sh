#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  NIGHTWIRE — cava → waybar spectrum
#  Reads cava's raw ascii stream, remaps 0..7 to unicode block
#  chars for a dense bar graph. One line per frame.
#
#  Deps: cava (pacman -S cava)
#  Tunables: BARS (width), framerate (smoothness)
# ──────────────────────────────────────────────────────────────
set -u

if ! command -v cava >/dev/null 2>&1; then
    while :; do printf '◇◇◇◇◇◇◇◇◇◇◇◇\n'; sleep 10; done
fi

BARS=14
CFG=$(mktemp --suffix=.cava)
cat > "$CFG" <<EOF
[general]
bars = ${BARS}
framerate = 60
sensitivity = 100

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
bar_delimiter = 59
EOF

cleanup() { rm -f "$CFG"; }
trap cleanup EXIT INT TERM

cava -p "$CFG" 2>/dev/null | while IFS=';' read -ra bars; do
    out=""
    for v in "${bars[@]}"; do
        case "$v" in
            0) out+="▁" ;;
            1) out+="▂" ;;
            2) out+="▃" ;;
            3) out+="▄" ;;
            4) out+="▅" ;;
            5) out+="▆" ;;
            6) out+="▇" ;;
            7) out+="█" ;;
            *) out+="▁" ;;
        esac
    done
    printf '%s\n' "$out"
done
