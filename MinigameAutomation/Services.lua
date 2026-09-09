-- SERVICES

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Event = game:GetService("ReplicatedStorage").ByteNetReliable

local Camera = Workspace:FindFirstChildOfClass("Camera")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local playerGui2 = Players.LocalPlayer:WaitForChild("PlayerGui")

local TOGGLE_KEY = Enum.KeyCode.LeftAlt

local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer