-- ==========================================
-- WAVES VOTE TESTER (Obsidian UI)
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")
local INTERFACE = PlayerGui:WaitForChild("Interface")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local postRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("POST")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ 
    Title = "Waves Vote Tester", 
    Center = true, 
    AutoShow = true 
})

local Tab = Window:AddTab("Tester", "search")
local Group = Tab:AddLeftGroupbox("Test Controls", "play")
local InfoGroup = Tab:AddRightGroupbox("Results", "info")

local statusLabel = Group:AddLabel("Status: Ready")
local resultLabel = InfoGroup:AddLabel("Results will show here...")

-- Auto scan function
local function scanForVoteButtons()
    local found = {}
    
    -- Method 1: Check Wave_Vote / WaveVote frame
    local waveVoteGui = INTERFACE:FindFirstChild("Wave_Vote") or INTERFACE:FindFirstChild("WaveVote")
    if waveVoteGui then
        table.insert(found, "📁 Frame: " .. waveVoteGui.Name .. " | Visible: " .. tostring(waveVoteGui.Visible))
        if waveVoteGui.Visible then
            for _, child in ipairs(waveVoteGui:GetDescendants()) do
                if (child:IsA("TextButton") or child:IsA("ImageButton")) then
                    table.insert(found, "  ✅ Button: " .. child.Name .. " | Text: " .. (child.Text or "N/A"))
                end
            end
        end
    else
        table.insert(found, "❌ Wave_Vote/WaveVote frame NOT found")
    end
    
    -- Method 2: Search all for vote buttons
    table.insert(found, "\n🔍 Searching all buttons with 'vote'...")
    local voteButtons = 0
    for _, v in ipairs(INTERFACE:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
            local nameMatch = string.find(v.Name:lower(), "vote")
            local textMatch = v:IsA("TextButton") and string.find(v.Text:lower(), "vote")
            if nameMatch or textMatch then
                voteButtons = voteButtons + 1
                table.insert(found, "  ✅ [" .. v.Name .. "] Text: " .. (v.Text or "N/A") .. " | Parent: " .. v.Parent.Name)
            end
        end
    end
    if voteButtons == 0 then
        table.insert(found, "  ❌ No visible vote buttons found")
    end
    
    return found
end

-- Test 1: Scan for buttons
Group:AddButton({
    Text = "🔍 Scan for Vote Buttons",
    Func = function()
        statusLabel:SetText("Status: Scanning...")
        local results = scanForVoteButtons()
        resultLabel:SetText(table.concat(results, "\n"))
        statusLabel:SetText("Status: Scan complete!")
    end,
    Tooltip = "Scan interface for wave vote buttons"
})

-- Test 2: Try clicking vote button
Group:AddButton({
    Text = "🎯 Try Click Vote Button",
    Func = function()
        statusLabel:SetText("Status: Trying to click...")
        local clicked = false
        
        -- Method 1
        local waveVoteGui = INTERFACE:FindFirstChild("Wave_Vote") or INTERFACE:FindFirstChild("WaveVote")
        if waveVoteGui and waveVoteGui.Visible then
            local btn = waveVoteGui:FindFirstChild("Vote", true) or waveVoteGui:FindFirstChild("Start", true)
            if btn then
                local vim = game:GetService("VirtualInputManager")
                local GuiService = game:GetService("GuiService")
                GuiService.SelectedObject = btn
                task.wait(0.05)
                vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                clicked = true
                resultLabel:SetText("✅ Clicked: " .. btn.Name)
            end
        end
        
        -- Method 2
        if not clicked then
            for _, v in ipairs(INTERFACE:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                    if string.find(v.Name:lower(), "vote") or (v:IsA("TextButton") and string.find(v.Text:lower(), "vote")) then
                        local vim = game:GetService("VirtualInputManager")
                        local GuiService = game:GetService("GuiService")
                        GuiService.SelectedObject = v
                        task.wait(0.05)
                        vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        clicked = true
                        resultLabel:SetText("✅ Clicked: " .. v.Name)
                        break
                    end
                end
            end
        end
        
        if not clicked then
            resultLabel:SetText("❌ No vote button found to click")
        end
        statusLabel:SetText("Status: Click attempt done! Clicked: " .. tostring(clicked))
    end,
    Tooltip = "Try to find and click vote button"
})

-- Test 3: Send remote only
Group:AddButton({
    Text = "📡 Send Vote Remote",
    Func = function()
        statusLabel:SetText("Status: Sending remote...")
        pcall(function()
            postRemote:FireServer("Waves", "Update")
        end)
        resultLabel:SetText("✅ Remote sent: Waves.Update")
        statusLabel:SetText("Status: Remote sent!")
    end,
    Tooltip = "Send Waves.Update remote without clicking"
})

-- Test 4: Combined (Button + Remote)
Group:AddButton({
    Text = "🚀 Test Full Vote (Button + Remote)",
    Func = function()
        statusLabel:SetText("Status: Full test running...")
        
        -- Try button first
        local waveVoteGui = INTERFACE:FindFirstChild("Wave_Vote") or INTERFACE:FindFirstChild("WaveVote")
        if waveVoteGui and waveVoteGui.Visible then
            local btn = waveVoteGui:FindFirstChild("Vote", true) or waveVoteGui:FindFirstChild("Start", true)
            if btn then
                local vim = game:GetService("VirtualInputManager")
                local GuiService = game:GetService("GuiService")
                GuiService.SelectedObject = btn
                task.wait(0.05)
                vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end
        
        -- Then remote
        task.wait(0.5)
        pcall(function()
            postRemote:FireServer("Waves", "Update")
        end)
        
        resultLabel:SetText("✅ Full test complete!\nButton click + Remote sent")
        statusLabel:SetText("Status: Full test done!")
    end,
    Tooltip = "Click button + Send remote together"
})

-- Test 5: Continuous auto vote (like your original code)
Group:AddToggle("AutoVoteLoopToggle", {
    Text = "Auto Vote Loop (Test)",
    Default = false,
    Tooltip = "Continuously try to vote every second"
})
Toggles.AutoVoteLoopToggle:OnChanged(function()
    if Toggles.AutoVoteLoopToggle.Value then
        task.spawn(function()
            while Toggles.AutoVoteLoopToggle.Value do
                pcall(function()
                    -- Try button
                    local waveVoteGui = INTERFACE:FindFirstChild("Wave_Vote") or INTERFACE:FindFirstChild("WaveVote")
                    if waveVoteGui and waveVoteGui.Visible then
                        local btn = waveVoteGui:FindFirstChild("Vote", true) or waveVoteGui:FindFirstChild("Start", true)
                        if btn then
                            local vim = game:GetService("VirtualInputManager")
                            local GuiService = game:GetService("GuiService")
                            GuiService.SelectedObject = btn
                            task.wait(0.05)
                            vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                    end
                    
                    -- Try all vote buttons
                    for _, v in ipairs(INTERFACE:GetDescendants()) do
                        if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                            if string.find(v.Name:lower(), "vote") or (v:IsA("TextButton") and string.find(v.Text:lower(), "vote")) then
                                local vim = game:GetService("VirtualInputManager")
                                local GuiService = game:GetService("GuiService")
                                GuiService.SelectedObject = v
                                task.wait(0.05)
                                vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            end
                        end
                    end
                    
                    -- Remote
                    postRemote:FireServer("Waves", "Update")
                end)
                task.wait(1)
            end
        end)
    end
end)

-- Info
InfoGroup:AddLabel("📌 How to test:")
InfoGroup:AddLabel("1. Click 'Scan for Vote Buttons'")
InfoGroup:AddLabel("2. Check if frames/buttons found")
InfoGroup:AddLabel("3. Try 'Click Vote Button'")
InfoGroup:AddLabel("4. Try 'Send Vote Remote'")
InfoGroup:AddLabel("5. Use 'Auto Vote Loop' for continuous")
