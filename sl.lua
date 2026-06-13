-- ==========================================
-- AUTO SKILLS TESTER (FIXED)
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("GET")
local postRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("POST")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ 
    Title = "Auto Skills Tester", 
    Center = true, 
    AutoShow = true 
})

local Tab = Window:AddTab("Skills", "zap")
local Group = Tab:AddLeftGroupbox("Test Controls", "play")
local InfoGroup = Tab:AddRightGroupbox("Info", "info")

local statusLabel = Group:AddLabel("Status: Ready")
local resultLabel = InfoGroup:AddLabel("Results here...")

-- Test different formats
local function testSkillFormat(skillId)
    statusLabel:SetText("Testing Skill " .. skillId .. "...")
    local results = ""
    
    -- Format 1: GET with string ID
    local ok1, r1 = pcall(function()
        return getRemote:InvokeServer("S_Skills", "Usage", tostring(skillId), false)
    end)
    results = results .. "GET string: " .. tostring(r1) .. "\n"
    
    -- Format 2: GET with number ID
    local ok2, r2 = pcall(function()
        return getRemote:InvokeServer("S_Skills", "Usage", skillId, false)
    end)
    results = results .. "GET number: " .. tostring(r2) .. "\n"
    
    -- Format 3: POST with string ID
    local ok3 = pcall(function()
        postRemote:FireServer("S_Skills", "Usage", tostring(skillId), false)
    end)
    results = results .. "POST string: " .. tostring(ok3) .. "\n"
    
    -- Format 4: GET without false
    local ok4, r4 = pcall(function()
        return getRemote:InvokeServer("S_Skills", "Usage", tostring(skillId))
    end)
    results = results .. "GET no bool: " .. tostring(r4) .. "\n"
    
    -- Format 5: GET with true
    local ok5, r5 = pcall(function()
        return getRemote:InvokeServer("S_Skills", "Usage", tostring(skillId), true)
    end)
    results = results .. "GET true: " .. tostring(r5) .. "\n"
    
    resultLabel:SetText(results)
    statusLabel:SetText("✅ Skill " .. skillId .. " tested!")
end

-- Test buttons
Group:AddLabel("Test Different Formats")

for i = 1, 5 do
    Group:AddButton({
        Text = "Test Skill " .. i .. " (All Formats)",
        Func = function() testSkillFormat(i) end,
        Tooltip = "Test all remote formats for Skill " .. i
    })
end

-- Simple test - sirf ek format
Group:AddDivider()
Group:AddLabel("Quick Test (Best Format)")

Group:AddButton({
    Text = "Use Skill 1 (GET number)",
    Func = function()
        local ok, result = pcall(function()
            return getRemote:InvokeServer("S_Skills", "Usage", 1, false)
        end)
        resultLabel:SetText("Skill 1: " .. tostring(result))
        Library:Notify({ Title = "Skill 1", Description = tostring(result), Time = 3 })
    end
})

Group:AddButton({
    Text = "Use Skill 1 (GET string)",
    Func = function()
        local ok, result = pcall(function()
            return getRemote:InvokeServer("S_Skills", "Usage", "1", false)
        end)
        resultLabel:SetText("Skill 1: " .. tostring(result))
        Library:Notify({ Title = "Skill 1", Description = tostring(result), Time = 3 })
    end
})

Group:AddButton({
    Text = "Use Skill 1 (POST)",
    Func = function()
        local ok = pcall(function()
            postRemote:FireServer("S_Skills", "Usage", "1", false)
        end)
        resultLabel:SetText("POST: " .. tostring(ok))
        Library:Notify({ Title = "Skill 1 POST", Description = tostring(ok), Time = 3 })
    end
})

InfoGroup:AddLabel("📋 Testing 5 formats:")
InfoGroup:AddLabel("1. GET + string ID + false")
InfoGroup:AddLabel("2. GET + number ID + false")
InfoGroup:AddLabel("3. POST + string ID + false")
InfoGroup:AddLabel("4. GET + string (no bool)")
InfoGroup:AddLabel("5. GET + string + true")
