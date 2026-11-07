-- ─────────────────────────────────────────────────────────────
--  Monitors — list from `hyprctl monitors all`
--  Fallback rule (empty output name) handles any monitor not
--  explicitly configured: preferred mode, auto-placed, scale 1.
-- ─────────────────────────────────────────────────────────────

-- fallback for any unconfigured monitor (laptop lid open, external plug-in, etc.)
hl.monitor({
  output   = "",
  mode     = "preferred",
  position = "auto",
  scale    = 1,
})

-- Example per-monitor rules — uncomment + edit for your setup.
-- Find your output name with: hyprctl monitors all
--
-- hl.monitor({
--   output   = "eDP-1",
--   mode     = "1920x1080@60",
--   position = "0x0",
--   scale    = 1.25,
--   vrr      = 1,
-- })
--
-- hl.monitor({
--   output   = "HDMI-A-1",
--   mode     = "2560x1440@144",
--   position = "1920x0",
--   scale    = 1.0,
-- })
--
-- Disable a monitor:
-- hl.monitor({ output = "eDP-1", disabled = true })
--
-- Mirror a monitor:
-- hl.monitor({ output = "HDMI-A-1", mirror = "eDP-1" })
