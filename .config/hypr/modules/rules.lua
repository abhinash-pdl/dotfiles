------------------------------
---- WINDOWS AND WORKSPACES ----
------------------------------
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
