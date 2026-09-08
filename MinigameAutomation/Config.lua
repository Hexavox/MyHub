-- Config.lua (ModuleScript)
return {
	WATERMELON_NAME = "watermelon",
	SCAN_INTERVAL = 1,

	VISUAL_FOLDER_NAME = "_DevWatermelonVisuals",
	PATH_VISUAL_FOLDER_NAME = "_PathVisuals",

	BOX_COLOR = Color3.fromRGB(220, 225, 235),
	OUTLINE_COLOR = Color3.fromRGB(255, 255, 255),
	PATH_COLOR = Color3.fromRGB(180, 210, 255),

	MAX_CONSECUTIVE_FAILURES = 5,
	PATH_OPTIONS = {
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		WaypointSpacing = 4,
	},
}