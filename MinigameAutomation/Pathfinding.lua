-- Pathfinding.lua (ModuleScript)
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local Config = require(script.Parent.Config)
local State = require(script.Parent.State)
local Utils = require(script.Parent.Utils)

local Pathfinding = {}

local function shouldContinue(token)
	return State.pathfindingEnabled and State.routineToken == token
end

local function attemptUnstuck(humanoid, rootPart)
	if State.gui then
		State.gui.setStatus("Unsticking character...", Color3.fromRGB(240, 200, 120))
	end

	humanoid.Jump = true
	local moveBackVector = -rootPart.CFrame.LookVector * 6
		+ Vector3.new(math.random(-4, 4), 0, math.random(-4, 4))
	humanoid:MoveTo(rootPart.Position + moveBackVector)
	task.wait(0.8)
end

function Pathfinding.walkToPosition(targetPosition, token)
	local character = game:GetService("Players").LocalPlayer.Character
	if not character then return false end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return false end

	while shouldContinue(token) do
		if State.consecutivePathFailures >= Config.MAX_CONSECUTIVE_FAILURES then
			-- clickGiveUpButton will be called from Automation
			return false
		end

		local effectiveTarget = targetPosition
		if State.consecutivePathFailures >= 3 then
			local detourOffset = Vector3.new(
				math.random(-12, 12),
				0,
				math.random(-12, 12)
			)
			effectiveTarget = targetPosition + detourOffset
		elseif State.consecutivePathFailures > 0 then
			local lightOffset = Vector3.new(
				math.random(-4, 4),
				0,
				math.random(-4, 4)
			)
			effectiveTarget = targetPosition + lightOffset
		end

		local path = PathfindingService:CreatePath(Config.PATH_OPTIONS)
		local computed = pcall(function()
			path:ComputeAsync(rootPart.Position, effectiveTarget)
		end)

		if not computed or path.Status ~= Enum.PathStatus.Success then
			State.consecutivePathFailures += 1
			if State.gui then
				State.gui.setStatus(
					"Path failed (" .. State.consecutivePathFailures .. "/" .. Config.MAX_CONSECUTIVE_FAILURES .. ")",
					Color3.fromRGB(240, 140, 150)
				)
			end

			if State.consecutivePathFailures >= Config.MAX_CONSECUTIVE_FAILURES then
				return false
			end

			attemptUnstuck(humanoid, rootPart)
		else
			Utils.drawPath(path)
			if State.gui then
				State.gui.setStatus("Walking...", Color3.fromRGB(180, 220, 255))
			end

			local waypoints = path:GetWaypoints()

			local autoJumpConn = nil
			if State.autoJumpEnabled then
				autoJumpConn = RunService.PreRender:Connect(function()
					if humanoid and humanoid.Health > 0 then
						humanoid.Jump = true
					end
				end)
			end

			local stepFailed = false
			for _, waypoint in ipairs(waypoints) do
				if not shouldContinue(token) or humanoid.Health <= 0 then
					if autoJumpConn then autoJumpConn:Disconnect() end
					return false
				end

				if waypoint.Action == Enum.PathWaypointAction.Jump and not State.autoJumpEnabled then
					humanoid.Jump = true
				end

				humanoid:MoveTo(waypoint.Position)

				local reached = false
				local finished = false

				local moveConnection = humanoid.MoveToFinished:Connect(function(result)
					reached = result
					finished = true
				end)

				local startedAt = os.clock()

				while not finished and shouldContinue(token) do
					if os.clock() - startedAt >= 6 then
						break
					end
					RunService.Heartbeat:Wait()
				end

				if moveConnection then moveConnection:Disconnect() end

				if not reached then
					if autoJumpConn then autoJumpConn:Disconnect() end
					State.consecutivePathFailures += 1
					if State.gui then
						State.gui.setStatus(
							"Stuck (" .. State.consecutivePathFailures .. "/" .. Config.MAX_CONSECUTIVE_FAILURES .. ")",
							Color3.fromRGB(240, 140, 150)
						)
					end

					attemptUnstuck(humanoid, rootPart)
					stepFailed = true
					break
				end
			end

			if autoJumpConn then autoJumpConn:Disconnect() end

			if not stepFailed then
				State.consecutivePathFailures = 0
				if State.gui then
					State.gui.setStatus("Reached target", Color3.fromRGB(200, 230, 255))
				end
				return true
			end
		end
	end

	return false
end

return Pathfinding