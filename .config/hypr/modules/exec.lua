-----------------
---- AUTOSTART ----
-----------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprlock &")
    hl.exec_cmd("awww-daemon &")
    hl.exec_cmd("~/.config/hypr/additional/wallpaper_random.sh &")
    hl.exec_cmd("hypridle &")
    hl.exec_cmd("waybar &")
    hl.exec_cmd("nm-applet --indicator &")
    -- hl.exec_cmd("blueman-applet &")
    hl.exec_cmd("swaync &")
    hl.exec_cmd("iio-hyprland &")
    hl.exec_cmd("sleep 3 && kdeconnect-indicator &")
    hl.exec_cmd("systemctl --user --no-block start hyprpolkitagent.service &")
    -- hl.exec_cmd("systemctl --user --no-block start mako.service &")
    hl.exec_cmd("wl-paste --type text --watch cliphist store &")
    hl.exec_cmd("wl-paste --type image --watch cliphist store &")
    hl.exec_cmd("systemctl --user --no-block start gammastep &")
    -- hl.exec_cmd("sleep 10 && vesktop --start-minimized &")
    hl.exec_cmd("kanshi &")
    -- battery-alert removed: now a native hl.timer() in battery.lua, no separate process
end)

-----------------------------
---- ENVIRONMENT VARIABLES ----
-- (one-off exec commands, not autostart)
-----------------------------
-- hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")   -- for GTK4 apps
-- hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Materia-light-compact'")   -- for GTK3 apps
