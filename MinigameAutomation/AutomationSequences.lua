-- AUTOMATION SEQUENCES

local plr = game.Players.LocalPlayer

local function resetPlr()
    if plr.Character then
        plr.Character:BreakJoints()
    end
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
    setStatus("Searching Watermelon...", Color3.fromRGB(240, 220, 160))
    local targetPrompt, watermelonPart = findWatermelonPrompt()
    local startTime = os.clock()

    while not targetPrompt and shouldContinue(token) do
        -- WATERMELON SEARCH TIMEOUT: If looking for more than 3 minutes (180s), give up
        if os.clock() - startTime > 180 then
            setStatus("Search timeout! Giving up...", Color3.fromRGB(255, 100, 100))
            clickGiveUpButton()
            return
        end

        task.wait(0.5)
        targetPrompt, watermelonPart = findWatermelonPrompt()
    end

    if not targetPrompt or not shouldContinue(token) then
        setStatus("Watermelon missing", Color3.fromRGB(240, 140, 150))
        task.wait(2)
        return
    end

    if watermelonPart and watermelonPart:IsA("BasePart") then
        walkToPosition(watermelonPart.Position, token)
    end

    if not shouldContinue(token) then return end

    task.wait(0.3)
    local freshPrompt, freshPart = findWatermelonPrompt()
    freshPrompt = freshPrompt or targetPrompt
    freshPart = freshPart or watermelonPart

    if freshPrompt and freshPart then
        if not isWithinPromptRange(freshPrompt, freshPart) then
            walkToPosition(freshPart.Position, token)
            task.wait(0.3)

            local recheckPrompt, recheckPart = findWatermelonPrompt()
            freshPrompt = recheckPrompt or freshPrompt
            freshPart = recheckPart or freshPart
        end

        if isWithinPromptRange(freshPrompt, freshPart) and shouldContinue(token) then
            spamPromptUntilRemoved(freshPrompt, freshPart, token)
        end
    end

    updateAttemptsUI()

    task.wait(1)
end

local function executeRoutine(token)
    if not shouldContinue(token) then return end

    local _, limePos, limePrompt = getLimeTarget()
    if not limePos or not limePrompt then
        setStatus("Waiting for Lime...", Color3.fromRGB(160, 168, 185))
        task.wait(1)
        return
    end

    if walkToPosition(limePos, token) then
        if not shouldContinue(token) then return end

        setStatus("Interacting with Lime...", Color3.fromRGB(240, 220, 160))
        triggerPromptEnhanced(limePrompt)

        task.wait(2)
        if not shouldContinue(token) then return end

        -- LIME CONVERSATION STUCK CHECK
        local conversationStartTime = os.clock()

        local minigameBtn = waitForChoiceButton("[ Minigame ]", 8, token)
        
        if not minigameBtn then
            if os.clock() - conversationStartTime > 60 then
                setStatus("Stuck on Lime! Resetting...", Color3.fromRGB(255, 100, 100))
                resetPlr()
                task.wait(5)
                return
            end
        end

        if minigameBtn then
            task.wait(0.5)
            clickChoiceButton(minigameBtn)

            local ticketBtn = waitForChoiceButton("[ -1 Minigame Ticket ]", 8, token)
            
            if not ticketBtn then
                if os.clock() - conversationStartTime > 60 then
                    setStatus("Stuck on Ticket! Resetting...", Color3.fromRGB(255, 100, 100))
                    resetPlr()
                    task.wait(5)
                    return
                end
            end

            if ticketBtn then
                task.wait(0.5)
                clickChoiceButton(ticketBtn)

                task.wait(1)
                if shouldContinue(token) then
                    startWatermelonMinigameSequence(token)
                end
            end
        end
    end
end
