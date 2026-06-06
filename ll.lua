-- ==========================================
-- AUTO RETRY REMOTE TESTER
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("GET")
local postRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("POST")

-- Load Obsidian UI
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ 
    Title = "Retry Remote Tester", 
    Center = true, 
    AutoShow = true 
})

local Tab = Window:AddTab("Main", "refresh-cw")
local Group = Tab:AddLeftGroupbox("Retry Tests", "play")

local statusLabel = Group:AddLabel("Status: Ready")
local resultLabel = Group:AddLabel("Result: -")

-- Test 1: GET Retry Add
Group:AddButton({
    Text = "Test 1: GET Retry Add",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Testing GET Retry Add...")
            
            local ok, result = pcall(function()
                return getRemote:InvokeServer("Functions", "Retry", "Add")
            end)
            
            statusLabel:SetText("ok=" .. tostring(ok))
            resultLabel:SetText("Result: " .. tostring(result))
        end)
    end,
    Tooltip = "Test GET remote: Functions.Retry.Add"
})

-- Test 2: GET Retry (no Add)
Group:AddButton({
    Text = "Test 2: GET Retry (no Add)",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Testing GET Retry...")
            
            local ok, result = pcall(function()
                return getRemote:InvokeServer("Functions", "Retry")
            end)
            
            statusLabel:SetText("ok=" .. tostring(ok))
            resultLabel:SetText("Result: " .. tostring(result))
        end)
    end,
    Tooltip = "Test GET remote: Functions.Retry"
})

-- Test 3: GET Teleport.Retry
Group:AddButton({
    Text = "Test 3: GET Teleport Retry",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Testing Teleport.Retry...")
            
            local ok, result = pcall(function()
                return getRemote:InvokeServer("Functions", "Teleport", "Retry")
            end)
            
            statusLabel:SetText("ok=" .. tostring(ok))
            resultLabel:SetText("Result: " .. tostring(result))
        end)
    end,
    Tooltip = "Test GET remote: Functions.Teleport.Retry"
})

-- Test 4: POST Retry Add
Group:AddButton({
    Text = "Test 4: POST Retry Add",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Testing POST Retry Add...")
            
            local ok, result = pcall(function()
                postRemote:FireServer("Functions", "Retry", "Add")
                return true
            end)
            
            statusLabel:SetText("Sent!")
            resultLabel:SetText("Result: " .. tostring(result))
        end)
    end,
    Tooltip = "Test POST remote: Functions.Retry.Add"
})

-- Test 5: POST Retry
Group:AddButton({
    Text = "Test 5: POST Retry",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Testing POST Retry...")
            
            local ok, result = pcall(function()
                postRemote:FireServer("Functions", "Retry")
                return true
            end)
            
            statusLabel:SetText("Sent!")
            resultLabel:SetText("Result: " .. tostring(result))
        end)
    end,
    Tooltip = "Test POST remote: Functions.Retry"
})

-- Test 6: S_Missions Retry
Group:AddButton({
    Text = "Test 6: S_Missions Retry",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Testing S_Missions Retry...")
            
            local ok, result = pcall(function()
                return getRemote:InvokeServer("S_Missions", "Retry")
            end)
            
            statusLabel:SetText("ok=" .. tostring(ok))
            resultLabel:SetText("Result: " .. tostring(result))
        end)
    end,
    Tooltip = "Test GET remote: S_Missions.Retry"
})

-- Test 7: S_Missions Restart
Group:AddButton({
    Text = "Test 7: S_Missions Restart",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Testing S_Missions Restart...")
            
            local ok, result = pcall(function()
                return getRemote:InvokeServer("S_Missions", "Restart")
            end)
            
            statusLabel:SetText("ok=" .. tostring(ok))
            resultLabel:SetText("Result: " .. tostring(result))
        end)
    end,
    Tooltip = "Test GET remote: S_Missions.Restart"
})

-- Info
Group:AddDivider()
Group:AddLabel("Run tests when stuck on reward screen")
Group:AddLabel("Click Retry button on rewards to trigger")
