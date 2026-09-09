-- ===== BIOME LOGS & GUI SYSTEM (PART 1 OF 4) =====
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Helper to safely capture text variations
local function escapePattern(str)
    return str:gsub("([^%w])", "%%%1")
end

-- 1. BIOME DEFINITION CONFIG (Ordered exactly as requested with Wiki colors)
local BIOME_CONFIG = {
    { ID = "Cyberspace",  Color = Color3.fromRGB(0, 100, 255),   Text = "Cyberspace" },
    { ID = "Dreamspace",  Color = Color3.fromRGB(255, 140, 200),  Text = "Dreammetric" }, 
    { ID = "Glitched",    Color = Color3.fromRGB(0, 255, 180),    Text = "Glitch" },
    { ID = "Singularity", Color = Color3.fromRGB(130, 50, 255),   Text = "Singularity" },
    { ID = "Null",        Color = Color3.fromRGB(150, 150, 150),  Text = "Null" },
    { ID = "Corruption",  Color = Color3.fromRGB(180, 70, 255),   Text = "Corruption" },
    { ID = "Heaven",      Color = Color3.fromRGB(255, 230, 100),  Text = "Heaven" },
    { ID = "Starfall",    Color = Color3.fromRGB(90, 160, 255),   Text = "Starfall" },
    { ID = "Hell",        Color = Color3.fromRGB(255, 60, 60),    Text = "Hell" },
    { ID = "Sandstorm",   Color = Color3.fromRGB(240, 200, 110),  Text = "Sandstorm" },
    { ID = "Rainy",       Color = Color3.fromRGB(140, 170, 190),  Text = "Rainy" },
    { ID = "Snowy",       Color = Color3.fromRGB(200, 235, 255),  Text = "Snowy" },
    { ID = "Windy",       Color = Color3.fromRGB(170, 255, 230),  Text = "Windy" }
}

-- Operational State Data Storage
local biomeCounters = {}
_G.BiomeFilterStates = {} 

for _, config in ipairs(BIOME_CONFIG) do
    biomeCounters[config.ID] = 0
    _G.BiomeFilterStates[config.ID] = true 
end
-- ===== BIOME LOGS & GUI SYSTEM (PART 2 OF 4) =====

-- Biome Data Mapping Table (Using your exact updated rules and entries)
local BIOME_DICTIONARY = {
    -- Normal Biomes
    ["A refreshing and cool wind passes through the world"] = "Windy",
    ["White snow and cold begin to cover the surroundings"] = "Snowy",
    ["Strong winds and showers sweep through the world"] = "Rainy",
    ["A harsh Sand Storm blocks your path"] = "Sandstorm",
    ["A strong and violent energy of chaos overtakes the world"] = "Hell",
    ["Beautiful and dreamy starlight pours into the world"] = "Starfall",
    ["A hand of angel leads you into divine place"] = "Heaven",
    ["Poisonous pollution spreads throughout the world"] = "Corruption",
    ["It's too dark here"] = "Null",
    
    -- Rare Biomes
    ["Unexpected error occurred. [Code 404]"] = "Glitched",
    ["[Code 404] has resolved."] = "Normal (Glitched Ended)",
    ["You begin to feel sleepy"] = "Dreamspace",
    ["Waking up"] = "Normal (Dreamspace Ended)",
    ["Signal_Received | From: Island_SOL"] = "Cyberspace",
    ["Signal Lost."] = "Normal (Cyberspace Ended)",
    ["The Singularity pulls in everything, including you"] = "Singularity",
    
    -- Event Biomes
    ["The hot sunlight begins to shine on you"] = "Blazing Sun",
    ["It's hotter than usual today! It's a heatwave!"] = "Incinerator"
}

-- 2. LIQUID GLASS UI STRUCTURING STYLES
local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function addGlassStroke(parent, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = transparency
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
end

local function addGlassGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 160, 180))
    })
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.75),
        NumberSequenceKeypoint.new(1, 0.90)
    })
    gradient.Rotation = 45
    gradient.Parent = parent
end
-- ===== BIOME LOGS & GUI SYSTEM (PART 3 OF 4) =====

