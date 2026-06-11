-- ==========================================
-- WAVES BUTTON FINDER (Obsidian UI)
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local INTERFACE = lp:WaitForChild("PlayerGui"):WaitForChild("Interface")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ 
    Title = "Waves Button Finder", 
    Center = true, 
    AutoShow = true 
})

local Tab = Window:AddTab("Finder", "search")
local Group = Tab:AddLeftGroupbox("Scan Results", "search")
local InfoGroup = Tab:AddRightGroupbox("Info", "info")

local resultLabel = Group:AddLabel("Click Scan to find buttons...")
local statusLabel = Group:AddLabel("Status: Ready")

-- Scan All Interface
Group:AddButton({
    Text = "🔍 Scan All Interface",
    Func = function()
        local found = {}
        statusLabel:SetText("Status: Scanning...")
        
        -- Search all visible buttons
        for _, obj in ipairs(INTERFACE:GetDescendants()) do
            if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                local text = obj.Text or ""
                local name = obj.Name or ""
                
                -- Check for waves/vote related buttons
                if string.find(string.lower(text), "wave") or 
                   string.find(string.lower(name), "wave") or
                   string.find(string.lower(text), "vote") or 
                   string.find(string.lower(name), "vote") then
                    
                    table.insert(found, {
                        name = name,
                        text = text,
                        parent = obj.Parent and obj.Parent.Name or "Unknown"
                    })
                end
            end
        end
        
        -- Display results
        local result = ""
        if #found > 0 then
            result = "✅ Found " .. #found .. " buttons:\n\n"
            for i, btn in ipairs(found) do
                result = result .. "[" .. i .. "] " .. btn.name .. "\n"
                result = result .. "   Text: " .. btn.text .. "\n"
                result = result .. "   Parent: " .. btn.parent .. "\n\n"
            end
        else
            result = "❌ No waves/vote buttons found!\nMake sure vote UI is visible."
        end
        
        resultLabel:SetText(result)
        statusLabel:SetText("Status: Scan complete! Found: " .. #found)
    end,
    Tooltip = "Scan entire interface for waves/vote buttons"
})

-- Scan Specific Frames
Group:AddButton({
    Text = "🔍 Scan 'Waves' Frame",
    Func = function()
        local wavesFrame = INTERFACE:FindFirstChild("Waves")
        local result = ""
        
        if wavesFrame then
            result = "✅ 'Waves' frame found!\n\nButtons:\n"
            local found = 0
            for _, child in ipairs(wavesFrame:GetDescendants()) do
                if child:IsA("TextButton") or child:IsA("ImageButton") then
                    found = found + 1
                    result = result .. "- " .. child.Name .. " | Text: " .. (child.Text or "N/A") .. "\n"
                end
            end
            if found == 0 then
                result = result .. "No buttons inside 'Waves' frame"
            end
        else
            result = "❌ 'Waves' frame NOT found!"
        end
        
        resultLabel:SetText(result)
        statusLabel:SetText("Status: Waves frame scan done")
    end,
    Tooltip = "Scan only the Waves frame"
})

Group:AddButton({
    Text = "🔍 Scan 'Vote' Frame",
    Func = function()
        local voteFrame = INTERFACE:FindFirstChild("Vote") or INTERFACE:FindFirstChild("Voting")
        local result = ""
        
        if voteFrame then
            result = "✅ 'Vote' frame found!\n\nButtons:\n"
            local found = 0
            for _, child in ipairs(voteFrame:GetDescendants()) do
                if child:IsA("TextButton") or child:IsA("ImageButton") then
                    found = found + 1
                    result = result .. "- " .. child.Name .. " | Text: " .. (child.Text or "N/A") .. "\n"
                end
            end
            if found == 0 then
                result = result .. "No buttons inside 'Vote' frame"
            end
        else
            result = "❌ 'Vote' frame NOT found!"
        end
        
        resultLabel:SetText(result)
        statusLabel:SetText("Status: Vote frame scan done")
    end,
    Tooltip = "Scan only the Vote frame"
})

-- Scan ALL frames (show all frame names)
Group:AddButton({
    Text = "📋 List All Visible Frames",
    Func = function()
        local frames = {}
        for _, obj in ipairs(INTERFACE:GetDescendants()) do
            if obj:IsA("Frame") and obj.Visible and #obj:GetChildren() > 0 then
                table.insert(frames, obj.Name)
            end
        end
        
        local result = "Visible Frames:\n\n"
        for _, name in ipairs(frames) do
            result = result .. "• " .. name .. "\n"
        end
        
        resultLabel:SetText(result)
        statusLabel:SetText("Status: Found " .. #frames .. " visible frames")
    end,
    Tooltip = "List all visible frame names in Interface"
})

-- Info
InfoGroup:AddLabel("📌 Instructions:")
InfoGroup:AddLabel("1. Wait for waves vote UI")
InfoGroup:AddLabel("2. Click 'Scan All Interface'")
InfoGroup:AddLabel("3. Note the button names")
InfoGroup:AddLabel("4. Share results for script fix")
