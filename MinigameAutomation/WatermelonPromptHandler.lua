-- PROXIMITY PROMPT & WATERMELON SEARCH

local function triggerPromptEnhanced(prompt)
    if not prompt then return end

    local char = player.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")

    if rootPart and prompt.Parent then
        local targetPart = prompt.Parent
        if targetPart:IsA("Attachment") then targetPart = targetPart.Parent end
        if targetPart and targetPart:IsA("BasePart") then
            rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(targetPart.Position.X, rootPart.Position.Y, targetPart.Position.Z))
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

    for targetModel, _ in pairs(trackedWatermelons) do
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

    setStatus("Collecting Watermelon...", Color3.fromRGB(200, 225, 255))

    while not removed and watermelonPart.Parent and pathfindingEnabled and routineToken == token do
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