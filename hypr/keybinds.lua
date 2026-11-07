-- ─────────────────────────────────────────────────────────────
--  Keybinds — last require, references submaps already defined
-- ─────────────────────────────────────────────────────────────

local mod = "SUPER"

local terminal    = "kitty"
local launcher    = "wofi --show drun"
local filemanager = "thunar"
local browser     = "firefox"
local screenshot  = "$HOME/.config/hypr/scripts/screenshot.sh"
local power_menu  = "$HOME/.config/hypr/scripts/power-menu.sh"
local cheatsheet  = "$HOME/.config/hypr/scripts/cheatsheet.sh"
local clip_hist   = "cliphist list | wofi --dmenu | cliphist decode | wl-copy"

-- ── core launches ───────────────────────────────────────────
hl.bind(mod .. ", return", function() hl.exec_cmd(terminal) end)
hl.bind(mod .. ", space",  function() hl.exec_cmd(launcher) end)
hl.bind(mod .. ", E",      function() hl.exec_cmd(filemanager) end)
hl.bind(mod .. ", B",      function() hl.exec_cmd(browser) end)
hl.bind(mod .. ", V",      function() hl.exec_cmd(clip_hist) end)
hl.bind(mod .. ", W",      function() hl.exec_cmd("waypaper") end)
hl.bind(mod .. ", X",      function() hl.exec_cmd("hyprlock") end)
hl.bind(mod .. " SHIFT, P", function() hl.exec_cmd(power_menu) end)
hl.bind(mod .. ", slash",  function() hl.exec_cmd(cheatsheet) end)

-- ── window management ───────────────────────────────────────
hl.bind(mod .. ", Q",      function() hl.exec_cmd("hyprctl dispatch killactive") end)
hl.bind(mod .. ", F",      function() hl.exec_cmd("hyprctl dispatch togglefloating") end)
hl.bind(mod .. ", G",      function() hl.exec_cmd("hyprctl dispatch fullscreen 0") end)
hl.bind(mod .. ", P",      function() hl.exec_cmd("hyprctl dispatch pseudo") end)
hl.bind(mod .. ", S",      function() hl.exec_cmd("hyprctl dispatch swapnext") end)
hl.bind(mod .. " SHIFT, M", function() hl.exec_cmd("hyprctl dispatch exit") end)
hl.bind(mod .. " SHIFT, R", function() hl.exec_cmd("hyprctl reload") end)

-- ── focus (vim + arrows) ────────────────────────────────────
hl.bind(mod .. ", H",     function() hl.exec_cmd("hyprctl dispatch movefocus l") end)
hl.bind(mod .. ", L",     function() hl.exec_cmd("hyprctl dispatch movefocus r") end)
hl.bind(mod .. ", K",     function() hl.exec_cmd("hyprctl dispatch movefocus u") end)
hl.bind(mod .. ", J",     function() hl.exec_cmd("hyprctl dispatch movefocus d") end)
hl.bind(mod .. ", left",  function() hl.exec_cmd("hyprctl dispatch movefocus l") end)
hl.bind(mod .. ", right", function() hl.exec_cmd("hyprctl dispatch movefocus r") end)
hl.bind(mod .. ", up",    function() hl.exec_cmd("hyprctl dispatch movefocus u") end)
hl.bind(mod .. ", down",  function() hl.exec_cmd("hyprctl dispatch movefocus d") end)

-- ── move windows ────────────────────────────────────────────
hl.bind(mod .. " SHIFT, H", function() hl.exec_cmd("hyprctl dispatch movewindow l") end)
hl.bind(mod .. " SHIFT, L", function() hl.exec_cmd("hyprctl dispatch movewindow r") end)
hl.bind(mod .. " SHIFT, K", function() hl.exec_cmd("hyprctl dispatch movewindow u") end)
hl.bind(mod .. " SHIFT, J", function() hl.exec_cmd("hyprctl dispatch movewindow d") end)

-- ── quick resize (one-shot) ─────────────────────────────────
hl.bind(mod .. " CTRL, H", function() hl.exec_cmd("hyprctl dispatch resizeactive -40 0") end)
hl.bind(mod .. " CTRL, L", function() hl.exec_cmd("hyprctl dispatch resizeactive  40 0") end)
hl.bind(mod .. " CTRL, K", function() hl.exec_cmd("hyprctl dispatch resizeactive  0 -40") end)
hl.bind(mod .. " CTRL, J", function() hl.exec_cmd("hyprctl dispatch resizeactive  0  40") end)

