-- ==========================================
-- PERK ENHANCE TESTER - OBSIDIAN UI
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("GET")

-- Load Obsidian UI
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Perk Enhance Tester",
    Footer = "AOT:R | Debug Tool",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab("Tester", "test-tube"),
    Logs = Window:AddTab("Logs", "scroll-text"),
}

local TestGroup = Tabs.Main:AddLeftGroupbox("Test Controls", "play")
local InfoGroup = Tabs.Main:AddRightGroupbox("Info", "info")
local LogGroup = Tabs.Logs:AddLeftGroupbox("Console", "terminal")

-- Log system
local logs = {}
local logLabel = LogGroup:AddLabel("Ready...")

local function addLog(msg)
    table.insert(logs, "[" .. os.date("%H:%M:%S") .. "] " .. msg)
    if #logs > 20 then table.remove(logs, 1) end
    local text = ""
    for _, l in ipairs(logs) do text = text .. l .. "\n" end
    pcall(function() logLabel:SetText(text) end)
end

-- Info labels
local slotLabel = InfoGroup:AddLabel("Slot: Checking...")
local dataLabel = InfoGroup:AddLabel("Data: Not loaded")
local perkLabel = InfoGroup:AddLabel("Perks: ?")
local resultLabel = InfoGroup:AddLabel("Result: No test yet")

-- Step 1: Init
TestGroup:AddButton({
    Text = "Step 1: Init Check",
    Func = function()
        addLog("🔍 Checking...")
        
        if game.PlaceId ~= 14916516914 then
            addLog("❌ Must be in LOBBY!")
            return
        end
        addLog("✅ Lobby OK")
        
        local slot = lp:GetAttribute("Slot")
        if not slot then
            addLog("⚠️ No slot, selecting A...")
            getRemote:InvokeServer("Functions", "Select", "A")
            task.wait(2)
            slot = lp:GetAttribute("Slot")
        end
        
        if slot then
            addLog("✅ Slot: " .. slot)
            slotLabel:SetText("Slot: " .. slot)
        else
            addLog("❌ Slot failed!")
            slotLabel:SetText("Slot: FAILED")
        end
    end,
    Tooltip = "Check lobby and slot"
})

-- Step 2: Fetch Data
TestGroup:AddButton({
    Text = "Step 2: Fetch Data",
    Func = function()
        addLog("📡 Fetching...")
        
        local data = nil
        for i = 1, 3 do
            local ok, result = pcall(function()
                return getRemote:InvokeServer("Functions", "Settings", "Get")
            end)
            if ok and result and result.Slots then
                data = result
                addLog("✅ Got data! (try " .. i .. ")")
                break
            end
            task.wait(1)
        end
        
        if not data then
            addLog("❌ Data fetch FAILED!")
            dataLabel:SetText("Data: FAILED")
            return
        end
        
        dataLabel:SetText("Data: ✅ Loaded")
        
        local slot = lp:GetAttribute("Slot")
        if not slot or not data.Slots[slot] then
            addLog("❌ No slot data!")
            perkLabel:SetText("Perks: No slot data")
            return
        end
        
        local slotData = data.Slots[slot]
        if not slotData.Perks then
            addLog("❌ No perks!")
            perkLabel:SetText("Perks: NONE")
            return
        end
        
        local eq = slotData.Perks.Equipped or {}
        local st = slotData.Perks.Storage or {}
        
        local eqCount = 0
        for _ in pairs(eq) do eqCount = eqCount + 1 end
        local stCount = 0
        for _ in pairs(st) do stCount = stCount + 1 end
        
        addLog("📋 Equipped: " .. eqCount .. " | Storage: " .. stCount)
        perkLabel:SetText("E:" .. eqCount .. " S:" .. stCount)
        
        -- Show equipped
        for ps, pid in pairs(eq) do
            local info = st[pid]
            if info then
                addLog("  [" .. ps .. "] " .. info.Name .. " Lv." .. (info.Level or 0))
            end
        end
        
        -- Store globally for test
        getgenv()._testData = data
        getgenv()._testSlot = slot
        getgenv()._testSlotData = slotData
        
        addLog("✅ Data stored for testing")
    end,
    Tooltip = "Fetch player data from server"
})

