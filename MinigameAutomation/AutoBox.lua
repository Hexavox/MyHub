-- ===== CONFIGURATION & TOGGLES (Declared First!) =====
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

local CHEST_INTERVAL = 6.5
local autoBoxEnabled = false -- Declared at the very top so everything below can see it!

-- ===== UI BUTTON SETUP =====
-- Note: Make sure your custom 'makeButton' function is defined somewhere above this line!
local autoBoxButton = makeButton("AutoBoxButton", "Auto-Box: OFF", 7)

local function updateBoxToggle()
    autoBoxButton.Text = autoBoxEnabled and "Auto-Box: ON" or "Auto-Box: OFF"
    autoBoxButton.BackgroundTransparency = autoBoxEnabled and 0.84 or 0.95
end

autoBoxButton.MouseButton1Click:Connect(function()
    autoBoxEnabled = not autoBoxEnabled -- Fixed name to match your loop variable
    updateBoxToggle()
end)


-- ===== UTILITY FUNCTIONS =====
-- Generic function to build and send the requested byte stream
local function fireChestPacket(bytes)
    local packetBuffer = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(packetBuffer, i - 1, bytes[i])
    end
    ByteNetEvent:FireServer(packetBuffer, nil)
end

-- Safely fetches item counts from the inventory UI grid
local function getBoxCount(boxName)
    local mainInterface = playerGui:FindFirstChild("MainInterface")
    if not mainInterface then return 0 end

    local itemGridScrollingFrame = mainInterface:FindFirstChild("Inventory")
        and mainInterface.Inventory:FindFirstChild("Items")
        and mainInterface.Inventory.Items:FindFirstChild("ItemGrid")
        and mainInterface.Inventory.Items.ItemGrid:FindFirstChild("ItemGridScrollingFrame")

    if not itemGridScrollingFrame then return 0 end

    local itemNode = itemGridScrollingFrame:FindFirstChild("Item\010" .. boxName) 
        or itemGridScrollingFrame:FindFirstChild("Item\n" .. boxName)

    if itemNode then
        local button = itemNode:FindFirstChild("Button")
        if button then
            local itemAmount = button:FindFirstChild("ItemAmount")
            if itemAmount then
                return tonumber(string.match(itemAmount.Text, "%d+")) or 0
            end
        end
    end

    return 0
end


-- ===== BACKGROUND INDEPENDENT LOOPS =====
local function runMegaBoxLoop()
    while true do
        if autoBoxEnabled then -- Now tracking the exact same variable as the button click
            local count = getBoxCount("Mega Summer Random Box")
            if count > 0 then
                fireChestPacket({ 34, 1, 0, 0, 0, 22, 0, 77, 101, 103, 97, 32, 83, 117, 109, 109, 101, 114, 32, 82, 97, 110, 100, 111, 109, 32, 66, 111, 120 })
                task.wait(CHEST_INTERVAL)
            else
                task.wait(1.0)
            end
        else
            task.wait(1.0)
        end
    end
end

local function runRareBoxLoop()
    while true do
        if autoBoxEnabled then
            local count = getBoxCount("Rare Summer Random Box")
            if count > 0 then
                fireChestPacket({ 34, 1, 0, 0, 0, 22, 0, 82, 97, 114, 101, 32, 83, 117, 109, 109, 101, 114, 32, 82, 97, 110, 100, 111, 109, 32, 66, 111, 120 })
                task.wait(CHEST_INTERVAL)
            else
                task.wait(1.0)
            end
        else
            task.wait(1.0)
        end
    end
end

local function runNormalBoxLoop()
    while true do
        if autoBoxEnabled then
            local count = getBoxEnabled and getBoxCount("Normal Summer Random Box")
            if count > 0 then
                fireChestPacket({ 34, 1, 0, 0, 0, 24, 0, 78, 111, 114, 109, 97, 108, 32, 83, 117, 109, 109, 101, 114, 32, 82, 97, 110, 100, 111, 109, 32, 66, 111, 120 })
                task.wait(CHEST_INTERVAL)
            else
                task.wait(1.0)
            end
        else
            task.wait(1.0)
        end
    end
end

-- Start up the background automation routines
task.spawn(runMegaBoxLoop)
task.spawn(runRareBoxLoop)
task.spawn(runNormalBoxLoop)
