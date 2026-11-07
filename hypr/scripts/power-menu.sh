#!/bin/bash
# Rafay-Hyprland-Arch — wofi power menu

DIR_SCRIPT="$(dirname "$(readlink -f "$0")")"

entries="⏻ Shutdown\n⏾ Suspend\n⟳ Reboot\n⎋ Log out\n Lock"

selected=$(printf "%b" "$entries" | wofi --dmenu \
    --prompt "Power" \
    --width 260 \
    --height 260 \
    --insensitive \
    --cache-file /dev/null)

case "$selected" in
    "⏻ Shutdown") systemctl poweroff ;;
    "⏾ Suspend")  systemctl suspend ;;
    "⟳ Reboot")   systemctl reboot ;;
    "⎋ Log out")  hyprctl dispatch exit ;;
    " Lock")     hyprlock ;;
esac
