repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")
local remotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Remotes")
local getRemote = remotesFolder:WaitForChild("GET")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ Title = "Perk UUID Debug", Center = true, AutoShow = true })
local Tab = Window:AddTab("Main", "settings")
local Group = Tab:AddLeftGroupbox("Debug", "settings")
local statusLabel = Group:AddLabel("Idle")

local function isUUID(str)
	return type(str) == "string" and #str == 36 and str:find("^[%x%-]+$") ~= nil
end

-- UUID wale frames dhundho
Group:AddButton({
	Text = "1. Open Perks GUI then press",
	Func = function()
		task.spawn(function()
			local INTERFACE = PlayerGui:WaitForChild("Interface")
			local customisation = INTERFACE:FindFirstChild("Customisation")
			if not customisation then statusLabel:SetText("No Customisation!") return end

			local found = {}
			local function scan(inst, depth)
				if depth > 8 then return end
				for _, child in ipairs(inst:GetChildren()) do
					if isUUID(child.Name) then
						table.insert(found, child:GetFullName())
					end
					scan(child, depth + 1)
				end
			end
			scan(customisation, 0)

			if #found == 0 then
				statusLabel:SetText("No UUID frames found!\nIs Perks screen open?")
			else
				statusLabel:SetText("Found " .. #found .. ":\n" .. (found[1] or "") .. "\n" .. (found[2] or ""))
				for i, v in ipairs(found) do print(i, v) end
			end
		end)
	end,
})

-- First UUID frame ke attributes print karo
Group:AddButton({
	Text = "2. Print First UUID Frame Attrs",
	Func = function()
		task.spawn(function()
			local INTERFACE = PlayerGui:WaitForChild("Interface")
			local customisation = INTERFACE:FindFirstChild("Customisation")
			if not customisation then statusLabel:SetText("No Customisation!") return end

			local function scan(inst, depth)
				if depth > 8 then return end
				for _, child in ipairs(inst:GetChildren()) do
					if isUUID(child.Name) then
						local msg = "Name=" .. child.Name .. "\nParent=" .. child.Parent.Name .. "\n"
						local attrs = child:GetAttributes()
						for k, v in pairs(attrs) do
							msg = msg .. k .. "=" .. tostring(v) .. "\n"
						end
						-- Children names
						for _, c in ipairs(child:GetChildren()) do
							msg = msg .. "  child: " .. c.Name .. " (" .. c.ClassName .. ")\n"
						end
						statusLabel:SetText(msg)
						print(msg)
						return
					end
					scan(child, depth + 1)
				end
			end
			scan(customisation, 0)
		end)
	end,
})

-- Equipped perk frame dhundho
Group:AddButton({
	Text = "3. Find Equipped Perk Frame",
	Func = function()
		task.spawn(function()
			local INTERFACE = PlayerGui:WaitForChild("Interface")
			local customisation = INTERFACE:FindFirstChild("Customisation")
			if not customisation then statusLabel:SetText("No Customisation!") return end

			-- "Equipped" ya "Slots" naam ka frame dhundho
			local equipped = customisation:FindFirstChild("Equipped", true)
				or customisation:FindFirstChild("Slots", true)
				or customisation:FindFirstChild("Active", true)
			if equipped then
				statusLabel:SetText("Equipped frame: " .. equipped:GetFullName())
				print("Equipped:", equipped:GetFullName())
				for _, c in ipairs(equipped:GetChildren()) do
					print("  ->", c.Name, c.ClassName)
				end
			else
				statusLabel:SetText("No Equipped frame found")
			end
		end)
	end,
})
