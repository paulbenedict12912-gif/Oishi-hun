--==================================================
-- OISHI HUB UI LIBRARY + MOBILE-SAFE ESP
-- Full Mobile + PC Version
--
-- Features:
-- • Left / Right layout
-- • Smooth UI animations
-- • Animated tab switching
-- • Animated dropdowns
-- • Smooth circular color picker
-- • White slider knobs
-- • PC + Mobile slider dragging
-- • Slider does NOT drag the main UI
-- • Header-only UI dragging
-- • Mobile Toggle UI
-- • Mobile Lock / Unlock
-- • Full ESP Features
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local isPC = not UIS.TouchEnabled

--==================================================
-- ESP SETTINGS
--==================================================

local ESP = {
    Enabled = true,
    Boxes = true,
    Names = true,
    HealthBar = true,
    Distance = true,
    Tracers = true,
    HeadDots = true,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(0, 255, 0),
    TracerColor = Color3.fromRGB(255, 255, 255),
    MaxDistance = 1000,
}

--==================================================
-- ESP CONTAINER
--==================================================

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "MobileESP"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.DisplayOrder = 100
ESPGui.Parent = PlayerGui

local ESPObjects = {}

--==================================================
-- ESP HELPERS
--==================================================

local function create(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function hideObject(object)
    if object then
        object.Visible = false
    end
end

local function destroyESP(player)
    local data = ESPObjects[player]
    if data then
        if data.Gui then
            data.Gui:Destroy()
        end
        ESPObjects[player] = nil
    end
end

local function getCharacterData(player)
    local character = player.Character
    if not character then
        return nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")

    if not humanoid or not root or not head then
        return nil
    end

    if humanoid.Health <= 0 then
        return nil
    end

    return character, humanoid, root, head
end

--==================================================
-- CREATE PLAYER ESP
--==================================================

local function createESP(player)
    if player == Player then
        return
    end

    destroyESP(player)

    local gui = create("Frame", {
        Name = player.Name .. "_ESP",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(1, 1),
        Position = UDim2.fromOffset(0, 0),
        Visible = false,
    }, ESPGui)

    local box = create("Frame", {
        Name = "Box",
        BackgroundTransparency = 1,
        BorderSizePixel = 2,
        BorderColor3 = ESP.BoxColor,
        Visible = false,
    }, gui)

    local boxOutline = create("Frame", {
        Name = "BoxOutline",
        BackgroundTransparency = 1,
        BorderSizePixel = 4,
        BorderColor3 = Color3.new(0, 0, 0),
        Visible = false,
        ZIndex = 1,
    }, gui)

    box.ZIndex = 2

    local name = create("TextLabel", {
        Name = "Name",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = player.Name,
        TextColor3 = ESP.NameColor,
        TextStrokeColor3 = Color3.new(0, 0, 0),
        TextStrokeTransparency = 0,
        TextSize = 14,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false,
        ZIndex = 5,
    }, gui)

    local distance = create("TextLabel", {
        Name = "Distance",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        TextColor3 = Color3.new(1, 1, 1),
        TextStrokeColor3 = Color3.new(0, 0, 0),
        TextStrokeTransparency = 0,
        TextSize = 13,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false,
        ZIndex = 5,
    }, gui)

    local healthBG = create("Frame", {
        Name = "HealthBG",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 3,
    }, gui)

    local healthBar = create("Frame", {
        Name = "HealthBar",
        BackgroundColor3 = ESP.HealthColor,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 4,
    }, gui)

    local headDot = create("Frame", {
        Name = "HeadDot",
        BackgroundColor3 = ESP.BoxColor,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 6,
    }, gui)

    local headCorner = Instance.new("UICorner")
    headCorner.CornerRadius = UDim.new(1, 0)
    headCorner.Parent = headDot

    local tracer = create("Frame", {
        Name = "Tracer",
        BackgroundColor3 = ESP.TracerColor,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 0,
    }, gui)

    ESPObjects[player] = {
        Gui = gui,
        Box = box,
        BoxOutline = boxOutline,
        Name = name,
        Distance = distance,
        HealthBG = healthBG,
        HealthBar = healthBar,
        HeadDot = headDot,
        Tracer = tracer,
    }
end

--==================================================
-- LINE BETWEEN TWO POINTS
--==================================================

local function setLine(line, from, to, thickness)
    local difference = to - from
    local length = difference.Magnitude

    if length <= 0 then
        line.Visible = false
        return
    end

    line.AnchorPoint = Vector2.new(0, 0.5)
    line.Position = UDim2.fromOffset(from.X, from.Y)
    line.Size = UDim2.fromOffset(length, thickness)
    line.Rotation = math.deg(math.atan2(difference.Y, difference.X))
    line.Visible = true
end

--==================================================
-- GET 2D BOUNDING BOX
--==================================================

local function getBoundingBox(character, camera)
    local success, cf, size = pcall(function()
        return character:GetBoundingBox()
    end)

    if not success or not cf or not size then
        return nil
    end

    local half = size / 2

    local corners = {
        cf * Vector3.new(-half.X, -half.Y, -half.Z),
        cf * Vector3.new(-half.X, -half.Y, half.Z),
        cf * Vector3.new(-half.X, half.Y, -half.Z),
        cf * Vector3.new(-half.X, half.Y, half.Z),
        cf * Vector3.new(half.X, -half.Y, -half.Z),
        cf * Vector3.new(half.X, -half.Y, half.Z),
        cf * Vector3.new(half.X, half.Y, -half.Z),
        cf * Vector3.new(half.X, half.Y, half.Z),
    }

    local minX = math.huge
    local minY = math.huge
    local maxX = -math.huge
    local maxY = -math.huge
    local visibleCorner = false

    for _, corner in ipairs(corners) do
        local screenPosition, onScreen = camera:WorldToViewportPoint(corner)

        if screenPosition.Z > 0 then
            visibleCorner = true
            minX = math.min(minX, screenPosition.X)
            minY = math.min(minY, screenPosition.Y)
            maxX = math.max(maxX, screenPosition.X)
            maxY = math.max(maxY, screenPosition.Y)
        end
    end

    if not visibleCorner then
        return nil
    end

    return minX, minY, maxX, maxY
end

--==================================================
-- HIDE ALL
--==================================================

local function hideESP(data)
    if not data then
        return
    end

    data.Gui.Visible = false
    data.Box.Visible = false
    data.BoxOutline.Visible = false
    data.Name.Visible = false
    data.Distance.Visible = false
    data.HealthBG.Visible = false
    data.HealthBar.Visible = false
    data.HeadDot.Visible = false
    data.Tracer.Visible = false
end

--==================================================
-- UPDATE PLAYER
--==================================================

local function updatePlayer(player, camera)
    local data = ESPObjects[player]

    if not data then
        createESP(player)
        data = ESPObjects[player]
    end

    if not ESP.Enabled then
        hideESP(data)
        return
    end

    local character, humanoid, root, head = getCharacterData(player)

    if not character then
        hideESP(data)
        return
    end

    -- Team check
    if ESP.TeamCheck then
        if Player.Team and player.Team and Player.Team == player.Team then
            hideESP(data)
            return
        end
    end

    -- Distance check
    local localCharacter = Player.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

    if localRoot then
        local distanceValue = (localRoot.Position - root.Position).Magnitude
        if distanceValue > ESP.MaxDistance then
            hideESP(data)
            return
        end
    end

    -- Bounding box
    local minX, minY, maxX, maxY = getBoundingBox(character, camera)

    if not minX then
        hideESP(data)
        return
    end

    local width = maxX - minX
    local height = maxY - minY

    if width <= 1 or height <= 1 then
        hideESP(data)
        return
    end

    data.Gui.Visible = true

    -- Box
    if ESP.Boxes then
        data.Box.Visible = true
        data.Box.Position = UDim2.fromOffset(minX, minY)
        data.Box.Size = UDim2.fromOffset(width, height)
        data.Box.BorderColor3 = ESP.BoxColor

        data.BoxOutline.Visible = true
        data.BoxOutline.Position = UDim2.fromOffset(minX - 2, minY - 2)
        data.BoxOutline.Size = UDim2.fromOffset(width + 4, height + 4)
    else
        data.Box.Visible = false
        data.BoxOutline.Visible = false
    end

    -- Name
    if ESP.Names then
        data.Name.Visible = true
        data.Name.Position = UDim2.fromOffset(minX, minY - 22)
        data.Name.Size = UDim2.fromOffset(width, 20)
        data.Name.Text = player.DisplayName
        data.Name.TextColor3 = ESP.NameColor
    else
        data.Name.Visible = false
    end

    -- Health
    if ESP.HealthBar then
        local maxHealth = math.max(humanoid.MaxHealth, 1)
        local healthRatio = math.clamp(humanoid.Health / maxHealth, 0, 1)
        local barX = minX - 7

        data.HealthBG.Visible = true
        data.HealthBG.Position = UDim2.fromOffset(barX, minY)
        data.HealthBG.Size = UDim2.fromOffset(4, height)

        data.HealthBar.Visible = true
        local healthHeight = height * healthRatio
        data.HealthBar.Position = UDim2.fromOffset(barX, maxY - healthHeight)
        data.HealthBar.Size = UDim2.fromOffset(4, healthHeight)

        if healthRatio > 0.7 then
            data.HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif healthRatio > 0.3 then
            data.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        else
            data.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    else
        data.HealthBG.Visible = false
        data.HealthBar.Visible = false
    end

    -- Distance
    if ESP.Distance and localRoot then
        local distanceValue = math.floor((localRoot.Position - root.Position).Magnitude)
        data.Distance.Visible = true
        data.Distance.Position = UDim2.fromOffset(minX, maxY + 3)
        data.Distance.Size = UDim2.fromOffset(width, 18)
        data.Distance.Text = tostring(distanceValue) .. "m"
    else
        data.Distance.Visible = false
    end

    -- Head Dot
    if ESP.HeadDots then
        local headPosition, onScreen = camera:WorldToViewportPoint(head.Position)

        if onScreen and headPosition.Z > 0 then
            local dotSize = 8
            data.HeadDot.Visible = true
            data.HeadDot.Position = UDim2.fromOffset(headPosition.X - dotSize / 2, headPosition.Y - dotSize / 2)
            data.HeadDot.Size = UDim2.fromOffset(dotSize, dotSize)
            data.HeadDot.BackgroundColor3 = ESP.BoxColor
        else
            data.HeadDot.Visible = false
        end
    else
        data.HeadDot.Visible = false
    end

    -- Tracer
    if ESP.Tracers then
        local targetPosition, onScreen = camera:WorldToViewportPoint(root.Position)

        if onScreen and targetPosition.Z > 0 then
            local viewport = camera.ViewportSize
            local startPosition = Vector2.new(viewport.X / 2, viewport.Y)
            local endPosition = Vector2.new(targetPosition.X, targetPosition.Y)

            data.Tracer.BackgroundColor3 = ESP.TracerColor
            setLine(data.Tracer, startPosition, endPosition, 1)
        else
            data.Tracer.Visible = false
        end
    else
        data.Tracer.Visible = false
    end
end

--==================================================
-- UPDATE ALL
--==================================================

local function updateESP()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            updatePlayer(player, camera)
        end
    end
end

--==================================================
-- PLAYER EVENTS
--==================================================

Players.PlayerAdded:Connect(function(player)
    createESP(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.25)
        if ESPObjects[player] then
            ESPObjects[player].Gui.Visible = false
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    destroyESP(player)
end)

--==================================================
-- INITIALIZE ESP
--==================================================

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Player then
        createESP(player)
    end
end

--==================================================
-- MAIN LOOP
--==================================================

RunService.RenderStepped:Connect(function()
    local success, err = pcall(updateESP)
    if not success then
        warn("ESP update error:", err)
    end
end)

--==================================================
-- CONFIG
--==================================================

local CONFIG = {
    Accent = Color3.fromRGB(0, 150, 255),
    Background = Color3.fromRGB(5, 5, 5),
    Surface = Color3.fromRGB(15, 15, 15),
    SurfaceLight = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(200, 200, 200),
    TextSecondary = Color3.fromRGB(100, 100, 100),
    ToggleOn = Color3.fromRGB(0, 150, 255),
    ToggleOff = Color3.fromRGB(40, 40, 40),
    TabActive = Color3.fromRGB(0, 150, 255),
    TabInactive = Color3.fromRGB(30, 30, 30),
    Border = Color3.fromRGB(0, 150, 255),
    HoverSurface = Color3.fromRGB(40, 40, 40),
    Font = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
}

--==================================================
-- ANIMATION SETTINGS
--==================================================

local ANIM = {
    OpenTime = 0.28,
    CloseTime = 0.2,
    TabTime = 0.2,
    DropdownTime = 0.2,
    HoverTime = 0.12,
    EasingStyle = Enum.EasingStyle.Quint,
    EasingDirection = Enum.EasingDirection.Out,
}

local function tween(object, time, properties)
    local info = TweenInfo.new(time, ANIM.EasingStyle, ANIM.EasingDirection)
    return TweenService:Create(object, info, properties)
end

--==================================================
-- REMOVE OLD UI
--==================================================

local oldUI = PlayerGui:FindFirstChild("OishiHubExample")
if oldUI then
    oldUI:Destroy()
end

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OishiHubExample"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==================================================
-- SIZE
--==================================================

local uiWidth = isPC and 600 or math.min(650, Camera.ViewportSize.X - 20)
local uiHeight = isPC and 450 or math.min(400, Camera.ViewportSize.Y * 0.5)

--==================================================
-- MAIN
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, uiWidth, 0, uiHeight)
Main.Position = UDim2.new(0.5, -uiWidth / 2, 0.5, -uiHeight / 2)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.ZIndex = 10
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.Border
MainStroke.Thickness = 2
MainStroke.Parent = Main

