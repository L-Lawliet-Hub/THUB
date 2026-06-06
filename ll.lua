-- ==========================================
-- SKIP CUTSCENE REMOTE TESTER
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local postRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("POST")
local INTERFACE = lp:WaitForChild("PlayerGui"):WaitForChild("Interface")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ Title = "Skip Cutscene Tester", Center = true, AutoShow = true })
local Tab = Window:AddTab("Main", "play")
local Group = Tab:AddLeftGroupbox("Tests", "zap")

local statusLabel = Group:AddLabel("Status: Ready")
local resultLabel = Group:AddLabel("Result: -")

-- Get Start object (like your remote)
local function getStartObject()
    for _, Object in getnilinstances() do
        if Object.Name == "Start" then
            return Object
        end
    end
    return nil
end

-- Test 1: Remote with Start object
Group:AddButton({
    Text = "Test 1: Remote + Start Object",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Finding Start object...")
            
            local startObj = getStartObject()
            if startObj then
                statusLabel:SetText("Start found! Sending...")
                resultLabel:SetText("Start DebugId: " .. startObj:GetDebugId())
                
                local ok, err = pcall(function()
                    postRemote:FireServer("Functions", "Finished", startObj)
                end)
                
                statusLabel:SetText("Sent! ok=" .. tostring(ok))
                resultLabel:SetText("Error: " .. tostring(err or "none"))
            else
                statusLabel:SetText("No Start object found!")
                resultLabel:SetText("Cutscene maybe not active?")
            end
        end)
    end,
    Tooltip = "FireServer Functions.Finished with Start object"
})

-- Test 2: Remote without Start object
Group:AddButton({
    Text = "Test 2: Remote (no Start)",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Sending without Start...")
            
            local ok, err = pcall(function()
                postRemote:FireServer("Functions", "Finished")
            end)
            
            statusLabel:SetText("Sent! ok=" .. tostring(ok))
            resultLabel:SetText("Error: " .. tostring(err or "none"))
        end)
    end,
    Tooltip = "FireServer Functions.Finished without Start object"
})

-- Test 3: Button click
Group:AddButton({
    Text = "Test 3: Button Click",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Looking for Skip button...")
            
            local skip = INTERFACE:FindFirstChild("Skip")
            if skip and skip.Visible then
                statusLabel:SetText("Skip button found! Clicking...")
                
                local interact = skip:FindFirstChild("Interact")
                if interact then
                    -- Simulate button click
                    local vim = game:GetService("VirtualInputManager")
                    local GuiService = game:GetService("GuiService")
                    
                    GuiService.SelectedObject = interact
                    task.wait(0.05)
                    vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    
                    resultLabel:SetText("Button clicked!")
                else
                    resultLabel:SetText("No Interact button!")
                end
            else
                statusLabel:SetText("Skip not visible!")
                resultLabel:SetText("Cutscene active: " .. tostring(lp:GetAttribute("Cutscene")))
            end
        end)
    end,
    Tooltip = "Click skip button via GUI"
})

-- Test 4: Combined (Button + Remote)
Group:AddButton({
    Text = "Test 4: Combined Method",
    Func = function()
        task.spawn(function()
            statusLabel:SetText("Trying all methods...")
            
            -- Method 1: Button
            local skip = INTERFACE:FindFirstChild("Skip")
            if skip and skip.Visible then
                local interact = skip:FindFirstChild("Interact")
                if interact then
                    local vim = game:GetService("VirtualInputManager")
                    local GuiService = game:GetService("GuiService")
                    GuiService.SelectedObject = interact
                    task.wait(0.05)
                    vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end
            end
            
            task.wait(0.3)
            
            -- Method 2: Remote with Start
            pcall(function()
                local startObj = getStartObject()
                if startObj then
                    postRemote:FireServer("Functions", "Finished", startObj)
                end
            end)
            
            -- Method 3: Remote without Start
            pcall(function()
                postRemote:FireServer("Functions", "Finished")
            end)
            
            task.wait(0.5)
            
            -- Check result
            local skipNow = INTERFACE:FindFirstChild("Skip")
            if not skipNow or not skipNow.Visible then
                statusLabel:SetText("✅ Skip successful!")
                resultLabel:SetText("Cutscene skipped!")
            else
                statusLabel:SetText("❌ Skip may have failed")
                resultLabel:SetText("Cutscene still visible")
            end
        end)
    end,
    Tooltip = "Try button + both remote methods together"
})

-- Info
Group:AddDivider()
Group:AddLabel("Run during an active cutscene")
Group:AddLabel("Click Test 4 for best results")
Group:AddLabel("Check which method works!")
