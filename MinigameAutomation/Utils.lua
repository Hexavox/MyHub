-- Utils.lua (ModuleScript)
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Config)
local State = require(script.Parent.State)

local Utils = {}

function Utils.getModelBounds(object)
	if object:IsA("Model") then
		if object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true) then
			return object:GetBoundingBox()
		end
	elseif object:IsA("BasePart") then
		return object.CFrame, object.Size
	end
	return nil, nil
end

function Utils.removeTrackedWatermelon(object)
	local data = State.trackedWatermelons[object]
	if not data then return end

	if data.Anchor and data.Anchor.Parent then
		data.Anchor:Destroy()
	end

	State.trackedWatermelons[object] = nil
end

function Utils.markWatermelon(object)
	if State.trackedWatermelons[object] then return end

	local boundsCFrame, boundsSize = Utils.getModelBounds(object)
	if not boundsCFrame or not boundsSize then return end

	local anchor = Instance.new("Part")
	anchor.Name = "_WatermelonAnchor"
	anchor.Size = boundsSize
	anchor.CFrame = boundsCFrame
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Transparency = 1
	anchor.Parent = State.visualFolder

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "_WatermelonBox"
	box.Adornee = anchor
	box.Size = boundsSize + Vector3.new(0.12, 0.12, 0.12)
	box.Color3 = Config.BOX_COLOR
	box.Transparency = 0.65
	box.AlwaysOnTop = true
	box.ZIndex = 10
	box.Visible = State.boxesEnabled
	box.Parent = anchor

	local outline = Instance.new("BoxHandleAdornment")
	outline.Name = "_WatermelonOutline"
	outline.Adornee = anchor
	outline.Size = boundsSize + Vector3.new(0.25, 0.25, 0.25)
	outline.Color3 = Config.OUTLINE_COLOR
	outline.Transparency = 0.25
	outline.AlwaysOnTop = true
	outline.ZIndex = 11
	outline.Visible = State.boxesEnabled
	outline.Parent = anchor

	State.trackedWatermelons[object] = {
		Anchor = anchor,
		Box = box,
		Outline = outline,
	}

	object.Destroying:Connect(function()
		Utils.removeTrackedWatermelon(object)
	end)

	object.AncestryChanged:Connect(function()
		if not object:IsDescendantOf(Workspace) then
			Utils.removeTrackedWatermelon(object)
		end
	end)
end

function Utils.checkObject(object)
	if string.lower(object.Name) ~= Config.WATERMELON_NAME then return end

	if object:IsA("Model") then
		Utils.markWatermelon(object)
		return
	end

	local model = object:FindFirstAncestorWhichIsA("Model")
	if model and model ~= Workspace then
		Utils.markWatermelon(model)
	else
		Utils.markWatermelon(object)
	end
end

function Utils.setBoxesVisible(enabled)
	State.boxesEnabled = enabled
	for _, data in pairs(State.trackedWatermelons) do
		data.Box.Visible = enabled
		data.Outline.Visible = enabled
	end
end

function Utils.clearPathVisuals()
	for _, item in ipairs(State.pathVisualFolder:GetChildren()) do
		item:Destroy()
	end
end

function Utils.createPathPoint(position, index)
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
	point.Color = Config.PATH_COLOR
	point.Transparency = 0.2
	point.Parent = State.pathVisualFolder
end

function Utils.createPathLine(a, b, index)
	local distance = (b - a).Magnitude
	if distance <= 0 then return end

	local segment = Instance.new("Part")
	segment.Name = "Segment_" .. index
	segment.Size = Vector3.new(0.1, 0.1, distance)
	segment.CFrame = CFrame.lookAt((a + b) / 2, b)
	segment.Anchored = true
	segment.CanCollide = false
	segment.CanTouch = false
	segment.CanQuery = false
	segment.Material = Enum.Material.Neon
	segment.Color = Config.PATH_COLOR
	segment.Transparency = 0.35
	segment.Parent = State.pathVisualFolder
end

function Utils.drawPath(path)
	Utils.clearPathVisuals()
	if not State.viewPathEnabled then return end

	local waypoints = path:GetWaypoints()
	for index, waypoint in ipairs(waypoints) do
		Utils.createPathPoint(waypoint.Position, index)
		if index > 1 then
			Utils.createPathLine(waypoints[index - 1].Position, waypoint.Position, index)
		end
	end
end

return Utils