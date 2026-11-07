-- ─────────────────────────────────────────────────────────────
--  Rafay-Hyprland-Arch — AMBERPHOSPHOR
--  Hyprland Lua config entrypoint
--
--  Each require is a separate scope: an error in one module
--  will not break the others. Order is intentional — env
--  before anything that spawns, animations before settings,
--  keybinds last so submaps exist.
-- ─────────────────────────────────────────────────────────────

local function safe_require(module)
  local ok, err = pcall(require, module)
  if not ok then
    hl.notification.create({
      text = "config module '" .. module .. "' failed: " .. tostring(err),
      timeout = 8000,
      icon = "error",
    })
  end
end

safe_require("env")        -- env vars first (before anything spawns)
safe_require("monitors")   -- outputs
safe_require("animations") -- curves must exist before settings references them
safe_require("settings")   -- general / decoration / input / misc
safe_require("rules")      -- window + workspace rules
safe_require("workspaces") -- named workspaces + app routing
safe_require("autostart")  -- hl.on("hyprland.start", ...)
safe_require("submaps")    -- submap definitions
safe_require("keybinds")   -- binds last (references submaps)
