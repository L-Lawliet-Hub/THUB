-- ==========================================
-- AUTO-SCAN WHEN VOTE APPEARS
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local INTERFACE = lp:WaitForChild("PlayerGui"):WaitForChild("Interface")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ 
    Title = "Waves Vote Finder", 
    Center = true, 
    AutoShow = true 
})

local Tab = Window:AddTab("Finder", "search")
local Group = Tab:AddLeftGroupbox("Auto Detect", "eye")

local resultLabel = Group:AddLabel("Waiting for vote UI...")
local statusLabel = Group:AddLabel("Status: Monitoring...")

-- Auto detect when vote appears
task.spawn(function()
    local lastScan = 0
    
    while true do
        task.wait(2)
        
        -- Check all possible vote frames
        local voteFrames = {
            INTERFACE:FindFirstChild("Vote"),
            INTERFACE:FindFirstChild("Voting"),
            INTERFACE:FindFirstChild("Waves"),
            INTERFACE:FindFirstChild("WaveVote"),
            INTERFACE:FindFirstChild("Update"),
            INTERFACE:FindFirstChild("Start"),
        }
        
        for _, frame in ipairs(voteFrames) do
            if frame and frame.Visible then
                -- Vote appeared! Scan it
                local result = "✅ Frame Found: " .. frame.Name .. "\n\nButtons:\n"
                local found = 0
                
                for _, child in ipairs(frame:GetDescendants()) do
                    if (child:IsA("TextButton") or child:IsA("ImageButton")) and child.Visible then
                        found = found + 1
                        result = result .. "• " .. child.Name
                        if child.Text and child.Text ~= "" then
                            result = result .. " | Text: " .. child.Text
                        end
                        result = result .. "\n"
                    end
                end
                
                -- Also search for buttons with "wave" in name
                result = result .. "\nWave-related buttons in Interface:\n"
                for _, obj in ipairs(INTERFACE:GetDescendants()) do
                    if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                        local text = obj.Text or ""
                        local name = obj.Name or ""
                        if string.find(string.lower(text), "wave") or string.find(string.lower(name), "wave") then
                            result = result .. "• " .. name .. " | Text: " .. text .. "\n"
                            found = found + 1
                        end
                    end
                end
                
                resultLabel:SetText(result)
                statusLabel:SetText("Status: Found " .. found .. " buttons!")
                
                -- Also print to console
                print(result)
            end
        end
    end
end)

-- Manual scan button
Group:AddButton({
    Text = "🔍 Force Scan Now",
    Func = function()
        statusLabel:SetText("Status: Force scanning...")
        
        local result = "ALL Interface children:\n\n"
        for _, child in ipairs(INTERFACE:GetChildren()) do
            if child:IsA("Frame") or child:IsA("ScreenGui") then
                result = result .. "📁 " .. child.Name .. " (Visible: " .. tostring(child.Visible) .. ")\n"
            end
        end
        
        resultLabel:SetText(result)
    end,
    Tooltip = "Force scan all interface children"
})

Group:AddLabel("Script auto-detects when vote appears")
Group:AddLabel("Keep this running while waiting for vote")
