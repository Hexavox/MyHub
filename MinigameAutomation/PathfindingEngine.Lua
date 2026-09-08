-- PATHFINDING & UNSTUCK ENGINE

local function shouldContinue(token)
    return pathfindingEnabled and routineToken == token
end

local function attemptUnstuck(humanoid, rootPart)
    setStatus("Unsticking character...", Color3.fromRGB(240, 200, 120))

    humanoid.Jump = true
    local moveBackVector = -rootPart.CFrame.LookVector * 6 + Vector3.new(math.random(-4, 4), 0, math.random(-4, 4))
    humanoid:MoveTo(rootPart.Position + moveBackVector)

    task.wait(0.8)
end

local function walkToPosition(targetPosition, token)
    local character = player.Character
    if not character then return false end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return false end

    while shouldContinue(token) do
        if consecutivePathFailures >= MAX_CONSECUTIVE_FAILURES then
            clickGiveUpButton()
            return false
        end

        local effectiveTarget = targetPosition
        if consecutivePathFailures >= 3 then
            local detourOffset = Vector3.new(
                math.random(-12, 12),
                0,
                math.random(-12, 12)
            )
            effectiveTarget = targetPosition + detourOffset
        elseif consecutivePathFailures > 0 then
            local lightOffset = Vector3.new(
                math.random(-4, 4),
                0,
                math.random(-4, 4)
            )
            effectiveTarget = targetPosition + lightOffset
        end

        local path = PathfindingService:CreatePath(PATH_OPTIONS)
        local computed = pcall(function()
            path:ComputeAsync(rootPart.Position, effectiveTarget)
        end)

        if not computed or path.Status ~= Enum.PathStatus.Success then
            consecutivePathFailures += 1
            setStatus("Path failed (" .. consecutivePathFailures .. "/" .. MAX_CONSECUTIVE_FAILURES .. ")", Color3.fromRGB(240, 140, 150))

            if consecutivePathFailures >= MAX_CONSECUTIVE_FAILURES then
                clickGiveUpButton()
                return false
            end

            attemptUnstuck(humanoid, rootPart)
        else
            drawPath(path)
            setStatus("Walking...", Color3.fromRGB(180, 220, 255))

            local waypoints = path:GetWaypoints()

            local autoJumpConn = nil
            if autoJumpEnabled then
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

                if waypoint.Action == Enum.PathWaypointAction.Jump and not autoJumpEnabled then
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
                    consecutivePathFailures += 1
                    setStatus("Stuck (" .. consecutivePathFailures .. "/" .. MAX_CONSECUTIVE_FAILURES .. ")", Color3.fromRGB(240, 140, 150))

                    attemptUnstuck(humanoid, rootPart)
                    stepFailed = true
                    break
                end
            end

            if autoJumpConn then autoJumpConn:Disconnect() end

            if not stepFailed then
                consecutivePathFailures = 0
                setStatus("Reached target", Color3.fromRGB(200, 230, 255))
                return true
            end
        end
    end

    return false
end