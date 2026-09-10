-- ===== BIOME LOGS, GUI SYSTEM & WEBHOOK CONTROLLER =====
-- Place this in a LocalScript inside StarterPlayerScripts (or similar).
-- Requires an exploit / environment that supports `request`/`syn.request`/`http_request`/`firerequest`.

local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean up older interface assets to prevent overlapping loops or memory leaks
if playerGui:FindFirstChild("BiomeTrackerGui") then
	playerGui.BiomeTrackerGui:Destroy()
end

-- Helper to safely escape patterns for string.find
local function escapePattern(str)
	return str:gsub("([^%w])", "%%%1")
end

-- ===== 1. BIOME DEFINITION CONFIG =====
-- Ordered exactly as requested with Wiki colors
local BIOME_CONFIG = {
	{ ID = "Cyberspace",      Color = Color3.fromRGB(0, 100, 255),   Text = "Cyberspace" },
	{ ID = "Dreamspace",      Color = Color3.fromRGB(255, 140, 200), Text = "Dreammetric" },
	{ ID = "Glitched",        Color = Color3.fromRGB(0, 255, 180),   Text = "Glitch" },
	{ ID = "Singularity",     Color = Color3.fromRGB(130, 50, 255),  Text = "Singularity" },
	{ ID = "Null",            Color = Color3.fromRGB(150, 150, 150), Text = "Null" },
	{ ID = "Corruption",      Color = Color3.fromRGB(180, 70, 255),  Text = "Corruption" },
	{ ID = "Heaven",          Color = Color3.fromRGB(255, 230, 100), Text = "Heaven" },
	{ ID = "Starfall",        Color = Color3.fromRGB(90, 160, 255),  Text = "Starfall" },
	{ ID = "Hell",            Color = Color3.fromRGB(255, 60, 60),   Text = "Hell" },
	{ ID = "Sandstorm",       Color = Color3.fromRGB(240, 200, 110), Text = "Sandstorm" },
	{ ID = "Rainy",           Color = Color3.fromRGB(140, 170, 190), Text = "Rainy" },
	{ ID = "Snowy",           Color = Color3.fromRGB(200, 235, 255), Text = "Snowy" },
	{ ID = "Windy",           Color = Color3.fromRGB(170, 255, 230), Text = "Windy" },
	{ ID = "Blazing Sun",     Color = Color3.fromRGB(236, 230, 46),  Text = "Blazing Sun" },
	{ ID = "Incinerator",     Color = Color3.fromRGB(206, 128, 0),   Text = "Incinerator" },
}

-- Operational State Data Storage
local biomeCounters = {}
_G.BiomeFilterStates = {}

for _, config in ipairs(BIOME_CONFIG) do
	biomeCounters[config.ID] = 0
	_G.BiomeFilterStates[config.ID] = true
end

-- ===== 2. BIOME DATA MAPPING =====
-- Map chat phrases → biome IDs (using your exact rules/entries)
local BIOME_DICTIONARY = {
	["A refreshing and cool wind passes through the world"] = "Windy",
	["White snow and cold begin to cover the surroundings"] = "Snowy",
	["Strong winds and showers sweep through the world"]    = "Rainy",
	["A harsh Sand Storm blocks your path"]                = "Sandstorm",
	["A strong and violent energy of chaos overtakes the world"] = "Hell",
	["Beautiful and dreamy starlight pours into the world"] = "Starfall",
	["A hand of angel leads you into divine place"]        = "Heaven",
	["Poisonous pollution spreads throughout the world"]   = "Corruption",
	["It's too dark here"]                                 = "Null",
	["Unexpected error occurred. [Code 404]"]              = "Glitched",
	["[Code 404] has resolved."]                           = "Normal (Glitched Ended)",
	["You begin to feel sleepy"]                           = "Dreamspace",
	["Waking up"]                                          = "Normal (Dreamspace Ended)",
	["Signal_Received | From: Island_SOL"]                 = "Cyberspace",
	["Signal Lost."]                                       = "Normal (Cyberspace Ended)",
	["The Singularity pulls in everything, including you"] = "Singularity",
	["The hot sunlight begins to shine on you"]            = "Blazing Sun",
	["It's hotter than usual today! It's a heatwave!"]     = "Incinerator",
}

-- ===== 3. LIQUID GLASS UI STYLING HELPERS =====
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
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 160, 180)),
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.75),
		NumberSequenceKeypoint.new(1, 0.90),
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

