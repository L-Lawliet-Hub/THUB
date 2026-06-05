repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local remotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Remotes")
local getRemote = remotesFolder:WaitForChild("GET")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ Title = "Upgrade Debug", Center = true, AutoShow = true })
local Tab = Window:AddTab("Main", "settings")
local Group = Tab:AddLeftGroupbox("Debug", "settings")
local Toggles = Library.Toggles
local Options = Library.Options

local statusLabel = Group:AddLabel("Status: Idle")

-- Step 1: Slot check
Group:AddButton({
	Text = "1. Check Slot Attribute",
	Func = function()
		local slot = lp:GetAttribute("Slot")
		statusLabel:SetText("Slot = " .. tostring(slot))
	end,
})

-- Step 2: Force select slot A
Group:AddButton({
	Text = "2. Select Slot A",
	Func = function()
		task.spawn(function()
			statusLabel:SetText("Selecting slot A...")
			local ok, err = pcall(function()
				getRemote:InvokeServer("Functions", "Select", "A")
			end)
			task.wait(1)
			local slot = lp:GetAttribute("Slot")
			statusLabel:SetText("ok=" .. tostring(ok) .. " slot=" .. tostring(slot))
		end)
	end,
})

-- Step 3: Try one upgrade, show raw result
Group:AddButton({
	Text = "3. Try Upgrade Crit_Damage",
	Func = function()
		task.spawn(function()
			local slot = lp:GetAttribute("Slot")
			statusLabel:SetText("Slot=" .. tostring(slot) .. " | Trying...")
			local ok, result = pcall(function()
				return getRemote:InvokeServer("S_Equipment", "Upgrade", "Crit_Damage")
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " result=" .. tostring(result))
		end)
	end,
})

-- Step 4: Try with different format
Group:AddButton({
	Text = "4. Try Upgrade ODM_Damage",
	Func = function()
		task.spawn(function()
			local ok, result = pcall(function()
				return getRemote:InvokeServer("S_Equipment", "Upgrade", "ODM_Damage")
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " result=" .. tostring(result))
		end)
	end,
})

-- Step 5 add karo existing debug script mein
Group:AddButton({
	Text = "5. Fetch Data Copy",
	Func = function()
		task.spawn(function()
			local ok, result = pcall(function()
				return getRemote:InvokeServer("Data", "Copy")
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " type=" .. type(result))
			if ok and type(result) == "table" then
				local slot = lp:GetAttribute("Slot") or "A"
				local slotData = result.Slots and result.Slots[slot]
				local weapon = slotData and slotData.Weapon or "nil"
				local upgrades = slotData and slotData.Upgrades and slotData.Upgrades[weapon]
				if upgrades then
					local msg = "Weapon=" .. weapon .. "\n"
					for k, v in pairs(upgrades) do
						msg = msg .. k .. "=" .. tostring(v) .. "\n"
					end
					statusLabel:SetText(msg)
				else
					statusLabel:SetText("No upgrades data! weapon=" .. weapon)
				end
			end
		end)
	end,
})
