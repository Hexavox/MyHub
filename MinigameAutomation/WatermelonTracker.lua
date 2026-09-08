-- WATERMELON BOUNDING BOX TRACKER

local function getModelBounds(object)
    if object:IsA("Model") then
        if object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true) then
            return object:GetBoundingBox()
        end
    elseif object:IsA("BasePart") then
        return object.CFrame, object.Size
    end

    return nil, nil
end

local function removeTrackedWatermelon(object)
    local data = trackedWatermelons[object]
    if not data then
        return
    end

    if data.Anchor and data.Anchor.Parent then
        data.Anchor:Destroy()
    end

    trackedWatermelons[object] = nil
end

local function markWatermelon(object)
    if trackedWatermelons[object] then
        return
    end

    local boundsCFrame, boundsSize = getModelBounds(object)
    if not boundsCFrame or not boundsSize then
        return
    end

    local anchor = Instance.new("Part")
    anchor.Name = "_WatermelonAnchor"
    anchor.Size = boundsSize
    anchor.CFrame = boundsCFrame
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.CanTouch = false
    anchor.CanQuery = false
    anchor.Transparency = 1
    anchor.Parent = visualFolder

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "_WatermelonBox"
    box.Adornee = anchor
    box.Size = boundsSize + Vector3.new(0.12, 0.12, 0.12)
    box.Color3 = BOX_COLOR
    box.Transparency = 0.65
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Visible = boxesEnabled
    box.Parent = anchor

    local outline = Instance.new("BoxHandleAdornment")
    outline.Name = "_WatermelonOutline"
    outline.Adornee = anchor
    outline.Size = boundsSize + Vector3.new(0.25, 0.25, 0.25)
    outline.Color3 = OUTLINE_COLOR
    outline.Transparency = 0.25
    outline.AlwaysOnTop = true
    outline.ZIndex = 11
    outline.Visible = boxesEnabled
    outline.Parent = anchor

    trackedWatermelons[object] = {
        Anchor = anchor,
        Box = box,
        Outline = outline,
    }

    object.Destroying:Connect(function()
        removeTrackedWatermelon(object)
    end)

    object.AncestryChanged:Connect(function()
        if not object:IsDescendantOf(Workspace) then
            removeTrackedWatermelon(object)
        end
    end)
end

local function checkObject(object)
    if string.lower(object.Name) ~= WATERMELON_NAME then
        return
    end

    if object:IsA("Model") then
        markWatermelon(object)
        return
    end

    local model = object:FindFirstAncestorWhichIsA("Model")
    if model and model ~= Workspace then
        markWatermelon(model)
    else
        markWatermelon(object)
    end
end

local function setBoxesVisible(enabled)
    boxesEnabled = enabled
    updateBoxesToggle()

    for _, data in pairs(trackedWatermelons) do
        data.Box.Visible = enabled
        data.Outline.Visible = enabled
    end
end

toggleBoxesButton.MouseButton1Click:Connect(function()
    setBoxesVisible(not boxesEnabled)
end)

for _, object in ipairs(Workspace:GetDescendants()) do
    checkObject(object)
end

Workspace.DescendantAdded:Connect(checkObject)

task.spawn(function()
    while screenGui.Parent do
        task.wait(SCAN_INTERVAL)

        for _, object in ipairs(Workspace:GetDescendants()) do
            checkObject(object)
        end

        for object, _ in pairs(trackedWatermelons) do
            if not object.Parent or not object:IsDescendantOf(Workspace) then
                removeTrackedWatermelon(object)
            end
        end
    end
end)