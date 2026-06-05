repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local remotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Remotes")
local getRemote = remotesFolder:WaitForChild("GET")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ Title = "Enhance Test", Center = true, AutoShow = true })
local Tab = Window:AddTab("Main", "settings")
local Group = Tab:AddLeftGroupbox("Debug", "settings")
local statusLabel = Group:AddLabel("Idle")

local function isUUID(s)
	return type(s) == "string" and #s == 36
end

-- Try every possible remote to get perk storage
local remotesToTry = {
	{"Functions", "Settings", "Get"},
	{"Data", "Copy"},
	{"S_Equipment", "Get"},
	{"S_Equipment", "Storage"},
	{"S_Perks", "Get"},
	{"S_Perks", "Storage"},
	{"Functions", "Get", "Perks"},
	{"Functions", "Perks", "Get"},
	{"S_Rewards", "Get", true},
}

Group:AddButton({
	Text = "1. Find Working Remote",
	Func = function()
		task.spawn(function()
			for _, args in ipairs(remotesToTry) do
				local ok, result = pcall(function()
					return getRemote:InvokeServer(table.unpack(args))
				end)
				local label = table.concat(args, ", ")
				if ok and type(result) == "table" then
					statusLabel:SetText("✅ FOUND: " .. label)
					print("WORKING REMOTE:", label)
					print(result)
					-- Check for UUIDs inside
					local uuids = {}
					local function scan(t, depth)
						if depth > 5 or type(t) ~= "table" then return end
						for k, v in pairs(t) do
							if isUUID(tostring(k)) then
								table.insert(uuids, tostring(k))
							end
							scan(v, depth + 1)
						end
					end
					scan(result, 0)
					if #uuids > 0 then
						print("UUIDs found:", #uuids)
						for i, u in ipairs(uuids) do print(i, u) end
						statusLabel:SetText("✅ " .. label .. "\n" .. #uuids .. " UUIDs found!")
					else
						statusLabel:SetText("✅ " .. label .. " works\nbut no UUIDs inside")
					end
					return
				end
				task.wait(0.3)
			end
			statusLabel:SetText("❌ All remotes nil")
		end)
	end,
})

-- Manual UUID input se enhance
Group:AddButton({
	Text = "2. Enhance with hardcoded IDs",
	Func = function()
		task.spawn(function()
			-- Yahan apna equipped perk ID daalo (log se copy karo)
			local equippedId = "EQUIPPED_PERK_UUID_HERE"

			-- Yahan food perk IDs daalo (log se copy karo)
			local foodPerks = {
				["FOOD_PERK_UUID_1"] = 1,
				["FOOD_PERK_UUID_2"] = 1,
			}

			if equippedId == "EQUIPPED_PERK_UUID_HERE" then
				statusLabel:SetText("Pehle IDs fill karo script mein!")
				return
			end

			local ok, result = pcall(function()
				return getRemote:InvokeServer("S_Equipment", "Enhance", equippedId, foodPerks)
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " result=" .. tostring(result))
		end)
	end,
})

-- RemoteSpy se captured IDs use karke enhance
Group:AddButton({
	Text = "3. Try Enhance from your log",
	Func = function()
		task.spawn(function()
			-- Tere log se exact copy
			local equippedId = "e6cda5e8-a12c-4d4c-800d-2c5e4bbc3294"
			local foodPerks = {
				["63d3e05c-7528-4247-86ef-6a32c52457c7"] = 1,
				["f6dbd460-2d0f-4cd4-93d6-ae7e4129e928"] = 1,
				["4639c37c-d86c-4e1c-b2a7-a42af5b3b683"] = 1,
				["794c600c-6103-4471-8689-e51779f81aa4"] = 1,
				["de80a837-2c3f-440c-906e-488ddbfac965"] = 1,
			}
			local ok, result = pcall(function()
				return getRemote:InvokeServer("S_Equipment", "Enhance", equippedId, foodPerks)
			end)
			statusLabel:SetText("ok=" .. tostring(ok) .. " result=" .. tostring(result))
			print("Enhance result:", ok, result)
		end)
	end,
})
