-- Oishi Hub v1.03 - Private UI (LocalScript) with Auto-Execute
-- ADDED: Main tab with Aimbot (0.0005 = snap, 5 = smooth)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local isPC = not UIS.TouchEnabled

-- Aimbot variables
local AimbotEnabled = false
local AimbotConnection = nil
local FOV = 50
local Smoothness = 0.5
local HitPart = "Head"

local function SetupAutoExecute()
    pcall(function()
        if writefile and isfolder and makefolder then
            if not isfolder("autoexec") then
                makefolder("autoexec")
            end
            local currentScript = debug.getinfo(1, "S").source
            if currentScript and currentScript:sub(1,1) == "@" then
                local path = currentScript:sub(2)
                if isfile(path) then
                    local content = readfile(path)
                    writefile("autoexec/oishi_hub.lua", content)
                end
            end
        end
    end)
end

--========================
-- CONFIGURATION
--========================
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

local ANIM = {
    OpenTime = 0.28,
    CloseTime = 0.2,
    TabTime = 0.2,
    DropdownTime = 0.2,
    CollapseTime = 0.25,
    HoverTime = 0.12,
    EasingStyle = Enum.EasingStyle.Quint,
    EasingDirection = Enum.EasingDirection.Out,
}

local function tween(object, time, properties)
    local info = TweenInfo.new(time, ANIM.EasingStyle, ANIM.EasingDirection)
    return TweenService:Create(object, info, properties)
end

local SaveData = {
    Aimbot = false,
    AimbotFOV = 50,
    AimbotSmoothness = 0.5,
    AimbotHitPart = "Head",
    Ragebot = false,
    AutoShoot = false,
    AutoShootDelay = 0.1,
    RapidFire = false,
    Fly = false,
    FlySpeed = 80,
    InfiniteJump = false,
    Noclip = false,
    Esp = false,
    EspBoxes = false,
    EspNames = false,
    EspHealth = false,
    EspDistance = false,
    EspHealthNumber = false,
    EspChams = false,
    EspTracers = false,
    EspBoxOutline = false,
    EspBoxColor = Color3.fromRGB(0, 150, 255),
    EspNameColor = Color3.fromRGB(255, 255, 255),
    EspHealthColor = Color3.fromRGB(0, 255, 0),
    EspDistanceColor = Color3.fromRGB(255, 255, 255),
    EspHealthNumberColor = Color3.fromRGB(255, 255, 255),
    EspChamsColor = Color3.fromRGB(0, 150, 255),
    EspTracerColor = Color3.fromRGB(0, 150, 255),
    AnimationEnabled = false,
    AnimationPreset = "Underground Glitch",
    AnimationSpeed = 2,
}

local function LoadSettings()
    local success, result = pcall(function()
        if not isfolder or not makefolder then return nil end
        if not isfolder("oishi_hub") then makefolder("oishi_hub") end
        if isfile("oishi_hub/settings.json") then
            local data = HttpService:JSONDecode(readfile("oishi_hub/settings.json"))
            for k, v in pairs(data) do
                if type(v) == "table" and v.r and v.g and v.b then
                    data[k] = Color3.new(v.r, v.g, v.b)
                end
            end
            return data
        end
        return nil
    end)
    if success and result then return result end
    return nil
end

local function SaveSettings()
    pcall(function()
        if not isfolder or not makefolder then return end
        if not isfolder("oishi_hub") then makefolder("oishi_hub") end
        local saveCopy = {}
        for k, v in pairs(SaveData) do
            if typeof(v) == "Color3" then
                saveCopy[k] = {r = v.R, g = v.G, b = v.B}
            else
                saveCopy[k] = v
            end
        end
        writefile("oishi_hub/settings.json", HttpService:JSONEncode(saveCopy))
    end)
end

local savedData = LoadSettings()
if savedData then
    for k, v in pairs(SaveData) do
        if savedData[k] ~= nil then
            SaveData[k] = savedData[k]
        end
    end
end

-- Sync aimbot variables with SaveData
AimbotEnabled = SaveData.Aimbot
FOV = SaveData.AimbotFOV
Smoothness = SaveData.AimbotSmoothness
HitPart = SaveData.AimbotHitPart

