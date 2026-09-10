-- ===== AUTO-CHEST LOGIC (FINAL WORKING VERSION) =====

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

-- Configuration Constants
local CHEST_INTERVAL = 7.5
local MAX_BATCH = 10 -- Opens up to 10 boxes at a time

print("[AutoChest]: Fixed Script loaded and monitoring your button toggle.")

-- Generic function to build and send the requested byte stream
local function fireChestPacket(bytes)
    local packetBuffer = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(packetBuffer, i - 1, bytes[i])
    end
    
    pcall(function()
        ByteNetEvent:FireServer(packetBuffer, nil)
    end)
end

-- Safely fetches item counts from the UI inventory path
local function getBoxCount(boxName)
    local mainInterface = playerGui:FindFirstChild("MainInterface")
    if not mainInterface then return 0 end

    local itemGridScrollingFrame = mainInterface:FindFirstChild("Inventory")
        and mainInterface.Inventory:FindFirstChild("Items")
        and mainInterface.Inventory.Items:FindFirstChild("ItemGrid")
        and mainInterface.Inventory.Items.ItemGrid:FindFirstChild("ItemGridScrollingFrame")

    if not itemGridScrollingFrame then return 0 end

    -- Test both newline variations to find the box container inside the grid
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

-- Individual loops tracking the exact button variable: autoBoxEnabled
local function runMegaBoxLoop()
    while true do
        if autoBoxEnabled then -- FIXED: Changed from autoBox to your working button variable
            local count = getBoxCount("Mega Summer Random Box")
            if count > 0 then
                -- Dynamically calculate batch size up to 10
                local batchSize = math.clamp(count, 1, MAX_BATCH)
                
                -- Second byte is dynamically injected with your batchSize
                fireChestPacket({ 34, batchSize, 0, 0, 0, 22, 0, 77, 101, 103, 97, 32, 83, 117, 109, 109, 101, 114, 32, 82, 97, 110, 100, 111, 109, 32, 66, 111, 120 })
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
        if autoBoxEnabled then -- FIXED: Changed from autoBox to your working button variable
            local megaCount = getBoxCount("Mega Summer Random Box")
            local count = getBoxCount("Rare Summer Random Box")
            
            -- Only runs if you have 0 Megas left (Priority 1)
            if megaCount == 0 and count > 0 then
                -- Dynamically calculate batch size up to 10
                local batchSize = math.clamp(count, 1, MAX_BATCH)
                
                -- Second byte is dynamically injected with your batchSize
                fireChestPacket({ 34, batchSize, 0, 0, 0, 22, 0, 82, 97, 114, 101, 32, 83, 117, 109, 109, 101, 114, 32, 82, 97, 110, 100, 111, 109, 32, 66, 111, 120 })
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
        if autoBoxEnabled then -- FIXED: Changed from autoBox to your working button variable
            local megaCount = getBoxCount("Mega Summer Random Box")
            local rareCount = getBoxCount("Rare Summer Random Box")
            local count = getBoxCount("Normal Summer Random Box")
            
            -- Only runs if you have 0 Megas and 0 Rares left (Priority 2)
            if megaCount == 0 and rareCount == 0 and count > 0 then
                -- Dynamically calculate batch size up to 10
                local batchSize = math.clamp(count, 1, MAX_BATCH)
                
                -- Second byte is dynamically injected with your batchSize
                fireChestPacket({ 34, batchSize, 0, 0, 0, 24, 0, 78, 111, 114, 109, 97, 108, 32, 83, 117, 109, 109, 101, 114, 32, 82, 97, 110, 100, 111, 109, 32, 66, 111, 120 })
                task.wait(CHEST_INTERVAL)
            else
                task.wait(1.0)
            end
        else
            task.wait(1.0)
        end
    end
end

-- Start independent automation loops
task.spawn(runMegaBoxLoop)
task.spawn(runRareBoxLoop)
task.spawn(runNormalBoxLoop)
