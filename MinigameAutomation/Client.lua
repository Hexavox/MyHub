-- Client.lua
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Modules = _G.MinigameAutomationModules
local Config = Modules.Config
local State = Modules.State
local Gui = Modules.Gui
local Utils = Modules.Utils
local TicketScanner = Modules.TicketScanner
local Automation = Modules.Automation
local Pathfinding = Modules.Pathfinding

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create visuals folders
local oldVisualFolder = Workspace:FindFirstChild(Config.VISUAL_FOLDER_NAME)
if oldVisualFolder then oldVisualFolder:Destroy() end

local oldPathFolder = Workspace:FindFirstChild(Config.PATH_VISUAL_FOLDER_NAME)
if oldPathFolder then oldPathFolder:Destroy() end

local visualFolder = Instance.new("Folder")
visualFolder.Name = Config.VISUAL_FOLDER_NAME
visualFolder.Parent = Workspace

local pathVisualFolder = Instance.new("Folder")
pathVisualFolder.Name = Config.PATH_VISUAL_FOLDER_NAME
pathVisualFolder.Parent = Workspace

State.visualFolder = visualFolder
State.pathVisualFolder = pathVisualFolder

-- Create GUI
Gui.create()

-- Start ticket scanner
TicketScanner.start()

-- Initial watermelon scan
for _, object in ipairs(Workspace:GetDescendants()) do
	Utils.checkObject(object)
end

Workspace.DescendantAdded:Connect(function(obj)
	Utils.checkObject(obj)
end)

-- Periodic scan / cleanup
task.spawn(function()
	while State.gui and State.gui.screenGui and State.gui.screenGui.Parent do
		task.wait(Config.SCAN_INTERVAL)

		for _, object in ipairs(Workspace:GetDescendants()) do
			Utils.checkObject(object)
		end

		for object, _ in pairs(State.trackedWatermelons) do
			if not object.Parent or not object:IsDescendantOf(Workspace) then
				Utils.removeTrackedWatermelon(object)
			end
		end
	end
end)

-- Toggle boxes
State.gui.toggleBoxesButton.MouseButton1Click:Connect(function()
	Utils.setBoxesVisible(not State.boxesEnabled)
	State.gui.updateBoxesToggle()
end)

-- Pathfinding toggle & routine loop
local function stopRoutine()
	State.routineToken += 1
	Utils.clearPathVisuals()
	if State.gui then
		State.gui.setStatus("Idle", Color3.fromRGB(160, 168, 185))
	end
end

local function startRoutineLoop()
	State.routineToken += 1
	local currentToken = State.routineToken

	task.spawn(function()
		while State.pathfindingEnabled and State.routineToken == currentToken do
			Automation.executeRoutine(currentToken)
			task.wait(0.5)
		end
	end)
end

State.gui.togglePathButton.MouseButton1Click:Connect(function()
	State.pathfindingEnabled = not State.pathfindingEnabled
	State.gui.updatePathToggle()

	if State.pathfindingEnabled then
		startRoutineLoop()
	else
		stopRoutine()
	end
end)