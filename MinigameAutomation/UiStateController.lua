-- UI STATE CONTROLLER

local function setStatus(text, color)
    statusLabel.Text = "Status: " .. text
    statusLabel.TextColor3 = color or Color3.fromRGB(160, 168, 185)
end

local function updateBoxesToggle()
    toggleBoxesButton.Text = boxesEnabled and "Bounding Boxes: ON" or "Bounding Boxes: OFF"
    toggleBoxesButton.BackgroundTransparency = boxesEnabled and 0.88 or 0.95
end

local function updatePathToggle()
    togglePathButton.Text = pathfindingEnabled and "Pathfinding: ON" or "Pathfinding: OFF"
    togglePathButton.BackgroundTransparency = pathfindingEnabled and 0.84 or 0.95
end

local function updateDeviceToggle()
    autoDeviceButton.Text = autoDeviceEnabled and "Auto-Device: ON" or "Auto-Device: OFF"
    autoDeviceButton.BackgroundTransparency = autoDeviceEnabled and 0.84 or 0.95
end

local function updateBoxToggle()
    autoBoxButton.Text = autoBoxEnabled and "Auto-Box: ON" or "Auto-Box: OFF"
    autoBoxButton.BackgroundTransparency = autoBoxEnabled and 0.84 or 0.95
end

updateDeviceToggle()
updateBoxesToggle()
updatePathToggle()
updateBoxToggle()