function applyLayout()
    -- hs.alert.show("Syncing by Screen Index...")
    -- -- See what the apps are called (run on each desktop)
    -- for i, v in ipairs(hs.window.allWindows())
    --     do print(v:application():name())
    -- end

    -- -- 1. Get all screens and sort them (Laptop is usually index 1 or the 'main' screen)
    -- local screens = hs.screen.allScreens()

    -- -- Identify screens based on your 3-monitor setup
    -- -- Usually: 1 is Laptop, 2 is First External, 3 is Second External
    -- -- We will print them to the console so you can see which is which
    -- for i, s in ipairs(screens) do
    --     print("Screen Index " .. i .. " is " .. s:name())
    -- end

    -- local laptop_scr = screens[1]
    -- local ext1_scr   = screens[3]
    -- local ext2_scr   = screens[2]

    hs.alert.show("Syncing by Physical Screen Position...")

    local screens = hs.screen.allScreens()

    -- Sort screens geometrically from Left to Right (by absolute X coordinate)
    table.sort(screens, function(a, b)
        return a:frame().x < b:frame().x
    end)

    -- Debug print to verify order
    for i, s in ipairs(screens) do
        print(string.format("Position %d (X: %d): %s", i, s:frame().x, s:name()))
    end

    -- Assuming Left = Laptop, Middle = Ext1, Right = Ext2
    -- Adjust these indices based on your actual physical desk order!
    local laptop_scr = screens[1]
    local ext1_scr   = screens[3]
    local ext2_scr   = screens[2]

    -- 2. Define the Map using the variables above
    local appMap = {
        ["chrome"]   = ext1_scr,
        ["sublime"]  = ext1_scr,
        ["firefox"]  = ext1_scr,
        ["spotify"]  = ext2_scr,
        ["ghostty"]  = ext2_scr,
        ["zed"]  = ext2_scr,
        ["code"]     = ext1_scr,
    }

    local wf = hs.window.filter.new(nil)
    wf:setFilters({visible = true, currentSpace = nil})
    local allWindows = wf:getWindows()

    for _, win in ipairs(allWindows) do
        local appName = string.lower(win:application():name())

        for mapKey, targetScreen in pairs(appMap) do
            if string.find(appName, mapKey) and targetScreen then
                print("SUCCESS: Moving " .. appName .. " to " .. targetScreen:name())
                win:moveToScreen(targetScreen, false, true)
                if mapKey == "spotify" then
                    -- hs.geometry.rect(x, y, width, height)
                    -- 0.1 means 10% from the edge, 0.8 means 80% width/height
                    local centeredRect = hs.geometry.rect(0.1, 0.1, 0.8, 0.8)
                    win:move(centeredRect, targetScreen, true)
                else
                    -- Everyone else gets the full treatment
                    win:maximize()
                end
            end
        end
    end
    hs.alert.show("Layout Fixed!")
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", applyLayout)

-- Auto-trigger with 5s delay for M4 handshake
hs.screen.watcher.new(function()
    hs.timer.doAfter(5, applyLayout)
end):start()
