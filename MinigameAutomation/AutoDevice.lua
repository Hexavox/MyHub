-- ===== AUTO-DEVICE LOGIC =====

local BIOME_RANDOMIZER_NAME = "Item\010Biome Randomizer"
local STRANGE_CONTROLLER_NAME = "Item\010Strange Controller"

local BIOME_INTERVAL = 30 * 60  -- 30 minutes
local STRANGE_INTERVAL = 20 * 60  -- 20 minutes

-- Assumes these already exist in your script:
-- local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
-- local GuiService = game:GetService("GuiService")
-- local VirtualInputManager = game:GetService("VirtualInputManager")
-- local autoDeviceEnabled = false  -- defined alongside your other booleans

local function clickGuiObject(object)
	if not object or not object:IsA("GuiObject") then
		return false
	end

	if not object.Visible then
		return false
	end

	local position = object.AbsolutePosition
	local size = object.AbsoluteSize
	local inset = GuiService:GetGuiInset()

	local clickX = position.X + (size.X / 2) + inset.X
	local clickY = position.Y + (size.Y / 2) + inset.Y

	VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
	task.wait(0.05)
	VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)

	return true
end

local function getMainInterface()
	return playerGui:FindFirstChild("MainInterface")
end

local function findInventorySideButton()
	local mainInterface = getMainInterface()
	if not mainInterface then
		return nil
	end

	local sideButtons = mainInterface:FindFirstChild("SideButtons")
	if not sideButtons then
		return nil
	end

	for _, button in ipairs(sideButtons:GetChildren()) do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			local usageLabel = button:FindFirstChild("Usage", true)
			if usageLabel
				and usageLabel:IsA("TextLabel")
				and usageLabel.Text == "Inventory" then
				return button
			end
		end
	end

	return nil
end

local function openInventoryMenu()
	local invButton = findInventorySideButton()
	if not invButton then
		return false
	end

	if not clickGuiObject(invButton) then
		return false
	end

	task.wait(0.2)
	return true
end

local function getItemsTabButton()
	local mainInterface = getMainInterface()
	if not mainInterface then
		return nil
	end

	local inventory = mainInterface:FindFirstChild("Inventory")
	if not inventory then
		return nil
	end

	local items = inventory:FindFirstChild("Items")
	if not items then
		return nil
	end

	return items:FindFirstChild("ItemsTab")
end

local function openItemsTab()
	local itemsTab = getItemsTabButton()
	if not itemsTab then
		return false
	end

	if not clickGuiObject(itemsTab) then
		return false
	end

	task.wait(0.2)
	return true
end

local function getItemButton(itemName)
	local mainInterface = getMainInterface()
	if not mainInterface then
		return nil
	end

	local inventory = mainInterface:FindFirstChild("Inventory")
	if not inventory then
		return nil
	end

	local items = inventory:FindFirstChild("Items")
	if not items then
		return nil
	end

	local itemGrid = items:FindFirstChild("ItemGrid")
	if not itemGrid then
		return nil
	end

	local scrollFrame = itemGrid:FindFirstChild("ItemGridScrollingFrame")
	if not scrollFrame then
		return nil
	end

	local itemButtonFrame = scrollFrame:FindFirstChild(itemName)
	if not itemButtonFrame then
		return nil
	end

	return itemButtonFrame:FindFirstChild("Button")
end

local function getUseButton()
	local mainInterface = getMainInterface()
	if not mainInterface then
		return nil
	end

	local inventory = mainInterface:FindFirstChild("Inventory")
	if not inventory then
		return nil
	end

	local indexFrame = inventory:FindFirstChild("Index")
	if not indexFrame then
		return nil
	end

	local itemIndex = indexFrame:FindFirstChild("ItemIndex")
	if not itemIndex then
		return nil
	end

	local useHolder = itemIndex:FindFirstChild("UseHolder")
	if not useHolder then
		return nil
	end

	return useHolder:FindFirstChild("UseButton")
end

local function useItem(itemName)
	if not openInventoryMenu() then
		return false
	end

	if not openItemsTab() then
		return false
	end

	local itemButton = getItemButton(itemName)
	if not itemButton then
		return false
	end

	if not clickGuiObject(itemButton) then
		return false
	end
	task.wait(0.15)

	local useButton = getUseButton()
	if not useButton then
		return false
	end

	if not clickGuiObject(useButton) then
		return false
	end
	task.wait(0.15)

	return true
end

local function runBiomeRandomizerLoop()
	while true do
		if autoDeviceEnabled then
			useItem(BIOME_RANDOMIZER_NAME)
		end
		task.wait(BIOME_INTERVAL)
	end
end

local function runStrangeControllerLoop()
	while true do
		if autoDeviceEnabled then
			useItem(STRANGE_CONTROLLER_NAME)
		end
		task.wait(STRANGE_INTERVAL)
	end
end

-- Start the timers
task.spawn(runBiomeRandomizerLoop)
task.spawn(runStrangeControllerLoop)