local function isTeammate(player)
    if not player then return false end
    local myTeam = Player.Team
    local myTeamColor = myTeam and myTeam.TeamColor
    local myTeamAttribute = Player:GetAttribute("TeamID")
    local playerTeam = player.Team
    local playerTeamColor = playerTeam and playerTeam.TeamColor
    local playerTeamAttribute = player:GetAttribute("TeamID")
    
    if myTeam and playerTeam and myTeam == playerTeam then return true end
    if myTeamColor and playerTeamColor and myTeamColor == playerTeamColor then return true end
    if myTeamAttribute and playerTeamAttribute and myTeamAttribute == playerTeamAttribute then return true end
    return false
end

-- Check for existing UI
if PlayerGui:FindFirstChild("OishiHub") then
    PlayerGui.OishiHub:Destroy()
end

--========================
-- AIMBOT SYSTEM
--========================
local function GetClosestEnemyToCenter()
    local closest = nil
    local closestDistance = FOV
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and not isTeammate(plr) then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local part = char:FindFirstChild(HitPart) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                    if part then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closest = plr
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

local function EnableAimbot()
    if AimbotConnection then return end
    AimbotEnabled = true
    
    AimbotConnection = RunService.RenderStepped:Connect(function()
        if not AimbotEnabled then return end
        
        local target = GetClosestEnemyToCenter()
        if target and target.Character then
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local targetPart = target.Character:FindFirstChild(HitPart) or target.Character:FindFirstChild("Head")
                if targetPart then
                    local targetPos = targetPart.Position
                    
                    local cameraCFrame = Camera.CFrame
                    local lookAt = CFrame.new(cameraCFrame.Position, targetPos)
                    
                    if Smoothness <= 0.001 then
                        Camera.CFrame = lookAt
                    else
                        local smoothingFactor = math.clamp(1 / Smoothness, 0.01, 1)
                        Camera.CFrame = cameraCFrame:Lerp(lookAt, smoothingFactor)
                    end
                end
            end
        end
    end)
end

local function DisableAimbot()
    AimbotEnabled = false
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
end

local function ToggleAimbot(enabled)
    if enabled then
        EnableAimbot()
    else
        DisableAimbot()
    end
end

local function OnAimbotFOV(value)
    FOV = value
    SaveData.AimbotFOV = value
    SaveSettings()
end

local function OnAimbotSmoothness(value)
    Smoothness = value
    SaveData.AimbotSmoothness = value
    SaveSettings()
end

local function OnAimbotHitPart(part)
    HitPart = part
    SaveData.AimbotHitPart = part
    SaveSettings()
end

--========================
-- NEW UI LIBRARY
--========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OishiHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local uiWidth = isPC and 600 or math.min(650, Camera.ViewportSize.X - 20)
local uiHeight = isPC and 450 or math.min(400, Camera.ViewportSize.Y * 0.5)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, uiWidth, 0, uiHeight)
Main.Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2)
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

-- Header
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
HeaderTitle.Size = UDim2.new(0, 200, 0, 20)
HeaderTitle.Position = UDim2.new(0, 10, 0, 5)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "OISHI HUB V1.03"
HeaderTitle.Font = CONFIG.Font
HeaderTitle.TextSize = 12
HeaderTitle.TextColor3 = CONFIG.Accent
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 12
HeaderTitle.Parent = Header

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

-- Tabs (Full width at top)
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 26)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = CONFIG.Surface
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex = 11
TabFrame.Parent = Main

local Tabs = {
    {name = "Main"},
    {name = "Ragebot"},
    {name = "ESP"},
    {name = "Misc"},
    {name = "Animation"},
}

local currentTab = "Main"
local TabButtons = {}
local TabContents = {}

-- Content container below tabs (full width)
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -56)
ContentContainer.Position = UDim2.new(0, 0, 0, 56)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 11
ContentContainer.Parent = Main

-- Left and right content areas
local LeftContent = Instance.new("Frame")
LeftContent.Size = UDim2.new(0.5, -1, 1, 0)
LeftContent.Position = UDim2.new(0, 0, 0, 0)
LeftContent.BackgroundColor3 = CONFIG.Background
LeftContent.BorderSizePixel = 0
LeftContent.ZIndex = 11
LeftContent.Parent = ContentContainer

