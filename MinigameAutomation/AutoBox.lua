-- ===== AUTO-CHEST LOGIC (PACKET INJECTION ONLY) =====

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

-- Configuration Constants
local CHEST_INTERVAL = 6.5
local MAX_BATCH = 10

-- Initialize the toggle flag globally so your button can read/write to it easily
_G.autoChestEnabled = false 

-- Generic function to build and send the requested byte stream
local function fireChestPacket(secondByte, lengthByte, nameString)
    local bytes = {34, secondByte, 0, 0, 0, lengthByte, 0}
    
    -- Dynamically append the string ASCII character bytes
    for i = 1, #nameString do
        table.insert(bytes, string.byte(nameString, i))
    end
    
    local packetBuffer = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(packetBuffer, i - 1, bytes[i])
    end
    ByteNetEvent:FireServer(packetBuffer, nil)
end

-- Safely parses the UI text properties to read the current numeric counts
local function getBoxCount(boxName)
    local path = playerGui:FindFirstChild("MainInterface")
        and playerGui.MainInterface:FindFirstChild("Inventory")
        and playerGui.MainInterface.Inventory:FindFirstChild("Items")
        and playerGui.MainInterface.Inventory.Items:FindFirstChild("ItemGrid")
        and playerGui.MainInterface.Inventory.Items.ItemGrid:FindFirstChild("ItemGridScrollingFrame")
        
    if not path then return 0 end
    
    local itemNode = path:FindFirstChild("Item\010" .. boxName)
    if not itemNode then return 0 end
    
    local button = itemNode:FindFirstChild("Button")
    local itemAmount = button and button:FindFirstChild("ItemAmount")
    
    if itemAmount then
        local rawText = itemAmount.Text
        return tonumber(string.match(rawText, "%d+")) or 0
    end
    
    return 0
end

-- Single execution cycle (Matching your Abyss Hunter logic style)
local function executeChestCycle()
    -- Only run if the global flag from your button is set to true
    if not _G.autoChestEnabled then
        return 1.0 -- Tells the loop to wait 1 second before trying again
    end

    -- Live inventory text value capture
    local megaCount = getBoxCount("Mega Summer Random Box")
    local rareCount = getBoxCount("Rare Summer Random Box")
    local normalCount = getBoxCount("Normal Summer Random Box")
    
    if megaCount > 0 then
        local batchSize = math.clamp(megaCount, 1, MAX_BATCH)
        fireChestPacket(batchSize, 22, "Mega Summer Random Box")
        return CHEST_INTERVAL
        
    elseif rareCount > 0 then
        local batchSize = math.clamp(rareCount, 1, MAX_BATCH)
        fireChestPacket(batchSize, 22, "Rare Summer Random Box")
        return CHEST_INTERVAL
        
    elseif normalCount > 0 then
        local batchSize = math.clamp(normalCount, 1, MAX_BATCH)
        fireChestPacket(batchSize, 24, "Normal Summer Random Box")
        return CHEST_INTERVAL
    end
    
    return 1.0 -- No boxes found; wait 1 second before checking UI elements again
end

-- Non-blocking constant execution loop
task.spawn(function()
    while true do
        local waitTime = executeChestCycle()
        task.wait(waitTime)
    end
end)
print("AutoChest: Background loop started. Use your button to toggle the feature on/off.")