--==================================================
-- OPEN ANIMATION
--==================================================

local MainScale = Instance.new("UIScale")
MainScale.Scale = 0.88
MainScale.Parent = Main

local function OpenUI()
    Main.Visible = true
    MainScale.Scale = 0.88
    tween(MainScale, ANIM.OpenTime, {Scale = 1}):Play()
end

local function CloseUI()
    local animation = tween(MainScale, ANIM.CloseTime, {Scale = 0.88})
    animation:Play()
    animation.Completed:Connect(function()
        if Main then
            Main.Visible = false
        end
    end)
end

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = CONFIG.Surface
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 300, 0, 20)
HeaderTitle.Position = UDim2.new(0, 10, 0, 5)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "OISHI HUB - ESP"
HeaderTitle.Font = CONFIG.Font
HeaderTitle.TextSize = 12
HeaderTitle.TextColor3 = CONFIG.Accent
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 12
HeaderTitle.Parent = Header

--==================================================
-- CLOSE BUTTON
--==================================================

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundColor3 = CONFIG.SurfaceLight
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.Font = CONFIG.Font
CloseBtn.TextSize = 10
CloseBtn.TextColor3 = CONFIG.Text
CloseBtn.ZIndex = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    CloseUI()
end)

--==================================================
-- TWO SIDED LAYOUT
--==================================================

