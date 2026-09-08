-- Gui.lua (ModuleScript)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local Config = require(script.Parent.Config)
local State = require(script.Parent.State)
local Utils = require(script.Parent.Utils)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Gui = {}

-- GUI helpers
local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function addGlassStroke(parent, transparency, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = transparency
	stroke.Thickness = thickness
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function addGlassGradient(parent)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 160, 180))
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.75),
		NumberSequenceKeypoint.new(1, 0.90)
	})
	gradient.Rotation = 45
	gradient.Parent = parent
	return gradient
end

function Gui.create()
	-- Clean old GUI
	local oldGui = playerGui:FindFirstChild("WatermelonTrackerGui")
	if oldGui then oldGui:Destroy() end

	-- ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "WatermelonTrackerGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- Main frame
	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.fromOffset(240, 185)
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

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -24, 0, 28)
	titleLabel.Position = UDim2.fromOffset(12, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Watermelon Bot"
	titleLabel.TextColor3 = Color3.fromRGB(240, 243, 250)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = frame

	-- Status
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "Status"
	statusLabel.Size = UDim2.new(1, -24, 0, 18)
	statusLabel.Position = UDim2.fromOffset(12, 30)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Status: Idle"
	statusLabel.TextColor3 = Color3.fromRGB(160, 168, 185)
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.TextSize = 11
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = frame

	local function makeButton(name, text, positionY)
		local button = Instance.new("TextButton")
		button.Name = name
		button.Size = UDim2.new(1, -20, 0, 38)
		button.Position = UDim2.fromOffset(10, positionY)
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

	local toggleBoxesButton = makeButton("ToggleBoxesButton", "Bounding Boxes: ON", 58)
	local togglePathButton = makeButton("TogglePathButton", "Pathfinding: OFF", 104)

	-- Attempts label
	local attemptsLabel = Instance.new("TextLabel")
	attemptsLabel.Name = "AttemptsLabel"
	attemptsLabel.Size = UDim2.new(1, -20, 0, 18)
	attemptsLabel.Position = UDim2.fromOffset(10, 148)
	attemptsLabel.BackgroundTransparency = 1
	attemptsLabel.Text = "⚠ 0 Attempts"
	attemptsLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	attemptsLabel.Font = Enum.Font.GothamMedium
	attemptsLabel.TextSize = 11
	attemptsLabel.TextXAlignment = Enum.TextXAlignment.Center
	attemptsLabel.Parent = frame

	-- Dropdown arrow
	local dropdownArrow = Instance.new("TextLabel")
	dropdownArrow.Name = "DropdownArrow"
	dropdownArrow.Size = UDim2.fromOffset(20, 20)
	dropdownArrow.Position = UDim2.new(1, -24, 0.5, -10)
	dropdownArrow.BackgroundTransparency = 1
	dropdownArrow.Text = "▼"
	dropdownArrow.TextColor3 = Color3.fromRGB(180, 190, 210)
	dropdownArrow.Font = Enum.Font.GothamBold
	dropdownArrow.TextSize = 10
	dropdownArrow.Parent = togglePathButton

	-- Context menu (path settings)
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

	local function updateMenuTexts()
		viewPathButton.Text = State.viewPathEnabled
			and "   ✓   View Pathfind Path"
			or "   □   View Pathfind Path"

		autoJumpButton.Text = State.autoJumpEnabled
			and "   ✓   Constant Auto-Jump"
			or "   □   Constant Auto-Jump"
	end

	updateMenuTexts()

	local function setStatus(text, color)
		statusLabel.Text = "Status: " .. text
		statusLabel.TextColor3 = color or Color3.fromRGB(160, 168, 185)
	end

	local function updateBoxesToggle()
		toggleBoxesButton.Text = State.boxesEnabled and "Bounding Boxes: ON" or "Bounding Boxes: OFF"
		toggleBoxesButton.BackgroundTransparency = State.boxesEnabled and 0.88 or 0.95
	end

	local function updatePathToggle()
		togglePathButton.Text = State.pathfindingEnabled and "Pathfinding: ON" or "Pathfinding: OFF"
		togglePathButton.BackgroundTransparency = State.pathfindingEnabled and 0.84 or 0.95
	end

	updateBoxesToggle()
	updatePathToggle()

	-- Dragging
	local dragging = false
	local dragStart = nil
	local frameStart = nil

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			frameStart = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not dragStart or not frameStart then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				frameStart.X.Scale,
				frameStart.X.Offset + delta.X,
				frameStart.Y.Scale,
				frameStart.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			dragStart = nil
			frameStart = nil
		end
	end)

	-- Context menu visibility toggle
	togglePathButton.MouseButton2Click:Connect(function()
		contextMenu.Position = UDim2.fromOffset(
			togglePathButton.AbsolutePosition.X + togglePathButton.AbsoluteSize.X + 5,
			togglePathButton.AbsolutePosition.Y
		)
		contextMenu.Visible = not contextMenu.Visible
	end)

	viewPathButton.MouseButton1Click:Connect(function()
		State.viewPathEnabled = not State.viewPathEnabled
		updateMenuTexts()
		if not State.viewPathEnabled then
			Utils.clearPathVisuals()
		end
	end)

	autoJumpButton.MouseButton1Click:Connect(function()
		State.autoJumpEnabled = not State.autoJumpEnabled
		updateMenuTexts()
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

	-- Expose important UI refs on State.gui
	State.gui = {
		screenGui = screenGui,
		frame = frame,
		statusLabel = statusLabel,
		toggleBoxesButton = toggleBoxesButton,
		togglePathButton = togglePathButton,
		attemptsLabel = attemptsLabel,
		contextMenu = contextMenu,
		viewPathButton = viewPathButton,
		autoJumpButton = autoJumpButton,
		setStatus = setStatus,
		updateBoxesToggle = updateBoxesToggle,
		updatePathToggle = updatePathToggle,
		updateMenuTexts = updateMenuTexts,
	}

	return State.gui
end

return Gui