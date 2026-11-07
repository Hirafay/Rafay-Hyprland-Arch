-- ─────────────────────────────────────────────────────────────
--  Submaps — modal keybinding modes
--  Entry binds live in keybinds.lua.
-- ─────────────────────────────────────────────────────────────

-- ── RESIZE mode ─────────────────────────────────────────────
hl.submap("resize", function()
  hl.bind(", H",     function() hl.exec_cmd("hyprctl dispatch resizeactive -30 0") end)
  hl.bind(", L",     function() hl.exec_cmd("hyprctl dispatch resizeactive  30 0") end)
  hl.bind(", K",     function() hl.exec_cmd("hyprctl dispatch resizeactive  0 -30") end)
  hl.bind(", J",     function() hl.exec_cmd("hyprctl dispatch resizeactive  0  30") end)
  hl.bind(", left",  function() hl.exec_cmd("hyprctl dispatch resizeactive -30 0") end)
  hl.bind(", right", function() hl.exec_cmd("hyprctl dispatch resizeactive  30 0") end)
  hl.bind(", up",    function() hl.exec_cmd("hyprctl dispatch resizeactive  0 -30") end)
  hl.bind(", down",  function() hl.exec_cmd("hyprctl dispatch resizeactive  0  30") end)
  hl.bind(", C",     function() hl.exec_cmd("hyprctl dispatch centerwindow") end)
  hl.bind(", escape", function() hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", return", function() hl.exec_cmd("hyprctl dispatch submap reset") end)
end)

-- ── LAUNCH mode ─────────────────────────────────────────────
hl.submap("launch", function()
  hl.bind(", B", function() hl.exec_cmd("firefox");      hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", T", function() hl.exec_cmd("kitty");        hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", C", function() hl.exec_cmd("code");         hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", F", function() hl.exec_cmd("thunar");       hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", D", function() hl.exec_cmd("discord");      hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", S", function() hl.exec_cmd("spotify");      hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", O", function() hl.exec_cmd("obs");          hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", G", function() hl.exec_cmd("gimp");         hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", M", function() hl.exec_cmd("kitty -e btop"); hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", N", function() hl.exec_cmd("kitty -e nvim"); hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", escape", function() hl.exec_cmd("hyprctl dispatch submap reset") end)
end)

-- ── SCREENSHOT mode ─────────────────────────────────────────
local SS = "$HOME/.config/hypr/scripts/screenshot.sh"

hl.submap("screenshot", function()
  hl.bind(", A", function() hl.exec_cmd(SS .. " area");   hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", W", function() hl.exec_cmd(SS .. " window"); hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", S", function() hl.exec_cmd(SS .. " screen"); hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", C", function() hl.exec_cmd(SS .. " color");  hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", D", function() hl.exec_cmd(SS .. " delay");  hl.exec_cmd("hyprctl dispatch submap reset") end)
  hl.bind(", escape", function() hl.exec_cmd("hyprctl dispatch submap reset") end)
end)

-- ── GROUP mode ──────────────────────────────────────────────
hl.submap("group", function()
  hl.bind(", G",   function() hl.exec_cmd("hyprctl dispatch togglegroup") end)
  hl.bind(", tab", function() hl.exec_cmd("hyprctl dispatch changegroupactive f") end)
  hl.bind(", H",   function() hl.exec_cmd("hyprctl dispatch changegroupactive b") end)
  hl.bind(", L",   function() hl.exec_cmd("hyprctl dispatch lockactivegroup toggle") end)
  hl.bind(", escape", function() hl.exec_cmd("hyprctl dispatch submap reset") end)
end)

-- ── waybar submap indicator ─────────────────────────────────
-- fire a small notification when submap changes so user sees the mode
hl.on("keybinds.submap", function(name)
  if name and name ~= "" then
    hl.notification.create({
      text = "mode: " .. name,
      timeout = 1500,
      icon = "hint",
    })
  end
end)
