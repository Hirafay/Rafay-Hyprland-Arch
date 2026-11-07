-- ─────────────────────────────────────────────────────────────
--  Autostart — runs once per Hyprland start
-- ─────────────────────────────────────────────────────────────

hl.on("hyprland.start", function()
  -- cursor theme (also set via env, but hyprctl ensures it takes)
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")

  -- polkit agent (KDE variant installed by default; GNOME fallback)
  hl.exec_cmd("pidof polkit-kde-authentication-agent-1 || "
           .. "/usr/lib/polkit-kde-authentication-agent-1 & "
           .. "pidof polkit-gnome-authentication-agent-1 || "
           .. "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &")

  -- bar + notifications + wallpaper daemon
  hl.exec_cmd("pidof waybar || waybar &")
  hl.exec_cmd("pidof swaync || swaync &")
  hl.exec_cmd("pidof swww-daemon || swww-daemon &")

  -- idle daemon
  hl.exec_cmd("pidof hypridle || hypridle &")

  -- system tray helpers
  hl.exec_cmd("pidof nm-applet || nm-applet --indicator &")
  hl.exec_cmd("pidof blueman-applet || blueman-applet &")

  -- clipboard history
  hl.exec_cmd("pidof cliphist-daemon || wl-paste --type text  --watch cliphist store &")
  hl.exec_cmd("pidof cliphist-daemon || wl-paste --type image --watch cliphist store &")

  -- OSD
  hl.exec_cmd("pidof swayosd-server || swayosd-server &")

  -- restore last wallpaper (waypaper writes to $HOME/.config/waypaper/config.ini)
  -- 1s delay gives swww-daemon time to initialize its socket
  hl.exec_cmd("sleep 1 && "
           .. "(waypaper --restore 2>/dev/null || "
           .. " swww img $HOME/.config/hypr/wall.png "
           .. "  --transition-type grow --transition-duration 1) &")

  hl.notification.create({
    text = "nightwire loaded — SUPER+/ for binds",
    timeout = 3500,
    icon = "ok",
  })
end)

-- ── reload hook — reapply cursor on hyprctl reload ─────────
hl.on("config.reloaded", function()
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)
