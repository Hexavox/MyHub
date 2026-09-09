local function toggleGuiVisibility()
    local watermelonGui = playerGui:FindFirstChild("WatermelonTrackerGui")
    local biomeGui = playerGui:FindFirstChild("BiomeTrackerGui")
    
    if watermelonGui then
        watermelonGui.Enabled = not watermelonGui.Enabled
    end
    
    if biomeGui then
        biomeGui.Enabled = not biomeGui.Enabled
    end
end

-- Process core input connection listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Do not trigger if typing in standard chat windows
    if gameProcessed then return end
    
    if input.KeyCode == TOGGLE_KEY then
        toggleGuiVisibility()
    end
end)
