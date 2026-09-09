-- ===== AutoEquip_Optimized.lua =====
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

local AUTO_EQUIP_AURA_NAME = "Abyssal Hunter"
local CHECK_INTERVAL = 5 -- Interval in seconds to verify equipment status

-- Keeping your original menu state variables intact
local autoEquipEnabled = true 

-- Helper function to fetch the UI panel safely from your structure
local function getAuraPanel()
    local mainInterface = PlayerGui:FindFirstChild("MainInterface")
    if not mainInterface then return nil end

    local interfaceChildren = mainInterface:GetChildren()
    return interfaceChildren[61] -- Keeping your original index mapping
end

-- Helper function to determine if the menu UI is visible
local function isAuraMenuOpen()
    local auraPanel = getAuraPanel()
    if not auraPanel or not auraPanel:IsA("GuiObject") then
        return false
    end
    return auraPanel.Visible
end

-- Efficient ByteNet layout writer 
local function fireEquipPacket()
    local bytes = { 135, 24, 0, 0 }
    local packetBuffer = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(packetBuffer, i - 1, bytes[i])
    end
    ByteNetEvent:FireServer(packetBuffer, nil)
end

-- Execution thread
task.spawn(function()
    while true do
        task.wait(CHECK_INTERVAL)
        
        -- Keeps menu system logic operating smoothly side-by-side
        if autoEquipEnabled and LocalPlayer.Character then
            -- Double check character instance to prevent redundant networking
            local currentAura = LocalPlayer.Character:FindFirstChild(AUTO_EQUIP_AURA_NAME)
            
            if not currentAura then
                -- Target aura missing from character; deploy network injection pack
                fireEquipPacket()
            end
        end
    end
end)