local RightContent = Instance.new("Frame")
RightContent.Size = UDim2.new(0.5, -1, 1, 0)
RightContent.Position = UDim2.new(0.5, 1, 0, 0)
RightContent.BackgroundColor3 = CONFIG.Surface
RightContent.BorderSizePixel = 0
RightContent.ZIndex = 11
RightContent.Parent = ContentContainer

for i, tab in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/5, -1, 0, 22)
    btn.Position = UDim2.new((i-1) * (1/5), 0.5, 0, 2)
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
    
    local leftScroll = Instance.new("ScrollingFrame")
    leftScroll.Size = UDim2.new(1, 0, 1, 0)
    leftScroll.BackgroundTransparency = 1
    leftScroll.BorderSizePixel = 0
    leftScroll.ScrollBarThickness = 3
    leftScroll.ScrollBarImageColor3 = CONFIG.Accent
    leftScroll.ScrollBarImageTransparency = 0.3
    leftScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    leftScroll.ZIndex = 12
    leftScroll.Visible = tab.name == currentTab
    leftScroll.Parent = LeftContent
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 6)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = leftScroll
    
    local leftPadding = Instance.new("UIPadding")
    leftPadding.PaddingTop = UDim.new(0, 10)
    leftPadding.PaddingLeft = UDim.new(0, 10)
    leftPadding.PaddingRight = UDim.new(0, 10)
    leftPadding.PaddingBottom = UDim.new(0, 10)
    leftPadding.Parent = leftScroll
    
    local rightScroll = Instance.new("ScrollingFrame")
    rightScroll.Size = UDim2.new(1, 0, 1, 0)
    rightScroll.BackgroundTransparency = 1
    rightScroll.BorderSizePixel = 0
    rightScroll.ScrollBarThickness = 3
    rightScroll.ScrollBarImageColor3 = CONFIG.Accent
    rightScroll.ScrollBarImageTransparency = 0.3
    rightScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    rightScroll.ZIndex = 12
    rightScroll.Visible = tab.name == currentTab
    rightScroll.Parent = RightContent
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 6)
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightScroll
    
    local rightPadding = Instance.new("UIPadding")
    rightPadding.PaddingTop = UDim.new(0, 10)
    rightPadding.PaddingLeft = UDim.new(0, 10)
    rightPadding.PaddingRight = UDim.new(0, 10)
    rightPadding.PaddingBottom = UDim.new(0, 10)
    rightPadding.Parent = rightScroll
    
    TabContents[tab.name] = {
        leftScroll = leftScroll,
        rightScroll = rightScroll,
        leftLayout = leftLayout,
        rightLayout = rightLayout,
    }
    
    btn.MouseButton1Click:Connect(function()
        if currentTab == tab.name then return end
        
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
        
        TabContents[oldTab].leftScroll.Visible = false
        TabContents[oldTab].rightScroll.Visible = false
        
        TabContents[tab.name].leftScroll.Visible = true
        TabContents[tab.name].rightScroll.Visible = true
    end)
end

-- Collapsible container (pushes content down)
local function CreateCollapsibleContainer(parent, initialOpen)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.ZIndex = 15
    container.Visible = initialOpen or false
    container.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 2)
    padding.Parent = container
    
    local open = initialOpen or false
    
    local function updateSize()
        local contentHeight = layout.AbsoluteContentSize.Y
        
        if open and contentHeight > 0 then
            container.Visible = true
            tween(container, ANIM.CollapseTime, {
                Size = UDim2.new(1, 0, 0, contentHeight + 4)
            }):Play()
        else
            tween(container, ANIM.CollapseTime, {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            task.delay(ANIM.CollapseTime, function()
                if not open then
                    container.Visible = false
                end
            end)
        end
        
        task.spawn(function()
            local scrollParent = container.Parent
            while scrollParent do
                if scrollParent:IsA("ScrollingFrame") then
                    local scrollLayout = scrollParent:FindFirstChildOfClass("UIListLayout")
                    if scrollLayout then
                        scrollParent.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 20)
                    end
                    break
                end
                scrollParent = scrollParent.Parent
            end
        end)
    end
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if open then
            updateSize()
        end
    end)
    
    task.spawn(function()
        task.wait(0.1)
        updateSize()
    end)
    
    return {
        container = container,
        layout = layout,
        setOpen = function(value)
            open = value
            updateSize()
        end,
        isOpen = function()
            return open
        end
    }
