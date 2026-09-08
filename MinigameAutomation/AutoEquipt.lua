-- ===== AutoEquipAbyssalHunter.lua =====
-- Auto-equip "Abyssal Hunter" every 10s unless disabled via GUI

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local CHECK_INTERVAL = 10 -- seconds
local MAIN_INTERFACE_WAIT = 5

-- PATHS (as you provided)
local function getAbyssalHunterCard()
	local main = playerGui:FindFirstChild("MainInterface")
	if not main then return nil end

	-- Adjust indices if needed
	local section = main:GetChildren()[61]
	if not section then return nil end

	local frame = section:GetChildren()[4]
	if not frame or not frame:FindFirstChild("Frame") then return nil end

	local scrolling = frame.Frame:FindFirstChild("ScrollingFrame")
	if not scrolling then return nil end

	-- This is the specific card container name you gave
	return scrolling:FindFirstChild("0.29954987813313594")
end

local function getEquipButton()
	local main = playerGui:FindFirstChild("MainInterface")
	if not main then return nil end

	local section = main:GetChildren()[61]
	if not section or not section:FindFirstChild("Frame") then return nil end

	local targetFrameChildren = section.Frame:GetChildren()
	local frameObj = targetFrameChildren[5]
	if not frameObj or not frameObj:FindFirstChild("Frame") then return nil end

	local imageButton = frameObj.Frame:FindFirstChild("ImageButton")
	if not imageButton or not imageButton:FindFirstChild("TextLabel") then return nil end

	local label = imageButton.TextLabel
	if label.Text == "Equip" then
		return imageButton
	end

	return nil
end

-- HELPER: click a button via VirtualInputManager (like your watermelon bot)
local function clickGuiObject(obj)
	if not obj then return false end

	-- Ensure it's visible and on-screen
	if not obj:IsA("GuiObject") then return false end

	local pos = obj.AbsolutePosition
	local size = obj.AbsoluteSize
	local inset, _ = GuiService:GetGuiInset()

	local clickX = pos.X + (size.X / 2) + inset.X
	local clickY = pos.Y + (size.Y / 2) + inset.Y

	VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
	task.wait(0.05)
	VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)

	return true
end

-- LOGIC: equip Abyssal Hunter
local function tryEquipAbyssalHunter()
	local card = getAbyssalHunterCard()
	if not card then
		-- Can't find card; maybe UI not ready or indices changed
		return false
	end

	-- Click the card first
	clickGuiObject(card)
	task.wait(0.25)

	local equipBtn = getEquipButton()
	if not equipBtn then
		return false
	end

	clickGuiObject(equipBtn)
	return true
end

-- GUI SETUP (simple toggle)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AbyssalAutoEquipGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "AutoEquipFrame"
frame.Size = UDim2.fromOffset(220, 70)
frame.Position = UDim2.new(0.02, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.75
stroke.Thickness = 1
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -16, 0, 20)
title.Position = UDim2.fromOffset(8, 6)
title.BackgroundTransparency = 1
title.Text = "Abyssal Auto-Equip"
title.TextColor3 = Color3.fromRGB(230, 235, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -16, 0, 18)
statusLabel.Position = UDim2.fromOffset(8, 26)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Off"
statusLabel.TextColor3 = Color3.fromRGB(170, 180, 200)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, -12, 0, 28)
toggleButton.Position = UDim2.fromOffset(6, 38)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundTransparency = 0.92
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Enable Auto-Equip"
toggleButton.TextColor3 = Color3.fromRGB(235, 240, 250)
toggleButton.Font = Enum.Font.GothamSemibold
toggleButton.TextSize = 12
toggleButton.AutoButtonColor = false
toggleButton.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = toggleButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(255, 255, 255)
buttonStroke.Transparency = 0.82
buttonStroke.Thickness = 1
buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
buttonStroke.Parent = toggleButton

-- STATE
local autoEquipEnabled = false
local routineToken = 0

local function setStatus(text, color)
	statusLabel.Text = "Status: " .. text
	statusLabel.TextColor3 = color or Color3.fromRGB(170, 180, 200)
end

local function updateToggleButton()
	toggleButton.Text = autoEquipEnabled and "Disable Auto-Equip" or "Enable Auto-Equip"
	toggleButton.BackgroundTransparency = autoEquipEnabled and 0.85 or 0.92
end

-- MAIN LOOP
local function autoEquipLoop(token)
	while autoEquipEnabled and routineToken == token do
		task.wait(CHECK_INTERVAL)

		if not autoEquipEnabled or routineToken ~= token then
			break
		end

		-- Try to equip
		local success = tryEquipAbyssalHunter()
		if success then
			setStatus("Equipped", Color3.fromRGB(160, 220, 180))
		else
			setStatus("Equip failed / missing", Color3.fromRGB(230, 160, 160))
		end
	end

	if not autoEquipEnabled then
		setStatus("Off", Color3.fromRGB(170, 180, 200))
	end
end

toggleButton.MouseButton1Click:Connect(function()
	autoEquipEnabled = not autoEquipEnabled
	updateToggleButton()

	if autoEquipEnabled then
		routineToken += 1
		setStatus("Running...", Color3.fromRGB(180, 210, 255))
		task.spawn(autoEquipLoop, routineToken)

		-- Do an immediate attempt
		local success = tryEquipAbyssalHunter()
		if success then
			setStatus("Equipped", Color3.fromRGB(160, 220, 180))
		else
			setStatus("Equip failed / missing", Color3.fromRGB(230, 160, 160))
		end
	else
		routineToken += 1
		setStatus("Off", Color3.fromRGB(170, 180, 200))
	end
end)

-- Initial state
setStatus("Off", Color3.fromRGB(170, 180, 200))
updateToggleButton()