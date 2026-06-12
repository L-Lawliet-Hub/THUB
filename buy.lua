-- ==========================================
-- AUTO BUY BOOSTS TESTER (With Notifications)
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("GET")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ 
    Title = "Auto Buy Boosts Tester", 
    Center = true, 
    AutoShow = true 
})

local Tab = Window:AddTab("Buy Boosts", "shopping-cart")
local Group = Tab:AddLeftGroupbox("Test Controls", "play")
local InfoGroup = Tab:AddRightGroupbox("Info", "info")

local statusLabel = Group:AddLabel("Status: Ready")
local resultLabel = InfoGroup:AddLabel("Results here...")

-- Boost Data
local boosts = {
    [1] = {name = "2x XP Boost [30m]", type = "XP", duration = "30m"},
    [2] = {name = "2x XP Boost [1h]", type = "XP", duration = "1h"},
    [3] = {name = "2x XP Boost [2h]", type = "XP", duration = "2h"},
    [4] = {name = "2x Luck Boost [30m]", type = "Luck", duration = "30m"},
    [5] = {name = "2x Luck Boost [1h]", type = "Luck", duration = "1h"},
    [6] = {name = "2x Luck Boost [2h]", type = "Luck", duration = "2h"},
    [7] = {name = "2x Gold Boost [30m]", type = "Gold", duration = "30m"},
    [8] = {name = "2x Gold Boost [1h]", type = "Gold", duration = "1h"},
    [9] = {name = "2x Gold Boost [2h]", type = "Gold", duration = "2h"},
}

-- Buy single boost with notify
local function buyBoost(boostId, amount)
    local boost = boosts[boostId]
    if not boost then
        Library:Notify({
            Title = "❌ Error",
            Description = "Invalid boost ID: " .. tostring(boostId),
            Time = 3
        })
        return false
    end
    
    statusLabel:SetText("Buying " .. boost.name .. " x" .. amount .. "...")
    
    Library:Notify({
        Title = "🛒 Buying...",
        Description = boost.name .. " x" .. amount,
        Time = 2
    })
    
    local ok, result = pcall(function()
        return getRemote:InvokeServer("S_Market", "Buy", "1_Boosts", boostId, amount)
    end)
    
    if ok and result ~= nil and result ~= false then
        Library:Notify({
            Title = "✅ Purchased!",
            Description = boost.name .. " x" .. amount,
            Time = 3
        })
        resultLabel:SetText("✅ " .. boost.name .. " x" .. amount)
        statusLabel:SetText("✅ Success!")
        return true
    else
        Library:Notify({
            Title = "❌ Failed!",
            Description = boost.name .. " | " .. tostring(result),
            Time = 3
        })
        resultLabel:SetText("❌ Failed: " .. boost.name)
        statusLabel:SetText("❌ Failed!")
        return false
    end
end

-- Test Buttons
Group:AddLabel("🧪 Single Boost Tests")

for id = 1, 9 do
    local boost = boosts[id]
    Group:AddButton({
        Text = "Buy " .. boost.name .. " x1",
        Func = function()
            buyBoost(id, 1)
        end,
        Tooltip = "Test buy: " .. boost.name
    })
end

-- Quick Buy
Group:AddDivider()
Group:AddLabel("🎯 Quick Buy (Multiple)")

Group:AddButton({
    Text = "Buy 5x XP [2h]",
    Func = function()
        buyBoost(3, 5)
    end
})

Group:AddButton({
    Text = "Buy 5x Gold [2h]",
    Func = function()
        buyBoost(9, 5)
    end
})

Group:AddButton({
    Text = "Buy 5x Luck [2h]",
    Func = function()
        buyBoost(6, 5)
    end
})

Group:AddButton({
    Text = "🛒 Buy All (1 each)",
    Func = function()
        Library:Notify({
            Title = "🛒 Buying All",
            Description = "Buying 9 boosts...",
            Time = 3
        })
        for id = 1, 9 do
            buyBoost(id, 1)
            task.wait(0.3)
        end
        Library:Notify({
            Title = "✅ Done!",
            Description = "All boosts purchased!",
            Time = 5
        })
    end
})

-- Info
InfoGroup:AddLabel("📋 Boost IDs:")
InfoGroup:AddLabel("1 = 2x XP Boost [30m]")
InfoGroup:AddLabel("2 = 2x XP Boost [1h]")
InfoGroup:AddLabel("3 = 2x XP Boost [2h]")
InfoGroup:AddLabel("4 = 2x Luck Boost [30m]")
InfoGroup:AddLabel("5 = 2x Luck Boost [1h]")
InfoGroup:AddLabel("6 = 2x Luck Boost [2h]")
InfoGroup:AddLabel("7 = 2x Gold Boost [30m]")
InfoGroup:AddLabel("8 = 2x Gold Boost [1h]")
InfoGroup:AddLabel("9 = 2x Gold Boost [2h]")