end

-- UI Components
local function CreateToggle(tabName, name, default, callback, side, collapsible)
    local content = TabContents[tabName]
    if not content then return end
    
    local targetScroll = side == "right" and content.rightScroll or content.leftScroll
    local targetLayout = side == "right" and content.rightLayout or content.leftLayout
    
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(1, 0, 0, 34)
    mainContainer.BackgroundTransparency = 1
    mainContainer.BorderSizePixel = 0
    mainContainer.ZIndex = 12
    mainContainer.Parent = targetScroll
    
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.Padding = UDim.new(0, 4)
    mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainLayout.Parent = mainContainer
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = mainContainer
    
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
    knob.Position = default and UDim2.new(0, 17, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = button
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local state = default or false
    local collapsibleContainer = nil
    
    if collapsible then
        collapsibleContainer = CreateCollapsibleContainer(mainContainer, state)
    end
    
    button.MouseButton1Click:Connect(function()
        state = not state
        
        if state then
            tween(button, 0.2, {BackgroundColor3 = CONFIG.ToggleOn}):Play()
            tween(knob, 0.2, {Position = UDim2.new(0, 17, 0, 3)}):Play()
        else
            tween(button, 0.2, {BackgroundColor3 = CONFIG.ToggleOff}):Play()
            tween(knob, 0.2, {Position = UDim2.new(0, 3, 0, 3)}):Play()
        end
        
        if collapsibleContainer then
            collapsibleContainer.setOpen(state)
        end
        
        task.spawn(function()
            task.wait(ANIM.CollapseTime)
            mainContainer.Size = UDim2.new(1, 0, 0, mainLayout.AbsoluteContentSize.Y)
            targetScroll.CanvasSize = UDim2.new(0, 0, 0, targetLayout.AbsoluteContentSize.Y + 20)
        end)
        
        if callback then callback(state) end
    end)
    
    mainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        mainContainer.Size = UDim2.new(1, 0, 0, mainLayout.AbsoluteContentSize.Y)
        targetScroll.CanvasSize = UDim2.new(0, 0, 0, targetLayout.AbsoluteContentSize.Y + 20)
    end)
    
    task.spawn(function()
        task.wait(0.1)
        mainContainer.Size = UDim2.new(1, 0, 0, mainLayout.AbsoluteContentSize.Y)
        targetScroll.CanvasSize = UDim2.new(0, 0, 0, targetLayout.AbsoluteContentSize.Y + 20)
    end)
    
    if collapsible then
        return {
            toggle = container,
            collapsible = collapsibleContainer,
            mainContainer = mainContainer
        }
    end
    
    return container
end

