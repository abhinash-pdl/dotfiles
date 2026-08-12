-------------------
---- KEYBINDINGS ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod     = "SUPER"
local terminal    = "foot"
local fileManager = "thunar"
local menu        = "~/.config/hypr/additional/rofi-toggle.sh"
local browser     = "firefox"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
-- hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("CTRL+ALT + Delete", hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + P", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pseudo())        -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))          -- dwindle
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser .. " -private-window"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("spotify-launcher"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("foot --app-id footfloat cava"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("foot --app-id footfloat1 tty-clock -c -C 2"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("vesktop"))

-- WhatsApp control
-- WhatsApp control (SUPER+W and SUPER+Q are now handled natively in whatsapp.lua,
-- with no external script / hyprctl / jq round-trip)

-- Recording stuff (bindd -> description passed via opts)
hl.bind("SUPER+ALT + R", hl.dsp.exec_cmd("~/.config/hypr/additional/record.sh"),
    { description = "Record region (no sound)" })
hl.bind("SUPER+SHIFT + R", hl.dsp.exec_cmd("~/.config/hypr/additional/record.sh --sound"),
    { description = "Record region (with sound)" })
hl.bind("CTRL+ALT + R", hl.dsp.exec_cmd("~/.config/hypr/additional/record.sh --fullscreen"),
    { description = "Record screen (no sound)" })
hl.bind("SUPER+SHIFT+ALT + R", hl.dsp.exec_cmd("~/.config/hypr/additional/record.sh --fullscreen-sound"),
    { description = "Record screen (with sound)" })

-- hl.bind("SUPER+SHIFT + W", hl.dsp.exec_cmd("pkill -USR1 waybar"))
hl.bind("CTRL+SHIFT + B", hl.dsp.exec_cmd([[fish -c "pkill -x waybar; waybar &"]]))

-- Immediate random wallpaper change
hl.bind(mainMod .. "+SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/additional/wallpaper_change.sh"))

-- Alt+Tab style window cycling
hl.bind("ALT + Tab", hl.dsp.window.cycle_next({ next = true }))
hl.bind("ALT+SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness (via swayosd)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),        { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),  { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })

hl.bind("XF86PowerOff", hl.dsp.exec_cmd("~/.config/wlogout/launch.sh"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Print: selection screenshot and copy
hl.bind("Print", hl.dsp.exec_cmd("~/.config/hypr/additional/screenshot_select.sh"))
-- mainMod + Print: full screenshot (save + copy)
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("~/.config/hypr/additional/screenshot_full.sh"))

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("sh -c 'copyq toggle'"))

-- Emoji picker
hl.bind(mainMod .. " + Period", hl.dsp.exec_cmd("rofimoji --action copy"))

-- gta
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(
    [[fish -c "cd '~/.wine/drive_c/Program Files (x86)/Grand Theft Auto San Andreas' && wine gta-sa.exe"]]))

-- notification control
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. "+SHIFT + N", hl.dsp.exec_cmd("swaync-client -C"))
