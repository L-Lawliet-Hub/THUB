repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local remotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Remotes")
local getRemote = remotesFolder:WaitForChild("GET")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ Title = "Perk Debug", Center = true, AutoShow = true })
local Tab = Window:AddTab("Main", "settings")
local Group = Tab:AddLeftGroupbox("Debug", "settings")
local statusLabel = Group:AddLabel("Idle")

Group:AddButton({
	Text = "1. Select Slot A",
	Func = function()
		task.spawn(function()
			getRemote:InvokeServer("Functions", "Select", "A")
			task.wait(1)
			statusLabel:SetText("Slot=" .. tostring(lp:GetAttribute("Slot")))
		end)
	end,
})

Group:AddButton({
	Text = "2. Try Functions Settings Get",
	Func = function()
		task.spawn(function()
			local ok, r = pcall(function()
				return getRemote:InvokeServer("Functions", "Settings", "Get")
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " type=" .. type(r))
		end)
	end,
})

Group:AddButton({
	Text = "3. Try Data Copy",
	Func = function()
		task.spawn(function()
			local ok, r = pcall(function()
				return getRemote:InvokeServer("Data", "Copy")
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " type=" .. type(r))
		end)
	end,
})

Group:AddButton({
	Text = "4. Try S_Equipment Get",
	Func = function()
		task.spawn(function()
			local ok, r = pcall(function()
				return getRemote:InvokeServer("S_Equipment", "Get")
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " type=" .. type(r))
		end)
	end,
})

Group:AddButton({
	Text = "5. Try Functions Get Perks",
	Func = function()
		task.spawn(function()
			local ok, r = pcall(function()
				return getRemote:InvokeServer("Functions", "Get", "Perks")
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " type=" .. type(r))
		end)
	end,
})

Group:AddButton({
	Text = "6. Try S_Perks Get",
	Func = function()
		task.spawn(function()
			local ok, r = pcall(function()
				return getRemote:InvokeServer("S_Perks", "Get")
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " type=" .. type(r))
		end)
	end,
})
