-- PATH SETTINGS DROPDOWN (RIGHT-CLICK MENU)

local contextMenu = Instance.new("Frame")
contextMenu.Name = "PathContextMenu"
contextMenu.Size = UDim2.fromOffset(200, 84)
contextMenu.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
contextMenu.BackgroundTransparency = 0.15
contextMenu.BorderSizePixel = 0
contextMenu.Visible = false
contextMenu.ZIndex = 20
contextMenu.Parent = screenGui
addCorner(contextMenu, 12)
addGlassStroke(contextMenu, 0.75, 1)
addGlassGradient(contextMenu)

local viewPathButton = Instance.new("TextButton")
viewPathButton.Name = "ViewPathButton"
viewPathButton.Size = UDim2.new(1, -10, 0, 34)
viewPathButton.Position = UDim2.fromOffset(5, 5)
viewPathButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
viewPathButton.BackgroundTransparency = 0.94
viewPathButton.BorderSizePixel = 0
viewPathButton.TextColor3 = Color3.fromRGB(230, 235, 245)
viewPathButton.Font = Enum.Font.GothamMedium
viewPathButton.TextSize = 11
viewPathButton.TextXAlignment = Enum.TextXAlignment.Left
viewPathButton.AutoButtonColor = false
viewPathButton.ZIndex = 21
viewPathButton.Parent = contextMenu
addCorner(viewPathButton, 8)

local autoJumpButton = Instance.new("TextButton")
autoJumpButton.Name = "AutoJumpButton"
autoJumpButton.Size = UDim2.new(1, -10, 0, 34)
autoJumpButton.Position = UDim2.fromOffset(5, 44)
autoJumpButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
autoJumpButton.BackgroundTransparency = 0.94
autoJumpButton.BorderSizePixel = 0
autoJumpButton.TextColor3 = Color3.fromRGB(230, 235, 245)
autoJumpButton.Font = Enum.Font.GothamMedium
autoJumpButton.TextSize = 11
autoJumpButton.TextXAlignment = Enum.TextXAlignment.Left
autoJumpButton.AutoButtonColor = false
autoJumpButton.ZIndex = 21
autoJumpButton.Parent = contextMenu
addCorner(autoJumpButton, 8)

local autoEquipButton = Instance.new("TextButton")
autoEquipButton.Name = "AutoEquipButton"
autoEquipButton.Size = UDim2.new(1, -10, 0, 34)
autoEquipButton.Position = UDim2.fromOffset(5, 83)
autoEquipButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
autoEquipButton.BackgroundTransparency = 0.94
autoEquipButton.BorderSizePixel = 0
autoEquipButton.TextColor3 = Color3.fromRGB(230, 235, 245)
autoEquipButton.Font = Enum.Font.GothamMedium
autoEquipButton.TextSize = 11
autoEquipButton.TextXAlignment = Enum.TextXAlignment.Left
autoEquipButton.AutoButtonColor = false
autoEquipButton.ZIndex = 21
autoEquipButton.Parent = contextMenu
addCorner(autoEquipButton, 8)

local function updateMenuTexts()
    viewPathButton.Text = viewPathEnabled
        and "   ✓   View Pathfind Path"
        or "   □   View Pathfind Path"

    autoJumpButton.Text = autoJumpEnabled
        and "   ✓   Constant Auto-Jump"
        or "   □   Constant Auto-Jump"

    autoEquipButton.Text = autoEquipEnabled
        and "   ✓   Auto-Equip Aura"
        or "   □   Auto-Equip Aura"
end

updateMenuTexts()