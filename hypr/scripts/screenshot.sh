#!/bin/bash
# Rafay-Hyprland-Arch — unified screenshot router
# Uses grim + slurp directly (no grimblast dependency)

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
TS="$(date +%Y-%m-%d_%H-%M-%S)"
FILE="$DIR/$TS.png"

notify() {
    command -v notify-send >/dev/null && \
        notify-send -a "Screenshot" -i "$FILE" "Screenshot" "$1"
}

case "$1" in
    area)
        grim -g "$(slurp)" "$FILE" && \
            wl-copy -t image/png < "$FILE" && \
            notify "Region saved to $FILE"
        ;;
    screen|full)
        grim "$FILE" && \
            wl-copy -t image/png < "$FILE" && \
            notify "Full screen saved to $FILE"
        ;;
    window)
        # active window geometry via hyprctl
        geom=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$geom" "$FILE" && \
            wl-copy -t image/png < "$FILE" && \
            notify "Active window saved to $FILE"
        ;;
    delay)
        sleep 5
        grim "$FILE" && \
            wl-copy -t image/png < "$FILE" && \
            notify "Delayed shot saved to $FILE"
        ;;
    color)
        # pick a pixel color and copy to clipboard
        if command -v hyprpicker >/dev/null; then
            color=$(hyprpicker -a -f hex)
            echo "$color" | wl-copy
            notify "Color $color copied"
        else
            notify "hyprpicker not installed"
        fi
        ;;
    *)
        echo "usage: $0 {area|screen|window|delay|color}"
        exit 1
        ;;
esac
