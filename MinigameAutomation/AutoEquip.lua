-- ===== AutoEquip_Optimized.lua =====
-- AUTO EQUIP ABYSSAL HUNTER (PACKET INJECTION ONLY)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

local AUTO_EQUIP_RETRY_INTERVAL = 30
local AUTO_EQUIP_AURA_NAME = "Abyssal Hunter"

-- Local runtime tracking variable
local autoEquipEnabled = true 

-- Packs and dispatches the raw { 135, 62, 0, 0 } buffer directly to the engine
local function fireEquipPacket()
	local bytes = { 135, 62, 0, 0 }
	local packetBuffer = buffer.create(#bytes)
	for i = 1, #bytes do
		buffer.writeu8(packetBuffer, i - 1, bytes[i])
	end
	ByteNetEvent:FireServer(packetBuffer, nil)
end

local function tryEquipAbyssalHunter()
	if not autoEquipEnabled or not LocalPlayer.Character then
		return
	end

	-- Checks character instance directly, completely bypassing screen GUI elements
	local currentAura = LocalPlayer.Character:FindFirstChild(AUTO_EQUIP_AURA_NAME)
	
	if not currentAura then
		fireEquipPacket()
	end
end

-- Non-blocking constant execution loop
task.spawn(function()
	while true do
		tryEquipAbyssalHunter()
		task.wait(AUTO_EQUIP_RETRY_INTERVAL)
	end
end)
