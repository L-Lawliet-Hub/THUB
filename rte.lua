-- Run this in F8 console when vote is visible
local INTERFACE = game:GetService("Players").LocalPlayer.PlayerGui.Interface

print("=== FULL INTERFACE STRUCTURE ===")
for _, child in ipairs(INTERFACE:GetChildren()) do
    print("[" .. child.Name .. "] Visible:", child.Visible, "| Class:", child.ClassName)
    for _, sub in ipairs(child:GetChildren()) do
        print("  └─ [" .. sub.Name .. "] Visible:", sub.Visible, "| Class:", sub.ClassName)
    end
end
