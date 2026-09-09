-- ===== AUTO-DEVICE LOGIC (PACKET INJECTION ONLY) =====

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

local BIOME_INTERVAL = 30 * 60  -- 30 minutes
local STRANGE_INTERVAL = 20 * 60  -- 20 minutes

-- Generic function to build and send the requested byte stream
local function fireDevicePacket(bytes)
    local packetBuffer = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(packetBuffer, i - 1, bytes[i])
    end
    ByteNetEvent:FireServer(packetBuffer, nil)
end

local function runBiomeRandomizerLoop()
    while true do
        if autoDeviceEnabled then
            -- Direct packet injection for Biome Randomizer
            fireDevicePacket({ 34, 1, 0, 0, 0, 16, 0, 66, 105, 111, 109, 101, 32, 82, 97, 110, 100, 111, 109, 105, 122, 101, 114 })
        end
        task.wait(BIOME_INTERVAL)
    end
end

local function runStrangeControllerLoop()
    while true do
        if autoDeviceEnabled then
            -- Direct packet injection for Strange Controller
            fireDevicePacket({ 34, 1, 0, 0, 0, 18, 0, 83, 116, 114, 97, 110, 103, 101, 32, 67, 111, 110, 116, 114, 111, 108, 108, 101, 114 })
        end
        task.wait(STRANGE_INTERVAL)
    end
end

-- Start the constant non-blocking loops
task.spawn(runBiomeRandomizerLoop)
task.spawn(runStrangeControllerLoop)
