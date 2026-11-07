#!/bin/bash
# Rafay-Hyprland-Arch — keybind cheatsheet via wofi dmenu

cat << 'EOF' | wofi --dmenu --prompt "Keybinds (ESC)" --width 720 --height 620 \
  --insensitive --cache-file /dev/null >/dev/null
—— LAUNCH ——————————————————————————
SUPER Return     Terminal (kitty)
SUPER Space      Launcher (wofi)
SUPER E          Files (thunar)
SUPER B          Browser (firefox)
SUPER V          Clipboard history
SUPER W          Wallpaper picker
SUPER X          Lock screen
SUPER SHIFT P    Power menu
SUPER /          This cheatsheet
—— WINDOW ——————————————————————————
SUPER Q          Close window
SUPER F          Toggle floating
SUPER G          Fullscreen
SUPER P          Pseudotile
SUPER S          Swap with next
SUPER SHIFT R    Reload Hyprland
SUPER SHIFT M    Exit Hyprland
SUPER SHIFT N    Toggle gaps
—— FOCUS ———————————————————————————
SUPER H/J/K/L    Focus left/down/up/right
SUPER arrows     Same, via arrow keys
SUPER SHIFT hjkl Move active window
SUPER CTRL  hjkl Resize active window
—— WORKSPACE ———————————————————————
SUPER 1..9,0     Switch workspace 1..10
SUPER SHIFT 1..0 Send window to WS
SUPER A          Toggle scratchpad
SUPER SHIFT A    Send to scratchpad
SUPER scroll     Cycle workspaces
—— SUBMAPS —————————————————————————
SUPER Y          [resize] hjkl steps 30px, c center
SUPER O          [launch] b/t/c/f/d/s/o/g/m/n
SUPER SHIFT X    [screenshot] a/w/s/c/d
SUPER SHIFT G    [group] g toggle, tab/h cycle, l lock
—— SCREENSHOT ——————————————————————
Print            Region (copy+save)
SHIFT Print      Full screen
CTRL  Print      Active window
ALT   Print      Pick color (hyprpicker)
—— MEDIA ———————————————————————————
XF86 vol/bright  swayosd (bezel overlay)
XF86 play/next   playerctl
EOF
