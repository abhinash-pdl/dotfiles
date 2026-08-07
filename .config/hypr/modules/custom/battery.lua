------------------------
---- BATTERY MONITOR ----
------------------------
-- Native replacement for ~/.local/bin/battery-alert.
--
-- Old version: infinite bash loop, spawning `cat` x2 + (on threshold) `notify-send`
-- + `canberra-gtk-play`, every 30s, forever, as a separate background process.
--
-- This version: a single hl.timer() ticking inside the compositor's own event loop,
-- reading /sys directly via io.open() (no shell, no subprocess) on every tick, and
-- only spawning a process on the rare occasion a notification actually needs to fire.
--
-- NOTE: kept notify-send + canberra-gtk-play (not hl.notification.create) on purpose:
-- Hyprland's native notifications are simple text-only popups and won't show up in
-- swaync's notification center/history the way your setup expects.

local BAT_PATH = nil -- cached once found, e.g. "/sys/class/power_supply/BAT0"
local last_alert_level = nil

local function find_battery_path()
    for _, name in ipairs({ "BAT0", "BAT1", "BAT2" }) do
        local f = io.open("/sys/class/power_supply/" .. name .. "/capacity", "r")
        if f then
            f:close()
            return "/sys/class/power_supply/" .. name
        end
    end
    return nil
end

local function read_trim(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*l")
    f:close()
    return content
end

local function check_battery()
    if not BAT_PATH then
        BAT_PATH = find_battery_path()
        if not BAT_PATH then
            hl.print("[battery-monitor] no battery found, skipping check")
            return
        end
    end

    local capacity_str = read_trim(BAT_PATH .. "/capacity")
    local status = read_trim(BAT_PATH .. "/status")
    if not capacity_str then return end

    local capacity = tonumber(capacity_str)

    if status == "Charging" then
        last_alert_level = nil
        return
    end

    local function notify(msg, level)
        hl.exec_cmd(string.format(
            "notify-send -u critical '\xF0\x9F\x94\x8B Low Battery' '%s' && canberra-gtk-play -i dialog-warning",
            msg
        ))
        last_alert_level = level
    end

    if capacity <= 5 and last_alert_level ~= 5 then
        notify(string.format("Battery is at %d%%. Plug in your charger immediately!", capacity), 5)
    elseif capacity <= 10 and last_alert_level ~= 10 and last_alert_level ~= 5 then
        notify(string.format("Battery is at %d%%.", capacity), 10)
    elseif capacity <= 20 and last_alert_level ~= 20 and last_alert_level ~= 10 and last_alert_level ~= 5 then
        notify(string.format("Battery is at %d%%.", capacity), 20)
    end
end

-- Poll every 30s, same cadence as the original script
hl.timer(check_battery, { timeout = 30000, type = "repeat" })