-- ===== 4. MAIN GUI CONSTRUCTION =====
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

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Biome Counter"
titleLabel.TextColor3 = Color3.fromRGB(240, 243, 250)
titleLabel.Font = Enum.Font.GothamMedium
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.LayoutOrder = 1
titleLabel.Parent = frame

-- Current Biome Label
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

-- Button Grid Container
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

-- Tally UI Core: Button Node Generator
local uiButtons = {}

for idx, config in ipairs(BIOME_CONFIG) do
	local biomeBtn = Instance.new("TextButton")
	biomeBtn.Name = config.ID .. "Button"
	biomeBtn.Size = UDim2.new(1, 0, 0, 32)
	biomeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	biomeBtn.BackgroundTransparency = 0.94
	biomeBtn.BorderSizePixel = 0
	biomeBtn.Text = string.format(" %s: 0 [ON]", config.Text)
	biomeBtn.TextColor3 = config.Color
	biomeBtn.Font = Enum.Font.GothamMedium
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
		biomeBtn.Text = string.format(" %s: %d [%s]", config.Text, biomeCounters[config.ID], modeStr)
	end)

	uiButtons[config.ID] = biomeBtn
end

-- ===== 5. WEBHOOK PANEL MODULE =====
local webhookContainer = Instance.new("Frame")
webhookContainer.Name = "WebhookPanel"
webhookContainer.Size = UDim2.new(1, 0, 0, 0)
webhookContainer.AutomaticSize = Enum.AutomaticSize.Y
webhookContainer.BackgroundTransparency = 1
webhookContainer.LayoutOrder = 4
webhookContainer.Parent = frame

local webLayout = Instance.new("UIListLayout")
webLayout.SortOrder = Enum.SortOrder.LayoutOrder
webLayout.Padding = UDim.new(0, 8)
webLayout.Parent = webhookContainer

-- Header
local panelHeader = Instance.new("TextLabel")
panelHeader.Name = "PanelHeader"
panelHeader.Size = UDim2.new(1, 0, 0, 16)
panelHeader.BackgroundTransparency = 1
panelHeader.Text = "DISCORD REMOTE NOTIFICATIONS"
panelHeader.TextColor3 = Color3.fromRGB(110, 118, 138)
panelHeader.Font = Enum.Font.GothamBold
panelHeader.TextSize = 10
panelHeader.TextXAlignment = Enum.TextXAlignment.Left
panelHeader.LayoutOrder = 0
panelHeader.Parent = webhookContainer

-- Webhook URL Input
local urlInput = Instance.new("TextBox")
urlInput.Name = "UrlInputField"
urlInput.Size = UDim2.new(1, 0, 0, 32)
urlInput.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
urlInput.BorderSizePixel = 0
urlInput.PlaceholderText = "Paste Discord Webhook URL..."
urlInput.Text = ""
urlInput.ClearTextOnFocus = false
urlInput.TextColor3 = Color3.fromRGB(240, 243, 250)
urlInput.PlaceholderColor3 = Color3.fromRGB(75, 82, 98)
urlInput.Font = Enum.Font.GothamMedium
urlInput.TextSize = 12
urlInput.TextTruncate = Enum.TextTruncate.AtEnd
urlInput.LayoutOrder = 1
urlInput.Parent = webhookContainer
addCorner(urlInput, 6)
addGlassStroke(urlInput, 0.4, 1)

-- Private Server Link Input
local psLinkInput = Instance.new("TextBox")
psLinkInput.Name = "PsLinkInputField"
psLinkInput.Size = UDim2.new(1, 0, 0, 32)
psLinkInput.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
psLinkInput.BorderSizePixel = 0
psLinkInput.PlaceholderText = "Paste Private Server Link Here..."
psLinkInput.Text = ""
psLinkInput.ClearTextOnFocus = false
psLinkInput.TextColor3 = Color3.fromRGB(240, 243, 250)
psLinkInput.PlaceholderColor3 = Color3.fromRGB(75, 82, 98)
psLinkInput.Font = Enum.Font.GothamMedium
psLinkInput.TextSize = 12
psLinkInput.TextTruncate = Enum.TextTruncate.AtEnd
psLinkInput.LayoutOrder = 2
psLinkInput.Parent = webhookContainer
addCorner(psLinkInput, 6)
addGlassStroke(psLinkInput, 0.4, 1)

