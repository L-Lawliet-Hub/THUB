-- ==========================================
-- PERK ENHANCE TEST SCRIPT
-- ==========================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getRemote = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Remotes"):WaitForChild("GET")

print("=":rep(50))
print("PERK ENHANCE TEST")
print("=":rep(50))

-- Step 1: Check Lobby
if game.PlaceId ~= 14916516914 then
    print("❌ Lobby mein jao pehle!")
    return
end
print("✅ Lobby OK")

-- Step 2: Ensure slot selected
local slot = lp:GetAttribute("Slot")
if not slot then
    print("⚠️ Slot not selected, selecting A...")
    getRemote:InvokeServer("Functions", "Select", "A")
    task.wait(2)
    slot = lp:GetAttribute("Slot")
end
print("✅ Slot:", slot)

-- Step 3: Force fresh data fetch
print("\n📡 Fetching data...")
local data = nil
for i = 1, 3 do
    local ok, result = pcall(function()
        return getRemote:InvokeServer("Functions", "Settings", "Get")
    end)
    if ok and result and result.Slots then
        data = result
        print("✅ Data fetched (attempt " .. i .. ")")
        break
    end
    task.wait(1)
end

if not data then
    print("❌ Data fetch FAILED!")
    return
end

-- Step 4: Check slot data
local slotData = data.Slots[slot]
if not slotData then
    print("❌ No slot data for", slot)
    return
end
print("✅ Slot data found")

-- Step 5: Check perks
if not slotData.Perks then
    print("❌ No perks!")
    return
end

local equipped = slotData.Perks.Equipped or {}
local storage = slotData.Perks.Storage or {}

print("\n📋 EQUIPPED PERKS:")
for ps, pid in pairs(equipped) do
    local info = storage[pid]
    if info then
        print("  [" .. ps .. "]", info.Name, "Lv." .. (info.Level or 0), "| ID:", pid)
    end
end

print("\n📋 STORAGE PERKS (Food):")
local count = 0
local firstFood = nil
for pid, info in pairs(storage) do
    count = count + 1
    if count <= 5 then
        print("  -", info.Name or "?", "Lv." .. (info.Level or 0), "| ID:", pid)
    end
    if not firstFood then firstFood = pid end
end
print("  Total:", count)

-- Step 6: Try enhance on Body perk
print("\n🧪 TESTING ENHANCE...")
local bodyId = equipped["Body"]
if not bodyId then
    print("❌ No perk in Body slot!")
    return
end

local bodyInfo = storage[bodyId]
if not bodyInfo then
    print("❌ Body perk not in storage! ID:", bodyId)
    return
end

print("🎯 Target:", bodyInfo.Name, "Lv." .. (bodyInfo.Level or 0))
print("   ID:", bodyId)

-- Find 5 food perks (excluding body perk)
local foodDict = {}
local foodCount = 0
for pid, info in pairs(storage) do
    if pid ~= bodyId and foodCount < 5 then
        foodDict[pid] = 1
        foodCount = foodCount + 1
        print("  🍖 Food:", info.Name or "?", "| ID:", pid)
    end
end

if foodCount == 0 then
    print("❌ No food perks!")
    return
end

-- Step 7: Send enhance request
print("\n📤 Sending request...")
print("  Remote: S_Equipment.Enhance")
print("  Equipped ID:", bodyId)
print("  Food count:", foodCount)

local ok, result = pcall(function()
    return getRemote:InvokeServer("S_Equipment", "Enhance", bodyId, foodDict)
end)

print("\n📥 RESULT:")
print("  Success:", ok)
print("  Response type:", type(result))
print("  Response:", tostring(result))

if ok and result then
    print("\n✅ ENHANCE SUCCESSFUL!")
    
    -- Verify
    task.wait(1)
    local newData = getRemote:InvokeServer("Functions", "Settings", "Get")
    if newData and newData.Slots[slot] then
        local newInfo = newData.Slots[slot].Perks.Storage[bodyId]
        if newInfo then
            print("  Old Level:", bodyInfo.Level or "?")
            print("  New Level:", newInfo.Level or "?")
            print("  Old XP:", bodyInfo.XP or "?")
            print("  New XP:", newInfo.XP or "?")
        end
    end
else
    print("\n❌ ENHANCE FAILED!")
    if not ok then
        print("  Error:", result)
    end
end

print("\n" .. "=":rep(50))
print("TEST COMPLETE")
print("=":rep(50))
