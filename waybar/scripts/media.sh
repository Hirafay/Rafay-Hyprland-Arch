#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  NIGHTWIRE — playerctl → waybar JSON
#  Emits an initial empty state, then one JSON per state change
#  while playerctl --follow emits events. Idle = empty text.
#  Deps: playerctl.
# ──────────────────────────────────────────────────────────────
set -u

emit_empty() {
    printf '{"text":"","class":"stopped","alt":"Stopped"}\n'
}

if ! command -v playerctl >/dev/null 2>&1; then
    printf '{"text":"","class":"stopped","alt":"missing playerctl"}\n'
    exit 0
fi

# always print one blank line first so waybar module clears any stale text
emit_empty

playerctl --follow metadata --format '{"status":"{{status}}","title":"{{title}}","artist":"{{artist}}"}' 2>/dev/null \
| while IFS= read -r line; do
    # strip control chars that would break waybar's JSON parse
    sanitized=$(printf '%s' "$line" | tr -d '\000-\037')

    status=$(printf '%s' "$sanitized" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')
    title=$(printf  '%s' "$sanitized" | sed -n 's/.*"title":"\([^"]*\)".*/\1/p')
    artist=$(printf '%s' "$sanitized" | sed -n 's/.*"artist":"\([^"]*\)".*/\1/p')

    [ -z "$status" ] && status="Stopped"
    class=$(printf '%s' "$status" | tr '[:upper:]' '[:lower:]')

    if [ "$status" = "Stopped" ] || [ -z "$title" ]; then
        emit_empty
        continue
    fi

    if [ -z "$artist" ]; then
        text="$title"
    else
        text="$artist — $title"
    fi

    text_esc=$(printf '%s' "$text"   | sed 's/\\/\\\\/g; s/"/\\"/g')
    alt_esc=$(printf  '%s' "$status" | sed 's/\\/\\\\/g; s/"/\\"/g')

    printf '{"text":"%s","class":"%s","alt":"%s"}\n' \
        "$text_esc" "$class" "$alt_esc"
done
