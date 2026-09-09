-- ===== AutoEquip.lua =====
-- AUTO EQUIP ABYSSAL HUNTER


local AUTO_EQUIP_SCAN_INTERVAL = 1000
local AUTO_EQUIP_RETRY_INTERVAL = 30
local AUTO_EQUIP_AURA_NAME = "Abyssal Hunter"


local cachedAbyssalHunterButton = nil
local lastAuraScan = 0


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


    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)


    return true
end


local function findAurasSideButton()
    local mainInterface = playerGui:FindFirstChild("MainInterface")
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
    local mainInterface = playerGui:FindFirstChild("MainInterface")
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
    -- Do not click the sidebar button if Auras is already open.
    -- Clicking it again can toggle the panel closed.
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


local function getAuraScrollingFrame()
    local auraPanel = getAuraPanel()
    if not auraPanel then
        return nil
    end


    local auraPanelChildren = auraPanel:GetChildren()
    local auraListContainer = auraPanelChildren[4]
    if not auraListContainer then
        return nil
    end


    local frame = auraListContainer:FindFirstChild("Frame")
    if not frame then
        return nil
    end


    return frame:FindFirstChild("ScrollingFrame")
end


local function getAuraNameFromButton(button)
    if not button or not button:IsA("GuiObject") then
        return nil
    end


    for _, object in ipairs(button:GetDescendants()) do
        if object:IsA("TextLabel") and object.Text == AUTO_EQUIP_AURA_NAME then
            return object.Text
        end
    end


    return nil
end


local function scanForAbyssalHunterButton()
    local scrollingFrame = getAuraScrollingFrame()
    if not scrollingFrame then
        cachedAbyssalHunterButton = nil
        return nil
    end


    local seenAuraNames = {}
    local abyssalHunterButton = nil


    for _, button in ipairs(scrollingFrame:GetChildren()) do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            local auraName = getAuraNameFromButton(button)


            if auraName and not seenAuraNames[auraName] then
                seenAuraNames[auraName] = true


                if auraName == AUTO_EQUIP_AURA_NAME then
                    abyssalHunterButton = button
                    break
                end
            end
        end
    end


    cachedAbyssalHunterButton = abyssalHunterButton
    lastAuraScan = os.clock()


    return cachedAbyssalHunterButton
end


local function getEquipButton()
    local auraPanel = getAuraPanel()
    if not auraPanel then
        return nil
    end


    local detailsFrame = auraPanel:FindFirstChild("Frame")
    if not detailsFrame then
        return nil
    end


    local detailsChildren = detailsFrame:GetChildren()
    local equipContainer = detailsChildren[5]
    if not equipContainer then
        return nil
    end


    local frame = equipContainer:FindFirstChild("Frame")
    if not frame then
        return nil
    end


    local imageButton = frame:FindFirstChild("ImageButton")
    if not imageButton then
        return nil
    end


    local textLabel = imageButton:FindFirstChild("TextLabel")
    if not textLabel or textLabel.Text ~= "Equip" then
        return nil
    end


    return imageButton
end


local function tryEquipAbyssalHunter()
    if not autoEquipEnabled then
        return false
    end


    if not openAurasMenu() then
        return false
    end


    local abyssalHunterButton = cachedAbyssalHunterButton


    if not abyssalHunterButton
        or not abyssalHunterButton.Parent
        or not abyssalHunterButton:IsDescendantOf(playerGui)
        or os.clock() - lastAuraScan >= AUTO_EQUIP_SCAN_INTERVAL then


        abyssalHunterButton = scanForAbyssalHunterButton()
    end


    if not abyssalHunterButton then
        return false
    end


    clickGuiObject(abyssalHunterButton)
    task.wait(0.25)


    local equipButton = getEquipButton()
    if not equipButton then
        -- The selected aura has no button labeled "Equip".
        -- Usually that means it is already equipped.
        return true
    end


    clickGuiObject(equipButton)
    return true
end


task.spawn(function()
    while screenGui.Parent do
        if autoEquipEnabled then
            tryEquipAbyssalHunter()
        end


        task.wait(AUTO_EQUIP_RETRY_INTERVAL)
    end
end)