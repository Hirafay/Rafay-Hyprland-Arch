-- ─────────────────────────────────────────────────────────────
--  NIGHTWIRE — animation curves + tree assignments (lush)
--  Curves must exist before animations reference them.
-- ─────────────────────────────────────────────────────────────

-- ── curves ──────────────────────────────────────────────────
hl.curve("overshoot", { type = "bezier", points = { {0.05, 0.9},  {0.1, 1.08} } })
hl.curve("smoothOut", { type = "bezier", points = { {0.36, 0},    {0.66, -0.56} } })
hl.curve("smoothIn",  { type = "bezier", points = { {0.25, 1},    {0.5, 1} } })
hl.curve("snappy",    { type = "bezier", points = { {0.68, -0.55},{0.27, 1.55} } })
hl.curve("gentle",    { type = "bezier", points = { {0.42, 0},    {0.58, 1} } })
hl.curve("menu",      { type = "bezier", points = { {0.2, 1},     {0.2, 1} } })

-- spring curves — organic motion
hl.curve("springy",      { type = "spring", mass = 1,   stiffness = 180, damping = 14 })
hl.curve("rubber",       { type = "spring", mass = 1,   stiffness = 70,  damping = 10 })
hl.curve("bouncy",       { type = "spring", mass = 0.8, stiffness = 220, damping = 10 })

-- ── master switch ───────────────────────────────────────────
hl.config({ animations = { enabled = true } })

-- ── tree assignments ────────────────────────────────────────
hl.animation({ leaf = "windows",      enabled = true, speed = 4.5, curve = "overshoot", style = "slide" })
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 4,   curve = "bouncy",    style = "popin 80%" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 3,   curve = "smoothOut", style = "slide" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 4,   curve = "springy",   style = "slide" })

hl.animation({ leaf = "layers",       enabled = true, speed = 4,   curve = "gentle",    style = "fade" })

hl.animation({ leaf = "fade",         enabled = true, speed = 6,   curve = "smoothIn" })
hl.animation({ leaf = "fadeDim",      enabled = true, speed = 6,   curve = "smoothIn" })
hl.animation({ leaf = "fadeLayers",   enabled = true, speed = 4,   curve = "smoothIn" })

hl.animation({ leaf = "border",       enabled = true, speed = 10,  curve = "default" })
-- fast border-angle loop — that classic "animated gradient border" effect
hl.animation({ leaf = "borderangle",  enabled = true, speed = 30,  curve = "linear",    style = "loop" })

hl.animation({ leaf = "workspaces",   enabled = true, speed = 5,   curve = "springy",   style = "slidevert" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, curve = "springy", style = "slidefadevert 20%" })
