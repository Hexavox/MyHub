-- TICKET SCANNER & ATTEMPTS UPDATER

local function updateAttemptsUI()
    local mainInterface = playerGui:FindFirstChild("MainInterface")
    if not mainInterface then
        attemptsLabel.Text = "⚠ 0 Attempts"
        return
    end

    local itemGridScrollingFrame = mainInterface:FindFirstChild("Inventory")
        and mainInterface.Inventory:FindFirstChild("Items")
        and mainInterface.Inventory.Items:FindFirstChild("ItemGrid")
        and mainInterface.Inventory.Items.ItemGrid:FindFirstChild("ItemGridScrollingFrame")

    if not itemGridScrollingFrame then
        attemptsLabel.Text = "⚠ 0 Attempts"
        return
    end

    local minigameTicket = itemGridScrollingFrame:FindFirstChild("Item\010minigame_ticket") 
        or itemGridScrollingFrame:FindFirstChild("Item\nminigame_ticket")

    if minigameTicket then
        local button = minigameTicket:FindFirstChild("Button")
        if button then
            local itemAmount = button:FindFirstChild("ItemAmount")
            if itemAmount then
                local rawText = itemAmount.Text
                local count = string.match(rawText, "%d+") or "0"
                attemptsLabel.Text = "⚠ " .. count .. " Attempts"
                return
            end
        end
    end

    attemptsLabel.Text = "⚠ 0 Attempts"
end

task.spawn(function()
    local mainInterface = playerGui:WaitForChild("MainInterface", 10)
    if not mainInterface then return end

    local itemGridScrollingFrame = mainInterface:WaitForChild("Inventory", 5)
        and mainInterface.Inventory:WaitForChild("Items", 5)
        and mainInterface.Inventory.Items:WaitForChild("ItemGrid", 5)
        and mainInterface.Inventory.Items.ItemGrid:WaitForChild("ItemGridScrollingFrame", 5)

    if itemGridScrollingFrame then
        local minigameTicket = itemGridScrollingFrame:FindFirstChild("Item\010minigame_ticket") 
            or itemGridScrollingFrame:FindFirstChild("Item\nminigame_ticket")

        if minigameTicket then
            local button = minigameTicket:WaitForChild("Button", 5)
            if button then
                local itemAmount = button:WaitForChild("ItemAmount", 5)
                if itemAmount then
                    itemAmount:GetPropertyChangedSignal("Text"):Connect(function()
                        updateAttemptsUI()
                    end)
                end
            end
        end
    end
end)

updateAttemptsUI()