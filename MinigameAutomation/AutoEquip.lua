-- ===== AutoEquip.lua =====
-- AUTO EQUIP ABYSSAL HUNTER


local AUTO_EQUIP_CHECK_INTERVAL = 10


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


local function getAbyssalHunterCard()
    local mainInterface = playerGui:FindFirstChild("MainInterface")
    if not mainInterface then
        return nil
    end


    local interfaceChildren = mainInterface:GetChildren()
    local section = interfaceChildren[61]
    if not section then
        return nil
    end


    local sectionChildren = section:GetChildren()
    local cardFrame = sectionChildren[4]
    if not cardFrame then
        return nil
    end


    local frame = cardFrame:FindFirstChild("Frame")
    if not frame then
        return nil
    end


    local scrollingFrame = frame:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then
        return nil
    end


    return scrollingFrame:FindFirstChild("0.29954987813313594")
end


local function getEquipButton()
    local mainInterface = playerGui:FindFirstChild("MainInterface")
    if not mainInterface then
        return nil
    end


    local interfaceChildren = mainInterface:GetChildren()
    local section = interfaceChildren[61]
    if not section then
        return nil
    end


    local sectionFrame = section:FindFirstChild("Frame")
    if not sectionFrame then
        return nil
    end


    local frameChildren = sectionFrame:GetChildren()
    local buttonContainer = frameChildren[5]
    if not buttonContainer then
        return nil
    end


    local frame = buttonContainer:FindFirstChild("Frame")
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


local function tryEquipAbyssalHunter()
    local abyssalHunterCard = getAbyssalHunterCard()
    if not abyssalHunterCard then
        return false
    end


    clickGuiObject(abyssalHunterCard)
    task.wait(0.25)


    local equipButton = getEquipButton()
    if not equipButton then
        return false
    end


    clickGuiObject(equipButton)
    return true
end


task.spawn(function()
    local mainInterface = playerGui:WaitForChild("MainInterface", 10)
    if not mainInterface then
        return
    end


    while screenGui.Parent do
        if autoEquipEnabled then
            tryEquipAbyssalHunter()
        end


        task.wait(AUTO_EQUIP_CHECK_INTERVAL)
    end
end)