-- Action Row (Test + Accept)
local actionRow = Instance.new("Frame")
actionRow.Name = "ActionRow"
actionRow.Size = UDim2.new(1, 0, 0, 30)
actionRow.BackgroundTransparency = 1
actionRow.LayoutOrder = 3
actionRow.Parent = webhookContainer

local rowLayout = Instance.new("UIListLayout")
rowLayout.FillDirection = Enum.FillDirection.Horizontal
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.Padding = UDim.new(0, 8)
rowLayout.Parent = actionRow

local testBtn = Instance.new("TextButton")
testBtn.Name = "TestButton"
testBtn.Size = UDim2.new(0.5, -4, 1, 0)
testBtn.BackgroundColor3 = Color3.fromRGB(48, 52, 66)
testBtn.BackgroundTransparency = 0.2
testBtn.Text = "Test Webhook"
testBtn.TextColor3 = Color3.fromRGB(250, 250, 250)
testBtn.TextTransparency = 0.6
testBtn.Font = Enum.Font.GothamBold
testBtn.TextSize = 11
testBtn.LayoutOrder = 1
testBtn.Parent = actionRow
addCorner(testBtn, 6)

local acceptBtn = Instance.new("TextButton")
acceptBtn.Name = "AcceptButton"
acceptBtn.Size = UDim2.new(0.5, -4, 1, 0)
acceptBtn.BackgroundColor3 = Color3.fromRGB(28, 115, 75)
acceptBtn.BackgroundTransparency = 0.3
acceptBtn.Text = "Accept URL"
acceptBtn.TextColor3 = Color3.fromRGB(250, 250, 250)
acceptBtn.TextTransparency = 0.6
acceptBtn.Font = Enum.Font.GothamBold
acceptBtn.TextSize = 11
acceptBtn.LayoutOrder = 2
acceptBtn.Parent = actionRow
addCorner(acceptBtn, 6)

-- Global/Script Reference Variables
local liveWebhookUrl = ""
local manualPrivateServerLink = "Not Provided"

-- ===== 6. INTERACTIVE BUTTON STYLES =====
local function applyInteractiveStyles(btn, activeColor)
	local defaultColor = btn.BackgroundColor3

	btn.MouseEnter:Connect(function()
		if btn.TextTransparency == 0 then
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = activeColor}):Play()
		end
	end)

	btn.MouseLeave:Connect(function()
		if btn.TextTransparency == 0 then
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor}):Play()
		end
	end)

	btn.MouseButton1Down:Connect(function()
		if btn.TextTransparency == 0 then
			TweenService:Create(btn, TweenInfo.new(0.05), {
				Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset, 1, -2)
			}):Play()
		end
	end)

	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {
			Size = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset, 1, 0)
		}):Play()
	end)
end

applyInteractiveStyles(testBtn, Color3.fromRGB(64, 70, 89))
applyInteractiveStyles(acceptBtn, Color3.fromRGB(36, 148, 96))

-- ===== 7. WEBHOOK SENDING HELPER =====
local function sendDiscordWebhook(targetUrl, payloadTable)
	if not targetUrl or targetUrl == "" then
		return
	end

	task.spawn(function()
		local payload = HttpService:JSONEncode(payloadTable)

		local requestFunc = firerequest
			or request
			or http_request
			or (syn and syn.request)

		if requestFunc then
			requestFunc({
				Url = targetUrl,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = payload,
			})
		end
	end)
end

-- ===== 8. INPUT VALIDATION =====
local function validateUrlInput()
	local cleanText = urlInput.Text:gsub("%s+", "")
	local isValid = string.sub(cleanText, 1, 8) == "https://" and #cleanText > 15

	local targetTransparency = isValid and 0 or 0.6
	TweenService:Create(testBtn, TweenInfo.new(0.2), {TextTransparency = targetTransparency}):Play()
	TweenService:Create(acceptBtn, TweenInfo.new(0.2), {TextTransparency = targetTransparency}):Play()

	return isValid
end

urlInput:GetPropertyChangedSignal("Text"):Connect(validateUrlInput)