-- ── workspaces 1..10 ────────────────────────────────────────
for i = 1, 9 do
  local n = tostring(i)
  hl.bind(mod .. ", " .. n,
    function() hl.exec_cmd("hyprctl dispatch workspace " .. n) end)
  hl.bind(mod .. " SHIFT, " .. n,
    function() hl.exec_cmd("hyprctl dispatch movetoworkspace " .. n) end)
end
hl.bind(mod .. ", 0",       function() hl.exec_cmd("hyprctl dispatch workspace 10") end)
hl.bind(mod .. " SHIFT, 0", function() hl.exec_cmd("hyprctl dispatch movetoworkspace 10") end)

-- scratchpad
hl.bind(mod .. ", A",       function() hl.exec_cmd("hyprctl dispatch togglespecialworkspace magic") end)
hl.bind(mod .. " SHIFT, A", function() hl.exec_cmd("hyprctl dispatch movetoworkspace special:magic") end)

-- scroll through workspaces
hl.bind(mod .. ", mouse_down", function() hl.exec_cmd("hyprctl dispatch workspace e+1") end)
hl.bind(mod .. ", mouse_up",   function() hl.exec_cmd("hyprctl dispatch workspace e-1") end)

-- ── mouse ───────────────────────────────────────────────────
hl.bindm(mod .. ", mouse:272", "movewindow")
hl.bindm(mod .. ", mouse:273", "resizewindow")

-- ── screenshots ─────────────────────────────────────────────
hl.bind(", Print",       function() hl.exec_cmd(screenshot .. " area")   end)
hl.bind("SHIFT, Print",  function() hl.exec_cmd(screenshot .. " screen") end)
hl.bind("CTRL, Print",   function() hl.exec_cmd(screenshot .. " window") end)
hl.bind("ALT, Print",    function() hl.exec_cmd(screenshot .. " color")  end)

-- ── media / volume / brightness (passthrough to locked state) ──
hl.bindel(", XF86AudioRaiseVolume",  function() hl.exec_cmd("swayosd-client --output-volume=raise") end)
hl.bindel(", XF86AudioLowerVolume",  function() hl.exec_cmd("swayosd-client --output-volume=lower") end)
hl.bindl (", XF86AudioMute",         function() hl.exec_cmd("swayosd-client --output-volume=mute-toggle") end)
hl.bindl (", XF86AudioMicMute",      function() hl.exec_cmd("swayosd-client --input-volume=mute-toggle") end)
hl.bindel(", XF86MonBrightnessUp",   function() hl.exec_cmd("swayosd-client --brightness=raise") end)
hl.bindel(", XF86MonBrightnessDown", function() hl.exec_cmd("swayosd-client --brightness=lower") end)
hl.bindl (", XF86AudioPlay",         function() hl.exec_cmd("playerctl play-pause") end)
hl.bindl (", XF86AudioNext",         function() hl.exec_cmd("playerctl next") end)
hl.bindl (", XF86AudioPrev",         function() hl.exec_cmd("playerctl previous") end)

-- ── submap entry points ─────────────────────────────────────
hl.bind(mod .. ", Y",          function() hl.exec_cmd("hyprctl dispatch submap resize") end)
hl.bind(mod .. ", O",          function() hl.exec_cmd("hyprctl dispatch submap launch") end)
hl.bind(mod .. " SHIFT, X",    function() hl.exec_cmd("hyprctl dispatch submap screenshot") end)
hl.bind(mod .. " SHIFT, G",    function() hl.exec_cmd("hyprctl dispatch submap group") end)

-- ── dynamic gaps toggle (demo of hl.get_config / hl.config) ──
hl.bind(mod .. " SHIFT, N", function()
  local cur = hl.get_config("general.gaps_in")
  if cur and cur.top and cur.top > 0 then
    hl.config({ ["general.gaps_in"] = 0, ["general.gaps_out"] = 0 })
    hl.notification.create({ text = "gaps off", timeout = 1200, icon = "info" })
  else
    hl.config({ ["general.gaps_in"] = 3, ["general.gaps_out"] = 8 })
    hl.notification.create({ text = "gaps on", timeout = 1200, icon = "info" })
  end
end)
