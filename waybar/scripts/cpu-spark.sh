#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  NIGHTWIRE — cpu sparkline (20-wide rolling window)
#  Reads /proc/stat deltas, persists a tiny state file between
#  waybar re-invocations, prints the window as block chars.
# ──────────────────────────────────────────────────────────────
set -u

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/nightwire"
mkdir -p "$STATE_DIR"
PREV="$STATE_DIR/cpu-prev"
WIN="$STATE_DIR/cpu-window"
WIDTH=20

read -r _ u n s i rest < /proc/stat
total=$((u + n + s + i))
busy=$((u + n + s))

if [ -f "$PREV" ]; then
    read -r p_total p_busy < "$PREV"
    dt=$((total - p_total))
    db=$((busy  - p_busy))
    if [ "$dt" -gt 0 ]; then
        pct=$((db * 100 / dt))
    else
        pct=0
    fi
else
    pct=0
fi
printf '%s %s\n' "$total" "$busy" > "$PREV"

touch "$WIN"
window=$(cat "$WIN")
window="$window $pct"
set -- $window
if [ "$#" -gt "$WIDTH" ]; then
    shift $(( $# - WIDTH ))
fi
echo "$*" > "$WIN"

block_for() {
    case $(( $1 / 13 )) in
        0) printf '▁' ;;
        1) printf '▂' ;;
        2) printf '▃' ;;
        3) printf '▄' ;;
        4) printf '▅' ;;
        5) printf '▆' ;;
        6) printf '▇' ;;
        *) printf '█' ;;
    esac
}

out=""
for v in $*; do out+="$(block_for "$v")"; done
printf '%s\n' "$out"
