-- StatsWatermark.lua (LocalScript)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local LocalizationService = game:GetService("LocalizationService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

-- ===== MAIN WATERMARK =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatsWatermark"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 170, 0, 95)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, -44)
label.BackgroundTransparency = 1
label.Font = Enum.Font.Code
label.TextSize = 14
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Text = "Loading..."
label.Parent = frame

local perfButton = Instance.new("TextButton")
perfButton.Size = UDim2.new(1, 0, 0, 22)
perfButton.Position = UDim2.new(0, 0, 1, -44)
perfButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
perfButton.Text = "Performance Mode: OFF"
perfButton.Font = Enum.Font.Code
perfButton.TextSize = 12
perfButton.TextColor3 = Color3.fromRGB(0, 255, 120)
perfButton.BorderSizePixel = 0
perfButton.Parent = frame
Instance.new("UICorner", perfButton).CornerRadius = UDim.new(0, 6)

local settingsButton = Instance.new("TextButton")
settingsButton.Size = UDim2.new(1, 0, 0, 22)
settingsButton.Position = UDim2.new(0, 0, 1, -22)
settingsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
settingsButton.Text = "Camera / Sky Settings"
settingsButton.Font = Enum.Font.Code
settingsButton.TextSize = 12
settingsButton.TextColor3 = Color3.fromRGB(120, 180, 255)
settingsButton.BorderSizePixel = 0
settingsButton.Parent = frame
Instance.new("UICorner", settingsButton).CornerRadius = UDim.new(0, 6)

-- ===== SETTINGS PANEL =====
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 220, 0, 280)
panel.Position = UDim2.new(0, 190, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BackgroundTransparency = 0.1
panel.Visible = false
panel.Active = true
panel.Draggable = true
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)

settingsButton.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

local function makeLabel(text, order, parent)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -20, 0, 16)
	lbl.Position = UDim2.new(0, 10, 0, order * 42)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = text
	lbl.Parent = parent
	return lbl
end

local function makeSlider(order, parent, min, max, default, callback)
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 6)
	track.Position = UDim2.new(0, 10, 0, order * 42 + 20)
	track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	track.BorderSizePixel = 0
	track.Parent = parent
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	knob.BorderSizePixel = 0
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local dragging = false
	knob.MouseButton1Down:Connect(function() dragging = true end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local relative = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(relative, 0, 1, 0)
			knob.Position = UDim2.new(relative, 0, 0.5, 0)
			callback(min + (max - min) * relative)
		end
	end)
end

-- FOV
local fovLabel = makeLabel("FOV: 70", 0, panel)
camera.FieldOfView = 70
makeSlider(0, panel, 30, 120, 70, function(value)
	camera.FieldOfView = value
	fovLabel.Text = string.format("FOV: %d", math.floor(value))
end)

-- View offset X
local offsetXLabel = makeLabel("View Offset X: 0", 1, panel)
makeSlider(1, panel, -2, 2, 0, function(value)
	offsetXLabel.Text = string.format("View Offset X: %.1f", value)
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			local o = hum.CameraOffset
			hum.CameraOffset = Vector3.new(value, o.Y, o.Z)
		end
	end
end)

-- View offset Y
local offsetYLabel = makeLabel("View Offset Y: 0", 2, panel)
makeSlider(2, panel, -2, 2, 0, function(value)
	offsetYLabel.Text = string.format("View Offset Y: %.1f", value)
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			local o = hum.CameraOffset
			hum.CameraOffset = Vector3.new(o.X, value, o.Z)
		end
	end
end)

-- Sensitivity
local sensLabel = makeLabel("Mouse Sensitivity: 1.0x", 3, panel)
makeSlider(3, panel, 0.1, 3, 1, function(value)
	sensLabel.Text = string.format("Mouse Sensitivity: %.1fx", value)
	UserSettings():GetService("UserGameSettings").MouseSensitivity = value * 0.5
end)

-- ===== SKY CONTROL =====
local currentSky = nil

local function clearSky()
	local existing = Lighting:FindFirstChildOfClass("Sky")
	if existing then existing:Destroy() end
end

local function applyGreySky()
	clearSky()
	local sky = Instance.new("Sky")
	for _, face in ipairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}) do
		sky[face] = "rbxasset://sky/grey_sky.png"
	end
	sky.Parent = Lighting
	Lighting.Brightness = 1.5
	Lighting.ColorShift_Top = Color3.fromRGB(150, 150, 150)
	Lighting.ColorShift_Bottom = Color3.fromRGB(100, 100, 100)
	Lighting.FogColor = Color3.fromRGB(150, 150, 150)
	Lighting.FogEnd = 800
	currentSky = "grey"
end

local function applyAuroraSky()
	clearSky()
	local sky = Instance.new("Sky")
	sky.SkyboxBk = "rbxassetid://159454299"
	sky.SkyboxDn = "rbxassetid://159454296"
	sky.SkyboxFt = "rbxassetid://159454311"
	sky.SkyboxLf = "rbxassetid://159454304"
	sky.SkyboxRt = "rbxassetid://159454322"
	sky.SkyboxUp = "rbxassetid://159454331"
	sky.StarCount = 3000
	sky.Parent = Lighting

	Lighting.Ambient = Color3.fromRGB(20, 40, 60)
	Lighting.OutdoorAmbient = Color3.fromRGB(30, 60, 90)
	Lighting.ClockTime = 0
	Lighting.Brightness = 1

	local glow = Instance.new("ColorCorrectionEffect")
	glow.Name = "AuroraGlow"
	glow.Parent = Lighting

	currentSky = "aurora"
	task.spawn(function()
		while currentSky == "aurora" do
			local t = tick()
			glow.TintColor = Color3.fromHSV((math.sin(t * 0.1) + 1) / 2 * 0.4 + 0.3, 0.6, 1)
			task.wait(0.1)
		end
	end)