local function CreateSliderInCollapsible(collapsible, name, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = CONFIG.SurfaceLight
    container.BorderSizePixel = 0
    container.Active = true
    container.ZIndex = 16
    container.Parent = collapsible.container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 0, 14)
    label.Position = UDim2.new(0, 8, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CONFIG.FontMedium
    label.TextSize = 8
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 17
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
    valueLabel.ZIndex = 17
    valueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 28)
    sliderBg.BackgroundColor3 = CONFIG.Surface
    sliderBg.BorderSizePixel = 0
    sliderBg.Active = true
    sliderBg.ZIndex = 17
    sliderBg.Parent = container
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = sliderBg
    
    local percentage = math.clamp((default - min) / (max - min), 0, 1)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(percentage, 0, 1, 0)
    fill.BackgroundColor3 = CONFIG.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 18
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
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
    knob.ZIndex = 20
    knob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
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
        
        if max - min <= 1 then
            value = math.floor(value * 1000) / 1000
        else
            value = math.floor(value)
        end
        
        local final = math.clamp((value - min) / (max - min), 0, 1)
        
        fill.Size = UDim2.new(final, 0, 1, 0)
        knob.Position = UDim2.new(final, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        
        if callback then callback(value) end
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
        if not draggingSlider then return end
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

local function CreateDropdownInCollapsible(collapsible, name, options, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = CONFIG.SurfaceLight
    container.BorderSizePixel = 0
    container.ZIndex = 30
    container.Parent = collapsible.container
    
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
    buttonCorner.CornerRadius = UDim.new(0, 5)
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
    
    local opened = false
    local dropdownPopup = nil
    
    local function closeDropdown()
        if dropdownPopup then
            dropdownPopup:Destroy()
            dropdownPopup = nil
        end
        opened = false
        tween(arrow, ANIM.DropdownTime, {Rotation = 0}):Play()
    end
    
    button.MouseButton1Click:Connect(function()
        if opened then
            closeDropdown()
            return
        end
        
        opened = true
        tween(arrow, ANIM.DropdownTime, {Rotation = 180}):Play()
        
        dropdownPopup = Instance.new("Frame")
        dropdownPopup.Size = UDim2.new(0, 200, 0, 0)
        dropdownPopup.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        dropdownPopup.BorderSizePixel = 0
        dropdownPopup.ClipsDescendants = true
        dropdownPopup.ZIndex = 9999
        dropdownPopup.Parent = ScreenGui
        
        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = UDim.new(0, 8)
        popupCorner.Parent = dropdownPopup
        
        local popupStroke = Instance.new("UIStroke")
        popupStroke.Color = CONFIG.Accent
        popupStroke.Thickness = 1
        popupStroke.Transparency = 0.2
        popupStroke.Parent = dropdownPopup
        
        local btnPos = button.AbsolutePosition
        local btnSize = button.AbsoluteSize
        local screenSize = Camera.ViewportSize
        
        local optionHeight = 35
        local totalHeight = #options * optionHeight
        local maxHeight = math.min(totalHeight, 300)
        
        local popupX = btnPos.X
        local popupY = btnPos.Y + btnSize.Y + 5
        
        if popupY + maxHeight > screenSize.Y - 10 then
            popupY = btnPos.Y - maxHeight - 5
        end
        
        if popupX + 200 > screenSize.X - 10 then
            popupX = screenSize.X - 210
        end
        
        if popupX < 10 then
            popupX = 10
        end
        
        if popupY < 10 then
            popupY = 10
        end
        
        dropdownPopup.Position = UDim2.new(0, popupX, 0, popupY)
        
        tween(dropdownPopup, ANIM.DropdownTime, {
            Size = UDim2.new(0, 200, 0, maxHeight)
        }):Play()
        
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = CONFIG.Accent
        scrollFrame.ScrollBarImageTransparency = 0.3
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        scrollFrame.ZIndex = 10000
        scrollFrame.Parent = dropdownPopup
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = scrollFrame
        
        for _, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, -8, 0, optionHeight - 5)
            optionButton.Position = UDim2.new(0, 4, 0, 0)
            optionButton.BackgroundColor3 = option == selected and CONFIG.Accent or Color3.fromRGB(30, 30, 35)
            optionButton.BackgroundTransparency = option == selected and 0.3 or 0
            optionButton.BorderSizePixel = 0
            optionButton.Text = tostring(option)
            optionButton.Font = CONFIG.FontMedium
            optionButton.TextSize = 10
            optionButton.TextColor3 = option == selected and Color3.new(1, 1, 1) or CONFIG.Text
            optionButton.AutoButtonColor = false
            optionButton.ZIndex = 10001
            optionButton.Parent = scrollFrame
            
            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 5)
            optionCorner.Parent = optionButton
            
            optionButton.MouseEnter:Connect(function()
                if option ~= selected then
                    tween(optionButton, 0.1, {
                        BackgroundColor3 = CONFIG.HoverSurface,
                        BackgroundTransparency = 0.2
                    }):Play()
                end
            end)
            
            optionButton.MouseLeave:Connect(function()
                if option ~= selected then
                    tween(optionButton, 0.1, {
                        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
                        BackgroundTransparency = 0
                    }):Play()
                end
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                selected = option
                button.Text = tostring(option)
                
                if callback then callback(option) end
                
                closeDropdown()
            end)
        end
    end)
    
    UIS.InputBegan:Connect(function(input)
        if opened and dropdownPopup then
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local clickPos = input.Position
                local popupPos = dropdownPopup.AbsolutePosition
                local popupSize = dropdownPopup.AbsoluteSize
                local btnPos = button.AbsolutePosition
                local btnSize = button.AbsoluteSize
                
                local clickedPopup = clickPos.X >= popupPos.X and clickPos.X <= popupPos.X + popupSize.X
                    and clickPos.Y >= popupPos.Y and clickPos.Y <= popupPos.Y + popupSize.Y
                
                local clickedButton = clickPos.X >= btnPos.X and clickPos.X <= btnPos.X + btnSize.X
                    and clickPos.Y >= btnPos.Y and clickPos.Y <= btnPos.Y + btnSize.Y
                
                if not clickedPopup and not clickedButton then
                    closeDropdown()
                end
            end
        end
    end)
    
    container.Destroying:Connect(function()
        closeDropdown()
    end)
    
    return container
