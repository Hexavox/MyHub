-- ===== AutoEquip.lua =====
-- AUTO EQUIP ABYSSAL HUNTER


local AUTO_EQUIP_AURA_NAME = "Abyssal Hunter"
local AUTO_EQUIP_SCAN_INTERVAL = 500
local AUTO_EQUIP_RETRY_INTERVAL = 15
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


    -- Kept from the path you provided.
    local auraPanel = mainInterface:GetChildren()[61]
    if not auraPanel or not auraPanel:IsA("GuiObject") then
        return nil
    end


    return auraPanel
end


local function isAuraMenuOpen()
    local auraPanel = getAuraPanel()
    return auraPanel and auraPanel.Visible or false
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


    for _, object in ipairs(sideButtons:GetChildren()) do
        if object:IsA("TextButton") or object:IsA("ImageButton") then
            local usageLabel = object:FindFirstChild("Usage", true)


            if usageLabel
                and usageLabel:IsA("TextLabel")
                and usageLabel.Text == "Auras" then


                return object
            end
        end
    end


    return nil
end


local function openAurasMenu()
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


    local auraListContainer = auraPanel:GetChildren()[4]
    if not auraListContainer then
        return nil
    end


    local frame = auraListContainer:FindFirstChild("Frame")
    if not frame then
        return nil
    end


    return frame:FindFirstChild("ScrollingFrame")
end


local function scanForAbyssalHunterButton()
    local scrollingFrame = getAuraScrollingFrame()
    if not scrollingFrame then
        cachedAbyssalHunterButton = nil
        return nil
    end


    local seenAuraNames = {}


    for _, button in ipairs(scrollingFrame:GetChildren()) do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            local auraName = nil


            for _, object in ipairs(button:GetDescendants()) do
                if object:IsA("TextLabel") and object.Text == AUTO_EQUIP_AURA_NAME then
                    auraName = object.Text
                    break
                end
            end


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


    local equipContainer = detailsFrame:GetChildren()[5]
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
    if not autoEquipEnabled then
        return false
    end


    local menuWasOpened, openedByScript = openAurasMenu()
    if not menuWasOpened then
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


    -- Only close the Aura panel if it was closed before the auto-equip ran.
    -- If you had it open yourself, leave it open.
    if openedByScript then
        closeAurasMenu()
    end


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