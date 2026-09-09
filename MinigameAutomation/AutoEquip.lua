-- ===== AutoEquip_Optimized.lua =====
-- AUTO EQUIP ABYSSAL HUNTER (PACKET INJECTION ONLY)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

local AUTO_EQUIP_RETRY_INTERVAL = 30

-- Packs and dispatches a raw byte array directly to the engine
local function fireEquipPacket(bytes)
    local packetBuffer = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(packetBuffer, i - 1, bytes[i])
    end
    ByteNetEvent:FireServer(packetBuffer, nil)
end

local function executeEquipCycle()
    if not autoEquipEnabled then
        return
    end

    -- Send the alternative packet
    fireEquipPacket({ 135, 64, 0, 0 })
    task.wait(0.1) -- Brief delay to let the server process the first swap
    
    -- Immediately swap back to the target aura packet
    fireEquipPacket({ 135, 62, 0, 0 })
end

-- Non-blocking constant execution loop
task.spawn(function()
    while true do
        executeEquipCycle()
        task.wait(AUTO_EQUIP_RETRY_INTERVAL)
    end
end)