end

--========================
-- CREATE UI ELEMENTS
--========================
-- Main Tab (Aimbot - Left side)
local aimbotToggle = CreateToggle("Main", "Aimbot", SaveData.Aimbot, ToggleAimbot, "left", true)
if aimbotToggle.collapsible then
    CreateSliderInCollapsible(aimbotToggle.collapsible, "FOV", 10, 360, SaveData.AimbotFOV, OnAimbotFOV)
    CreateSliderInCollapsible(aimbotToggle.collapsible, "Smoothness", 0.0005, 5, SaveData.AimbotSmoothness, OnAimbotSmoothness)
    CreateDropdownInCollapsible(aimbotToggle.collapsible, "Hit Part", {
        "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"
    }, SaveData.AimbotHitPart, OnAimbotHitPart)
end

-- Ragebot Tab
CreateToggle("Ragebot", "Ragebot", SaveData.Ragebot, ToggleWallbang, "left")

local autoShootToggle = CreateToggle("Ragebot", "Auto Shoot", SaveData.AutoShoot, ToggleAutoShoot, "left", true)
if autoShootToggle.collapsible then
    CreateSliderInCollapsible(autoShootToggle.collapsible, "Shoot Delay", 0.0005, 5, SaveData.AutoShootDelay, OnAutoShootDelay)
end

CreateToggle("Ragebot", "Rapid Fire", SaveData.RapidFire, ToggleRapidFire, "left")

-- ESP Tab
local espToggle = CreateToggle("ESP", "Enable ESP", SaveData.Esp, ToggleEsp, "left", true)
if espToggle.collapsible then
    local boxEsp = CreateToggle("ESP", "Box ESP", SaveData.EspBoxes, ToggleEspBoxes, "left", true)
    if boxEsp.collapsible then
        boxEsp.collapsible.container.Parent = espToggle.collapsible.container
        CreateColorPickerInCollapsible(boxEsp.collapsible, "Box Color", SaveData.EspBoxColor, OnEspBoxColorChange)
        CreateToggle("ESP", "Box Outline", SaveData.EspBoxOutline, ToggleEspBoxOutline, "left")
    end
    
    local healthEsp = CreateToggle("ESP", "Health Bar ESP", SaveData.EspHealth, ToggleEspHealth, "left", true)
    if healthEsp.collapsible then
        healthEsp.collapsible.container.Parent = espToggle.collapsible.container
        CreateColorPickerInCollapsible(healthEsp.collapsible, "Health Color", SaveData.EspHealthColor, OnEspHealthColorChange)
    end
    
    local nameEsp = CreateToggle("ESP", "Name ESP", SaveData.EspNames, ToggleEspNames, "left", true)
    if nameEsp.collapsible then
        nameEsp.collapsible.container.Parent = espToggle.collapsible.container
        CreateColorPickerInCollapsible(nameEsp.collapsible, "Name Color", SaveData.EspNameColor, OnEspNameColorChange)
    end
    
    local healthNumEsp = CreateToggle("ESP", "Health Number", SaveData.EspHealthNumber, ToggleEspHealthNumber, "left", true)
    if healthNumEsp.collapsible then
        healthNumEsp.collapsible.container.Parent = espToggle.collapsible.container
        CreateColorPickerInCollapsible(healthNumEsp.collapsible, "Health Number Color", SaveData.EspHealthNumberColor, OnEspHealthNumberColorChange)
    end
    
    local distEsp = CreateToggle("ESP", "Distance ESP", SaveData.EspDistance, ToggleEspDistance, "left", true)
    if distEsp.collapsible then
        distEsp.collapsible.container.Parent = espToggle.collapsible.container
        CreateColorPickerInCollapsible(distEsp.collapsible, "Distance Color", SaveData.EspDistanceColor, OnEspDistanceColorChange)
    end
    
    local tracerEsp = CreateToggle("ESP", "Tracer ESP", SaveData.EspTracers, ToggleEspTracers, "left", true)
    if tracerEsp.collapsible then
        tracerEsp.collapsible.container.Parent = espToggle.collapsible.container
        CreateColorPickerInCollapsible(tracerEsp.collapsible, "Tracer Color", SaveData.EspTracerColor, OnEspTracerColorChange)
    end
