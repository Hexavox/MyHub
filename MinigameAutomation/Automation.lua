-- Automation.lua (ModuleScript)
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local Config = require(script.Parent.Config)
local State = require(script.Parent.State)
local Utils = require(script.Parent.Utils)
local Pathfinding = require(script.Parent.Pathfinding)
local TicketScanner = require(script.Parent.TicketScanner)

local player = Players.LocalPlayer
local Camera = Workspace:FindFirstChildOfClass("Camera")

local Automation = {}

local function clickGiveUpButton()
	local mainInterface = player:WaitForChild("PlayerGui"):FindFirstChild("MainInterface")
	if not mainInterface then return false end

	for _, obj in ipairs(mainInterface:GetDescendants()) do
		if obj:IsA("ImageButton") or obj:IsA("TextButton") then
			local textLabel = obj:FindFirstChildWhichIsA("TextLabel", true)
			if (textLabel and string.find(string.lower(textLabel.Text), "give up")) or
				(obj:IsA("TextButton") and string.find(string.lower(obj.Text), "give up")) then

				if State.gui then
					State.gui.setStatus("Giving Up...", Color3.fromRGB(240, 190, 140))
				end

				if typeof(getconnections) == "function" then
					for _, conn in ipairs(getconnections(obj.Activated)) do
						if conn.Function then conn.Function() end
					end
					for _, conn in ipairs(getconnections(obj.MouseButton1Click)) do
						if conn.Function then conn.Function() end
					end
				end

				local pos = obj.AbsolutePosition
				local size = obj.AbsoluteSize
				local inset, _ = GuiService:GetGuiInset()

				local clickX = pos.X + (size.X / 2) + inset.X
				local clickY = pos.Y + (size.Y / 2) + inset.Y

				VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
				task.wait(0.05)
				VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)

				State.consecutivePathFailures = 0
				return true
			end
		end
	end
	return false
end

local function findChoiceButtonByText(targetText)
	local mainInterface = player:WaitForChild("PlayerGui"):FindFirstChild("MainInterface")
	if not mainInterface then return nil end

	local dialog = mainInterface:FindFirstChild("Dialog")
	if not dialog then return nil end

	local choices = dialog:FindFirstChild("Choices")
	if not choices then return nil end

	for _, obj in ipairs(choices:GetChildren()) do
		if obj:IsA("TextButton") and obj.Text == targetText then
			return obj
		end
	end
	return nil
end

local function waitForChoiceButton(targetText, timeout, token)
	local startTime = os.clock()
	repeat
		if not State.pathfindingEnabled or State.routineToken ~= token then return nil end
		local button = findChoiceButtonByText(targetText)
		if button then return button end
		task.wait(0.25)
	until os.clock() - startTime >= timeout
	return nil
end

local function clickChoiceButton(button)
	if not button then return end

	if typeof(getconnections) == "function" then
		for _, connection in ipairs(getconnections(button.Activated)) do
			if connection.Function then connection.Function() end
		end
		for _, connection in ipairs(getconnections(button.MouseButton1Click)) do
			if connection.Function then connection.Function() end
		end
	end

	local pos = button.AbsolutePosition
	local size = button.AbsoluteSize
	local inset, _ = GuiService:GetGuiInset()

	local clickX = pos.X + (size.X / 2) + inset.X
	local clickY = pos.Y + (size.Y / 2) + inset.Y

	VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
	task.wait(0.05)
	VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
end

local function triggerPromptEnhanced(prompt)
	if not prompt then return end

	local char = player.Character
	local rootPart = char and char:FindFirstChild("HumanoidRootPart")

	if rootPart and prompt.Parent then
		local targetPart = prompt.Parent
		if targetPart:IsA("Attachment") then targetPart = targetPart.Parent end
		if targetPart and targetPart:IsA("BasePart") then
			rootPart.CFrame = CFrame.new(
				rootPart.Position,
				Vector3.new(targetPart.Position.X, rootPart.Position.Y, targetPart.Position.Z)
			)
		end
	end

	task.wait(0.1)
	prompt.HoldDuration = 0

	if typeof(fireproximityprompt) == "function" then
		fireproximityprompt(prompt)
	end

	prompt:InputHoldBegin()
	task.wait(0.05)
	prompt:InputHoldEnd()
end

local function findWatermelonPrompt()
	local topWatermelon = Workspace:FindFirstChild("Watermelon")
	if topWatermelon then
		local innerWatermelon = topWatermelon:FindFirstChild("Watermelon")
		if innerWatermelon then
			local attachment = innerWatermelon:FindFirstChild("Attachment")
			if attachment then
				local prompt = attachment:FindFirstChildWhichIsA("ProximityPrompt")
				if prompt then return prompt, innerWatermelon end
			end
		end
	end

	for targetModel, _ in pairs(State.trackedWatermelons) do
		local prompt = targetModel:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			local part = targetModel:FindFirstChildWhichIsA("BasePart", true) or targetModel.PrimaryPart
			return prompt, part
		end
	end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and string.find(string.lower(obj.Parent.Name), "watermelon") then
			local part = obj.Parent
			if part:IsA("BasePart") then
				return obj, part
			end
		end
	end

	return nil, nil
end

