------------------------
---- BATTERY MONITOR ----
------------------------
-- Native replacement for ~/.local/bin/battery-alert.

local BAT_PATH = nil          -- cached once found, e.g. "/sys/class/power_supply/BAT0"
local last_alert_level = nil  -- last threshold we actually notified at (5/10/20), or nil
local NOTIFY_REPLACE_ID = 91053  -- fixed id -> repeated alerts REPLACE the existing
                                   -- popup instead of stacking a new one every 30s
local NOTIFY_TIMEOUT_MS = 15000   -- how long the popup stays up before auto-dismissing

local THRESHOLDS = { 20, 10, 5 }  -- checked low->high priority order below (5 first)

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

local function notify(msg, urgency)
    -- -r/--replace-id: server-side sync so re-alerts at the same/lower level UPDATE
    --   the existing notification bubble instead of piling up duplicates.
    -- -t: explicit timeout so it doesn't linger forever or vanish before you read it.
    local cmd = string.format(
        "notify-send -u %s -r %d -t %d '\xF0\x9F\x94\x8B Low Battery' '%s' " ..
        "&& canberra-gtk-play -i dialog-warning",
        urgency, NOTIFY_REPLACE_ID, NOTIFY_TIMEOUT_MS, msg
    )
    local ok, err = pcall(hl.exec_cmd, cmd)
    if not ok then
        hl.print("[battery-monitor] notify failed: " .. tostring(err))
    end
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
    if not capacity then return end

    -- Any non-discharging state (Charging, Full, "Not charging" on some
    -- ThinkPad/Dell firmwares when capped) resets the alert state.
    if status ~= "Discharging" then
        last_alert_level = nil
        return
    end

    -- Find the lowest threshold we're at or under.
    local level = nil
    for _, t in ipairs(THRESHOLDS) do
        if capacity <= t then level = t end
    end

    if not level then
        last_alert_level = nil -- back above 20%, e.g. brief charge then unplug
        return
    end

    -- Hysteresis: only re-fire when we cross INTO a strictly lower/new level than
    -- the last one we alerted on. Prevents spam if capacity flickers 20/21/20.
    if last_alert_level and level >= last_alert_level then
        return
    end

    local urgency = (level == 5) and "critical" or "normal"
    local msg = (level == 5)
        and string.format("Battery is at %d%%. Plug in your charger immediately!", capacity)
        or string.format("Battery is at %d%%.", capacity)

    notify(msg, urgency)
    last_alert_level = level
end

-- Poll every 30s, same cadence as the original script.
hl.timer(check_battery, { timeout = 30000, type = "repeat" })
