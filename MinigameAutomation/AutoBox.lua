-- Configuration Constants
local CHEST_INTERVAL = 6.5
local MAX_BATCH = 10

-- External state control (Toggle this to true/false via your button interface)
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

-- Primary non-blocking background scanning engine
local function runAutoChestLoop()
    while true do
        if _G.autoChestEnabled then
            -- Live inventory text value capture
            local megaCount = getBoxCount("Mega Summer Random Box")
            local rareCount = getBoxCount("Rare Summer Random Box")
            local normalCount = getBoxCount("Normal Summer Random Box")
            
            if megaCount > 0 then
                local batchSize = math.clamp(megaCount, 1, MAX_BATCH)
                fireChestPacket(batchSize, 22, "Mega Summer Random Box")
                task.wait(CHEST_INTERVAL)
                
            elseif rareCount > 0 then
                local batchSize = math.clamp(rareCount, 1, MAX_BATCH)
                fireChestPacket(batchSize, 22, "Rare Summer Random Box")
                task.wait(CHEST_INTERVAL)
                
            elseif normalCount > 0 then
                local batchSize = math.clamp(normalCount, 1, MAX_BATCH)
                fireChestPacket(batchSize, 24, "Normal Summer Random Box")
                task.wait(CHEST_INTERVAL)
                
            else
                -- No boxes left in inventory; rest the thread slightly before checking again
                task.wait(1.0)
            end
        else
            -- Feature is turned off; wait a short interval to prevent high CPU utilization
            task.wait(0.5)
        end
    end
end

-- Start the constant background routine cleanly
task.spawn(runAutoChestLoop)
