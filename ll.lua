repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local remotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Remotes")
local getRemote = remotesFolder:WaitForChild("GET")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({
	Title = "Upgrade Test",
	Center = true,
	AutoShow = true,
})

local Tab = Window:AddTab("Main", "settings")
local Group = Tab:AddLeftGroupbox("Upgrade Gear", "trending-up")
local Toggles = Library.Toggles
local Options = Library.Options

local allUpgrades = {
	"Crit_Damage", "Crit_Chance",
	"ODM_Damage", "ODM_Control", "ODM_Gas", "ODM_Speed", "Blade_Durability", "ODM_Range",
	"Blast_Radius", "TS_Control", "TS_Range", "TS_Damage", "TS_Gas", "TS_Speed",
}

local statusLabel = Group:AddLabel("Status: Idle")

Group:AddToggle("UpgradeToggle", { Text = "Auto Upgrade Gear", Default = false })
Toggles.UpgradeToggle:OnChanged(function()
	if not Toggles.UpgradeToggle.Value then
		statusLabel:SetText("Status: Stopped")
		return
	end
	task.spawn(function()
		-- Slot select
		local slot = lp:GetAttribute("Slot")
		if not slot then
			statusLabel:SetText("Status: Selecting slot...")
			getRemote:InvokeServer("Functions", "Select", "A")
			local waited = 0
			repeat task.wait(0.5); waited += 0.5 until lp:GetAttribute("Slot") or waited >= 5
			slot = lp:GetAttribute("Slot")
		end

		if not slot then
			statusLabel:SetText("Status: Slot select failed!")
			Toggles.UpgradeToggle:SetValue(false)
			return
		end

		statusLabel:SetText("Status: Upgrading slot " .. slot)

		while Toggles.UpgradeToggle.Value do
			local anyDone = false
			for _, upg in ipairs(allUpgrades) do
				if not Toggles.UpgradeToggle.Value then break end
				local ok, result = pcall(function()
					return getRemote:InvokeServer("S_Equipment", "Upgrade", upg)
				end)
				if ok and result ~= nil and result ~= false then
					anyDone = true
					statusLabel:SetText("Upgraded: " .. string.gsub(upg, "_", " "))
					task.wait(0.5)
				end
			end
			if not anyDone then
				statusLabel:SetText("Status: All maxed!")
				Toggles.UpgradeToggle:SetValue(false)
				break
			end
			task.wait(1)
		end
	end)
end)
