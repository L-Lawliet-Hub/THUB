-- ==========================================
-- AUTO SKILLS USAGE TESTER
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("GET")
local postRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("POST")
local INTERFACE = lp:WaitForChild("PlayerGui"):WaitForChild("Interface")

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

-- Skill IDs to test
local skills = {1, 2, 3, 4, 5}

-- Test single skill
local function testSkill(skillId)
    Library:Notify({ Title = "🧪 Testing", Description = "Skill " .. skillId, Time = 2 })
    
    local ok, result = pcall(function()
        return getRemote:InvokeServer("S_Skills", "Usage", tostring(skillId), false)
    end)
    
    if ok and result ~= nil then
        Library:Notify({ Title = "✅ Skill " .. skillId, Description = "Used! Result: " .. tostring(result), Time = 3 })
        resultLabel:SetText("✅ Skill " .. skillId .. " = " .. tostring(result))
        return true
    else
        Library:Notify({ Title = "❌ Skill " .. skillId, Description = "Failed: " .. tostring(result), Time = 3 })
        resultLabel:SetText("❌ Skill " .. skillId .. " failed")
        return false
    end
end

-- Test buttons for each skill
Group:AddLabel("Single Skill Tests")

for _, skillId in ipairs(skills) do
    Group:AddButton({
        Text = "Use Skill " .. skillId,
        Func = function()
            statusLabel:SetText("Testing Skill " .. skillId .. "...")
            testSkill(skillId)
        end,
        Tooltip = "Test S_Skills.Usage." .. skillId
    })
end

-- Use all skills
Group:AddDivider()
Group:AddLabel("Bulk Tests")

Group:AddButton({
    Text = "Use All Skills (1→5)",
    Func = function()
        statusLabel:SetText("Using all skills...")
        local results = ""
        for _, skillId in ipairs(skills) do
            local ok, result = pcall(function()
                return getRemote:InvokeServer("S_Skills", "Usage", tostring(skillId), false)
            end)
            results = results .. "Skill " .. skillId .. ": " .. tostring(result) .. "\n"
            task.wait(0.5)
        end
        resultLabel:SetText(results)
        statusLabel:SetText("✅ All skills tested!")
    end,
    Tooltip = "Use all 5 skills in sequence"
})

-- Auto loop (use while killing titans)
Group:AddToggle("AutoSkillsLoopToggle", {
    Text = "Auto Skills Loop (Kill Mode)",
    Default = false,
    Tooltip = "Auto use skills 1→5 while titans are nearby"
})
Toggles.AutoSkillsLoopToggle:OnChanged(function()
    if Toggles.AutoSkillsLoopToggle.Value then
        task.spawn(function()
            local lastKillCount = lp:GetAttribute("Kills") or 0
            local skillIndex = 1
            
            while Toggles.AutoSkillsLoopToggle.Value do
                pcall(function()
                    local currentKills = lp:GetAttribute("Kills") or 0
                    local titansNearby = false
                    
                    -- Check if titans nearby
                    local titans = workspace:FindFirstChild("Titans")
                    if titans then
                        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            for _, titan in ipairs(titans:GetChildren()) do
                                if not titan:GetAttribute("Killed") then
                                    local hrp = titan:FindFirstChild("HumanoidRootPart")
                                    if hrp and (hrp.Position - root.Position).Magnitude < 300 then
                                        titansNearby = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Only use skills if titans nearby AND getting kills
                    if titansNearby and currentKills > lastKillCount then
                        local skillId = skills[skillIndex]
                        getRemote:InvokeServer("S_Skills", "Usage", tostring(skillId), false)
                        Library:Notify({ Title = "⚡ Skill", Description = "Used Skill " .. skillId, Time = 1.5 })
                        
                        skillIndex = skillIndex + 1
                        if skillIndex > #skills then skillIndex = 1 end
                        lastKillCount = currentKills
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

-- Info
InfoGroup:AddLabel("📋 Skill IDs:")
InfoGroup:AddLabel("1 - Skill 1")
InfoGroup:AddLabel("2 - Skill 2")
InfoGroup:AddLabel("3 - Skill 3")
InfoGroup:AddLabel("4 - Skill 4")
InfoGroup:AddLabel("5 - Skill 5")
InfoGroup:AddDivider()
InfoGroup:AddLabel("Remote: S_Skills.Usage")
InfoGroup:AddLabel("Args: skillId, false")
InfoGroup:AddDivider()
InfoGroup:AddLabel("Auto Loop:")
InfoGroup:AddLabel("• Uses skills only when killing")
InfoGroup:AddLabel("• Checks titans nearby (300 range)")
InfoGroup:AddLabel("• Cycles 1→2→3→4→5")
