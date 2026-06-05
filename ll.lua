-- ==========================================
-- ENHANCE PERK TESTER WITH OBSIDIAN UI
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("GET")

-- Load Obsidian UI
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Perk Enhancer Tester",
    Footer = "AOT:R | Test Tool",
    Center = true,
    AutoShow = true,
    Resizable = true,
})

local Tabs = {
    Main = Window:AddTab("Tester", "flask-conical"),
    Logs = Window:AddTab("Logs", "scroll-text"),
}

local TestGroup = Tabs.Main:AddLeftGroupbox("Enhance Test", "test-tube")
local PerkInfo = Tabs.Main:AddRightGroupbox("Perk Info", "info")
local LogGroup = Tabs.Logs:AddLeftGroupbox("Console Logs", "terminal")

-- Variables
local testData = {
    slot = nil,
    playerData = nil,
    equippedPerks = {},
    storagePerks = {},
    selectedPerk = nil,
    foodPerks = {},
    logs = {}
}

-- Log function
local function addLog(msg, color)
    table.insert(testData.logs, {
        text = msg,
        color = color or Color3.fromRGB(255, 255, 255),
        time = os.date("%H:%M:%S")
    })
    
    -- Update log display
    local logText = ""
    for i = math.max(1, #testData.logs - 15), #testData.logs do
        local log = testData.logs[i]
        logText = logText .. "[" .. log.time .. "] " .. log.text .. "\n"
    end
    
    pcall(function()
        logLabel:SetText(logText)
    end)
end

-- Log label
local logLabel = LogGroup:AddLabel("Waiting for tests...")

-- Step 1: Check Lobby
TestGroup:AddButton({
    Text = "Step 1: Check Lobby & Slot",
    Func = function()
        addLog("🔍 Checking lobby status...", Color3.fromRGB(255, 255, 0))
        
        if game.PlaceId ~= 14916516914 then
            addLog("❌ Must be in LOBBY!", Color3.fromRGB(255, 0, 0))
            return
        end
        addLog("✅ In Lobby - PlaceId: " .. game.PlaceId, Color3.fromRGB(0, 255, 0))
        
        local slot = lp:GetAttribute("Slot")
        if not slot then
            addLog("⚠️ No slot, selecting A...", Color3.fromRGB(255, 165, 0))
            getRemote:InvokeServer("Functions", "Select", "A")
            task.wait(2)
            slot = lp:GetAttribute("Slot")
        end
        
        testData.slot = slot
        addLog("✅ Slot: " .. (slot or "NONE"), Color3.fromRGB(0, 255, 0))
        
        if slot then
            slotLabel:SetText("Current Slot: " .. slot)
        end
    end,
    Tooltip = "Check if you're in lobby and slot is selected"
})

TestGroup:AddDivider()

-- Step 2: Fetch Data
TestGroup:AddButton({
    Text = "Step 2: Fetch Player Data",
    Func = function()
        addLog("📡 Fetching player data...", Color3.fromRGB(255, 255, 0))
        
        local plrData = nil
        for i = 1, 3 do
            local ok, result = pcall(function()
                return getRemote:InvokeServer("Functions", "Settings", "Get")
            end)
            if ok and result and result.Slots then
                plrData = result
                addLog("✅ Data fetched on attempt " .. i, Color3.fromRGB(0, 255, 0))
                break
            end
            task.wait(1)
        end
        
        if not plrData then
            addLog("❌ Failed to fetch data!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        testData.playerData = plrData
        addLog("✅ Player data loaded successfully!", Color3.fromRGB(0, 255, 0))
        
        -- Update info
        local slot = testData.slot
        if slot and plrData.Slots[slot] then
            local slotData = plrData.Slots[slot]
            dataLabel:SetText("Slot Data: ✅ Loaded")
            
            if slotData.Perks then
                local eqCount = 0
                for _, _ in pairs(slotData.Perks.Equipped or {}) do eqCount = eqCount + 1 end
                local stCount = 0
                for _, _ in pairs(slotData.Perks.Storage or {}) do stCount = stCount + 1 end
                perksLabel:SetText("Equipped: " .. eqCount .. " | Storage: " .. stCount)
            end
        end
    end,
    Tooltip = "Fetch player data from server"
})

TestGroup:AddDivider()

-- Step 3: Show Perks
TestGroup:AddButton({
    Text = "Step 3: List All Perks",
    Func = function()
        if not testData.playerData then
            addLog("❌ Fetch data first!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        local slotData = testData.playerData.Slots[testData.slot]
        if not slotData or not slotData.Perks then
            addLog("❌ No perks data!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        addLog("📋 EQUIPPED PERKS:", Color3.fromRGB(0, 255, 255))
        testData.equippedPerks = {}
        
        for perkSlot, perkId in pairs(slotData.Perks.Equipped or {}) do
            local perkInfo = slotData.Perks.Storage and slotData.Perks.Storage[perkId]
            if perkInfo then
                testData.equippedPerks[perkSlot] = {id = perkId, info = perkInfo}
                addLog("  [" .. perkSlot .. "] " .. perkInfo.Name .. " | Lv." .. (perkInfo.Level or 0), Color3.fromRGB(255, 255, 255))
            end
        end
        
        addLog("📋 STORAGE PERKS (first 10):", Color3.fromRGB(0, 255, 255))
        testData.storagePerks = {}
        local count = 0
        for perkId, perkInfo in pairs(slotData.Perks.Storage or {}) do
            testData.storagePerks[perkId] = perkInfo
            if count < 10 then
                addLog("  - " .. (perkInfo.Name or "Unknown") .. " | Lv." .. (perkInfo.Level or 0), Color3.fromRGB(200, 200, 200))
            end
            count = count + 1
        end
        addLog("  Total: " .. count .. " perks in storage", Color3.fromRGB(255, 255, 255))
        
        -- Update dropdown
        local perkNames = {}
        for perkSlot, data in pairs(testData.equippedPerks) do
            table.insert(perkNames, "[" .. perkSlot .. "] " .. data.info.Name)
        end
        if #perkNames > 0 then
            Options.PerkSelectDropdown:SetValues(perkNames)
        end
    end,
    Tooltip = "Show all equipped and storage perks"
})

TestGroup:AddDivider()

-- Perk selector
TestGroup:AddDropdown("PerkSelectDropdown", {
    Values = {"Select a perk first..."},
    Default = 1,
    Multi = false,
    Text = "Select Perk to Enhance",
    Tooltip = "Choose which equipped perk to enhance"
})

-- Step 4: Test Enhance
TestGroup:AddButton({
    Text = "Step 4: Test Enhance (Body Perk)",
    Func = function()
        if not testData.playerData then
            addLog("❌ Fetch data first!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        local slotData = testData.playerData.Slots[testData.slot]
        if not slotData or not slotData.Perks then
            addLog("❌ No perks data!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        -- Get Body perk
        local bodyPerkId = slotData.Perks.Equipped["Body"]
        if not bodyPerkId then
            addLog("❌ No perk in Body slot!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        local bodyPerk = slotData.Perks.Storage[bodyPerkId]
        if not bodyPerk then
            addLog("❌ Body perk not in storage!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        addLog("🎯 Target: " .. bodyPerk.Name .. " | Lv." .. (bodyPerk.Level or 0), Color3.fromRGB(255, 255, 0))
        
        -- Find food perks
        local foodDict = {}
        local count = 0
        for perkId, info in pairs(slotData.Perks.Storage) do
            if perkId ~= bodyPerkId and count < 5 then
                foodDict[perkId] = 1
                count = count + 1
                addLog("  🍖 Food: " .. (info.Name or "Unknown") .. " | Lv." .. (info.Level or 0), Color3.fromRGB(200, 200, 200))
            end
        end
        
        if count == 0 then
            addLog("❌ No food perks available!", Color3.fromRGB(255, 0, 0))
            return
        end
        
        addLog("📤 Sending enhance request...", Color3.fromRGB(255, 255, 0))
        addLog("  Equipped: " .. bodyPerkId, Color3.fromRGB(150, 150, 150))
        addLog("  Food: " .. count .. " items", Color3.fromRGB(150, 150, 150))
        
        local ok, result = pcall(function()
            return getRemote:InvokeServer("S_Equipment", "Enhance", bodyPerkId, foodDict)
        end)
        
        if ok and result then
            addLog("✅ ENHANCE SUCCESSFUL!", Color3.fromRGB(0, 255, 0))
            
            -- Verify
            task.wait(1)
            local newData = getRemote:InvokeServer("Functions", "Settings", "Get")
            if newData and newData.Slots[testData.slot] then
                local newPerk = newData.Slots[testData.slot].Perks.Storage[bodyPerkId]
                if newPerk then
                    addLog("  New Level: " .. (newPerk.Level or "?"), Color3.fromRGB(0, 255, 0))
                    addLog("  New XP: " .. (newPerk.XP or "?"), Color3.fromRGB(0, 255, 0))
                    resultLabel:SetText("Last Result: ✅ Success | " .. bodyPerk.Name .. " Lv." .. (newPerk.Level or "?"))
                end
            end
        else
            addLog("❌ ENHANCE FAILED!", Color3.fromRGB(255, 0, 0))
            addLog("  Reason: " .. tostring(result or "Unknown"), Color3.fromRGB(255, 0, 0))
            resultLabel:SetText("Last Result: ❌ Failed")
        end
    end,
    Tooltip = "Test enhance on Body slot perk with 5 food perks"
})

-- Info Labels
local slotLabel = PerkInfo:AddLabel("Current Slot: Unknown")
local dataLabel = PerkInfo:AddLabel("Slot Data: Not loaded")
local perksLabel = PerkInfo:AddLabel("Equipped: ? | Storage: ?")
PerkInfo:AddDivider()
local resultLabel = PerkInfo:AddLabel("Last Result: No test yet")

PerkInfo:AddButton({
    Text = "Clear Logs",
    Func = function()
        testData.logs = {}
        pcall(function() logLabel:SetText("Logs cleared...") end)
    end
})

-- Status check button
TestGroup:AddDivider()
TestGroup:AddButton({
    Text = "🔍 Quick Status Check",
    Func = function()
        addLog("=== QUICK STATUS ===", Color3.fromRGB(255, 255, 0))
        
        local inLobby = game.PlaceId == 14916516914
        addLog("Lobby: " .. (inLobby and "✅ YES" or "❌ NO"), inLobby and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
        
        local slot = lp:GetAttribute("Slot")
        addLog("Slot: " .. (slot or "❌ NONE"), slot and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
        
        if testData.playerData then
            addLog("Data: ✅ Loaded", Color3.fromRGB(0, 255, 0))
        else
            addLog("Data: ❌ Not loaded", Color3.fromRGB(255, 0, 0))
        end
        
        local slotData = testData.playerData and testData.playerData.Slots[testData.slot]
        if slotData and slotData.Perks then
            local eq = 0
            for _ in pairs(slotData.Perks.Equipped or {}) do eq = eq + 1 end
            local st = 0
            for _ in pairs(slotData.Perks.Storage or {}) do st = st + 1 end
            addLog("Perks: " .. eq .. " equipped, " .. st .. " storage", Color3.fromRGB(0, 255, 0))
        else
            addLog("Perks: ❌ Not available", Color3.fromRGB(255, 0, 0))
        end
    end,
    Tooltip = "Quick overview of current status"
})