local LeftSide = Instance.new("Frame")
LeftSide.Size = UDim2.new(0.5, -1, 1, -30)
LeftSide.Position = UDim2.new(0, 0, 0, 30)
LeftSide.BackgroundColor3 = CONFIG.Background
LeftSide.BorderSizePixel = 0
LeftSide.ZIndex = 11
LeftSide.Parent = Main

local RightSide = Instance.new("Frame")
RightSide.Size = UDim2.new(0.5, -1, 1, -30)
RightSide.Position = UDim2.new(0.5, 1, 0, 30)
RightSide.BackgroundColor3 = CONFIG.Surface
RightSide.BorderSizePixel = 0
RightSide.ZIndex = 11
RightSide.Parent = Main

--==================================================
-- TABS
--==================================================

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 26)
TabFrame.BackgroundColor3 = CONFIG.Surface
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex = 11
TabFrame.Parent = LeftSide

local Tabs = {
    {name = "Toggles"},
    {name = "Colors"},
    {name = "Settings"},
}

local currentTab = "Toggles"
local TabButtons = {}
local TabContents = {}

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -26)
ContentContainer.Position = UDim2.new(0, 0, 0, 26)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 11
ContentContainer.Parent = LeftSide

--==================================================
-- CREATE TABS
--==================================================