-- 3. INTERACTIVE MAIN WINDOW BUILDER
if playerGui:FindFirstChild("BiomeTrackerGui") then
    playerGui.BiomeTrackerGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BiomeTrackerGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(240, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Position = UDim2.new(0.82, 0, 0.20, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui
addCorner(frame, 16)
addGlassStroke(frame, 0.7, 1)
addGlassGradient(frame)

local framePadding = Instance.new("UIPadding")
framePadding.PaddingTop = UDim.new(0, 12)
framePadding.PaddingBottom = UDim.new(0, 12)
framePadding.PaddingLeft = UDim.new(0, 12)
framePadding.PaddingRight = UDim.new(0, 12)
framePadding.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Biome Counter"
titleLabel.TextColor3 = Color3.fromRGB(240, 243, 250)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.LayoutOrder = 1
titleLabel.Parent = frame

local currentBiomeLabel = Instance.new("TextLabel")
currentBiomeLabel.Name = "CurrentBiomeLabel"
currentBiomeLabel.Size = UDim2.new(1, 0, 0, 16)
currentBiomeLabel.BackgroundTransparency = 1
currentBiomeLabel.Text = "Current: Normal"
currentBiomeLabel.TextColor3 = Color3.fromRGB(160, 168, 185)
currentBiomeLabel.Font = Enum.Font.GothamMedium
currentBiomeLabel.TextSize = 11
currentBiomeLabel.TextXAlignment = Enum.TextXAlignment.Left
currentBiomeLabel.LayoutOrder = 2
currentBiomeLabel.Parent = frame

local biomeStroke = Instance.new("UIStroke")
biomeStroke.Color = Color3.fromRGB(10, 12, 16)      -- Deep dark tone to provide a strong drop shadow
biomeStroke.Thickness = 1.5                         -- Optimal thickness for text under 18pt
biomeStroke.Transparency = 0.2                      -- Subtle blend so it doesn't look harsh
biomeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual -- Ensures the outline binds to text geometry
biomeStroke.Parent = currentBiomeLabel

-- Container Grid Framework
local buttonGridFrame = Instance.new("Frame")
buttonGridFrame.Name = "ButtonGrid"
buttonGridFrame.Size = UDim2.new(1, 0, 0, 0)
buttonGridFrame.AutomaticSize = Enum.AutomaticSize.Y
buttonGridFrame.BackgroundTransparency = 1
buttonGridFrame.LayoutOrder = 3
buttonGridFrame.Parent = frame

local gridLayout = Instance.new("UIListLayout")
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Padding = UDim.new(0, 5)
gridLayout.Parent = buttonGridFrame
-- ===== BIOME LOGS & GUI SYSTEM (PART 4 OF 4) =====

-- Tally UI Core Button Node Generator
local uiButtons = {}
for idx, config in ipairs(BIOME_CONFIG) do
    local biomeBtn = Instance.new("TextButton")
    biomeBtn.Name = config.ID .. "Button"
    biomeBtn.Size = UDim2.new(1, 0, 0, 32)
    biomeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    biomeBtn.BackgroundTransparency = 0.94
    biomeBtn.BorderSizePixel = 0
    biomeBtn.Text = string.format("  %s: 0  [ON]", config.Text)
    biomeBtn.TextColor3 = config.Color
    biomeBtn.Font = Enum.Font.GothamSemibold
    biomeBtn.TextSize = 12
    biomeBtn.TextXAlignment = Enum.TextXAlignment.Left
    biomeBtn.AutoButtonColor = false
    biomeBtn.LayoutOrder = idx
    biomeBtn.Parent = buttonGridFrame
    addCorner(biomeBtn, 8)
    addGlassStroke(biomeBtn, 0.85, 1)

    -- Toggle Engine Handler Hook
    biomeBtn.MouseButton1Click:Connect(function()
        _G.BiomeFilterStates[config.ID] = not _G.BiomeFilterStates[config.ID]
        local modeStr = _G.BiomeFilterStates[config.ID] and "ON" or "OFF"
        
        biomeBtn.BackgroundTransparency = _G.BiomeFilterStates[config.ID] and 0.94 or 0.97
        biomeBtn.Text = string.format("  %s: %d  [%s]", config.Text, biomeCounters[config.ID], modeStr)
    end)

    uiButtons[config.ID] = biomeBtn
end

-- 4. REAL-TIME DATA PROCESSING PIPELINE
local function handleBiomeDetection(detectedString)
    -- Check if it's an ending message first
    if string.find(detectedString, "Normal") then
        currentBiomeLabel.Text = "Current: Normal"
        currentBiomeLabel.TextColor3 = Color3.fromRGB(160, 168, 185)
        return
    end

    -- Process standard tally updates
    local targetID = detectedString
    if biomeCounters[targetID] ~= nil then
        biomeCounters[targetID] += 1
        
        local matchConfig = nil
        for _, config in ipairs(BIOME_CONFIG) do
            if config.ID == targetID then
                matchConfig = config
                break
            end
        end

        if matchConfig then
            currentBiomeLabel.Text = "Current: " .. matchConfig.Text
            currentBiomeLabel.TextColor3 = matchConfig.Color
            
            local activeMode = _G.BiomeFilterStates[targetID] and "ON" or "OFF"
            uiButtons[targetID].Text = string.format("  %s: %d  [%s]", matchConfig.Text, biomeCounters[targetID], activeMode)
        end
    end
end

-- Intercept and map messages via new pipeline
TextChatService.OnIncomingMessage = function(message)
    if message.Text and message.Text ~= "" then
        for pattern, biomeID in pairs(BIOME_DICTIONARY) do
            if string.find(message.Text, escapePattern(pattern)) then
                handleBiomeDetection(biomeID)
                break
            end
        end
    end
end
print("Biome Tracker fully initiated!")
