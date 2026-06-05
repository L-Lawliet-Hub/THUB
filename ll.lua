repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local remotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Remotes")
local getRemote = remotesFolder:WaitForChild("GET")

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({ Title = "Perk Enhance Debug", Center = true, AutoShow = true })
local Tab = Window:AddTab("Main", "settings")
local Group = Tab:AddLeftGroupbox("Debug", "settings")
local Toggles = Library.Toggles
local Options = Library.Options

local statusLabel = Group:AddLabel("Status: Idle")
local dataLabel = Group:AddLabel("Data: Not loaded")

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

-- Step 3: Fetch player data
Group:AddButton({
	Text = "3. Fetch Player Data",
	Func = function()
		task.spawn(function()
			statusLabel:SetText("Fetching data...")
			local ok, result = pcall(function()
				return getRemote:InvokeServer("Functions", "Settings", "Get")
			end)
			
			if ok and result and result.Slots then
				local slot = lp:GetAttribute("Slot") or "A"
				local slotData = result.Slots[slot]
				
				if slotData and slotData.Perks then
					local eq = slotData.Perks.Equipped or {}
					local st = slotData.Perks.Storage or {}
					
					local eqCount = 0
					for _ in pairs(eq) do eqCount = eqCount + 1 end
					local stCount = 0
					for _ in pairs(st) do stCount = stCount + 1 end
					
					statusLabel:SetText("Data OK! Eq:" .. eqCount .. " St:" .. stCount)
					dataLabel:SetText("Slot=" .. slot .. " | Eq=" .. eqCount .. " | St=" .. stCount)
					
					-- Store for later
					getgenv()._testData = result
					getgenv()._testSlot = slot
				else
					statusLabel:SetText("No perks data!")
				end
			else
				statusLabel:SetText("Fetch FAILED! ok=" .. tostring(ok))
			end
		end)
	end,
})

-- Step 4: Show Body perk info
Group:AddButton({
	Text = "4. Show Body Perk Info",
	Func = function()
		local data = getgenv()._testData
		local slot = getgenv()._testSlot
		
		if not data or not slot then
			statusLabel:SetText("Fetch data first! (Step 3)")
			return
		end
		
		local slotData = data.Slots[slot]
		if slotData and slotData.Perks then
			local bodyId = slotData.Perks.Equipped["Body"]
			if bodyId then
				local info = slotData.Perks.Storage[bodyId]
				if info then
					statusLabel:SetText("Body: " .. info.Name .. " Lv." .. (info.Level or 0) .. " XP:" .. (info.XP or 0))
					getgenv()._bodyId = bodyId
					getgenv()._bodyInfo = info
				else
					statusLabel:SetText("Body ID not in storage! ID=" .. bodyId)
				end
			else
				statusLabel:SetText("No Body perk equipped!")
				-- Show all equipped
				local msg = "Equipped: "
				for ps, pid in pairs(slotData.Perks.Equipped) do
					msg = msg .. ps .. "=" .. pid .. " "
				end
				statusLabel:SetText(msg)
			end
		end
	end,
})

-- Step 5: Show first 5 food perks
Group:AddButton({
	Text = "5. Show Food Perks",
	Func = function()
		local data = getgenv()._testData
		local slot = getgenv()._testSlot
		
		if not data or not slot then
			statusLabel:SetText("Fetch data first! (Step 3)")
			return
		end
		
		local slotData = data.Slots[slot]
		if slotData and slotData.Perks and slotData.Perks.Storage then
			local foodDict = {}
			local bodyId = getgenv()._bodyId
			local count = 0
			local msg = "Food: "
			
			for pid, info in pairs(slotData.Perks.Storage) do
				if pid ~= bodyId and count < 5 then
					foodDict[pid] = 1
					count = count + 1
					msg = msg .. (info.Name or "?") .. " Lv." .. (info.Level or 0) .. ", "
				end
			end
			
			getgenv()._foodDict = foodDict
			statusLabel:SetText(msg .. "Total: " .. count)
			dataLabel:SetText("Food perks ready: " .. count)
		end
	end,
})

-- Step 6: Test Enhance
Group:AddButton({
	Text = "6. Test Enhance (Body)",
	Func = function()
		task.spawn(function()
			local bodyId = getgenv()._bodyId
			local foodDict = getgenv()._foodDict
			local bodyInfo = getgenv()._bodyInfo
			
			if not bodyId then
				statusLabel:SetText("Show Body perk first! (Step 4)")
				return
			end
			
			if not foodDict or next(foodDict) == nil then
				statusLabel:SetText("Show food perks first! (Step 5)")
				return
			end
			
			statusLabel:SetText("Enhancing " .. (bodyInfo and bodyInfo.Name or "?") .. "...")
			
			local ok, result = pcall(function()
				return getRemote:InvokeServer("S_Equipment", "Enhance", bodyId, foodDict)
			end)
			
			if ok and result then
				statusLabel:SetText("✅ SUCCESS! result=" .. tostring(result))
				
				-- Verify new level
				task.wait(1)
				local ok2, newData = pcall(function()
					return getRemote:InvokeServer("Functions", "Settings", "Get")
				end)
				
				if ok2 and newData then
					local slot = getgenv()._testSlot
					local newInfo = newData.Slots[slot].Perks.Storage[bodyId]
					if newInfo then
						dataLabel:SetText("Old Lv:" .. (bodyInfo.Level or 0) .. " → New Lv:" .. (newInfo.Level or 0))
					end
				end
			else
				statusLabel:SetText("❌ FAILED! ok=" .. tostring(ok) .. " result=" .. tostring(result))
			end
		end)
	end,
})

-- Step 7: Try different slot
Group:AddButton({
	Text = "7. Test Enhance (Offense)",
	Func = function()
		task.spawn(function()
			local data = getgenv()._testData
			local slot = getgenv()._testSlot
			
			if not data or not slot then
				statusLabel:SetText("Fetch data first! (Step 3)")
				return
			end
			
			local slotData = data.Slots[slot]
			local offenseId = slotData.Perks.Equipped["Offense"]
			
			if not offenseId then
				statusLabel:SetText("No Offense perk!")
				return
			end
			
			local foodDict = {}
			local count = 0
			for pid, _ in pairs(slotData.Perks.Storage) do
				if pid ~= offenseId and count < 5 then
					foodDict[pid] = 1
					count = count + 1
				end
			end
			
			if count == 0 then
				statusLabel:SetText("No food perks!")
				return
			end
			
			statusLabel:SetText("Enhancing Offense...")
			
			local ok, result = pcall(function()
				return getRemote:InvokeServer("S_Equipment", "Enhance", offenseId, foodDict)
			end)
			
			statusLabel:SetText("ok=" .. tostring(ok) .. " result=" .. tostring(result))
		end)
	end,
})

-- Reset
Group:AddButton({
	Text = "Clear Stored Data",
	Func = function()
		getgenv()._testData = nil
		getgenv()._testSlot = nil
		getgenv()._bodyId = nil
		getgenv()._bodyInfo = nil
		getgenv()._foodDict = nil
		statusLabel:SetText("Cleared!")
		dataLabel:SetText("Data: Not loaded")
	end,
})