for i, tab in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / 3, -1, 0, 22)
    btn.Position = UDim2.new((i - 1) * (1 / 3), 0.5, 0, 2)
    btn.BackgroundColor3 = tab.name == currentTab and CONFIG.TabActive or CONFIG.TabInactive
    btn.BackgroundTransparency = tab.name == currentTab and 0.3 or 0.5
    btn.BorderSizePixel = 0
    btn.Text = tab.name
    btn.Font = CONFIG.Font
    btn.TextSize = 8
    btn.TextColor3 = tab.name == currentTab and Color3.new(1,1,1) or CONFIG.Text
    btn.ZIndex = 12
    btn.AutoButtonColor = false
    btn.Parent = TabFrame

    TabButtons[tab.name] = btn

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = tab.name == currentTab
    content.ZIndex = 11
    content.Parent = ContentContainer

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = CONFIG.Accent
    scroll.ScrollBarImageTransparency = 0.3
    scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    scroll.ZIndex = 12
    scroll.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = scroll

    TabContents[tab.name] = {
        frame = content,
        scroll = scroll,
        layout = layout,
    }

    btn.MouseButton1Click:Connect(function()
        if currentTab == tab.name then
            return
        end

        local oldTab = currentTab
        currentTab = tab.name

        for name, b in pairs(TabButtons) do
            if name == tab.name then
                tween(b, ANIM.TabTime, {
                    BackgroundColor3 = CONFIG.TabActive,
                    BackgroundTransparency = 0.3,
                    TextColor3 = Color3.new(1, 1, 1)
                }):Play()
            else
                tween(b, ANIM.TabTime, {
                    BackgroundColor3 = CONFIG.TabInactive,
                    BackgroundTransparency = 0.5,
                    TextColor3 = CONFIG.Text
                }):Play()
            end
        end

        local oldContent = TabContents[oldTab]
        local newContent = TabContents[tab.name]

        if oldContent and newContent then
            oldContent.frame.Visible = false
            newContent.frame.Visible = true

            local scale = newContent.frame:FindFirstChild("TabScale")
            if not scale then
                scale = Instance.new("UIScale")
                scale.Name = "TabScale"
                scale.Scale = 0.96
                scale.Parent = newContent.frame
            end

            tween(scale, ANIM.TabTime, {Scale = 1}):Play()
        end
    end)
end

--==================================================
-- SECTION LABEL
--==================================================

local function CreateSectionLabel(tabName, text)
    local content = TabContents[tabName]
    if not content then
        return
    end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = CONFIG.Font
    label.TextSize = 9
    label.TextColor3 = CONFIG.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = content.scroll

    return label
end

--==================================================
-- TOGGLE
--==================================================

local function CreateToggle(tabName, name, default, callback)
    local content = TabContents[tabName]
    if not content then
        return
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 0, 14)
    label.Position = UDim2.new(0, 8, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CONFIG.FontMedium
    label.TextSize = 9
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = container

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 32, 0, 18)
    button.Position = UDim2.new(1, -40, 0, 8)
    button.BackgroundColor3 = default and CONFIG.ToggleOn or CONFIG.ToggleOff
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 13
    button.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = default and UDim2.new(0,17,0,3) or UDim2.new(0,3,0,3)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = button

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1,0)
    knobCorner.Parent = knob

    local state = default or false

    button.MouseButton1Click:Connect(function()
        state = not state

        if state then
            tween(button, 0.2, {BackgroundColor3 = CONFIG.ToggleOn}):Play()
            tween(knob, 0.2, {Position = UDim2.new(0, 17, 0, 3)}):Play()
        else
            tween(button, 0.2, {BackgroundColor3 = CONFIG.ToggleOff}):Play()
            tween(knob, 0.2, {Position = UDim2.new(0, 3, 0, 3)}):Play()
        end

        if callback then
            callback(state)
        end
    end)

    return container
