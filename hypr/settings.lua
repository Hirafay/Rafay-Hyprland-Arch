-- ─────────────────────────────────────────────────────────────
--  NIGHTWIRE — Hyprland core settings (lush)
--  Big rounding, animated gradient borders, rich blur, phosphor
--  shadow glow. Reads like a modern caelestia-tier rice.
-- ─────────────────────────────────────────────────────────────

hl.config({
  general = {
    gaps_in  = 5,
    gaps_out = 14,
    border_size = 2,
    layout = "dwindle",
    resize_on_border = true,
    allow_tearing = false,
    col = {
      -- phosphor → cyan sweep when active (border angle loop animates this)
      active_border   = "rgba(00ff9cff) rgba(00e5ffff) rgba(ff2975ff) 45deg",
      inactive_border = "rgba(1b2330cc)",
      nogroup_border        = "rgba(ff2975aa)",
      nogroup_border_active = "rgba(ff2975ff) rgba(00e5ffff) 45deg",
    },
    snap = {
      enabled       = true,
      border_overlap = false,
      respect_gaps  = true,
      monitor_gap   = 12,
      window_gap    = 8,
    },
  },

  decoration = {
    rounding       = 16,
    rounding_power = 2.4,
    active_opacity     = 1.0,
    inactive_opacity   = 0.92,
    fullscreen_opacity = 1.0,
    dim_inactive = true,
    dim_strength = 0.12,
    dim_special  = 0.4,

    blur = {
      enabled           = true,
      size              = 8,
      passes            = 4,
      new_optimizations = true,
      xray              = false,
      noise             = 0.015,
      contrast          = 1.05,
      brightness        = 0.86,
      vibrancy          = 0.22,
      vibrancy_darkness = 0.1,
      popups            = true,
      popups_ignorealpha = 0.2,
    },

    shadow = {
      enabled        = true,
      range          = 40,
      render_power   = 3,
      offset         = "0 2",
      -- phosphor-tinted glow, not a dark drop shadow
      color          = "rgba(00ff9c44)",
      color_inactive = "rgba(00000099)",
    },
  },

  input = {
    kb_layout       = "us",
    follow_mouse    = 1,
    sensitivity     = 0,
    numlock_by_default = true,
    repeat_delay    = 350,
    repeat_rate     = 40,
    touchpad = {
      natural_scroll       = true,
      disable_while_typing = true,
      tap_to_click         = true,
      drag_lock            = 1,
      scroll_factor        = 0.8,
    },
  },

  gestures = {
    workspace_swipe_distance   = 300,
    workspace_swipe_cancel_ratio = 0.5,
    workspace_swipe_forever    = true,
    workspace_swipe_create_new = true,
  },

  misc = {
    disable_hyprland_logo    = true,
    disable_splash_rendering = true,
    animate_manual_resizes   = true,
    animate_mouse_windowdragging = false,
    mouse_move_enables_dpms  = true,
    key_press_enables_dpms   = true,
    enable_swallow           = true,
    swallow_regex            = "^(kitty|Alacritty|org\\.wezfurlong\\.wezterm)$",
    vrr                      = 1,
    focus_on_activate        = false,
    middle_click_paste       = true,
    new_float_force_onscreen = 2,
    background_color         = "0x05070a",
  },

  cursor = {
    inactive_timeout         = 5,
    hide_on_key_press        = false,
    no_warps                 = false,
    persistent_warps         = true,
    warp_on_change_workspace = 1,
    sync_gsettings_theme     = true,
  },

  xwayland = {
    enabled           = true,
    force_zero_scaling = true,
  },

  render = {
    direct_scanout = 2,
  },

  binds = {
    workspace_back_and_forth   = 1,
    workspace_center_on        = 1,
    movefocus_cycles_fullscreen = true,
  },

  dwindle = {
    preserve_split   = true,
    pseudotile       = true,
    smart_split      = false,
    smart_resizing   = true,
    force_split      = 0,
  },
})
