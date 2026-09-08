-- State.lua
return {
	boxesEnabled = true,
	pathfindingEnabled = false,
	viewPathEnabled = false,
	autoJumpEnabled = true,

	trackedWatermelons = {},

	routineToken = 0,
	activeRoutine = false,
	consecutivePathFailures = 0,

	gui = nil,
	visualFolder = nil,
	pathVisualFolder = nil,
}