end

--==================================================
-- BUTTON
--==================================================

local function CreateButton(tabName, name, callback)
    local content = TabContents[tabName]
    if not content then
        return
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = CONFIG.Surface
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = CONFIG.Font
    btn.TextSize = 9
    btn.TextColor3 = CONFIG.Text
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    btn.Parent = content.scroll

    btn.MouseEnter:Connect(function()
        tween(btn, ANIM.HoverTime, {BackgroundColor3 = CONFIG.HoverSurface}):Play()
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, ANIM.HoverTime, {BackgroundColor3 = CONFIG.Surface}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return btn
end

--==================================================
-- SLIDER
--==================================================

local function CreateSlider(tabName, name, min, max, default, callback)
    local content = TabContents[tabName]
    if not content then
        return
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.Active = true
    container.ZIndex = 12
    container.Parent = content.scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 0, 14)
    label.Position = UDim2.new(0, 8, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CONFIG.FontMedium
    label.TextSize = 8
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 14)
    valueLabel.Position = UDim2.new(0.65, -5, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.Font = CONFIG.FontMedium
    valueLabel.TextSize = 8
    valueLabel.TextColor3 = CONFIG.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 13
    valueLabel.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 28)
    sliderBg.BackgroundColor3 = CONFIG.SurfaceLight
    sliderBg.BorderSizePixel = 0
    sliderBg.Active = true
    sliderBg.ZIndex = 13
    sliderBg.Parent = container

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1,0)
    barCorner.Parent = sliderBg

    local percentage = math.clamp((default - min) / (max - min), 0, 1)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(percentage, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 14
    fill.Parent = sliderBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1,0)
    fillCorner.Parent = fill

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(percentage, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.Active = true
    knob.ZIndex = 16
    knob.Parent = sliderBg

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1,0)
    knobCorner.Parent = knob

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Color3.fromRGB(0, 0, 0)
    knobStroke.Transparency = 0.3
    knobStroke.Thickness = 1
    knobStroke.Parent = knob

    local draggingSlider = false

    local function updateSlider(input)
        local pos = sliderBg.AbsolutePosition
        local size = sliderBg.AbsoluteSize
        local relative = (input.Position.X - pos.X) / size.X
        relative = math.clamp(relative, 0, 1)

        local value = min + (max - min) * relative
        value = math.floor(value + 0.5)

        local final = math.clamp((value - min) / (max - min), 0, 1)

        fill.Size = UDim2.new(final, 0, 1, 0)
        knob.Position = UDim2.new(final, 0, 0.5, 0)
        valueLabel.Text = tostring(value)

        if callback then
            callback(value)
        end
    end

    local function beginSlider(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlider(input)
        end
    end

    sliderBg.InputBegan:Connect(beginSlider)
    knob.InputBegan:Connect(beginSlider)

    local moveConnection = UIS.InputChanged:Connect(function(input)
        if not draggingSlider then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)

    local endConnection = UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    container.Destroying:Connect(function()
        draggingSlider = false
        moveConnection:Disconnect()
        endConnection:Disconnect()
    end)

    return container
end

--==================================================
-- DROPDOWN
--==================================================

local function CreateDropdown(tabName, name, options, default, callback)
    local content = TabContents[tabName]
    if not content then
        return
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.ZIndex = 30
    container.Parent = content.scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.45, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CONFIG.FontMedium
    label.TextSize = 9
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 31
    label.Parent = container

    local selected = default or options[1]

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 105, 0, 24)
    button.Position = UDim2.new(1, -113, 0, 5)
    button.BackgroundColor3 = CONFIG.SurfaceLight
    button.BorderSizePixel = 0
    button.Text = tostring(selected)
    button.Font = CONFIG.FontMedium
    button.TextSize = 8
    button.TextColor3 = CONFIG.Text
    button.AutoButtonColor = false
    button.ZIndex = 32
    button.Parent = container

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0,5)
    buttonCorner.Parent = button

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -22, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = CONFIG.Font
    arrow.TextSize = 7
    arrow.TextColor3 = CONFIG.Text
    arrow.ZIndex = 33
    arrow.Parent = button

    local list = Instance.new("Frame")
    list.Size = UDim2.new(0, 105, 0, 0)
    list.Position = UDim2.new(1, -113, 0, 31)
    list.BackgroundColor3 = CONFIG.Surface
    list.BorderSizePixel = 0
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 40
    list.Parent = container

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0,5)
    listCorner.Parent = list

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = CONFIG.Border
    listStroke.Transparency = 0.3
    listStroke.Thickness = 1
    listStroke.Parent = list

    local optionHeight = 27
    local opened = false

    for index, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -6, 0, optionHeight)
        optionButton.Position = UDim2.new(0, 3, 0, (index - 1) * optionHeight)
        optionButton.BackgroundColor3 = CONFIG.Surface
        optionButton.BorderSizePixel = 0
        optionButton.Text = tostring(option)
        optionButton.Font = CONFIG.FontMedium
        optionButton.TextSize = 8
        optionButton.TextColor3 = CONFIG.Text
        optionButton.AutoButtonColor = false
        optionButton.ZIndex = 41
        optionButton.Parent = list

        optionButton.MouseEnter:Connect(function()
            tween(optionButton, 0.1, {BackgroundColor3 = CONFIG.HoverSurface}):Play()
        end)

        optionButton.MouseLeave:Connect(function()
            tween(optionButton, 0.1, {BackgroundColor3 = CONFIG.Surface}):Play()
        end)

        optionButton.MouseButton1Click:Connect(function()
            selected = option
            button.Text = tostring(option)

            if callback then
                callback(option)
            end

            opened = false

            tween(list, ANIM.DropdownTime, {Size = UDim2.new(0, 105, 0, 0)}):Play()

            task.delay(ANIM.DropdownTime, function()
                if not opened then
                    list.Visible = false
                end
            end)

            tween(arrow, ANIM.DropdownTime, {Rotation = 0}):Play()
        end)
    end

    button.MouseButton1Click:Connect(function()
        opened = not opened

        if opened then
            list.Visible = true
            list.Size = UDim2.new(0, 105, 0, 0)

            tween(list, ANIM.DropdownTime, {
                Size = UDim2.new(0, 105, 0, math.min(#options * optionHeight, 135))
            }):Play()

            tween(arrow, ANIM.DropdownTime, {Rotation = 180}):Play()
        else
            local close = tween(list, ANIM.DropdownTime, {Size = UDim2.new(0, 105, 0, 0)})
            close:Play()

            tween(arrow, ANIM.DropdownTime, {Rotation = 0}):Play()

            task.delay(ANIM.DropdownTime, function()
                if not opened then
                    list.Visible = false
                end
            end)
        end
    end)

    return container
end

--==================================================
-- COLOR PICKER
--==================================================

local function CreateRainbowColorPicker(tabName, name, callback)
    local content = TabContents[tabName]
    if not content then
        return
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 24)
    label.Position = UDim2.new(0, 8, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CONFIG.FontMedium
    label.TextSize = 9
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = container

    local preview = Instance.new("TextButton")
    preview.Size = UDim2.new(0, 24, 0, 24)
    preview.Position = UDim2.new(1, -32, 0, 5)
    preview.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    preview.BorderSizePixel = 0
    preview.Text = ""
    preview.AutoButtonColor = false
    preview.ZIndex = 13
    preview.Parent = container

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(1,0)
    previewCorner.Parent = preview

    local activePopup = nil

    preview.MouseButton1Click:Connect(function()
        if activePopup then
            activePopup:Destroy()
            activePopup = nil
            return
        end

        local popup = Instance.new("Frame")
        activePopup = popup

        local width = 210
        local height = 255
        local viewport = Camera.ViewportSize

        local x = preview.AbsolutePosition.X - 180
        local y = preview.AbsolutePosition.Y - height - 5

        x = math.clamp(x, 5, viewport.X - width - 5)
        y = math.clamp(y, 5, viewport.Y - height - 5)

        popup.Size = UDim2.new(0, width, 0, height)
        popup.Position = UDim2.new(0, x, 0, y)
        popup.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        popup.BorderSizePixel = 0
        popup.ZIndex = 999
        popup.Parent = ScreenGui

        local popupScale = Instance.new("UIScale")
        popupScale.Scale = 0.82
        popupScale.Parent = popup

        tween(popupScale, 0.22, {Scale = 1}):Play()

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,10)
        corner.Parent = popup

        local stroke = Instance.new("UIStroke")
        stroke.Color = CONFIG.Accent
        stroke.Thickness = 1
        stroke.Transparency = 0.15
        stroke.Parent = popup

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -50, 0, 25)
        title.Position = UDim2.new(0, 10, 0, 3)
        title.BackgroundTransparency = 1
        title.Text = name
        title.Font = CONFIG.Font
        title.TextSize = 10
        title.TextColor3 = CONFIG.Text
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 1001
        title.Parent = popup

        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0, 20, 0, 20)
        close.Position = UDim2.new(1, -25, 0, 5)
        close.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        close.BorderSizePixel = 0
        close.Text = "×"
        close.Font = CONFIG.Font
        close.TextSize = 12
        close.TextColor3 = CONFIG.Text
        close.ZIndex = 1002
        close.AutoButtonColor = false
        close.Parent = popup

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(1,0)
        closeCorner.Parent = close

        close.MouseButton1Click:Connect(function()
            popup:Destroy()
        end)

        local wheelSize = 160

        local wheel = Instance.new("ImageButton")
        wheel.Size = UDim2.new(0, wheelSize, 0, wheelSize)
        wheel.Position = UDim2.new(0.5, -wheelSize / 2, 0, 30)
        wheel.BackgroundTransparency = 1
        wheel.BorderSizePixel = 0
        wheel.AutoButtonColor = false
        wheel.ZIndex = 1000
        wheel.Image = "rbxassetid://6020299385"
        wheel.ScaleType = Enum.ScaleType.Fit
        wheel.Parent = popup

        local wheelCorner = Instance.new("UICorner")
        wheelCorner.CornerRadius = UDim.new(1,0)
        wheelCorner.Parent = wheel

        local centerSize = 38

        local center = Instance.new("Frame")
        center.Size = UDim2.new(0, centerSize, 0, centerSize)
        center.Position = UDim2.new(0.5, -centerSize / 2, 0.5, -centerSize / 2)
        center.BackgroundColor3 = Color3.new(1, 1, 1)
        center.BorderSizePixel = 0
        center.ZIndex = 1001
        center.Parent = wheel

        local centerCorner = Instance.new("UICorner")
        centerCorner.CornerRadius = UDim.new(1,0)
        centerCorner.Parent = center

        local cursor = Instance.new("Frame")
        cursor.Size = UDim2.new(0, 12, 0, 12)
        cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        cursor.Position = UDim2.new(0.5, 0, 0.5, 0)
        cursor.BackgroundColor3 = Color3.new(1, 1, 1)
        cursor.BorderSizePixel = 0
        cursor.ZIndex = 1005
        cursor.Parent = wheel

        local cursorCorner = Instance.new("UICorner")
        cursorCorner.CornerRadius = UDim.new(1,0)
        cursorCorner.Parent = cursor

        local cursorStroke = Instance.new("UIStroke")
        cursorStroke.Color = Color3.new(0, 0, 0)
        cursorStroke.Thickness = 2
        cursorStroke.Parent = cursor

        local rgb = Instance.new("TextLabel")
        rgb.Size = UDim2.new(1, -20, 0, 20)
        rgb.Position = UDim2.new(0, 10, 0, 193)
        rgb.BackgroundTransparency = 1
        rgb.Text = "RGB: 255, 0, 0"
        rgb.Font = CONFIG.FontMedium
        rgb.TextSize = 9
        rgb.TextColor3 = CONFIG.Text
        rgb.TextXAlignment = Enum.TextXAlignment.Center
        rgb.ZIndex = 1001
        rgb.Parent = popup

        local presets = {
            Color3.fromRGB(255,0,0),
            Color3.fromRGB(255,128,0),
            Color3.fromRGB(255,255,0),
            Color3.fromRGB(0,255,0),
            Color3.fromRGB(0,255,255),
            Color3.fromRGB(0,128,255),
            Color3.fromRGB(0,0,255),
            Color3.fromRGB(128,0,255),
            Color3.fromRGB(255,0,255),
            Color3.fromRGB(255,255,255),
            Color3.fromRGB(0,0,0),
        }

        local function setColor(color)
            preview.BackgroundColor3 = color
            rgb.Text = string.format("RGB: %d, %d, %d", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))

            local h, s = color:ToHSV()
            local radius = wheelSize / 2
            local distance = radius * s
            local angle = h * math.pi * 2

            cursor.Position = UDim2.new(0.5, math.cos(angle) * distance, 0.5, math.sin(angle) * distance)

            if callback then
                callback(color)
            end
        end

        for i, color in ipairs(presets) do
            local preset = Instance.new("TextButton")
            preset.Size = UDim2.new(0, 14, 0, 14)
            preset.Position = UDim2.new(0, 8 + (i - 1) * 18, 0, 218)
            preset.BackgroundColor3 = color
            preset.BorderSizePixel = 0
            preset.Text = ""
            preset.AutoButtonColor = false
            preset.ZIndex = 1002
            preset.Parent = popup

            local pc = Instance.new("UICorner")
            pc.CornerRadius = UDim.new(1,0)
            pc.Parent = preset

            preset.MouseButton1Click:Connect(function()
                setColor(color)
            end)
        end

        local draggingWheel = false

        local function pickColor(input)
            local pos = wheel.AbsolutePosition
            local size = wheel.AbsoluteSize
            local cx = pos.X + size.X / 2
            local cy = pos.Y + size.Y / 2
            local dx = input.Position.X - cx
            local dy = input.Position.Y - cy
            local distance = math.sqrt(dx * dx + dy * dy)
            local radius = size.X / 2

            if distance > radius then
                local scale = radius / distance
                dx = dx * scale
                dy = dy * scale
                distance = radius
            end

            local angle = math.atan2(dy, dx)
            local hue = angle / (math.pi * 2)

            if hue < 0 then
                hue = hue + 1
            end

            local saturation = math.clamp(distance / radius, 0, 1)
            local color = Color3.fromHSV(hue, saturation, 1)

            preview.BackgroundColor3 = color
            rgb.Text = string.format("RGB: %d, %d, %d", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
            cursor.Position = UDim2.new(0.5, dx, 0.5, dy)

            if callback then
                callback(color)
            end
        end

        wheel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingWheel = true
                pickColor(input)
            end
        end)

        local move = UIS.InputChanged:Connect(function(input)
            if not draggingWheel then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                pickColor(input)
            end
        end)

        local ended = UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingWheel = false
            end
        end)

        popup.Destroying:Connect(function()
            draggingWheel = false
            move:Disconnect()
            ended:Disconnect()

            if activePopup == popup then
                activePopup = nil
            end
        end)
    end)

    return container
