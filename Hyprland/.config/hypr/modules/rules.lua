-- ------------------------------
-- WINDOWS AND WORKSPACES
-- ------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- ------------------------------
-- POPUPS / DIALOGS / AUTH (ported from niri config)
-- ------------------------------

-- Firefox Picture-in-Picture
hl.window_rule({
    name  = "float-firefox-pip",
    match = { class = "^firefox$", title = "^Picture%-in%-Picture$" },
    float = true,
})

-- Browser / editor / notes apps -> "browser" workspace
hl.window_rule({
    name  = "workspace-browser-apps",
    match = { class = "^(firefox|google%-chrome|code|obsidian)$" },

})

-- VS Code -> dedicated "vscode" workspace (may show as code-oss/codium)
hl.window_rule({
    name  = "workspace-vscode",
    match = { class = "^(code|code%-oss|codium)$" },

})

-- File open/save/select dialogs
hl.window_rule({
    name  = "float-file-dialogs",
    match = { title = ".*(Open|Save|Select).*" },
    float = true,
    max_size = "800 1000",
})
hl.window_rule({
    name  = "float-file-title",
    match = { title = ".*File.*" },
    float = true,
    max_size = "800 1000",
})
hl.window_rule({
    name  = "float-gtk-filechooser",
    match = { class = "^org%.gtk%.FileChooserDialog$" },
    float = true,
    max_size = "800 1000",
})

-- Google account sign-in popup in Firefox
hl.window_rule({
    name  = "float-google-signin",
    match = { title = ".*Sign in %- Google Accounts — Mozilla Firefox" },
    float = true,
})

-- Generic dialog/settings/prefs windows
hl.window_rule({
    name  = "float-dialogs",
    match = { title = ".*(Dialog|Properties|Preferences|Settings|Rename).*" },
    float = true,
})

-- zenity
hl.window_rule({
    name  = "float-zenity",
    match = { class = "^zenity$" },
    float = true,
})

-- polkit auth agent
hl.window_rule({
    name  = "float-polkit-kde",
    match = { class = "^org%.kde%.polkit%-kde%-authentication%-agent%-1$" },
    float = true,
})

-- generic auth windows
hl.window_rule({
    name  = "float-auth",
    match = { title = ".*Authentication.*" },
    float = true,
})

-- KeePassXC auto-type
hl.window_rule({
    name  = "float-keepassxc-autotype",
    match = { class = "^org%.keepassxc%.KeePassXC$", title = ".*Auto%-Type.*" },
    float = true,
})

-- Bitwarden unlock
hl.window_rule({
    name  = "float-bitwarden-unlock",
    match = { class = "^Bitwarden$", title = ".*unlock.*" },
    float = true,
})

-- nm-connection-editor
hl.window_rule({
    name  = "float-nm-editor",
    match = { class = "^nm%-connection%-editor$" },
    float = true,
})

-- blueman-manager
hl.window_rule({
    name  = "float-blueman",
    match = { class = "^blueman%-manager$" },
    float = true,
})

-- pavucontrol
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^pavucontrol$" },
    float = true,
})

-- Steam friends/settings/properties popups
hl.window_rule({
    name  = "float-steam-popups",
    match = { class = "^steam$", title = ".*(Friends|Settings|Properties).*" },
    float = true,
})

-- ------------------------------
-- APP-SPECIFIC FLOATS (existing)
-- ------------------------------

-- Spotify
hl.window_rule({
    name  = "spotify-float",
    match = { class = "spotify" },
    float        = true,
    size         = "1200 700",
    center       = true,
    no_anim      = false,
    no_blur      = false,
    pin          = false,
    stay_focused = false,
    opacity      = 0.8,
})
-- Float Foot
hl.window_rule({
    name  = "foot-float",
    match = { class = "^(footfloat)$" },
    float  = true,
    size   = "1000 600",
    center = true,
})
-- Float Foot TTY
hl.window_rule({
    name  = "foot-float-tty",
    match = { class = "^(footfloat1)$" },
    float = true,
    size  = "400 175",
    move  = "50 50",
})
-- WhatsApp
hl.window_rule({
    name  = "whatsapp-float",
    match = { class = "WhatsApp Desktop" },
    float  = true,
    size   = "1200 800",
    center = true,
})
-- xwayland video bridge
hl.window_rule({
    name  = "xwaylandvideobridge-fix",
    match = { class = "^(xwaylandvideobridge)$" },
    opacity          = "0.0 override",
    no_anim          = true,
    no_initial_focus = true,
    max_size         = "1 1",
    no_blur          = true,
    no_focus         = true,
})
-- Apache NetBeans IDE
hl.window_rule({
    name  = "netbeans-float",
    match = { class = "^(Apache NetBeans IDE.*)$" },
    float        = true,
    pin          = false,
    stay_focused = false,
})
hl.window_rule({
    name  = "swaync-opacity",
    match = { class = "^(swaync-control-center)$" },
    opacity = "0.92 0.92",
})
hl.window_rule({
    name  = "glut",
    match = { class = "^$" },
    float  = true,
    center = true,
})
-- CopyQ clipboard manager
hl.window_rule({
    name   = "copyq-float",
    match  = { class = "^(com.github.hluk.copyq)$" },
    float  = true,
    size   = "550 500",
    center = true,
})

-- ------------------------------
-- GLOBAL APPEARANCE (from niri config)
-- ------------------------------

-- Corner radius, applied to all windows
hl.window_rule({
    name  = "global-rounding",
    match = { class = ".*" },
    rounding = 12,
})

