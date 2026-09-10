-- GUI SETUP

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WatermelonTrackerGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(240, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Position = UDim2.new(0.02, 0, 0.20, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = false
frame.Parent = screenGui
addCorner(frame, 16)
addGlassStroke(frame, 0.7, 1)
addGlassGradient(frame)

local framePadding = Instance.new("UIPadding")
framePadding.PaddingTop = UDim.new(0, 12)
framePadding.PaddingBottom = UDim.new(0, 12)
framePadding.PaddingLeft = UDim.new(0, 12)
framePadding.PaddingRight = UDim.new(0, 12)
framePadding.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Watermelon Bot"
titleLabel.TextColor3 = Color3.fromRGB(240, 243, 250)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.LayoutOrder = 1
titleLabel.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(160, 168, 185)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.LayoutOrder = 2
statusLabel.Parent = frame

local attemptsLabel = Instance.new("TextLabel")
attemptsLabel.Name = "AttemptsLabel"
attemptsLabel.Size = UDim2.new(1, 0, 0, 16)
attemptsLabel.BackgroundTransparency = 1
attemptsLabel.Text = "⚠ 0 Attempts"
attemptsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
attemptsLabel.Font = Enum.Font.GothamMedium
attemptsLabel.TextSize = 11
attemptsLabel.TextXAlignment = Enum.TextXAlignment.Center
attemptsLabel.LayoutOrder = 3
attemptsLabel.Parent = frame

local function makeButton(name, text, layoutOrder)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 38)
    button.LayoutOrder = layoutOrder
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = 0.92
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(235, 240, 250)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = frame
    addCorner(button, 10)
    addGlassStroke(button, 0.82, 1)
    return button
end

local toggleBoxesButton = makeButton("ToggleBoxesButton", "Bounding Boxes: ON", 4)
local togglePathButton = makeButton("TogglePathButton", "Pathfinding: OFF", 5)
local autoDeviceButton = makeButton("AutoDeviceButton", "Auto-Device: OFF", 6)
local autoBoxButton = makeButton("AutoBoxButton", "Auto-Box: OFF", 7)

local dropdownArrow = Instance.new("TextLabel")
dropdownArrow.Name = "DropdownArrow"
dropdownArrow.Size = UDim2.fromOffset(30, 30)
dropdownArrow.Position = UDim2.new(1, -30, 0.5, -15)
dropdownArrow.BackgroundTransparency = 1
dropdownArrow.Text = "▼"
dropdownArrow.TextColor3 = Color3.fromRGB(180, 190, 210)
dropdownArrow.Font = Enum.Font.GothamBold
dropdownArrow.TextSize = 10
dropdownArrow.Parent = togglePathButton