end

--==================================================
-- ESP CONTENT
--==================================================

-- Toggles Tab
CreateSectionLabel("Toggles", "ESP TOGGLES")

CreateToggle("Toggles", "ESP Enabled", true, function(state)
    ESP.Enabled = state
end)

CreateToggle("Toggles", "Boxes", true, function(state)
    ESP.Boxes = state
end)

CreateToggle("Toggles", "Names", true, function(state)
    ESP.Names = state
end)

CreateToggle("Toggles", "Health Bars", true, function(state)
    ESP.HealthBar = state
end)

CreateToggle("Toggles", "Distance", true, function(state)
    ESP.Distance = state
end)

CreateToggle("Toggles", "Tracers", true, function(state)
    ESP.Tracers = state
end)

CreateToggle("Toggles", "Head Dots", true, function(state)
    ESP.HeadDots = state
end)

CreateToggle("Toggles", "Team Check", true, function(state)
    ESP.TeamCheck = state
end)

-- Colors Tab
CreateSectionLabel("Colors", "ESP COLORS")

CreateRainbowColorPicker("Colors", "Box Color", function(color)
    ESP.BoxColor = color
end)

CreateRainbowColorPicker("Colors", "Name Color", function(color)
    ESP.NameColor = color
end)

CreateRainbowColorPicker("Colors", "Tracer Color", function(color)
    ESP.TracerColor = color
end)