end

local function applyMinecraftSky()
	clearSky()
	local sky = Instance.new("Sky")
	for _, face in ipairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}) do
		sky[face] = "rbxassetid://6444320592"
	end
	sky.Parent = Lighting
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(150, 200, 255)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 200, 255)
	Lighting.ClockTime = 12
	Lighting.FogEnd = 100000
	currentSky = "minecraft"
end

local function applyMoonSky()
	clearSky()
	local sky = Instance.new("Sky")
	sky.MoonTextureId = "rbxasset://sky/moon.jpg"
	sky.MoonAngularSize = 20
	sky.StarCount = 6000
	sky.CelestialBodiesShown = true
	sky.Parent = Lighting

	Lighting.ClockTime = 0
	Lighting.Brightness = 0.5
	Lighting.Ambient = Color3.fromRGB(30, 30, 50)
	Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 40)
	Lighting.FogColor = Color3.fromRGB(10, 10, 20)
	Lighting.FogEnd = 2000
	currentSky = "moon"
end

local function resetSky()
	clearSky()
	local glow = Lighting:FindFirstChild("AuroraGlow")
	if glow then glow:Destroy() end
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(0, 0, 0)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	currentSky = nil
end

makeLabel("Sky:", 4, panel).Position = UDim2.new(0, 10, 0, 180)

local skyOptions = {
	{name = "Grey", fn = applyGreySky},
	{name = "Aurora", fn = applyAuroraSky},
	{name = "Minecraft", fn = applyMinecraftSky},
	{name = "Moon", fn = applyMoonSky},
	{name = "Default", fn = resetSky},
}
for i, opt in ipairs(skyOptions) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 22)
	btn.Position = UDim2.new(0, 10 + ((i - 1) % 5) * 42, 0, 200)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.Text = opt.name
	btn.Font = Enum.Font.Code
	btn.TextSize = 10
	btn.TextColor3 = Color3.fromRGB(120, 200, 255)
	btn.BorderSizePixel = 0
	btn.Parent = panel
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(opt.fn)
end

-- ===== TOGGLE STATE (shared by RightShift and mobile button) =====
local uiVisible = true

local function toggleUI()
	uiVisible = not uiVisible
	frame.Visible = uiVisible
	if not uiVisible then
		panel.Visible = false
	end
end

-- RightShift toggle (PC)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		toggleUI()
	end
end)

-- ===== MOBILE TOGGLE BUTTON =====
local mobileToggle = Instance.new("TextButton")
mobileToggle.Name = "MobileToggle"
mobileToggle.Size = UDim2.new(0, 50, 0, 50)
mobileToggle.Position = UDim2.new(1, -60, 0.5, -25)
mobileToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mobileToggle.BackgroundTransparency = 0.2
mobileToggle.Text = "UI"
mobileToggle.Font = Enum.Font.Code
mobileToggle.TextSize = 14
mobileToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileToggle.BorderSizePixel = 0
mobileToggle.Active = true
mobileToggle.Draggable = true
mobileToggle.Parent = screenGui
Instance.new("UICorner", mobileToggle).CornerRadius = UDim.new(1, 0)

mobileToggle.Visible = UserInputService.TouchEnabled

mobileToggle.MouseButton1Click:Connect(function()
	toggleUI()
	mobileToggle.Text = uiVisible and "UI" or "•"
end)

-- ===== COUNTRY/REGION =====
local country = "Unknown"
local ok, result = pcall(function()
	return LocalizationService.SystemLocaleId or LocalizationService:GetCountryRegionForPlayerAsync(player)
end)
if ok and result then country = result end

-- ===== FPS TRACKING =====
local frameCount, lastCheck, fps = 0, tick(), 0
RunService.RenderStepped:Connect(function()
	frameCount += 1
	local now = tick()
	if now - lastCheck >= 1 then
		fps = frameCount
		frameCount = 0
		lastCheck = now
	end
end)

-- ===== PERFORMANCE MODE =====
local performanceMode = false
local savedSettings = {}

local function setPerformanceMode(enabled)
	performanceMode = enabled
	if enabled then
		savedSettings.GlobalShadows = Lighting.GlobalShadows
		savedSettings.FogEnd = Lighting.FogEnd
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 100000
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				obj.Enabled = false
			end
		end
		perfButton.Text = "Performance Mode: ON"
		perfButton.TextColor3 = Color3.fromRGB(255, 80, 80)
	else
		if savedSettings.GlobalShadows ~= nil then
			Lighting.GlobalShadows = savedSettings.GlobalShadows
			Lighting.FogEnd = savedSettings.FogEnd
		end
		settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				obj.Enabled = true
			end
		end
		perfButton.Text = "Performance Mode: OFF"
		perfButton.TextColor3 = Color3.fromRGB(0, 255, 120)
	end
end
perfButton.MouseButton1Click:Connect(function()
	setPerformanceMode(not performanceMode)
end)

-- ===== UPDATE LOOP =====
task.spawn(function()
	while frame.Parent do
		local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
		label.Text = string.format("FPS: %d\nPing: %d ms\nRegion: %s", fps, ping, country)
		task.wait(0.25)
	end
end)
