# Waybar — Rafay-Hyprland-Arch

Modular status bar for the rice. Entry point loads 11 module files, grouped into drawers on the left (apps, storage, system) and right (audio, connections, tray).

---

## Structure

```
waybar/
├── config.jsonc                     # Entry point, loads all modules
├── style.css                        # Main stylesheet, imports tokens
├── modules/                         # One file per module
│   ├── audio.jsonc
│   ├── battery.jsonc
│   ├── clock.jsonc
│   ├── connections.jsonc            # Network + Bluetooth
│   ├── distro.jsonc                 # App launcher icons
│   ├── groups.jsonc                 # Drawer grouping
│   ├── idle-ihibitor.jsonc
│   ├── power-profiles-daemon.jsonc
│   ├── storage.jsonc
│   ├── system.jsonc                 # CPU, temperature
│   ├── tray-notif.jsonc             # Tray + SwayNC
│   └── workspace.jsonc
└── tokens/                          # CSS variables
    ├── colors.css                   # ← edit colors here
    ├── batt-clock.css
    ├── slider.css
    ├── state.css
    ├── widget.css
    └── workspace.css
```

---

## Module interactions

| Module | Interaction | Action |
| --- | --- | --- |
| Network | Left click | Show `nm-applet` in tray |
| | Right click | Hide `nm-applet` |
| | Scroll up | Enable Wi-Fi |
| | Scroll down | Disable Wi-Fi |
| Bluetooth | Left click | Open `blueman-manager` |
| | Right click | Toggle power on/off |
| SwayNC arrow | Left click | Open/close notification panel |
| | Right click | Toggle Do Not Disturb |
| Power Profiles | Click | Cycle Saver → Balanced → Performance |
| Idle Inhibitor | Click | Toggle screen dimming lock |
| Pulseaudio | Click | Open `pavucontrol` |

---

## Colors

Edit `tokens/colors.css` — all other token files reference its `@define-color` entries.

---

## Dependencies

All installed by the top-level `install.sh`:

| Package | Purpose |
| --- | --- |
| waybar | The bar itself |
| swaync | Notification center |
| network-manager-applet | Tray icon for Wi-Fi |
| blueman | Bluetooth manager |
| pipewire / wireplumber | Audio backend (`wpctl`) |
| power-profiles-daemon | Power profile switching |
| pavucontrol | Audio mixer |

---

## License

MIT — part of Rafay-Hyprland-Arch.