-- Settings Tab
CreateSectionLabel("Settings", "ESP SETTINGS")

CreateSlider("Settings", "Max Distance", 100, 5000, 1000, function(value)
    ESP.MaxDistance = value
end)

CreateButton("Settings", "Refresh ESP", function()
    for player, data in pairs(ESPObjects) do
        destroyESP(player)
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            createESP(player)
        end
    end
end)

--==================================================
-- UPDATE CANVAS
--==================================================

task.wait()

for _, content in pairs(TabContents) do
    content.scroll.CanvasSize = UDim2.new(0, 0, 0, content.layout.AbsoluteContentSize.Y + 20)
end

--==================================================
-- HEADER-ONLY DRAG SYSTEM
--==================================================

local dragging = false
local dragStart
local startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--==================================================
-- MOBILE CONTROLS
--==================================================

if isMobile then
    local isUnlocked = false

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 88, 0, 30)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 150)
    ToggleBtn.BackgroundColor3 = CONFIG.Accent
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = "Toggle UI"
    ToggleBtn.Font = CONFIG.Font
    ToggleBtn.TextSize = 10
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.ZIndex = 999999
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = ScreenGui

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0,5)
    tc.Parent = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()
        if Main.Visible then
            CloseUI()
        else
            OpenUI()
        end
    end)

    local LockBtn = Instance.new("TextButton")
    LockBtn.Size = UDim2.new(0, 88, 0, 30)
    LockBtn.Position = UDim2.new(0, 10, 0, 190)
    LockBtn.BackgroundColor3 = CONFIG.Surface
    LockBtn.BorderSizePixel = 0
    LockBtn.Text = "Unlock UI"
    LockBtn.Font = CONFIG.Font
    LockBtn.TextSize = 10
    LockBtn.TextColor3 = Color3.new(1,1,1)
    LockBtn.ZIndex = 999999
    LockBtn.AutoButtonColor = false
    LockBtn.Parent = ScreenGui

    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0,5)
    lc.Parent = LockBtn

    LockBtn.MouseButton1Click:Connect(function()
        isUnlocked = not isUnlocked
        LockBtn.Text = isUnlocked and "Lock UI" or "Unlock UI"
        LockBtn.BackgroundColor3 = isUnlocked and CONFIG.Accent or CONFIG.Surface
    end)

    local function makeDraggable(btn)
        local draggingButton = false
        local start
        local position

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingButton = true
                start = input.Position
                position = btn.Position
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if not draggingButton then
                return
            end

            if not isUnlocked then
                return
            end

            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - start
                btn.Position = UDim2.new(position.X.Scale, position.X.Offset + delta.X, position.Y.Scale, position.Y.Offset + delta.Y)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingButton = false
            end
        end)
    end

    makeDraggable(ToggleBtn)
    makeDraggable(LockBtn)
end

--==================================================
-- PC RIGHT SHIFT
--==================================================

if isPC then
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if input.KeyCode == Enum.KeyCode.RightShift then
            if Main.Visible then
                CloseUI()
            else
                OpenUI()
            end
        end
    end)
end

--==================================================
-- START
--==================================================

if isPC then
    OpenUI()
end

print("[Oishi Hub UI Library + ESP] Loaded!")
print("[ESP] Features: Boxes, Names, Health Bars, Distance, Tracers, Head Dots, Team Check")
print("[ESP] Mobile + PC compatible")
