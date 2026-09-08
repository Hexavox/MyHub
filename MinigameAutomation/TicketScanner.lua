local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

-- CONFIG
local CHECK_INTERVAL = 10 -- seconds

-- HELPERS: get card & equip button (same structure style as your ticket scanner)
local function getAbyssalHunterCard()
	local mainInterface = playerGui:FindFirstChild("MainInterface")
	if not mainInterface then return nil end

	-- Adjust indices if your UI changes
	local section = mainInterface:GetChildren()[61]
	if not section then return nil end

	local frame = section:GetChildren()[4]
	if not frame or not frame:FindFirstChild("Frame") then return nil end

	local scrolling = frame.Frame:FindFirstChild("ScrollingFrame")
	if not scrolling then return nil end

	return scrolling:FindFirstChild("0.29954987813313594")
end

local function getEquipButton()
	local mainInterface = playerGui:FindFirstChild("MainInterface")
	if not mainInterface then return nil end

	local section = mainInterface:GetChildren()[61]
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

-- HELPER: click a GuiObject via VirtualInputManager (same idea as your watermelon bot)
local function clickGuiObject(obj)
	if not obj or not obj:IsA("GuiObject") then return false end

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

-- MAIN: try to equip Abyssal Hunter
local function tryEquipAbyssalHunter()
	local card = getAbyssalHunterCard()
	if not card then
		-- Can't find card; maybe UI not ready or indices changed
		return false
	end

	-- Click card
	clickGuiObject(card)
	task.wait(0.2)

	local equipBtn = getEquipButton()
	if not equipBtn then
		return false
	end

	clickGuiObject(equipBtn)
	return true
end

-- TICKET-SCANNER STYLE LOOP
task.spawn(function()
	-- Optional: wait for MainInterface once at start
	local mainInterface = playerGui:WaitForChild("MainInterface", 10)
	if not mainInterface then return end

	while true do
		task.wait(CHECK_INTERVAL)

		local success = tryEquipAbyssalHunter()
		if success then
			-- Optional: print("Equipped Abyssal Hunter")
		else
			-- Optional: print("Equip failed / missing")
		end
	end
end)