-- ===== 9. TEST WEBHOOK (RANDOM MOCK EMBED) =====
testBtn.MouseButton1Click:Connect(function()
	if not validateUrlInput() then
		return
	end

	local dummyBiomes = {
		{ name = "Glitched",   color = 5145599,  icon = "https://cdn.discordapp.com/embed/avatars/0.png" },
		{ name = "Dreamspace", color = 16720436, icon = "https://cdn.discordapp.com/embed/avatars/1.png" },
		{ name = "Cyberspace", color = 9044161,  icon = "https://cdn.discordapp.com/embed/avatars/2.png" },
	}

	local picked = dummyBiomes[math.random(1, #dummyBiomes)]
	local currentPSLink = psLinkInput.Text ~= "" and psLinkInput.Text or "https://roblox.com"

	local mockEmbed = {
		content = "📢 @" .. picked.name .. " Logger Ping",
		embeds = {
			{
				title = picked.name,
				color = picked.color,
				thumbnail = {
					url = picked.icon,
				},
				fields = {
					{ name = "Biome", value = "✨ " .. picked.name, inline = true },
					{ name = "Author", value = "Roblox User", inline = true },
					{ name = "Private Server Link", value = currentPSLink, inline = false },
				},
			},
		},
	}

	sendDiscordWebhook(urlInput.Text, mockEmbed)
end)

-- ===== 10. ACCEPT & SAVE WEBHOOK + PS LINK =====
acceptBtn.MouseButton1Click:Connect(function()
	if not validateUrlInput() then
		return
	end

	liveWebhookUrl = urlInput.Text
	manualPrivateServerLink = psLinkInput.Text ~= "" and psLinkInput.Text or "Not Provided"

	acceptBtn.Text = "✓ Data Saved"
	task.delay(1.5, function()
		acceptBtn.Text = "Accept URL"
	end)
end)

-- ===== 11. REAL-TIME BIOME DETECTION & LOGGING =====
local function handleBiomeDetection(detectedString)
	-- Handle "Normal" states
	if string.find(detectedString, "Normal") then
		currentBiomeLabel.Text = "Current: Normal"
		currentBiomeLabel.TextColor3 = Color3.fromRGB(160, 168, 185)
		return
	end

	local targetID = detectedString
	if biomeCounters[targetID] == nil then
		return
	end

	biomeCounters[targetID] = biomeCounters[targetID] + 1

	local matchConfig = nil
	for _, config in ipairs(BIOME_CONFIG) do
		if config.ID == targetID then
			matchConfig = config
			break
		end
	end

	if not matchConfig then
		return
	end

	-- Update current biome label
	currentBiomeLabel.Text = "Current: " .. matchConfig.Text
	currentBiomeLabel.TextColor3 = matchConfig.Color

	-- Update button text
	local activeMode = _G.BiomeFilterStates[targetID] and "ON" or "OFF"
	uiButtons[targetID].Text = string.format(
		" %s: %d [%s]",
		matchConfig.Text,
		biomeCounters[targetID],
		activeMode
	)

	-- Send webhook if enabled
	if _G.BiomeFilterStates[targetID] and liveWebhookUrl and liveWebhookUrl ~= "" then
		local embedColor = math.floor(matchConfig.Color.R * 255) * 65536
			+ math.floor(matchConfig.Color.G * 255) * 256
			+ math.floor(matchConfig.Color.B * 255)

		-- Dynamic thumbnail (you can customize URLs per biome here)
		local selectedThumbnail = "https://cdn.discordapp.com/embed/avatars/0.png"
		local lowerText = string.lower(matchConfig.Text)

		if lowerText:find("dreamspace") then
			selectedThumbnail = "https://cdn.discordapp.com/embed/avatars/1.png"
		elseif lowerText:find("cyberspace") then
			selectedThumbnail = "https://cdn.discordapp.com/embed/avatars/2.png"
		end

		local currentPSLink = (manualPrivateServerLink ~= "Not Provided" and manualPrivateServerLink)
			or "https://roblox.com"

		local logEmbed = {
			content = string.format("📢 @%s Logger Ping", matchConfig.Text),
			embeds = {
				{
					title = matchConfig.Text,
					color = embedColor,
					thumbnail = {
						url = selectedThumbnail,
					},
					fields = {
						{ name = "Biome", value = "✨ " .. matchConfig.Text, inline = true },
						{ name = "Author", value = "Roblox User", inline = true },
						{ name = "Private Server Link", value = currentPSLink, inline = false },
					},
				},
			},
		}

		sendDiscordWebhook(liveWebhookUrl, logEmbed)
	end
end

-- ===== 12. CHAT HOOK (TextChatService) =====
if TextChatService then
	TextChatService.MessageReceived:Connect(function(message)
		local chatText = message.Text

		for alertPhrase, biomeId in pairs(BIOME_DICTIONARY) do
			if string.find(chatText, escapePattern(alertPhrase)) then
				handleBiomeDetection(biomeId)
				break
			end
		end
	end)
end