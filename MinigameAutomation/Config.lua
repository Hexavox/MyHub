-- CONFIG

local WATERMELON_NAME = "watermelon"
local SCAN_INTERVAL = 1

local VISUAL_FOLDER_NAME = "_DevWatermelonVisuals"
local PATH_VISUAL_FOLDER_NAME = "_PathVisuals"

local BOX_COLOR = Color3.fromRGB(220, 225, 235)
local OUTLINE_COLOR = Color3.fromRGB(255, 255, 255)
local PATH_COLOR = Color3.fromRGB(180, 210, 255)

local MAX_CONSECUTIVE_FAILURES = 5
local PATH_OPTIONS = {
    AgentRadius = 2,
    AgentHeight = 5,
    AgentCanJump = true,
    WaypointSpacing = 4,
}