-- State.lua (ModuleScript)
local State = {
	boxesEnabled = true,
	pathfindingEnabled = false,
	viewPathEnabled = false,
	autoJumpEnabled = true,

	trackedWatermelons = {},

	routineToken = 0,
	activeRoutine = false,
	consecutivePathFailures = 0,

	gui = nil,          -- will hold main frame, buttons, labels, etc.
	visualFolder = nil,
	pathVisualFolder = nil,
}

return State