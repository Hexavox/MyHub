-- CONTROLLER EXECUTION & TOGGLES

local function stopRoutine()
    routineToken += 1
    clearPathVisuals()
    setStatus("Idle", Color3.fromRGB(160, 168, 185))
end

local function startRoutineLoop()
    routineToken += 1
    local currentToken = routineToken

    task.spawn(function()
        while pathfindingEnabled and routineToken == currentToken do
            executeRoutine(currentToken)
            task.wait(0.5)
        end
    end)
end

togglePathButton.MouseButton1Click:Connect(function()
    pathfindingEnabled = not pathfindingEnabled
    updatePathToggle()

    if pathfindingEnabled then
        startRoutineLoop()
    else
        stopRoutine()
    end
end)

togglePathButton.MouseButton2Click:Connect(function()
    contextMenu.Position = UDim2.fromOffset(
        togglePathButton.AbsolutePosition.X + togglePathButton.AbsoluteSize.X + 5,
        togglePathButton.AbsolutePosition.Y
    )
    contextMenu.Visible = not contextMenu.Visible
end)

viewPathButton.MouseButton1Click:Connect(function()
    viewPathEnabled = not viewPathEnabled
    updateMenuTexts()
    if not viewPathEnabled then
        clearPathVisuals()
    end
end)

autoJumpButton.MouseButton1Click:Connect(function()
    autoJumpEnabled = not autoJumpEnabled
    updateMenuTexts()
end)

autoEquipButton.MouseButton1Click:Connect(function()
    autoEquipEnabled = not autoEquipEnabled
    updateMenuTexts()
end)

autoDeviceButton.MouseButton1Click:Connect(function()
    autoDeviceEnabled = not autoDeviceEnabled
    updateDeviceToggle()
end)

autoBoxButton.MouseButton1Click:Connect(function()
    autoBoxEnabled = not autoBoxEnabled
    updateBoxToggle()
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if contextMenu.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local menuPos = contextMenu.AbsolutePosition
            local menuSize = contextMenu.AbsoluteSize

            if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X
                or mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then

                contextMenu.Visible = false
            end
        end
    end
end)