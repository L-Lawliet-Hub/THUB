repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotesFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes")
local getRemote = remotesFolder:WaitForChild("GET")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ Title = "Perk Enhance - Direct", Center = true, AutoShow = true })
local Tab = Window:AddTab("Main", "settings")
local Group = Tab:AddLeftGroupbox("Direct Enhance", "zap")

local statusLabel = Group:AddLabel("Status: Ready")

Group:AddButton({
    Text = "Select Slot A",
    Func = function()
        getRemote:InvokeServer("Functions", "Select", "A")
        task.wait(1)
        local slot = lp:GetAttribute("Slot")
        statusLabel:SetText("Slot: " .. tostring(slot))
    end,
})

Group:AddButton({
    Text = "Enhance Body Perk (Get IDs Auto)",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Fetching perk IDs...")
            
            -- Get fresh data
            local ok, data = pcall(function()
                return getRemote:InvokeServer("Functions", "Settings", "Get")
            end)
            
            if not ok or not data or not data.Slots then
                statusLabel:SetText("❌ Failed to get data!")
                return
            end
            
            local slot = lp:GetAttribute("Slot") or "A"
            local slotData = data.Slots[slot]
            
            if not slotData or not slotData.Perks then
                statusLabel:SetText("❌ No perks for slot " .. slot)
                return
            end
            
            -- Get Body perk ID
            local bodyId = slotData.Perks.Equipped and slotData.Perks.Equipped["Body"]
            if not bodyId then
                statusLabel:SetText("❌ No Body perk equipped!")
                return
            end
            
            local bodyInfo = slotData.Perks.Storage and slotData.Perks.Storage[bodyId]
            local bodyName = bodyInfo and bodyInfo.Name or "Unknown"
            local bodyLevel = bodyInfo and bodyInfo.Level or 0
            
            statusLabel:SetText("Body: " .. bodyName .. " Lv." .. bodyLevel)
            
            -- Get 5 random food perks
            local foodDict = {}
            local count = 0
            for pid, info in pairs(slotData.Perks.Storage or {}) do
                if pid ~= bodyId and count < 5 then
                    foodDict[pid] = 1
                    count = count + 1
                end
            end
            
            if count == 0 then
                statusLabel:SetText("❌ No food perks in storage!")
                return
            end
            
            statusLabel:SetText("Enhancing " .. bodyName .. " with " .. count .. " food perks...")
            
            -- DIRECT ENHANCE - no extra checks
            local ok2, result = pcall(function()
                return getRemote:InvokeServer("S_Equipment", "Enhance", bodyId, foodDict)
            end)
            
            if ok2 and result then
                -- Check new level
                task.wait(1)
                local ok3, newData = pcall(function()
                    return getRemote:InvokeServer("Functions", "Settings", "Get")
                end)
                
                if ok3 and newData then
                    local newInfo = newData.Slots[slot].Perks.Storage[bodyId]
                    if newInfo then
                        statusLabel:SetText("✅ " .. bodyName .. ": Lv." .. bodyLevel .. " → Lv." .. (newInfo.Level or "?"))
                    else
                        statusLabel:SetText("✅ Enhanced! (new data fetch failed)")
                    end
                else
                    statusLabel:SetText("✅ Enhanced! result=" .. tostring(result))
                end
            else
                statusLabel:SetText("❌ Failed! " .. tostring(result))
            end
        end)
    end,
})

Group:AddButton({
    Text = "Enhance All Equipped (One by One)",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Starting enhance all...")
            
            local ok, data = pcall(function()
                return getRemote:InvokeServer("Functions", "Settings", "Get")
            end)
            
            if not ok or not data or not data.Slots then
                statusLabel:SetText("❌ Data failed!")
                return
            end
            
            local slot = lp:GetAttribute("Slot") or "A"
            local slotData = data.Slots[slot]
            
            if not slotData or not slotData.Perks then
                statusLabel:SetText("❌ No perks!")
                return
            end
            
            for perkSlot, perkId in pairs(slotData.Perks.Equipped or {}) do
                -- Skip if level 10
                local info = slotData.Perks.Storage[perkId]
                if info and (info.Level or 0) < 10 then
                    -- Find 5 food perks
                    local foodDict = {}
                    local count = 0
                    for pid, _ in pairs(slotData.Perks.Storage or {}) do
                        if pid ~= perkId and count < 5 then
                            foodDict[pid] = 1
                            count = count + 1
                        end
                    end
                    
                    if count >= 1 then
                        statusLabel:SetText("Enhancing [" .. perkSlot .. "] " .. (info.Name or "?"))
                        pcall(function()
                            getRemote:InvokeServer("S_Equipment", "Enhance", perkId, foodDict)
                        end)
                        task.wait(1)
                    end
                end
            end
            
            statusLabel:SetText("✅ Done enhancing all perks!")
        end)
    end,
})

Group:AddButton({
    Text = "Enhance with Manual IDs",
    Func = function()
        task.spawn(function()
            -- YAHAN APNE PERK IDs DALO
            local bodyPerkId = "YOUR_BODY_PERK_ID_HERE"  -- Replace with actual ID
            local foodIds = {
                "FOOD_PERK_ID_1",  -- Replace
                "FOOD_PERK_ID_2",  -- Replace
                "FOOD_PERK_ID_3",  -- Replace
            }
            
            local foodDict = {}
            for _, id in ipairs(foodIds) do
                foodDict[id] = 1
            end
            
            statusLabel:SetText("Direct enhancing...")
            
            local ok, result = pcall(function()
                return getRemote:InvokeServer("S_Equipment", "Enhance", bodyPerkId, foodDict)
            end)
            
            statusLabel:SetText("Result: " .. tostring(result))
        end)
    end,
})
