-----------------------
---- WHATSAPP TOGGLE ----
-----------------------
local WHATSAPP_CLASS = "WhatsApp Desktop"
local WHATSAPP_BIN   = "/opt/WhatsApp Desktop/whatsapp-linux-desktop"

local function find_whatsapp_window()
    local wins = hl.get_windows()
    if wins then
        for _, w in ipairs(wins) do
            if w.initial_class == WHATSAPP_CLASS or w.class == WHATSAPP_CLASS then
                return w
            end
        end
    end
    return nil
end

-- SUPER + W: toggle show/hide/move-here
local function whatsapp_toggle()
    local w = find_whatsapp_window()
    
    if not w then
        print("[whatsapp] not running, launching")
        hl.exec_cmd('"' .. WHATSAPP_BIN .. '"')
        return
    end

    local active = hl.get_active_window()
    local is_focused = active and (active.address == w.address)
    local current_ws = hl.get_active_workspace()

    if is_focused then
        -- 1. Window is focused. We want to HIDE it.
        -- Move it to the special workspace as a "storage room" to get it off screen.
        print("[whatsapp] hiding to special workspace storage")
        hl.dispatch(hl.dsp.window.move({ workspace = "special:whatsapp", window = w, follow = false }))
    else
        -- 2. Window is NOT focused (either hidden in storage or on another workspace).
        -- Move it physically to your CURRENT normal workspace.
        -- Because it becomes a normal window here, it will NOT follow you when you switch workspaces.
        print("[whatsapp] pulling to current normal workspace")
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(current_ws.id), window = w, follow = false }))
        hl.dispatch(hl.dsp.focus({ window = w }))
    end
end

-- SUPER + Q: hide WhatsApp if it's active, otherwise close whatever is active
local function whatsapp_hide_or_close()
    local active = hl.get_active_window()
    
    if not active then 
        return 
    end 
    
    if active.initial_class == WHATSAPP_CLASS or active.class == WHATSAPP_CLASS then
        print("[whatsapp] hiding active WhatsApp window to storage")
        hl.dispatch(hl.dsp.window.move({ workspace = "special:whatsapp", window = active, follow = false }))
    else
        print("[whatsapp] closing active window")
        hl.dispatch(hl.dsp.window.close())
    end
end

hl.bind("SUPER + W", whatsapp_toggle)
hl.bind("SUPER + Q", whatsapp_hide_or_close)