local function spamPromptUntilRemoved(prompt, watermelonPart, token)
	if not prompt or not watermelonPart then return end

	local removed = false
	local destroyConn = watermelonPart.Destroying:Connect(function()
		removed = true
	end)

	local rotSpeed = math.rad(120)
	local startTime = os.clock()

	if State.gui then
		State.gui.setStatus("Collecting Watermelon...", Color3.fromRGB(200, 225, 255))
	end

	while not removed and watermelonPart.Parent and State.pathfindingEnabled and State.routineToken == token do
		prompt:InputHoldBegin()
		task.wait(0.05)
		prompt:InputHoldEnd()

		if typeof(fireproximityprompt) == "function" then
			fireproximityprompt(prompt)
		end

		local now = os.clock()
		if Camera then
			local center = watermelonPart.Position
			local radius = 6
			local angle = (now - startTime) * rotSpeed

			local newX = center.X + math.cos(angle) * radius
			local newZ = center.Z + math.sin(angle) * radius

			Camera.CFrame = CFrame.new(
				Vector3.new(newX, center.Y + 3, newZ),
				center
			)
		end

		task.wait(0.05)
	end

	if destroyConn then destroyConn:Disconnect() end
end

local function isWithinPromptRange(prompt, watermelonPart)
	if not prompt or not watermelonPart then return false end

	local char = player.Character
	if not char then return false end

	local rootPart = char:FindFirstChild("HumanoidRootPart")
	if not rootPart then return false end

	local maxDist = prompt.MaxActivationDistance or 10
	return (rootPart.Position - watermelonPart.Position).Magnitude <= maxDist
end

local function getLimeTarget()
	local mapFolder = Workspace:WaitForChild("Map", 5)
	if not mapFolder then return nil, nil, nil end

	local limeModel = mapFolder:WaitForChild("Lime", 5)
	if not limeModel then return nil, nil, nil end

	local torso = limeModel:WaitForChild("Torso", 5)
	if not torso then return nil, nil, nil end

	return limeModel, torso.Position, torso:FindFirstChildWhichIsA("ProximityPrompt")
end

local function startWatermelonMinigameSequence(token)
	if State.gui then
		State.gui.setStatus("Searching Watermelon...", Color3.fromRGB(240, 220, 160))
	end

	local targetPrompt, watermelonPart = findWatermelonPrompt()
	local startTime = os.clock()

	while not targetPrompt and (os.clock() - startTime < 10) and State.pathfindingEnabled and State.routineToken == token do
		task.wait(0.5)
		targetPrompt, watermelonPart = findWatermelonPrompt()
	end

	if not targetPrompt or not (State.pathfindingEnabled and State.routineToken == token) then
		if State.gui then
			State.gui.setStatus("Watermelon missing", Color3.fromRGB(240, 140, 150))
		end
		task.wait(2)
		return
	end

	if watermelonPart and watermelonPart:IsA("BasePart") then
		Pathfinding.walkToPosition(watermelonPart.Position, token)
	end

	if not (State.pathfindingEnabled and State.routineToken == token) then return end

	task.wait(0.3)
	local freshPrompt, freshPart = findWatermelonPrompt()
	freshPrompt = freshPrompt or targetPrompt
	freshPart = freshPart or watermelonPart

	if freshPrompt and freshPart then
		if not isWithinPromptRange(freshPrompt, freshPart) then
			Pathfinding.walkToPosition(freshPart.Position, token)
			task.wait(0.3)

			local recheckPrompt, recheckPart = findWatermelonPrompt()
			freshPrompt = recheckPrompt or freshPrompt
			freshPart = recheckPart or freshPart
		end

		if isWithinPromptRange(freshPrompt, freshPart) and State.pathfindingEnabled and State.routineToken == token then
			spamPromptUntilRemoved(freshPrompt, freshPart, token)
		end
	end

	-- Refresh attempts after watermelon sequence
	TicketScanner.updateAttemptsUI()

	task.wait(1)
end

function Automation.executeRoutine(token)
	if not (State.pathfindingEnabled and State.routineToken == token) then return end

	local _, limePos, limePrompt = getLimeTarget()
	if not limePos or not limePrompt then
		if State.gui then
			State.gui.setStatus("Waiting for Lime...", Color3.fromRGB(160, 168, 185))
		end
		task.wait(1)
		return
	end

	if Pathfinding.walkToPosition(limePos, token) then
		if not (State.pathfindingEnabled and State.routineToken == token) then return end

		if State.gui then
			State.gui.setStatus("Interacting with Lime...", Color3.fromRGB(240, 220, 160))
		end
		triggerPromptEnhanced(limePrompt)

		task.wait(2)
		if not (State.pathfindingEnabled and State.routineToken == token) then return end

		local minigameBtn = waitForChoiceButton("[ Minigame ]", 8, token)
		if minigameBtn then
			task.wait(0.5)
			clickChoiceButton(minigameBtn)

			local ticketBtn = waitForChoiceButton("[ -1 Minigame Ticket ]", 8, token)
			if ticketBtn then
				task.wait(0.5)
				clickChoiceButton(ticketBtn)

				task.wait(1)
				if State.pathfindingEnabled and State.routineToken == token then
					startWatermelonMinigameSequence(token)
				end
			end
		end
	end
end

return Automation