-- Step 3: Test Enhance
TestGroup:AddButton({
    Text = "Step 3: Test Enhance (Body)",
    Func = function()
        local data = getgenv()._testData
        local slot = getgenv()._testSlot
        
        if not data or not slot then
            addLog("❌ Fetch data first!")
            return
        end
        
        local slotData = data.Slots[slot]
        if not slotData or not slotData.Perks then
            addLog("❌ No perks!")
            return
        end
        
        local equipped = slotData.Perks.Equipped or {}
        local storage = slotData.Perks.Storage or {}
        
        local bodyId = equipped["Body"]
        if not bodyId then
            addLog("❌ No Body perk!")
            resultLabel:SetText("Result: No Body perk")
            return
        end
        
        local bodyInfo = storage[bodyId]
        if not bodyInfo then
            addLog("❌ Body perk not in storage!")
            addLog("  Body ID: " .. bodyId)
            resultLabel:SetText("Result: Body ID not in storage")
            return
        end
        
        addLog("🎯 Target: " .. bodyInfo.Name .. " Lv." .. (bodyInfo.Level or 0))
        addLog("  ID: " .. bodyId)
        
        -- Find 5 food perks
        local foodDict = {}
        local count = 0
        for pid, info in pairs(storage) do
            if pid ~= bodyId and count < 5 then
                foodDict[pid] = 1
                count = count + 1
                addLog("  🍖 " .. (info.Name or "?") .. " Lv." .. (info.Level or 0))
            end
        end
        
        if count == 0 then
            addLog("❌ No food perks!")
            resultLabel:SetText("Result: No food")
            return
        end
        
        addLog("📤 Sending enhance...")
        addLog("  Remote: S_Equipment.Enhance")
        addLog("  Equipped: " .. bodyId)
        addLog("  Food items: " .. count)
        
        local ok, result = pcall(function()
            return getRemote:InvokeServer("S_Equipment", "Enhance", bodyId, foodDict)
        end)
        
        if ok and result then
            addLog("✅ ENHANCE SUCCESS!")
            resultLabel:SetText("Result: ✅ Success")
            
            -- Verify
            task.wait(1)
            local newData = getRemote:InvokeServer("Functions", "Settings", "Get")
            if newData and newData.Slots[slot] then
                local newInfo = newData.Slots[slot].Perks.Storage[bodyId]
                if newInfo then
                    addLog("  Old Lv: " .. (bodyInfo.Level or "?") .. " → New Lv: " .. (newInfo.Level or "?"))
                    resultLabel:SetText("Result: ✅ " .. bodyInfo.Name .. " Lv." .. (newInfo.Level or "?"))
                end
            end
        else
            addLog("❌ ENHANCE FAILED!")
            addLog("  Error: " .. tostring(result or "unknown"))
            resultLabel:SetText("Result: ❌ Failed")
        end
    end,
    Tooltip = "Test enhance on Body slot with 5 food perks"
})

-- Step 4: Quick Debug
TestGroup:AddButton({
    Text = "🔍 Quick Debug Info",
    Func = function()
        addLog("=== DEBUG INFO ===")
        addLog("PlaceId: " .. game.PlaceId)
        addLog("Lobby: " .. (game.PlaceId == 14916516914 and "YES" or "NO"))
        
        local slot = lp:GetAttribute("Slot")
        addLog("Slot attr: " .. tostring(slot))
        
        -- Try direct data fetch
        local ok, data = pcall(function()
            return getRemote:InvokeServer("Functions", "Settings", "Get")
        end)
        addLog("Direct fetch: " .. (ok and "OK" or "FAIL"))
        
        if ok and data then
            addLog("Data type: " .. type(data))
            addLog("Has Slots: " .. (data.Slots and "YES" or "NO"))
            
            if data.Slots and data.Slots[slot] then
                local sd = data.Slots[slot]
                addLog("Has Perks: " .. (sd.Perks and "YES" or "NO"))
                
                if sd.Perks then
                    local eq = sd.Perks.Equipped or {}
                    local st = sd.Perks.Storage or {}
                    
                    local eqc = 0
                    for _ in pairs(eq) do eqc = eqc + 1 end
                    local stc = 0
                    for _ in pairs(st) do stc = stc + 1 end
                    
                    addLog("Equipped count: " .. eqc)
                    addLog("Storage count: " .. stc)
                    
                    -- Show first equipped perk
                    for ps, pid in pairs(eq) do
                        local info = st[pid]
                        addLog("  [" .. ps .. "]=" .. pid .. " → " .. (info and info.Name or "NOT IN STORAGE"))
                    end
                end
            else
                addLog("❌ No slot data for: " .. tostring(slot))
            end
        end
    end,
    Tooltip = "Show detailed debug information"
})

-- Clear logs
TestGroup:AddButton({
    Text = "Clear Logs",
    Func = function()
        logs = {}
        pcall(function() logLabel:SetText("Cleared...") end)
    end
})

addLog("✅ Tester loaded! Click Step 1 → 2 → 3")
