# NIGHTWIRE — SDDM greeter

Terminal-HUD login screen for Rafay-Hyprland-Arch. Pure QtQuick,
no `SddmComponents 2.0` import — loads on both Qt5-SDDM (0.19.x)
and Qt6-SDDM (0.21+).

## What's on screen

- **Boot-log cold start** — fake kernel log scrolls on load, then
  clears to the login HUD.
- **Matrix rain** canvas layer at 18% opacity behind content.
- **CRT scanlines** (animated, drifting) + vertical and horizontal
  vignettes.
- **Monster monospace clock** `HH:MM:SS`, live seconds, 160px
  phosphor bold.
- **Box-drawing login frame** with `╡ NIGHTWIRE // auth-prompt ╞`
  header and `+` corner tick marks.
- **Prompt-style inputs** — `> login as [ rafay ]`, `> passwd : ●●●●`,
  `> session: [ Hyprland ]`.
- **Blinking phosphor caret** on the password field.
- **Keyboard shortcuts** — F1 cycles session, F2 cycles user, ESC
  clears, ENTER submits.
- **Fail state** — red `>> ACCESS DENIED · retry_` + shake animation.
- **Success state** — phosphor-flood flash overlay.

## Palette

Phosphor-void. `#00ff9c` phosphor green, `#ff2975` hot magenta,
`#00e5ff` cyan, `#05070a` void, `#d8e3d4` bone fg, `#ff003c` blood
critical, `#ffb000` amber warn.

## Install (manual)

```bash
sudo cp -r sddm-theme /usr/share/sddm/themes/nightwire
sudo cp /path/to/wallpaper.png /usr/share/sddm/themes/nightwire/wall.png
sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << 'EOF'
[Theme]
Current=nightwire
CursorTheme=Bibata-Modern-Classic
EOF
```

The main `install.sh` does all of this for you — pick option 1 at the SDDM
prompt.

## Customize

Edit `theme.conf` — colors, font, clock format are all driven from
there, no QML edits needed. Swap the accent for a different phosphor
hue (amber `#ffb000`, red `#ff003c`, cyan `#00e5ff`) and the whole
greeter re-tints to match.

## Requirements

- `qt6-declarative` (or `qt5-declarative` on older systems)
- `qt6-svg`
- `qt6-5compat` — SDDM 0.21+ pulls Qt6 QtQuick
- `qt6-shadertools qt6-wayland` — recommended for the canvas layers
- `ttf-jetbrains-mono-nerd` (falls back to default mono)
