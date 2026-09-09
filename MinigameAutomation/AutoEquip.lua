-- ===== AutoEquip.lua =====
-- AUTO EQUIP ABYSSAL HUNTER

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

local AUTO_EQUIP_SCAN_INTERVAL = 1000
local AUTO_EQUIP_RETRY_INTERVAL = 30
local AUTO_EQUIP_AURA_NAME = "Abyssal Hunter"

local cachedAbyssalHunterButton = nil
local lastAuraScan = 0

-- Preserved local variable for your menu system tracking
local autoEquipEnabled = true 

local function clickGuiObject(object)
    if not object or not object:IsA("GuiObject") then
        return false
    end

    if not object.Visible then
        return false
    end

    local position = object.AbsolutePosition
    local size = object.AbsoluteSize
    local inset = GuiService:GetGuiInset()

    local clickX = position.X + (size.X / 2) + inset.X
    local clickY = position.Y + (size.Y / 2) + inset.Y

    -- Click event logic retained for layout system sync
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
    task.wait(0.05)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)

    return true
end

local function findAurasSideButton()
    local mainInterface = PlayerGui:FindFirstChild("MainInterface")
    if not mainInterface then
        return nil
    end

    local sideButtons = mainInterface:FindFirstChild("SideButtons")
    if not sideButtons then
        return nil
    end

    for _, button in ipairs(sideButtons:GetChildren()) do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            local usageLabel = button:FindFirstChild("Usage", true)

            if usageLabel
                and usageLabel:IsA("TextLabel")
                and usageLabel.Text == "Auras" then

                return button
            end
        end
    end

    return nil
end

local function getAuraPanel()
    local mainInterface = PlayerGui:FindFirstChild("MainInterface")
    if not mainInterface then
        return nil
    end

    local interfaceChildren = mainInterface:GetChildren()
    local auraSection = interfaceChildren[61]
    if not auraSection then
        return nil
    end

    return auraSection
end

local function isAuraMenuOpen()
    local auraPanel = getAuraPanel()
    if not auraPanel or not auraPanel:IsA("GuiObject") then
        return false
    end

    return auraPanel.Visible
end

local function openAurasMenu()
    if isAuraMenuOpen() then
        return true
    end

    local aurasSideButton = findAurasSideButton()
    if not aurasSideButton then
        return false
    end

    if not clickGuiObject(aurasSideButton) then
        return false
    end

    local startedAt = os.clock()
    while os.clock() - startedAt < 2 do
        if isAuraMenuOpen() then
            return true
        end

        task.wait(0.1)
    end

    return false
end

-- Efficient ByteNet custom packet implementation replacing layout tracking logic
local function fireEquipPacket()
    local bytes = { 135, 62, 0, 0 }
    local packetBuffer = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(packetBuffer, i - 1, bytes[i])
    end
    ByteNetEvent:FireServer(packetBuffer, nil)
end

local function tryEquipAbyssalHunter()
    if not autoEquipEnabled then
        return false
    end

    -- Keeps your menu checks performing properly alongside the execution thread
    openAurasMenu()

    if LocalPlayer.Character then
        local currentAura = LocalPlayer.Character:FindFirstChild(AUTO_EQUIP_AURA_NAME)
        
        if not currentAura then
            -- Injecting the corrected `{ 135, 62, 0, 0 }` binary buffer pattern
            fireEquipPacket()
        end
    end
    
    return true
end

-- Fallback loop wrapper safely bound to tracking structures
task.spawn(function()
    while true do
        if autoEquipEnabled then
            tryEquipAbyssalHunter()
        end
        task.wait(AUTO_EQUIP_RETRY_INTERVAL)
    end
end)
