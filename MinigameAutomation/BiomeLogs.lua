-- ===== BIOME LOGS, GUI SYSTEM & WEBHOOK CONTROLLER =====
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean up older interface assets to prevent overlapping loops or memory leaks
if playerGui:FindFirstChild("BiomeTrackerGui") then
    playerGui.BiomeTrackerGui:Destroy()
end

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
    { ID = "Windy",       Color = Color3.fromRGB(170, 255, 230),  Text = "Windy" },
    { ID = "Blazing Sun", Color = Color3.fromRGB(236, 230, 46),   Text = "Blazing Sun" },
    { ID = "Incinerator", Color = Color3.fromRGB(206, 128, 0),    Text = "Incinerator" }
}

-- Operational State Data Storage
local biomeCounters = {}
_G.BiomeFilterStates = {} 
local liveWebhookUrl = "" -- Kept strictly local inside this upvalue space for security

for _, config in ipairs(BIOME_CONFIG) do
    biomeCounters[config.ID] = 0
    _G.BiomeFilterStates[config.ID] = true 
end

-- Biome Data Mapping Table (Using your exact updated rules and entries)
local BIOME_DICTIONARY = {
    ["A refreshing and cool wind passes through the world"] = "Windy",
    ["White snow and cold begin to cover the surroundings"] = "Snowy",
    ["Strong winds and showers sweep through the world"] = "Rainy",
    ["A harsh Sand Storm blocks your path"] = "Sandstorm",
    ["A strong and violent energy of chaos overtakes the world"] = "Hell",
    ["Beautiful and dreamy starlight pours into the world"] = "Starfall",
    ["A hand of angel leads you into divine place"] = "Heaven",
    ["Poisonous pollution spreads throughout the world"] = "Corruption",
    ["It's too dark here"] = "Null",
    ["Unexpected error occurred. [Code 404]"] = "Glitched",
    ["[Code 404] has resolved."] = "Normal (Glitched Ended)",
    ["You begin to feel sleepy"] = "Dreamspace",
    ["Waking up"] = "Normal (Dreamspace Ended)",
    ["Signal_Received | From: Island_SOL"] = "Cyberspace",
    ["Signal Lost."] = "Normal (Cyberspace Ended)",
    ["The Singularity pulls in everything, including you"] = "Singularity",
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

local function addTextOutline(parent)
    local textStroke = Instance.new("UIStroke")
    textStroke.Color = Color3.fromRGB(10, 12, 16)
    textStroke.Thickness = 1.2
    textStroke.Transparency = 0.2
    textStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    textStroke.Parent = parent
end

-- 3. INTERACTIVE MAIN WINDOW BUILDER
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
    addTextOutline(biomeBtn)

    biomeBtn.MouseButton1Click:Connect(function()
        _G.BiomeFilterStates[config.ID] = not _G.BiomeFilterStates[config.ID]
        local modeStr = _G.BiomeFilterStates[config.ID] and "ON" or "OFF"
        biomeBtn.BackgroundTransparency = _G.BiomeFilterStates[config.ID] and 0.94 or 0.97
        biomeBtn.Text = string.format("  %s: %d  [%s]", config.Text, biomeCounters[config.ID], modeStr)
    end)

    uiButtons[config.ID] = biomeBtn
end

-- ===== NEW SECURE WEBHOOK PANEL MODULE SETUP =====
local webhookContainer = Instance.new("Frame")
webhookContainer.Name = "WebhookPanel"
webhookContainer.Size = UDim2.new(1, 0, 0, 0)
webhookContainer.AutomaticSize = Enum.AutomaticSize.Y
webhookContainer.BackgroundTransparency = 1
webhookContainer.LayoutOrder = 4
webhookContainer.Parent = frame

local webLayout = Instance.new("UIListLayout")
webLayout.SortOrder = Enum.SortOrder.LayoutOrder
webLayout.Padding = UDim.new(0, 5)
webLayout.Parent = webhookContainer

local urlInput = Instance.new("TextBox")
urlInput.Name = "UrlInputField"
urlInput.Size = UDim2.new(1, 0, 0, 28)
urlInput.BackgroundColor3 = Color3.fromRGB(30, 33, 43)
urlInput.BorderSizePixel = 0
urlInput.PlaceholderText = "Paste Webhook URL Here..."
urlInput.Text = ""
urlInput.ClearTextOnFocus = false
urlInput.TextColor3 = Color3.fromRGB(230, 235, 245)
urlInput.PlaceholderColor3 = Color3.fromRGB(100, 110, 125)
urlInput.Font = Enum.Font.Gotham
urlInput.TextSize = 11
urlInput.LayoutOrder = 1
urlInput.Parent = webhookContainer
addCorner(urlInput, 6)
addGlassStroke(urlInput, 0.8, 1)

local actionRow = Instance.new("Frame")
actionRow.Name = "ActionRow"
actionRow.Size = UDim2.new(1, 0, 0, 26)
actionRow.BackgroundTransparency = 1
actionRow.LayoutOrder = 2
actionRow.Parent = webhookContainer

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.Padding = UDim.new(0, 6)
rowLayout.Parent = actionRow

local testBtn = Instance.new("TextButton")
testBtn.Name = "TestButton"
testBtn.Size = UDim2.new(0.5, -3, 1, 0)
testBtn.BackgroundColor3 = Color3.fromRGB(60, 65, 80)
testBtn.BackgroundTransparency = 0.4
testBtn.Text = "Test Webhook"
testBtn.TextColor3 = Color3.fromRGB(200, 205, 215)
testBtn.TextTransparency = 0.6 -- Greyed out initially
testBtn.Font = Enum.Font.GothamMedium
testBtn.TextSize = 11
testBtn.LayoutOrder = 1
testBtn.Parent = actionRow
addCorner(testBtn, 6)

local acceptBtn = Instance.new("TextButton")
acceptBtn.Name = "AcceptButton"
acceptBtn.Size = UDim2.new(0.5, -3, 1, 0)
acceptBtn.BackgroundColor3 = Color3.fromRGB(45, 140, 90)
acceptBtn.BackgroundTransparency = 0.4
acceptBtn.Text = "Accept URL"
acceptBtn.TextColor3 = Color3.fromRGB(200, 205, 215)
acceptBtn.TextTransparency = 0.6 -- Greyed out initially
acceptBtn.Font = Enum.Font.GothamMedium
acceptBtn.TextSize = 11
acceptBtn.LayoutOrder = 2
acceptBtn.Parent = actionRow
addCorner(acceptBtn, 6)

-- Helper to safely send requests to the server console executor link
local function sendDiscordWebhook(targetUrl, contentString)
	if not targetUrl or targetUrl == "" then return end
	task.spawn(function()
		local payload = HttpService:JSONEncode({content = contentString})
		-- Using standard executor request implementations (wraps request/http.request/syn.request)
		local requestFunc = firerequest or request or http_request or (syn and syn.request)
		if requestFunc then
			requestFunc({Url = targetUrl,Method = "POST",Headers = {["Content-Type"] = "application/json"},Body = payload})
		end
	end)
end

-- Handles input changes to safely un-grey out choices when text contains elements
local function validateUrlInput()
	local cleanText = urlInput.Text:gsub("%s+", "")
	local isValid = string.sub(cleanText, 1, 8) == "https://" and #cleanText > 15

	if isValid then
		testBtn.TextTransparency = 0
		acceptBtn.TextTransparency = 0
	else
		testBtn.TextTransparency = 0.6
		acceptBtn.TextTransparency = 0.6
	end

	return isValid
end

urlInput:GetPropertyChangedSignal("Text"):Connect(validateUrlInput)

testBtn.MouseButton1Click:Connect(function()
	if validateUrlInput() then
		sendDiscordWebhook(urlInput.Text, "🧪 [Biome Tracker]: This is a test alert transmission! Webhook is working perfectly.")
	end
end)

acceptBtn.MouseButton1Click:Connect(function()
	if validateUrlInput() then
		liveWebhookUrl = urlInput.Text
		acceptBtn.Text = "✓ URL Accepted"
		task.delay(1.5, function()
			accept Btn.Text = "Accept URL"
		end)
	end
end)

-- 4. REAL-TIME DATA PROCESSING PIPELIN
local function handleBiomeDetection(detectedString)
	if string.find(detectedString, "Normal") then
		currentBiomeLabel.Text = "Current: Normal"
		currentBiomeLabel.TextColor3 = Color3.fromRGB(160, 168, 185)
		return
	end

	local targetID = detectedString

	if biomeCounters[targetID] ~= nil then
		biomeCounters[targetID] += 1

		local matchConfig =
			nil

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
            
            -- If checked ON and a webhook was successfully accepted, send logs
            if _G.BiomeFilterStates[targetID] and liveWebhookUrl ~= "" then
                local logMessage = string.format("🌍 New Biome Discovered: %s (Total Encountered: %d)", matchConfig.Text, biomeCounters[targetID])
                sendDiscordWebhook(liveWebhookUrl, logMessage)
            end
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

print("Biome Tracker fully initiated with readable text outlines and secure Webhook systems!")
