-- ===== AutoEquip.lua =====
-- AUTO EQUIP ABYSSAL HUNTER


local AUTO_EQUIP_AURA_NAME = "Abyssal Hunter"
local AUTO_EQUIP_SCAN_INTERVAL = 1000
local AUTO_EQUIP_RETRY_INTERVAL = 30
local AUTO_EQUIP_MENU_WAIT = 2


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


local function getAuraPanel()
    local mainInterface = playerGui:FindFirstChild("MainInterface")
    if not mainInterface then
        return nil
    end


    local interfaceChildren = mainInterface:GetChildren()
    local auraPanel = interfaceChildren[61]
    if not auraPanel or not auraPanel:IsA("GuiObject") then
        return nil
    end


    return auraPanel
end


local function isAuraMenuOpen()
    local auraPanel = getAuraPanel()
    if not auraPanel then
        return false
    end


    return auraPanel.Visible
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


local function openAurasMenu()
    -- Never click the Aura side button when its panel is already open.
    -- That prevents it from toggling itself closed.
    if isAuraMenuOpen() then
        return true, false
    end


    local aurasSideButton = findAurasSideButton()
    if not aurasSideButton then
        return false, false
    end


    if not clickGuiObject(aurasSideButton) then
        return false, false
    end


    local startedAt = os.clock()
    while os.clock() - startedAt < AUTO_EQUIP_MENU_WAIT do
        if isAuraMenuOpen() then
            return true, true
        end


        task.wait(0.1)
    end


    return false, false
end


local function closeAurasMenu()
    if not isAuraMenuOpen() then
        return
    end


    local aurasSideButton = findAurasSideButton()
    if not aurasSideButton then
        return
    end


    clickGuiObject(aurasSideButton)
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
    if not button then
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
        lastAuraScan = os.clock()
        return nil
    end


    local seenAuraNames = {}


    for _, button in ipairs(scrollingFrame:GetChildren()) do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            local auraName = getAuraNameFromButton(button)


            if auraName and not seenAuraNames[auraName] then
                seenAuraNames[auraName] = true


                if auraName == AUTO_EQUIP_AURA_NAME then
                    cachedAbyssalHunterButton = button
                    lastAuraScan = os.clock()
                    return button
                end
            end
        end
    end


    cachedAbyssalHunterButton = nil
    lastAuraScan = os.clock()
    return nil
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
    if not textLabel then
        return nil
    end


    if textLabel.Text ~= "Equip" then
        return nil
    end


    return imageButton
end


local function shouldRescanAuraList()
    if not cachedAbyssalHunterButton then
        return true
    end


    if not cachedAbyssalHunterButton.Parent then
        return true
    end


    if not cachedAbyssalHunterButton:IsDescendantOf(playerGui) then
        return true
    end


    return os.clock() - lastAuraScan >= AUTO_EQUIP_SCAN_INTERVAL
end


local function tryEquipAbyssalHunter()
    -- Auto-equip only runs when BOTH options are enabled.
    if not autoEquipEnabled or not pathfindingEnabled then
        return false
    end


    local menuOpened, openedByScript = openAurasMenu()
    if not menuOpened then
        return false
    end


    local abyssalHunterButton = cachedAbyssalHunterButton
    if shouldRescanAuraList() then
        abyssalHunterButton = scanForAbyssalHunterButton()
    end


    if not abyssalHunterButton then
        if openedByScript then
            closeAurasMenu()
        end


        return false
    end


    clickGuiObject(abyssalHunterButton)
    task.wait(0.25)


    local equipButton = getEquipButton()
    if equipButton then
        clickGuiObject(equipButton)
        task.wait(0.15)
    end


    -- Keep the Aura menu open if YOU were already using it.
    -- Close it only when this script had to open it itself.
    if openedByScript then
        closeAurasMenu()
    end


    return true
end


task.spawn(function()
    while screenGui.Parent do
        if autoEquipEnabled and pathfindingEnabled then
            tryEquipAbyssalHunter()
        end


        task.wait(AUTO_EQUIP_RETRY_INTERVAL)
    end
end)