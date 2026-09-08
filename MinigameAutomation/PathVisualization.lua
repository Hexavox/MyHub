-- PATH VISUALIZATION

local function clearPathVisuals()
    for _, item in ipairs(pathVisualFolder:GetChildren()) do
        item:Destroy()
    end
end

local function createPathPoint(position, index)
    local point = Instance.new("Part")
    point.Name = "Waypoint_" .. index
    point.Shape = Enum.PartType.Ball
    point.Size = Vector3.new(0.4, 0.4, 0.4)
    point.Position = position + Vector3.new(0, 0.25, 0)
    point.Anchored = true
    point.CanCollide = false
    point.CanTouch = false
    point.CanQuery = false
    point.Material = Enum.Material.Neon
    point.Color = PATH_COLOR
    point.Transparency = 0.2
    point.Parent = pathVisualFolder
end

local function createPathLine(a, b, index)
    local distance = (b - a).Magnitude
    if distance <= 0 then
        return
    end

    local segment = Instance.new("Part")
    segment.Name = "Segment_" .. index
    segment.Size = Vector3.new(0.1, 0.1, distance)
    segment.CFrame = CFrame.lookAt((a + b) / 2, b)
    segment.Anchored = true
    segment.CanCollide = false
    segment.CanTouch = false
    segment.CanQuery = false
    segment.Material = Enum.Material.Neon
    segment.Color = PATH_COLOR
    segment.Transparency = 0.35
    segment.Parent = pathVisualFolder
end

local function drawPath(path)
    clearPathVisuals()

    if not viewPathEnabled then
        return
    end

    local waypoints = path:GetWaypoints()
    for index, waypoint in ipairs(waypoints) do
        createPathPoint(waypoint.Position, index)

        if index > 1 then
            createPathLine(waypoints[index - 1].Position, waypoint.Position, index)
        end
    end
end