end

-- Misc Tab
local flyToggle = CreateToggle("Misc", "Fly", SaveData.Fly, ToggleFly, "left", true)
if flyToggle.collapsible then
    CreateSliderInCollapsible(flyToggle.collapsible, "Fly Speed", 1, 500, SaveData.FlySpeed, OnFlySpeed)
end

CreateToggle("Misc", "Infinite Jump", SaveData.InfiniteJump, ToggleInfiniteJump, "right")
CreateToggle("Misc", "Noclip", SaveData.Noclip, ToggleNoclip, "right")

-- Animation Tab
local animToggle = CreateToggle("Animation", "Enable Animation", SaveData.AnimationEnabled, ToggleAnimation, "left", true)
if animToggle.collapsible then
    CreateSliderInCollapsible(animToggle.collapsible, "Animation Speed", 1, 500, SaveData.AnimationSpeed, OnAnimationSpeedChange)
    CreateDropdownInCollapsible(animToggle.collapsible, "Anim Preset", {
        "Underground Glitch", "Orbit", "Tweaking", "Kicking Feet",
        "Low Cortisol", "Floss", "Take the L", "Upside Down",
        "Michael Myers Shake", "Headless", "Wall Peek L", "Glitch Through",
        "Spin",
    }, SaveData.AnimationPreset, OnAnimationPresetChanged)
end

-- Update canvas sizes
task.wait(0.1)
for _, content in pairs(TabContents) do
    content.leftScroll.CanvasSize = UDim2.new(0, 0, 0, content.leftLayout.AbsoluteContentSize.Y + 20)
    content.rightScroll.CanvasSize = UDim2.new(0, 0, 0, content.rightLayout.AbsoluteContentSize.Y + 20)
end

--========================
-- HEADER-ONLY DRAG SYSTEM
--========================
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
    if not dragging then return end
    
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--========================
-- MOBILE CONTROLS
--========================
if isMobile then
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 88, 0, 30)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 150)
    ToggleBtn.BackgroundColor3 = CONFIG.Accent
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = "Toggle UI"
    ToggleBtn.Font = CONFIG.Font
    ToggleBtn.TextSize = 10
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.ZIndex = 999999
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = ScreenGui
    
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 5)
    tc.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        if Main.Visible then
            CloseUI()
        else
            OpenUI()
        end
    end)
end

--========================
-- PC RIGHT SHIFT
--========================
if isPC then
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.RightShift then
            if Main.Visible then
                CloseUI()
            else
                OpenUI()
            end
        end
    end)
end

--========================
-- AUTO-ENABLE SAVED FEATURES
--========================
if SaveData.Aimbot then EnableAimbot() end
if SaveData.Ragebot then EnableWallbang() end
if SaveData.AutoShoot then EnableAutoShoot() end
if SaveData.RapidFire then EnableRapidFire() end
if SaveData.Fly then EnableFly() end
if SaveData.InfiniteJump then EnableInfiniteJump() end
if SaveData.Noclip then EnableNoclip() end
if SaveData.Esp then EnableEsp() end
if SaveData.AnimationEnabled then ToggleAnimation(true) end

--========================
-- SETUP AUTO-EXECUTE
--========================
SetupAutoExecute()

-- Open UI on first load
OpenUI()

print("[Oishi Hub V1.03] Loaded with Aimbot! 0.0005 = Snap, 5 = Smooth")
