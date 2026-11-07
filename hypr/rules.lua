-- ─────────────────────────────────────────────────────────────
--  Window & layer rules
-- ─────────────────────────────────────────────────────────────

-- helper to float + center + size
local function float_centered(selector, w, h)
  hl.windowrule("float", selector)
  hl.windowrule("center", selector)
  hl.windowrule("size " .. w .. "% " .. h .. "%", selector)
end

-- ── control panels / dialogs ────────────────────────────────
float_centered("class:^(pavucontrol)$", 50, 60)
float_centered("class:^(blueman-manager)$", 45, 55)
float_centered("class:^(nm-connection-editor)$", 45, 60)
float_centered("class:^(qt6ct)$", 55, 70)
float_centered("class:^(nwg-look)$", 55, 70)
float_centered("class:^(org\\.kde\\.polkit-kde-authentication-agent-1)$", 25, 25)

-- xdg portal picker
hl.windowrule("float",  "class:^(xdg-desktop-portal-gtk)$")
hl.windowrule("center", "class:^(xdg-desktop-portal-gtk)$")

-- image viewers float by default
hl.windowrule("float",  "class:^(imv|feh|swappy|org\\.gnome\\.eog)$")
hl.windowrule("center", "class:^(imv|feh|swappy|org\\.gnome\\.eog)$")

-- waypaper picker
float_centered("class:^(waypaper)$", 60, 70)

-- ── opacity rules ──────────────────────────────────────────
hl.windowrule("opacity 1.0 override 1.0 override", "class:^(firefox|org\\.mozilla\\.firefox)$")
hl.windowrule("opacity 1.0 override 1.0 override", "class:^(Code|code-oss|code-url-handler)$")
hl.windowrule("opacity 1.0 override 1.0 override", "class:^(mpv|vlc)$")
hl.windowrule("opacity 1.0 override 1.0 override", "fullscreen:1")

-- ── no shadow for picture-in-picture / tooltips ────────────
hl.windowrule("noshadow",  "floating:0")
hl.windowrule("rounding 0", "fullscreen:1")

-- ── layer rules ─────────────────────────────────────────────
hl.layerrule("blur",          "waybar")
hl.layerrule("ignorezero",    "waybar")
hl.layerrule("blur",          "swaync-notification-window")
hl.layerrule("ignorezero",    "swaync-notification-window")
hl.layerrule("blur",          "swaync-control-center")
hl.layerrule("ignorezero",    "swaync-control-center")
hl.layerrule("blur",          "wofi")
hl.layerrule("ignorezero",    "wofi")
hl.layerrule("blur",          "rofi")
hl.layerrule("ignorezero",    "rofi")

-- hyprlock gets the full screen
hl.layerrule("noanim", "hyprlock")

-- ── suppress specific noisy events ─────────────────────────
hl.windowrule("suppressevent maximize", "class:.*")
