-- ===== AUTO-DEVICE LOGIC =====

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNetEvent = ReplicatedStorage:WaitForChild("ByteNetReliable")

local BIOME_INTERVAL = 30 * 60  -- 30 minutes
local STRANGE_INTERVAL = 20 * 60  -- 20 minutes

local autoDeviceEnabled = true -- Global macro state variable from your script

-- Raw ByteNet byte definitions
local STRANGE_BYTES = { 34, 1, 0, 0, 0, 18, 0, 83, 116, 114, 97, 110, 103, 101, 32, 67, 111, 110, 116, 114, 111, 108, 108, 101, 114 }
local BIOME_BYTES = { 34, 1, 0, 0, 0, 16, 0, 66, 105, 111, 109, 101, 32, 82, 97, 110, 100, 111, 109, 105, 122, 101, 114 }

-- Universal encoder to prepare memory arrays for network deployment
local function firePacket(byteArray)
	local packetBuffer = buffer.create(#byteArray)
	for i = 1, #byteArray do
		buffer.writeu8(packetBuffer, i - 1, byteArray[i])
	end
	ByteNetEvent:FireServer(packetBuffer, nil)
end

-- Independent, non-blocking execution threads for both devices
local function runBiomeRandomizerLoop()
	while true do
		if autoDeviceEnabled then
			firePacket(BIOME_BYTES)
		end
		task.wait(BIOME_INTERVAL)
	end
end

local function runStrangeControllerLoop()
	while true do
		if autoDeviceEnabled then
			firePacket(STRANGE_BYTES)
		end
		task.wait(STRANGE_INTERVAL)
	end
end

-- Fire immediate execution on activation
task.spawn(function()
	if autoDeviceEnabled then
		firePacket(BIOME_BYTES)
		task.wait(0.5) -- Tiny safety interval to prevent frame congestion
		firePacket(STRANGE_BYTES)
	end
end)

-- Initialize continuous loops
task.spawn(runBiomeRandomizerLoop)
task.spawn(runStrangeControllerLoop)
