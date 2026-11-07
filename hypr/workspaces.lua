-- ─────────────────────────────────────────────────────────────
--  Named workspaces + app routing
--  Apps auto-route to their home workspace via windowrule v2.
-- ─────────────────────────────────────────────────────────────

-- persistent workspaces (shown in waybar even when empty)
for i = 1, 10 do
  hl.workspacerule({ workspace = tostring(i), persistent = true })
end

-- named workspaces — numbered so order stays stable in the bar
hl.workspacerule({ workspace = "name:1-sys",   monitor = "" })
hl.workspacerule({ workspace = "name:2-web",   monitor = "" })
hl.workspacerule({ workspace = "name:3-code",  monitor = "" })
hl.workspacerule({ workspace = "name:4-chat",  monitor = "" })
hl.workspacerule({ workspace = "name:5-media", monitor = "" })
hl.workspacerule({ workspace = "name:6-vm",    monitor = "" })
hl.workspacerule({ workspace = "name:7-games", monitor = "" })
hl.workspacerule({ workspace = "name:8-art",   monitor = "" })
hl.workspacerule({ workspace = "name:9-misc",  monitor = "" })

-- special (scratchpad) workspace: gapped-out
hl.workspacerule({ workspace = "special:magic", gapsout = 60, gapsin = 15 })
hl.workspacerule({ workspace = "special:magic", ["on-created-empty"] = "kitty" })

-- ── app routing via window rules ────────────────────────────
-- browsers → 2
hl.windowrule("workspace 2 silent", "class:^(firefox|librewolf|zen|brave-browser|chromium)$")

-- editors / IDEs → 3
hl.windowrule("workspace 3 silent", "class:^(Code|code-oss|code-url-handler)$")
hl.windowrule("workspace 3 silent", "class:^(jetbrains-.*)$")

-- chat → 4
hl.windowrule("workspace 4 silent", "class:^(discord|WebCord|org\\.telegram\\.desktop|whatsapp-for-linux)$")

-- media → 5
hl.windowrule("workspace 5 silent", "class:^(spotify|org\\.strawberrymusicplayer\\.strawberry|mpv|vlc)$")

-- vm → 6
hl.windowrule("workspace 6 silent", "class:^(virt-manager|virt-viewer|VirtualBox.*)$")

-- games → 7
hl.windowrule("workspace 7 silent", "class:^(steam|lutris|heroic|bottles|minecraft-launcher)$")
hl.windowrule("fullscreen",         "class:^(steam_app_.*)$")

-- art → 8
hl.windowrule("workspace 8 silent", "class:^(org\\.gimp\\.GIMP|org\\.inkscape\\.Inkscape|org\\.kde\\.krita|Aseprite|Blender)$")
