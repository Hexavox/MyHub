-- GAME INTERACTION HELPER FUNCTIONS

local function clickGiveUpButton()
    local mainInterface = playerGui:FindFirstChild("MainInterface")
    if not mainInterface then return false end

    for _, obj in ipairs(mainInterface:GetDescendants()) do
        if obj:IsA("ImageButton") or obj:IsA("TextButton") then
            local textLabel = obj:FindFirstChildWhichIsA("TextLabel", true)
            if (textLabel and string.find(string.lower(textLabel.Text), "give up")) or
               (obj:IsA("TextButton") and string.find(string.lower(obj.Text), "give up")) then

                setStatus("Giving Up...", Color3.fromRGB(240, 190, 140))

                if typeof(getconnections) == "function" then
                    for _, conn in ipairs(getconnections(obj.Activated)) do
                        if conn.Function then conn.Function() end
                    end
                    for _, conn in ipairs(getconnections(obj.MouseButton1Click)) do
                        if conn.Function then conn.Function() end
                    end
                end

                local pos = obj.AbsolutePosition
                local size = obj.AbsoluteSize
                local inset, _ = GuiService:GetGuiInset()

                local clickX = pos.X + (size.X / 2) + inset.X
                local clickY = pos.Y + (size.Y / 2) + inset.Y

                VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)

                consecutivePathFailures = 0
                return true
            end
        end
    end
    return false
end

local function findChoiceButtonByText(targetText)
    local mainInterface = playerGui:FindFirstChild("MainInterface")
    if not mainInterface then return nil end

    local dialog = mainInterface:FindFirstChild("Dialog")
    if not dialog then return nil end

    local choices = dialog:FindFirstChild("Choices")
    if not choices then return nil end

    for _, obj in ipairs(choices:GetChildren()) do
        if obj:IsA("TextButton") and obj.Text == targetText then
            return obj
        end
    end
    return nil
end

local function waitForChoiceButton(targetText, timeout, token)
    local startTime = os.clock()
    repeat
        if pathfindingEnabled == false or routineToken ~= token then return nil end
        local button = findChoiceButtonByText(targetText)
        if button then return button end
        task.wait(0.25)
    until os.clock() - startTime >= timeout
    return nil
end

local function clickChoiceButton(button)
    if not button then return end

    if typeof(getconnections) == "function" then
        for _, connection in ipairs(getconnections(button.Activated)) do
            if connection.Function then connection.Function() end
        end
        for _, connection in ipairs(getconnections(button.MouseButton1Click)) do
            if connection.Function then connection.Function() end
        end
    end

    local pos = button.AbsolutePosition
    local size = button.AbsoluteSize
    local inset, _ = GuiService:GetGuiInset()

    local clickX = pos.X + (size.X / 2) + inset.X
    local clickY = pos.Y + (size.Y / 2) + inset.Y

    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
end