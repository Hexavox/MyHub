-- ===== AUTO-FISHING LOGIC (OUTGOING PACKET INTERCEPTION + SPAM) =====
-- im so fucking cool

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

-- Configuration Constants
local REEL_DURATION = 5.4   -- Total duration to spam the reel packet
local SPAM_INTERVAL = 0.05  -- Roughly 100 times over 5.4 seconds (~0.054s)
local RESTART_DELAY = 3.0  -- Cooldown after hooking before resetting back to step 1

local isFishingActive = false

print("[AutoFish]: Fixed script monitoring outgoing packets + reel spamming active. Toggle via autoFishEnabled.")

-- Generic function to build and send the requested byte stream
local function fireFishingPacket(bytes)
    local packetBuffer = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(packetBuffer, i - 1, bytes[i])
    end
    pcall(function()
        ByteNetEvent:FireServer(packetBuffer, nil)
    end)
end

-- Core casting loop (Step 1 & Loop Reset Handling)
local function runAutoFishLoop()
    while true do
        if autoFishEnabled and not isFishingActive then
            isFishingActive = true
            -- Step 1: Cast the rod / Press fish on the menu (Fires once)
            fireFishingPacket({ 200, 36, 0, 57, 48, 49, 101, 102, 49, 49, 101, 45, 52, 51, 51, 99, 45, 52, 57, 52, 98, 45, 97, 50, 48, 52, 45, 100, 101, 54, 57, 53, 57, 51, 56, 55, 54, 102, 50 })
        end
        task.wait(1.0)
    end
end

-- Hooking the outgoing network layer to catch when the game drops the initial reel trigger
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Filter for your client calling FireServer on the ByteNet remote
    if autoFishEnabled and self == ByteNetEvent and (method == "FireServer" or method == "fireServer") then
        local packetBuffer = args
        
        -- Analyze the buffer content of your outgoing packet
        if typeof(packetBuffer) == "buffer" and buffer.len(packetBuffer) >= 2 then
            local firstByte = buffer.readu8(packetBuffer, 0)
            local secondByte = buffer.readu8(packetBuffer, 1)
            
            -- Detect the explicit "3, 36" signature of the outgoing reel packet
            if firstByte == 3 and secondByte == 36 then
                -- Check an internal state flag so your script's own spammed packets don't re-trigger this block infinitely
                if isFishingActive and not _G.IsSpammingReel then
                    _G.IsSpammingReel = true
                    
                    -- Spawn off-thread so the main network stream doesn't lag out
                    task.spawn(function()
                        local startTime = os.clock()
                        
                        -- Keep spamming until the 5.4 seconds run out
                        while os.clock() - startTime < REEL_DURATION and autoFishEnabled do
                            fireFishingPacket({ 3, 36, 0, 100, 52, 48, 57, 49, 54, 56, 97, 45, 102, 97, 52, 98, 45, 52, 49, 54, 56, 45, 56, 48, 98, 102, 45, 98, 50, 48, 57, 50, 57, 98, 97, 55, 102, 55, 51 })
                            task.wait(SPAM_INTERVAL)
                        end
                        
                        _G.IsSpammingReel = false
                        
                        -- Final Step: Use the hook packet now that spam duration is over
                        if autoFishEnabled then
                            fireFishingPacket({ 182, 1 })
                            
                            -- Cooldown block before allowing Step 1 to cast again
                            task.wait(RESTART_DELAY)
                            isFishingActive = false
                        else
                            isFishingActive = false
                        end
                    end)
                end
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Start independent automation thread
task.spawn(runAutoFishLoop)
