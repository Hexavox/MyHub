-- AutoEquip.lua
-- AUTO EQUIP ABYSSAL HUNTER


local CHECK_INTERVAL = 10


-- ===== Services.lua =====
-- SERVICES


local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")


local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)


-- ===== EquipHelpers.lua =====
-- CLICK HELPERS (SAME STYLE AS WATERMELON BOT)


local function clickGuiObject(obj)
	if not obj or not obj:IsA("GuiObject") then
		return false
	end


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


-- ===== AbyssalLocator.lua =====
-- FIND ABYSSAL HUNTER CARD & EQUIP BUTTON


local function getAbyssalHunterCard()
	local mainInterface = playerGui:FindFirstChild("MainInterface")
	if not mainInterface then
		return nil
	end


	local section = mainInterface:GetChildren()[61]
	if not section then
		return nil
	end


	local frame = section:GetChildren()[4]
	if not frame or not frame:FindFirstChild("Frame") then
		return nil
	end


	local scrolling = frame.Frame:FindFirstChild("ScrollingFrame")
	if not scrolling then
		return nil
	end


	return scrolling:FindFirstChild("0.29954987813313594")
end


local function getEquipButton()
	local mainInterface = playerGui:FindFirstChild("MainInterface")
	if not mainInterface then
		return nil
	end


	local section = mainInterface:GetChildren()[61]
	if not section or not section:FindFirstChild("Frame") then
		return nil
	end


	local targetFrameChildren = section.Frame:GetChildren()
	local frameObj = targetFrameChildren[5]
	if not frameObj or not frameObj:FindFirstChild("Frame") then
		return nil
	end


	local imageButton = frameObj.Frame:FindFirstChild("ImageButton")
	if not imageButton or not imageButton:FindFirstChild("TextLabel") then
		return nil
	end


	local label = imageButton.TextLabel
	if label.Text == "Equip" then
		return imageButton
	end


	return nil
end


-- ===== AutoEquipLogic.lua =====
-- TRY TO EQUIP ABYSSAL HUNTER


local function tryEquipAbyssalHunter()
	local card = getAbyssalHunterCard()
	if not card then
		return false
	end


	clickGuiObject(card)
	task.wait(0.2)


	local equipBtn = getEquipButton()
	if not equipBtn then
		return false
	end


	clickGuiObject(equipBtn)
	return true
end


-- ===== AutoEquipScanner.lua =====
-- PERIODIC CHECK (TICKET SCANNER STYLE)


task.spawn(function()
	local mainInterface = playerGui:WaitForChild("MainInterface", 10)
	if not mainInterface then
		return
	end


	while true do
		task.wait(CHECK_INTERVAL)


		tryEquipAbyssalHunter()
	end
end)

