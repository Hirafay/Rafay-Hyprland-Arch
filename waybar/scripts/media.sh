#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  NIGHTWIRE — playerctl → waybar JSON
#  Emits one JSON per state change. Blocks on playerctl --follow.
#  Deps: playerctl.
# ──────────────────────────────────────────────────────────────
set -u

if ! command -v playerctl >/dev/null 2>&1; then
    echo '{"text":"", "class":"stopped", "alt":"missing playerctl"}'
    exit 0
fi

playerctl --follow metadata --format '{"status":"{{status}}","title":"{{title}}","artist":"{{artist}}"}' 2>/dev/null \
| while IFS= read -r line; do
    sanitized=$(echo "$line" | tr -d '\000-\037')

    status=$(echo "$sanitized"  | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')
    title=$(echo  "$sanitized"  | sed -n 's/.*"title":"\([^"]*\)".*/\1/p')
    artist=$(echo "$sanitized"  | sed -n 's/.*"artist":"\([^"]*\)".*/\1/p')

    [ -z "$status" ] && status="Stopped"
    class=$(echo "$status" | tr '[:upper:]' '[:lower:]')

    if [ -z "$title" ]; then
        text=""
    elif [ -z "$artist" ]; then
        text="$title"
    else
        text="$artist — $title"
    fi

    text_esc=$(printf '%s' "$text"   | sed 's/\\/\\\\/g; s/"/\\"/g')
    alt_esc=$(printf  '%s' "$status" | sed 's/\\/\\\\/g; s/"/\\"/g')

    printf '{"text":"%s","class":"%s","alt":"%s"}\n' \
        "$text_esc" "$class" "$alt_esc"
done
