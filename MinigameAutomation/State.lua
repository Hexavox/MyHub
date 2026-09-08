-- STATE

local boxesEnabled = true
local pathfindingEnabled = false
local viewPathEnabled = false
local autoJumpEnabled = true
local autoEquipEnabled = false

local trackedWatermelons = {}

local routineToken = 0
local activeRoutine = false
local consecutivePathFailures = 0