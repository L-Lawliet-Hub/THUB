repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotesFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes")
local getRemote = remotesFolder:WaitForChild("GET")
local HttpService = game:GetService("HttpService")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ Title = "Perk Enhance Debug", Center = true, AutoShow = true })
local Tab = Window:AddTab("Main", "settings")
local Group = Tab:AddLeftGroupbox("Debug", "settings")

local statusLabel = Group:AddLabel("Status: Idle")
local dataLabel = Group:AddLabel("Data: Not loaded")

-- Check all possible data sources
Group:AddButton({
    Text = "Test 1: Direct Settings.Get",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Trying Functions.Settings.Get...")
            
            local ok, result = pcall(function()
                return getRemote:InvokeServer("Functions", "Settings", "Get")
            end)
            
            if ok and type(result) == "table" then
                if result.Slots then
                    local slot = lp:GetAttribute("Slot") or "?"
                    local slotData = result.Slots[slot]
                    if slotData then
                        statusLabel:SetText("✅ Got data! Slot=" .. slot)
                        dataLabel:SetText("Has Perks=" .. tostring(slotData.Perks ~= nil))
                        getgenv()._data = result
                        getgenv()._slot = slot
                    else
                        statusLabel:SetText("No data for slot: " .. slot)
                    end
                else
                    statusLabel:SetText("No Slots in data!")
                    dataLabel:SetText("Keys: " .. table.concat(getKeys(result), ", "))
                end
            else
                statusLabel:SetText("❌ FAILED: " .. tostring(result))
            end
        end)
    end,
})

Group:AddButton({
    Text = "Test 2: Data.Copy",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Trying Data.Copy...")
            
            local ok, result = pcall(function()
                return getRemote:InvokeServer("Data", "Copy")
            end)
            
            if ok and type(result) == "table" then
                statusLabel:SetText("✅ Data.Copy OK!")
                if result.Slots then
                    local slot = lp:GetAttribute("Slot") or "A"
                    local slotData = result.Slots[slot]
                    dataLabel:SetText("Slot=" .. slot .. " Perks=" .. tostring(slotData and slotData.Perks ~= nil))
                end
            else
                statusLabel:SetText("❌ FAILED: " .. tostring(result))
            end
        end)
    end,
})

Group:AddButton({
    Text = "Test 3: Check Slot & Select",
    Func = function()
        task.spawn(function()
            -- Check current slot
            local slot = lp:GetAttribute("Slot")
            statusLabel:SetText("Current Slot: " .. tostring(slot))
            
            -- Force select A
            pcall(function()
                getRemote:InvokeServer("Functions", "Select", "A")
            end)
            
            task.wait(1)
            
            slot = lp:GetAttribute("Slot")
            dataLabel:SetText("After select: " .. tostring(slot))
        end)
    end,
})

Group:AddButton({
    Text = "Test 4: Try Direct Enhance",
    Func = function()
        task.spawn(function()
            local data = getgenv()._data
            local slot = getgenv()._slot
            
            if not data or not slot then
                statusLabel:SetText("Run Test 1 first!")
                return
            end
            
            local slotData = data.Slots[slot]
            if not slotData or not slotData.Perks then
                statusLabel:SetText("No perks data!")
                return
            end
            
            -- Get Body perk ID
            local bodyId = nil
            if slotData.Perks.Equipped then
                bodyId = slotData.Perks.Equipped["Body"]
            end
            
            if not bodyId then
                statusLabel:SetText("No Body perk!")
                -- Show what's equipped
                local eq = {}
                for k, v in pairs(slotData.Perks.Equipped or {}) do
                    table.insert(eq, k .. "=" .. tostring(v))
                end
                dataLabel:SetText("Equipped: " .. table.concat(eq, ", "))
                return
            end
            
            -- Get 5 food perks
            local foodDict = {}
            local count = 0
            for pid, info in pairs(slotData.Perks.Storage or {}) do
                if pid ~= bodyId and count < 5 then
                    foodDict[pid] = 1
                    count = count + 1
                end
            end
            
            if count == 0 then
                statusLabel:SetText("No food perks! Need " .. (slotData.Perks.Storage and "more" or "storage"))
                return
            end
            
            statusLabel:SetText("Enhancing... Body=" .. bodyId .. " Food=" .. count)
            
            local ok, result = pcall(function()
                return getRemote:InvokeServer("S_Equipment", "Enhance", bodyId, foodDict)
            end)
            
            if ok then
                statusLabel:SetText("Result: " .. tostring(result))
                dataLabel:SetText("Body ID: " .. bodyId .. " | Food: " .. count)
            else
                statusLabel:SetText("❌ Error: " .. tostring(result))
            end
        end)
    end,
})

-- Helper
function getKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, tostring(k))
    end
    return keys
end

Group:AddButton({
    Text = "Clear",
    Func = function()
        getgenv()._data = nil
        getgenv()._slot = nil
        statusLabel:SetText("Cleared!")
        dataLabel:SetText("Data: Not loaded")
    end,
})
