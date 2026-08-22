-- Oishi Hub v1.02 - Private UI (LocalScript) with Auto-Execute
-- COLLAPSIBLE: Settings push content down inside UI
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
    Ragebot = false,
    AutoShoot = false,
    AutoShootDelay = 0.1,
    RapidFire = false,
    Fly = false,
    FlySpeed = 80,
    InfiniteJump = false,
    Noclip = false,
    ThirdPerson = false,
    ThirdPersonMode = "Third Person",
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
    AutoCollect = false,
    AutoQueueEnabled = false,
    AutoQueueMode = "1v1",
    AimbotEnabled = false,
    AimbotShowFOV = false,
    AimbotTargetPart = "Head",
    AimbotFOVRadius = 500,
    AimbotSmoothness = 2,
    AimbotCurve = "Linear",
    AimbotFollowMuzzle = false,
    AimbotTeamCheck = true,
    AimbotAliveCheck = true,
    AimbotWallCheck = false,
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

-- Load saved data
local savedData = LoadSettings()
if savedData then
    for k, v in pairs(SaveData) do
        if savedData[k] ~= nil then
            SaveData[k] = savedData[k]
        end
    end
end

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
HeaderTitle.Text = "OISHI HUB V1.02"
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
        
        -- Update parent scroll
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
    
    -- Function to update button visuals
    local function updateVisuals()
        if state then
            button.BackgroundColor3 = CONFIG.ToggleOn
            knob.Position = UDim2.new(0, 17, 0, 3)
        else
            button.BackgroundColor3 = CONFIG.ToggleOff
            knob.Position = UDim2.new(0, 3, 0, 3)
        end
    end
    
    -- Set initial visuals
    updateVisuals()
    
    button.MouseButton1Click:Connect(function()
        state = not state
        
        updateVisuals()
        
        if collapsibleContainer then
            collapsibleContainer.setOpen(state)
        end
        
        -- Update sizes
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
            mainContainer = mainContainer,
            setState = function(value)
                state = value
                updateVisuals()
                if collapsibleContainer then
                    collapsibleContainer.setOpen(value)
                end
            end
        }
    end
    
    return {
        setState = function(value)
            state = value
            updateVisuals()
        end
    }
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

local function CreateColorPickerInCollapsible(collapsible, name, defaultColor, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = CONFIG.SurfaceLight
    container.BorderSizePixel = 0
    container.ZIndex = 16
    container.Parent = collapsible.container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 24)
    label.Position = UDim2.new(0, 8, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CONFIG.FontMedium
    label.TextSize = 9
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 17
    label.Parent = container
    
    local preview = Instance.new("TextButton")
    preview.Size = UDim2.new(0, 24, 0, 24)
    preview.Position = UDim2.new(1, -32, 0, 5)
    preview.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0)
    preview.BorderSizePixel = 0
    preview.Text = ""
    preview.AutoButtonColor = false
    preview.ZIndex = 17
    preview.Parent = container
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(1, 0)
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
        popup.ZIndex = 9999
        popup.Parent = ScreenGui
        
        local popupScale = Instance.new("UIScale")
        popupScale.Scale = 0.82
        popupScale.Parent = popup
        
        tween(popupScale, 0.22, {Scale = 1}):Play()
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
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
        title.ZIndex = 10001
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
        close.ZIndex = 10002
        close.AutoButtonColor = false
        close.Parent = popup
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(1, 0)
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
        wheel.ZIndex = 10000
        wheel.Image = "rbxassetid://6020299385"
        wheel.ScaleType = Enum.ScaleType.Fit
        wheel.Parent = popup
        
        local wheelCorner = Instance.new("UICorner")
        wheelCorner.CornerRadius = UDim.new(1, 0)
        wheelCorner.Parent = wheel
        
        local centerSize = 38
        
        local center = Instance.new("Frame")
        center.Size = UDim2.new(0, centerSize, 0, centerSize)
        center.Position = UDim2.new(0.5, -centerSize / 2, 0.5, -centerSize / 2)
        center.BackgroundColor3 = Color3.new(1, 1, 1)
        center.BorderSizePixel = 0
        center.ZIndex = 10001
        center.Parent = wheel
        
        local centerCorner = Instance.new("UICorner")
        centerCorner.CornerRadius = UDim.new(1, 0)
        centerCorner.Parent = center
        
        local cursor = Instance.new("Frame")
        cursor.Size = UDim2.new(0, 12, 0, 12)
        cursor.AnchorPoint = Vector2.new(0.5, 0.5)
        cursor.Position = UDim2.new(0.5, 0, 0.5, 0)
        cursor.BackgroundColor3 = Color3.new(1, 1, 1)
        cursor.BorderSizePixel = 0
        cursor.ZIndex = 10005
        cursor.Parent = wheel
        
        local cursorCorner = Instance.new("UICorner")
        cursorCorner.CornerRadius = UDim.new(1, 0)
        cursorCorner.Parent = cursor
        
        local cursorStroke = Instance.new("UIStroke")
        cursorStroke.Color = Color3.new(0, 0, 0)
        cursorStroke.Thickness = 2
        cursorStroke.Parent = cursor
        
        local rgb = Instance.new("TextLabel")
        rgb.Size = UDim2.new(1, -20, 0, 20)
        rgb.Position = UDim2.new(0, 10, 0, 193)
        rgb.BackgroundTransparency = 1
        rgb.Text = string.format("RGB: %d, %d, %d", 
            math.floor(defaultColor.R * 255), 
            math.floor(defaultColor.G * 255), 
            math.floor(defaultColor.B * 255))
        rgb.Font = CONFIG.FontMedium
        rgb.TextSize = 9
        rgb.TextColor3 = CONFIG.Text
        rgb.TextXAlignment = Enum.TextXAlignment.Center
        rgb.ZIndex = 10001
        rgb.Parent = popup
        
        local presets = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 128, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(0, 128, 255),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(128, 0, 255),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(0, 0, 0),
        }
        
        local function setColor(color)
            preview.BackgroundColor3 = color
            
            rgb.Text = string.format("RGB: %d, %d, %d",
                math.floor(color.R * 255),
                math.floor(color.G * 255),
                math.floor(color.B * 255))
            
            local h, s = color:ToHSV()
            
            local radius = wheelSize / 2
            local distance = radius * s
            local angle = h * math.pi * 2
            
            cursor.Position = UDim2.new(0.5, math.cos(angle) * distance, 0.5, math.sin(angle) * distance)
            
            if callback then callback(color) end
        end
        
        for i, color in ipairs(presets) do
            local preset = Instance.new("TextButton")
            preset.Size = UDim2.new(0, 14, 0, 14)
            preset.Position = UDim2.new(0, 8 + (i - 1) * 18, 0, 218)
            preset.BackgroundColor3 = color
            preset.BorderSizePixel = 0
            preset.Text = ""
            preset.AutoButtonColor = false
            preset.ZIndex = 10002
            preset.Parent = popup
            
            local pc = Instance.new("UICorner")
            pc.CornerRadius = UDim.new(1, 0)
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
            
            if hue < 0 then hue = hue + 1 end
            
            local saturation = math.clamp(distance / radius, 0, 1)
            
            local color = Color3.fromHSV(hue, saturation, 1)
            
            preview.BackgroundColor3 = color
            
            rgb.Text = string.format("RGB: %d, %d, %d",
                math.floor(color.R * 255),
                math.floor(color.G * 255),
                math.floor(color.B * 255))
            
            cursor.Position = UDim2.new(0.5, dx, 0.5, dy)
            
            if callback then callback(color) end
        end
        
        wheel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingWheel = true
                pickColor(input)
            end
        end)
        
        local move = UIS.InputChanged:Connect(function(input)
            if not draggingWheel then return end
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
-- RAGEBOT SYSTEM
--========================
local WallbangSystem = nil
local WallbangEnabled = false
local desyncShootPos = nil
local voidPosition = Vector3.new(0, -1000, 0)

local function EnableWallbang()
    if WallbangSystem then return end
    WallbangEnabled = true
    
    local RepStorage = ReplicatedStorage
    local LP = Player
    local GunModule = require(LP.PlayerScripts.Modules.ItemTypes.Gun)
    local UtilityModule = require(RepStorage.Modules.Utility)
    
    local CharHelper = setmetatable({}, {
        __index = function(_, key)
            local char = LP.Character
            if not char then return nil end
            if key == "root" then return char:FindFirstChild("HumanoidRootPart")
            elseif key == "head" then return char:FindFirstChild("Head") end
            return nil
        end
    })
    
    WallbangSystem = {Active = true}
    local Controller = WallbangSystem
    
    function Controller:FindTarget()
        local myChar = LP.Character
        if not myChar then return nil end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        
        local closest = nil
        local closestDist = math.huge
        
        for _, player in next, Players:GetPlayers() do
            if player == LP then continue end
            if isTeammate(player) then continue end
            
            local char = player.Character
            if not char then continue end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            
            if not (root and head and hum and hum.Health > 0) then continue end
            
            local dist = (myRoot.Position - root.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
        
        return closest
    end
    
    Controller.Connection = RunService.Heartbeat:Connect(function()
        if not Controller.Active then return end
        
        Controller.Target = Controller:FindTarget()
        
        if Controller.Target and Controller.Target.Character then
            local enemyHead = Controller.Target.Character:FindFirstChild("Head")
            if enemyHead then
                local root = CharHelper.root
                if root then
                    local savedCF = root.CFrame
                    local savedVel = root.Velocity
                    local savedRotVel = root.RotVelocity
                    
                    root.CFrame = enemyHead.CFrame
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                    desyncShootPos = enemyHead.Position
                    
                    RunService:BindToRenderStep("WallbangRestore", 101, function()
                        root.CFrame = savedCF
                        root.Velocity = savedVel
                        root.RotVelocity = savedRotVel
                        RunService:UnbindFromRenderStep("WallbangRestore")
                    end)
                end
            end
        else
            local root = CharHelper.root
            if root then
                local savedCF = root.CFrame
                local savedVel = root.Velocity
                local savedRotVel = root.RotVelocity
                
                root.CFrame = CFrame.new(voidPosition)
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
                desyncShootPos = voidPosition
                
                RunService:BindToRenderStep("WallbangVoid", 101, function()
                    root.CFrame = savedCF
                    root.Velocity = savedVel
                    root.RotVelocity = savedRotVel
                    RunService:UnbindFromRenderStep("WallbangVoid")
                end)
            end
        end
    end)
    
    local OriginalShoot = GunModule.StartShooting
    Controller.OldShootFunc = OriginalShoot
    
    GunModule.StartShooting = function(gun, ...)
        local results = {OriginalShoot(gun, ...)}
        
        if not gun.ClientFighter or not gun.ClientFighter.IsLocalPlayer then
            return unpack(results)
        end
        
        local data = results[3]
        if not data or typeof(data) ~= "table" then
            return unpack(results)
        end
        
        results[4] = true
        
        local target = Controller.Target
        if not Controller.Active or not target or not target.Character then
            return unpack(results)
        end
        
        local head = target.Character:FindFirstChild("Head")
        if not head then return unpack(results) end
        
        local headPos = head.Position
        local headCF = head.CFrame
        local offset = headCF:ToObjectSpace(CFrame.new(headPos + Vector3.new(math.random() * 0.1, math.random() * 0.1, math.random() * 0.1)))
        
        data[utf8.char(0)] = UtilityModule:EncodeCFrame(CFrame.new(headPos, headPos + head.CFrame.LookVector))
        data[utf8.char(1)] = UtilityModule:EncodeCFrame(CFrame.new(headPos))
        data[utf8.char(2)] = head
        data[utf8.char(3)] = UtilityModule:EncodeCFrame(offset)
        
        return unpack(results)
    end
    
    function Controller:Shutdown()
        self.Active = false
        desyncShootPos = nil
        
        if self.Connection then
            self.Connection:Disconnect()
        end
        
        if self.OldShootFunc then
            GunModule.StartShooting = self.OldShootFunc
        end
        
        RunService:UnbindFromRenderStep("WallbangRestore")
        RunService:UnbindFromRenderStep("WallbangVoid")
    end
end

local function DisableWallbang()
    if WallbangSystem then
        WallbangSystem:Shutdown()
        WallbangSystem = nil
    end
    WallbangEnabled = false
    desyncShootPos = nil
end

local function ToggleWallbang(enabled)
    if enabled then
        EnableWallbang()
    else
        DisableWallbang()
    end
end

--========================
-- AUTO SHOOT SYSTEM
--========================
local AutoShootEnabled = false
local autoShootConnection = nil
local lastFire = 0

local Utility = require(ReplicatedStorage.Modules.Utility)
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)

local restricted = {
    "Medkit", "Grenade", "Flashbang", "Jump Pad", "Molotov", "Satchel",
    "Smoke Grenade", "War Horn", "Subspace Tripmine", "Warpstone"
}

local function isRestricted(weapon)
    if not weapon then return false end
    for _, w in ipairs(restricted) do
        if weapon == w then return true end
    end
    return false
end

local function getClosestEnemy()
    local myChar = Player.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local closest = nil
    local closestDist = math.huge
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            if isTeammate(plr) then continue end
            
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and not char:FindFirstChildOfClass("ForceField") then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local dist = (myRoot.Position - root.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = char
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

local function getWeapon()
    local vm = Workspace:FindFirstChild("ViewModels")
    if not vm then return nil end
    
    local fp = vm:FindFirstChild("FirstPerson")
    if not fp then return nil end
    
    for _, child in ipairs(fp:GetChildren()) do
        local dash = child.Name:find("-")
        if dash then
            return child.Name:sub(dash + 1):match("^%s*(.-)%s*$")
        end
    end
    
    return nil
end

local function isPlayerAlive()
    local char = Player.Character
    if not char then return false end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    return true
end

local function fire()
    if not AutoShootEnabled then return end
    if not isPlayerAlive() then return end
    
    local weap = getWeapon()
    if weap and isRestricted(weap) then return end
    
    local now = tick()
    local delay = SaveData.AutoShootDelay or 0.1
    if now - lastFire < delay then return end
    
    local target = getClosestEnemy()
    if not target then return end
    
    local head = target:FindFirstChild("Head")
    if not head then return end
    
    local targetPlayer = Players:GetPlayerFromCharacter(target)
    if not targetPlayer or isTeammate(targetPlayer) then return end
    
    pcall(function()
        local fighterController = require(Player.PlayerScripts.Controllers.FighterController)
        local equipped = fighterController.LocalFighter and fighterController.LocalFighter.EquippedItem
        if not equipped then return end
        
        local objId = equipped:Get("ObjectID")
        if not objId then return end
        
        lastFire = now
        
        local myChar = Player.Character
        local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local shootPos = root and root.Position or head.Position
        
        if WallbangEnabled and desyncShootPos then
            shootPos = desyncShootPos
        end
        
        local data = {
            [utf8.char(1)] = {
                [utf8.char(0)] = Utility:EncodeCFrame(CFrame.new(shootPos, head.Position)),
                [utf8.char(1)] = Utility:EncodeCFrame(CFrame.new(shootPos, head.Position)),
                [utf8.char(2)] = head,
                [utf8.char(3)] = Utility:EncodeCFrame(CFrame.new(0.43, 0.25, 0.42)),
            }
        }
        
        ReplicatedStorage.Remotes.Replication.Fighter.UseItem:FireServer(objId, EnumLibrary:ToEnum("StartShooting"), data, nil)
    end)
end

local function EnableAutoShoot()
    if AutoShootEnabled then return end
    AutoShootEnabled = true
    
    autoShootConnection = RunService.Heartbeat:Connect(function()
        if AutoShootEnabled then fire() end
    end)
end

local function DisableAutoShoot()
    AutoShootEnabled = false
    
    if autoShootConnection then
        autoShootConnection:Disconnect()
        autoShootConnection = nil
    end
end

local function ToggleAutoShoot(enabled)
    if enabled then
        EnableAutoShoot()
    else
        DisableAutoShoot()
    end
end

local function OnAutoShootDelay(value)
    SaveData.AutoShootDelay = value
    SaveSettings()
end

--========================
-- RAPID FIRE SYSTEM
--========================
local RapidFireEnabled = false

local function EnableRapidFire()
    if RapidFireEnabled then return end
    RapidFireEnabled = true
    
    pcall(function()
        local Storage = game:GetService("ReplicatedStorage")
        local Items = require(Storage.Modules.ItemLibrary).Items
        
        for name, data in pairs(Items) do
            if typeof(data) == "table" then
                if data.ShootSpread then data.ShootSpread = 0 end
                if data.ShootAccuracy then data.ShootAccuracy = 0 end
                if data.ShootRecoil then data.ShootRecoil = 0 end
                if data.ShootCooldown then data.ShootCooldown = 0.001 end
                if data.ShootBurstCooldown then data.ShootBurstCooldown = 0.001 end
                if data.AttackCooldown then data.AttackCooldown = 0.001 end
                if data.SwingCooldown then data.SwingCooldown = 0.001 end
                if data.MeleeCooldown then data.MeleeCooldown = 0.001 end
                if data.Cooldown then data.Cooldown = 0.001 end
                if data.RecoveryTime then data.RecoveryTime = 0.001 end
                if data.ResetTime then data.ResetTime = 0.001 end
                if data.ReloadTime then data.ReloadTime = 0.001 end
                if data.ChargeTime then data.ChargeTime = 0.001 end
            end
        end
    end)
end

local function DisableRapidFire()
    RapidFireEnabled = false
end

local function ToggleRapidFire(enabled)
    if enabled then
        EnableRapidFire()
    else
        DisableRapidFire()
    end
end

--========================
-- FLY SYSTEM
--========================
local FlyEnabled = false
local flyAttachment, flyVelocity, flyAlign
local flyHumanoid, flyRoot

local function setupFlyPhysics()
    local char = Player.Character or Player.CharacterAdded:Wait()
    flyHumanoid = char:WaitForChild("Humanoid")
    flyRoot = char:WaitForChild("HumanoidRootPart")
    
    if FlyEnabled then
        if flyAttachment then flyAttachment:Destroy() end
        flyHumanoid.PlatformStand = true
        
        flyAttachment = Instance.new("Attachment", flyRoot)
        flyVelocity = Instance.new("LinearVelocity", flyAttachment)
        flyVelocity.MaxForce = 9e9
        flyVelocity.VectorVelocity = Vector3.zero
        flyVelocity.Attachment0 = flyAttachment
        
        flyAlign = Instance.new("AlignOrientation", flyAttachment)
        flyAlign.MaxTorque = 9e9
        flyAlign.Responsiveness = 200
        flyAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
        flyAlign.Attachment0 = flyAttachment
    end
end

Player.CharacterAdded:Connect(function()
    task.wait(0.1)
    setupFlyPhysics()
end)

setupFlyPhysics()

local PlayerModule = require(Player.PlayerScripts:WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

RunService.RenderStepped:Connect(function()
    if FlyEnabled and flyRoot and Camera and flyVelocity and flyAlign then
        local cam = Camera
        local moveVector = Controls:GetMoveVector()
        local speed = SaveData.FlySpeed or 80
        
        if moveVector.Magnitude > 0 then
            flyVelocity.VectorVelocity = (cam.CFrame.LookVector * -moveVector.Z + cam.CFrame.RightVector * moveVector.X).Unit * speed
        else
            flyVelocity.VectorVelocity = Vector3.zero
        end
        
        flyAlign.CFrame = cam.CFrame
    end
end)

local function EnableFly()
    FlyEnabled = true
    setupFlyPhysics()
end

local function DisableFly()
    FlyEnabled = false
    
    if flyHumanoid then flyHumanoid.PlatformStand = false end
    if flyAttachment then flyAttachment:Destroy() end
    
    flyAttachment = nil
    flyVelocity = nil
    flyAlign = nil
end

local function ToggleFly(enabled)
    if enabled then
        EnableFly()
    else
        DisableFly()
    end
end

local function OnFlySpeed(value)
    SaveData.FlySpeed = value
    SaveSettings()
end

--========================
-- INFINITE JUMP SYSTEM
--========================
local InfiniteJumpEnabled = false
local jumpConnection = nil

local function EnableInfiniteJump()
    if InfiniteJumpEnabled then return end
    InfiniteJumpEnabled = true
    
    jumpConnection = UIS.JumpRequest:Connect(function()
        if not InfiniteJumpEnabled then return end
        
        local char = Player.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function DisableInfiniteJump()
    InfiniteJumpEnabled = false
    
    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end
end

local function ToggleInfiniteJump(enabled)
    if enabled then
        EnableInfiniteJump()
    else
        DisableInfiniteJump()
    end
end

--========================
-- NOCLIP SYSTEM
--========================
local NoclipEnabled = false
local noclipConnection = nil

local function EnableNoclip()
    if NoclipEnabled then return end
    NoclipEnabled = true
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not NoclipEnabled then return end
        
        local char = Player.Character
        if not char then return end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function DisableNoclip()
    NoclipEnabled = false
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function ToggleNoclip(enabled)
    if enabled then
        EnableNoclip()
    else
        DisableNoclip()
    end
end

--========================
-- ESP SYSTEM
--========================
local EspEnabled = false
local ESPObjects = {}
local espConnection = nil

local function newDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function createESPElements(player)
    local elements = {}
    
    if SaveData.EspBoxes then
        if SaveData.EspBoxOutline then
            elements.BoxOutline = newDrawing("Square", {
                Visible = false, Thickness = 3, Filled = false, Color = Color3.new(0, 0, 0)
            })
        end
        elements.Box = newDrawing("Square", {
            Visible = false, Thickness = 1.5, Filled = false, Color = SaveData.EspBoxColor or Color3.fromRGB(0, 150, 255)
        })
    end
    
    if SaveData.EspNames then
        elements.Name = newDrawing("Text", {
            Visible = false, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0),
            Size = 13, Font = 2, Color = SaveData.EspNameColor or Color3.new(1, 1, 1)
        })
    end
    
    if SaveData.EspHealth then
        elements.HealthBarBG = newDrawing("Line", {Visible = false, Thickness = 5, Color = Color3.new(0, 0, 0)})
        elements.HealthBar = newDrawing("Line", {Visible = false, Thickness = 3, Color = SaveData.EspHealthColor or Color3.new(0, 1, 0)})
    end
    
    if SaveData.EspDistance then
        elements.Distance = newDrawing("Text", {
            Visible = false, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0),
            Size = 11, Font = 2, Color = SaveData.EspDistanceColor or Color3.new(1, 1, 1)
        })
    end
    
    if SaveData.EspHealthNumber then
        elements.HealthNumber = newDrawing("Text", {
            Visible = false, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0),
            Size = 11, Font = 2, Color = SaveData.EspHealthNumberColor or Color3.new(1, 1, 1)
        })
    end
    
    if SaveData.EspTracers then
        elements.Tracer = newDrawing("Line", {
            Visible = false, Thickness = 1, Color = SaveData.EspTracerColor or Color3.fromRGB(0, 150, 255)
        })
    end
    
    return elements
end

local function getBoxScreenPoints(cframe, size)
    local half = size / 2
    local points = {}
    local visible = true
    
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local corner = cframe * Vector3.new(half.X * x, half.Y * y, half.Z * z)
                local screenPos, onScreen = Camera:WorldToViewportPoint(corner)
                if not onScreen then visible = false end
                table.insert(points, Vector2.new(screenPos.X, screenPos.Y))
            end
        end
    end
    
    return points, visible
end

local function hideAll(data)
    for _, drawing in pairs(data) do
        if drawing and drawing.Visible then
            drawing.Visible = false
        end
    end
end

local function applyChams(character)
    if not SaveData.EspChams then return end
    if not character then return end
    
    local bodyParts = {
        "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
        "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm",
        "LeftLowerArm", "RightLowerArm", "LeftUpperLeg", "RightUpperLeg",
        "LeftLowerLeg", "RightLowerLeg", "HumanoidRootPart"
    }
    
    for _, partName in ipairs(bodyParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.Transparency = 0.3
            part.Material = Enum.Material.ForceField
            part.Color = SaveData.EspChamsColor or Color3.fromRGB(0, 150, 255)
        end
    end
end

local function removeChams(character)
    if not character then return end
    
    local bodyParts = {
        "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
        "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm",
        "LeftLowerArm", "RightLowerArm", "LeftUpperLeg", "RightUpperLeg",
        "LeftLowerLeg", "RightLowerLeg", "HumanoidRootPart"
    }
    
    for _, partName in ipairs(bodyParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.Transparency = 0
            part.Material = Enum.Material.Plastic
        end
    end
end

local function updateESP()
    if not EspEnabled then
        for _, data in pairs(ESPObjects) do
            hideAll(data)
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                removeChams(player.Character)
            end
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end
        
        if isTeammate(player) then
            if ESPObjects[player] then hideAll(ESPObjects[player]) end
            if player.Character then removeChams(player.Character) end
            continue
        end
        
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if character and humanoid and humanoid.Health > 0 then
            if SaveData.EspChams then
                applyChams(character)
            else
                removeChams(character)
            end
            
            if SaveData.EspBoxes or SaveData.EspNames or SaveData.EspHealth or SaveData.EspDistance or SaveData.EspHealthNumber or SaveData.EspTracers then
                local success, cframe, size = pcall(character.GetBoundingBox, character)
                
                if success and cframe and size then
                    local points, visible = getBoxScreenPoints(cframe, size)
                    
                    if not visible then
                        if ESPObjects[player] then hideAll(ESPObjects[player]) end
                    else
                        local data = ESPObjects[player] or createESPElements(player)
                        ESPObjects[player] = data
                        
                        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
                        
                        for _, pt in ipairs(points) do
                            minX = math.min(minX, pt.X)
                            minY = math.min(minY, pt.Y)
                            maxX = math.max(maxX, pt.X)
                            maxY = math.max(maxY, pt.Y)
                        end
                        
                        local boxWidth, boxHeight = maxX - minX, maxY - minY
                        local slimWidth = boxWidth * 0.7
                        local slimX = minX + (boxWidth - slimWidth) / 2
                        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local head = character:FindFirstChild("Head")
                        
                        if data.BoxOutline and SaveData.EspBoxes and SaveData.EspBoxOutline then
                            data.BoxOutline.Visible = true
                            data.BoxOutline.Position = Vector2.new(slimX - 1, minY - 1)
                            data.BoxOutline.Size = Vector2.new(slimWidth + 2, boxHeight + 2)
                        end
                        
                        if data.Box and SaveData.EspBoxes then
                            data.Box.Visible = true
                            data.Box.Position = Vector2.new(slimX, minY)
                            data.Box.Size = Vector2.new(slimWidth, boxHeight)
                        end
                        
                        if data.Name and SaveData.EspNames then
                            data.Name.Visible = true
                            data.Name.Text = player.Name
                            data.Name.Position = Vector2.new(slimX + slimWidth / 2, minY - 16)
                        end
                        
                        local barHeight = boxHeight * healthRatio
                        
                        if data.HealthBarBG and SaveData.EspHealth then
                            data.HealthBarBG.Visible = true
                            data.HealthBarBG.From = Vector2.new(slimX - 6, maxY)
                            data.HealthBarBG.To = Vector2.new(slimX - 6, minY)
                        end
                        
                        if data.HealthBar and SaveData.EspHealth then
                            data.HealthBar.Visible = true
                            
                            if healthRatio > 0.7 then
                                data.HealthBar.Color = SaveData.EspHealthColor or Color3.fromRGB(0, 255, 0)
                            elseif healthRatio > 0.3 then
                                data.HealthBar.Color = Color3.fromRGB(255, 165, 0)
                            else
                                data.HealthBar.Color = Color3.fromRGB(255, 0, 0)
                            end
                            
                            data.HealthBar.From = Vector2.new(slimX - 6, maxY)
                            data.HealthBar.To = Vector2.new(slimX - 6, maxY - barHeight)
                        end
                        
                        if data.Distance and SaveData.EspDistance and head then
                            local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                            if myRoot then
                                local dist = math.floor((myRoot.Position - head.Position).Magnitude)
                                data.Distance.Visible = true
                                data.Distance.Text = dist .. "m"
                                data.Distance.Position = Vector2.new(slimX + slimWidth / 2, maxY + 4)
                            end
                        end
                        
                        if data.HealthNumber and SaveData.EspHealthNumber then
                            data.HealthNumber.Visible = true
                            data.HealthNumber.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                            data.HealthNumber.Position = Vector2.new(slimX + slimWidth / 2, maxY + 16)
                        end
                        
                        if data.Tracer and SaveData.EspTracers then
                            local root = character:FindFirstChild("HumanoidRootPart")
                            if root then
                                local screenPos = Camera:WorldToViewportPoint(root.Position)
                                local screenSize = Camera.ViewportSize
                                
                                data.Tracer.Visible = true
                                data.Tracer.From = Vector2.new(screenSize.X / 2, screenSize.Y)
                                data.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                            end
                        end
                    end
                end
            end
        else
            if ESPObjects[player] then hideAll(ESPObjects[player]) end
            if character then removeChams(character) end
        end
    end
end

local function EnableEsp()
    EspEnabled = true
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.RenderStepped:Connect(updateESP)
end

local function DisableEsp()
    EspEnabled = false
    
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    
    for _, data in pairs(ESPObjects) do
        pcall(function()
            for _, obj in pairs(data) do
                if obj and obj.Remove then obj:Remove() end
            end
        end)
    end
    
    ESPObjects = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            removeChams(player.Character)
        end
    end
end

local function ToggleEsp(enabled)
    if enabled then
        EnableEsp()
    else
        DisableEsp()
    end
end

local function RefreshESP()
    if EspEnabled then
        DisableEsp()
        EnableEsp()
    end
end

local function ToggleEspBoxes(enabled)
    SaveData.EspBoxes = enabled
    SaveSettings()
    RefreshESP()
end

local function ToggleEspNames(enabled)
    SaveData.EspNames = enabled
    SaveSettings()
    RefreshESP()
end

local function ToggleEspHealth(enabled)
    SaveData.EspHealth = enabled
    SaveSettings()
    RefreshESP()
end

local function ToggleEspDistance(enabled)
    SaveData.EspDistance = enabled
    SaveSettings()
    RefreshESP()
end

local function ToggleEspHealthNumber(enabled)
    SaveData.EspHealthNumber = enabled
    SaveSettings()
    RefreshESP()
end

local function ToggleEspChams(enabled)
    SaveData.EspChams = enabled
    SaveSettings()
    RefreshESP()
end

local function ToggleEspTracers(enabled)
    SaveData.EspTracers = enabled
    SaveSettings()
    RefreshESP()
end

local function ToggleEspBoxOutline(enabled)
    SaveData.EspBoxOutline = enabled
    SaveSettings()
    RefreshESP()
end

local function OnEspBoxColorChange(color)
    SaveData.EspBoxColor = color
    SaveSettings()
    RefreshESP()
end

local function OnEspNameColorChange(color)
    SaveData.EspNameColor = color
    SaveSettings()
    RefreshESP()
end

local function OnEspHealthColorChange(color)
    SaveData.EspHealthColor = color
    SaveSettings()
    RefreshESP()
end

local function OnEspDistanceColorChange(color)
    SaveData.EspDistanceColor = color
    SaveSettings()
    RefreshESP()
end

local function OnEspHealthNumberColorChange(color)
    SaveData.EspHealthNumberColor = color
    SaveSettings()
    RefreshESP()
end

local function OnEspChamsColorChange(color)
    SaveData.EspChamsColor = color
    SaveSettings()
    RefreshESP()
end

local function OnEspTracerColorChange(color)
    SaveData.EspTracerColor = color
    SaveSettings()
    RefreshESP()
end

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function()
                if obj and obj.Remove then obj:Remove() end
            end)
        end
        ESPObjects[player] = nil
    end
    
    if player.Character then
        removeChams(player.Character)
    end
end)

--========================
-- ANIMATION SYSTEM
--========================
local animPlayer = {
    enabled = false,
    animationId = "",
    loop = true,
    speed = 2,
    serverSide = true,
    jitter = false,
    jitterId = "",
    jitterSpeed = 0.1,
    spawnProof = true,
}

local animTracks = {}

local animPresets = {
    ["Underground Glitch"] = "138847307095534",
    ["Orbit"] = "133811691098518",
    ["Tweaking"] = "114353590132838",
    ["Kicking Feet"] = "131879764029003",
    ["Low Cortisol"] = "125822752810863",
    ["Floss"] = "72174079036035",
    ["Take the L"] = "112884830175040",
    ["Upside Down"] = "128616002281906",
    ["Michael Myers Shake"] = "123682198526131",
    ["Headless"] = "74738520664045",
    ["Wall Peek L"] = "123671647250039",
    ["Glitch Through"] = "85364072005108",
    ["Spin"] = "97064653080056",
}

local function stopAllAnims()
    for _, track in ipairs(animTracks) do
        pcall(function()
            track:Stop(0)
            track:Destroy()
        end)
    end
    animTracks = {}
end

local function getAnimator(char)
    if not char then return nil end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    
    return animator
end

local function downloadAnimation(animId)
    local s, o = pcall(function()
        return game:GetObjects("rbxassetid://" .. animId)
    end)
    
    if not s or not o or #o == 0 then return nil end
    
    for _, obj in ipairs(o) do
        if obj:IsA("Animation") and obj.AnimationId ~= "" then
            return obj
        end
    end
    
    for _, obj in ipairs(o) do
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("Animation") and d.AnimationId ~= "" then
                return d
            end
        end
    end
    
    return nil
end

local function playAnimOnChar(char, animId, speed, looped)
    if not char or animId == "" then return nil end
    
    local animator = getAnimator(char)
    if not animator then return nil end
    
    local anim = downloadAnimation(animId)
    if not anim then
        anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. animId
    end
    
    local s, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)
    
    if not s or not track then
        pcall(function() anim:Destroy() end)
        return nil
    end
    
    track.Looped = looped
    track.Priority = Enum.AnimationPriority.Action4
    track:Play(0.1, 1, speed)
    
    return track
end

local function playAnimation()
    stopAllAnims()
    
    if not animPlayer.enabled or animPlayer.animationId == "" then return end
    
    local char = Player.Character
    if char then
        local t = playAnimOnChar(char, animPlayer.animationId, animPlayer.speed, animPlayer.loop)
        if t then table.insert(animTracks, t) end
    end
    
    local live = Workspace:FindFirstChild("Live")
    if live then
        local sc = live:FindFirstChild(Player.Name)
        if sc then
            local st = playAnimOnChar(sc, animPlayer.animationId, animPlayer.speed, animPlayer.loop)
            if st then table.insert(animTracks, st) end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not animPlayer.enabled then return end
    if #animTracks == 0 and animPlayer.animationId ~= "" then
        playAnimation()
    end
    
    for _, track in ipairs(animTracks) do
        pcall(function()
            track:AdjustSpeed(animPlayer.speed)
        end)
    end
end)

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if animPlayer.enabled and animPlayer.spawnProof then
        playAnimation()
    end
end)

local function ToggleAnimation(enabled)
    if enabled then
        animPlayer.enabled = true
        local presetId = animPresets[SaveData.AnimationPreset]
        if presetId then animPlayer.animationId = presetId end
        animPlayer.speed = SaveData.AnimationSpeed
        animPlayer.loop = true
        animPlayer.serverSide = true
        playAnimation()
    else
        animPlayer.enabled = false
        stopAllAnims()
    end
end

local function OnAnimationPresetChanged(preset)
    SaveData.AnimationPreset = preset
    SaveSettings()
    
    local presetId = animPresets[preset]
    if presetId then
        animPlayer.animationId = presetId
        if animPlayer.enabled then
            playAnimation()
        end
    end
end

local function OnAnimationSpeedChange(value)
    SaveData.AnimationSpeed = value
    SaveSettings()
    animPlayer.speed = value
end

--========================
-- AIMBOT SYSTEM
--========================
local fovScreenGui = Instance.new("ScreenGui")
fovScreenGui.Name = "AimbotFOV"
fovScreenGui.ResetOnSpawn = false
fovScreenGui.IgnoreGuiInset = true
fovScreenGui.DisplayOrder = 999998
fovScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fovScreenGui.Parent = PlayerGui

local aimbot = {
    enabled = false,
    masterEnabled = false,
    keyMode = "toggle",
    showFov = false,
    targetPart = "Head",
    fovRadius = 500,
    smoothness = 2,
    aimCurve = "Linear",
    followMuzzle = false,
    lockedTarget = nil,
    smoothCF = nil,
    teamCheck = true,
    aliveCheck = true,
    wallCheck = false,
}

local aimbotFOVCfg = {
    OutlineColor1 = Color3.fromRGB(255, 255, 255),
    OutlineColor2 = Color3.fromRGB(255, 255, 255),
    OutlineRotation = 0,
    OutlineThickness = 1.5,
    OutlineTransparency = 0,
    FilledEnabled = false,
    FilledColor1 = Color3.fromRGB(255, 255, 255),
    FilledColor2 = Color3.fromRGB(0, 0, 0),
    FilledRotation = 0,
    FilledTransparency = 0.7,
    FilledAnimated = false,
    FilledSpeed = 1,
    SpinOn = false,
    SpinSpd = 1,
}

local aimbotFOVContainer, aimbotFOVFill, aimbotFOVFillGrad, aimbotFOVStroke, aimbotFOVStrokeGrad

local function buildfov(name, cfg)
    local container = Instance.new("Frame")
    container.Name = name
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Visible = false
    container.Parent = fovScreenGui

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(1, 1, 1)
    fill.BackgroundTransparency = cfg.FilledTransparency
    fill.BorderSizePixel = 0
    fill.Visible = false
    fill.ZIndex = 1
    fill.Parent = container
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local fillgrad = Instance.new("UIGradient")
    fillgrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, cfg.FilledColor1),
        ColorSequenceKeypoint.new(1, cfg.FilledColor2),
    })
    fillgrad.Rotation = cfg.FilledRotation
    fillgrad.Parent = fill

    local outline = Instance.new("Frame")
    outline.Size = UDim2.new(1, 0, 1, 0)
    outline.BackgroundTransparency = 1
    outline.BorderSizePixel = 0
    outline.ZIndex = 2
    outline.Parent = container
    local outlineCorner = Instance.new("UICorner")
    outlineCorner.CornerRadius = UDim.new(1, 0)
    outlineCorner.Parent = outline

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = cfg.OutlineThickness
    stroke.Transparency = cfg.OutlineTransparency
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = outline

    local strokegrad = Instance.new("UIGradient")
    strokegrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, cfg.OutlineColor1),
        ColorSequenceKeypoint.new(1, cfg.OutlineColor2),
    })
    strokegrad.Rotation = cfg.OutlineRotation
    strokegrad.Parent = stroke

    return {
        container = container,
        fill = fill,
        fillgrad = fillgrad,
        stroke = stroke,
        strokegrad = strokegrad,
    }
end

local aimbotFOV = buildfov("AimbotFOV", aimbotFOVCfg)
aimbotFOVContainer = aimbotFOV.container
aimbotFOVFill = aimbotFOV.fill
aimbotFOVFillGrad = aimbotFOV.fillgrad
aimbotFOVStroke = aimbotFOV.stroke
aimbotFOVStrokeGrad = aimbotFOV.strokegrad

local function worldToScreen(wp, cam)
    cam = cam or Camera
    if not cam or not wp then return nil, false end
    local v, on = cam:WorldToViewportPoint(wp)
    if not on or v.Z <= 0 then return v, false end
    return v, true
end

local function screenCenter(cam)
    cam = cam or Camera
    if not cam then return Vector2.zero end
    local vs = cam.ViewportSize
    return Vector2.new(vs.X * 0.5, vs.Y * 0.5)
end

local function screenpos2(wp)
    if not wp then return nil end
    local sp, ok = worldToScreen(wp, Camera)
    if not ok then return nil end
    return Vector2.new(sp.X, sp.Y)
end

local function findShotMuzzlePosition()
    local myChar = Player.Character
    if not myChar then
        local cam = workspace.CurrentCamera
        return cam and (cam.CFrame.Position + cam.CFrame.LookVector * 4) or Vector3.zero
    end
    local vm = Workspace:FindFirstChild("ViewModels")
    if vm then
        local fp = vm:FindFirstChild("FirstPerson")
        if fp then
            for _, m in ipairs(fp:GetChildren()) do
                if m:IsA("Model") then
                    local iv = m:FindFirstChild("ItemVisual")
                    if iv then
                        local b = iv:FindFirstChild("Body")
                        if b then
                            local bp = b:FindFirstChild("BodyPrimary")
                            if bp then
                                local mz = bp:FindFirstChild("_muzzle")
                                if mz and mz:IsA("Attachment") then return mz.WorldPosition end
                            end
                        end
                    end
                    local mz = m:FindFirstChild("Muzzle") or m:FindFirstChild("MuzzleFlash") or m:FindFirstChild("Barrel") or m:FindFirstChild("GunTip")
                    if mz then
                        if mz:IsA("Attachment") then return mz.WorldPosition end
                        if mz:IsA("BasePart") then return mz.Position end
                    end
                    for _, p in ipairs(m:GetChildren()) do
                        if p:IsA("BasePart") then
                            local pn = p.Name:lower()
                            if pn:find("tip") or pn:find("barrel") or pn:find("muzzle") then return p.Position end
                        end
                    end
                    local pp = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                    if pp then return pp.Position end
                end
            end
        end
    end
    local cam = workspace.CurrentCamera
    if cam then return cam.CFrame.Position + cam.CFrame.LookVector * 4 end
    local root = myChar:FindFirstChild("HumanoidRootPart")
    return root and root.Position or Vector3.zero
end

local function aimbotfovcenter()
    if aimbot.followMuzzle then
        local s = screenpos2(findShotMuzzlePosition())
        if s then return s end
    end
    return screenCenter(Camera)
end

local function getAimbotScreenPoint()
    if aimbot.followMuzzle then return aimbotfovcenter() end
    local loc = UIS:GetMouseLocation()
    return Vector2.new(loc.X, loc.Y)
end

local function aimbotIsTeammate(player)
    if not aimbot.teamCheck then return false end
    if not player then return false end
    local mt = Player:GetAttribute("TeamID")
    local tt = player:GetAttribute("TeamID")
    if mt and tt and mt == tt then return true end
    if Player.Team and player.Team and Player.Team == player.Team then return true end
    return false
end

local function aimbotIsAlive(player)
    if not aimbot.aliveCheck then return true end
    if not player then return false end
    local char = player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function aimbotIsVisible(player)
    if not aimbot.wallCheck then return true end
    if not player or not player.Character then return false end
    local targetPart = player.Character:FindFirstChild(aimbot.targetPart)
    if not targetPart then targetPart = player.Character:FindFirstChild("Head") end
    if not targetPart then return false end
    local cp = Camera.CFrame.Position
    local tp = targetPart.Position
    local dir = (tp - cp).Unit
    local dist = (tp - cp).Magnitude
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {Player.Character}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.IgnoreWater = true
    local rr = workspace:Raycast(cp, dir * dist, rp)
    if not rr then return true end
    local hm = rr.Instance:FindFirstAncestorOfClass("Model")
    if hm == player.Character then return true end
    return rr.Instance:IsDescendantOf(player.Character)
end

local function aimbotIsValidTarget(player)
    if not player then return false end
    if player == Player then return false end
    if aimbotIsTeammate(player) then return false end
    if not aimbotIsAlive(player) then return false end
    if not aimbotIsVisible(player) then return false end
    local char = player.Character
    if not char then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    return true
end

local function closesttocursor()
    local best, bestDist = nil, aimbot.fovRadius
    local mp = getAimbotScreenPoint()
    if not mp then return nil end
    local cam = Camera
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and aimbotIsValidTarget(p) then
            local part = p.Character:FindFirstChild(aimbot.targetPart)
            if part and part:IsDescendantOf(workspace) then
                local scr, on = worldToScreen(part.Position, cam)
                if on then
                    local dx = scr.X - mp.X
                    local dy = scr.Y - mp.Y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < bestDist then
                        bestDist = dist
                        best = part
                    end
                end
            end
        end
    end
    return best
end

local function getAimbotLerpAlpha(dt)
    local smoothness = math.clamp(tonumber(aimbot.smoothness) or 2, 0.1, 10)
    local curve = aimbot.aimCurve or "Linear"
    local speed = 6 / smoothness
    if curve == "Instant" then return 1
    elseif curve == "Expo" then return 1 - math.exp(-(4 / smoothness) * dt)
    elseif curve == "EaseIn" then local t = math.clamp(speed * dt, 0, 1); return t * t
    elseif curve == "EaseOut" then local t = math.clamp(speed * dt, 0, 1); return 1 - (1 - t) * (1 - t)
    elseif curve == "EaseInOut" then local t = math.clamp(speed * dt, 0, 1); if t < 0.5 then return 2 * t * t end; return 1 - ((-2 * t + 2) ^ 2) / 2
    elseif curve == "Cubic" then local t = math.clamp(speed * dt, 0, 1); return t * t * t
    end
    return math.clamp(speed * dt, 0, 1)
end

local function clearAimbotLock()
    aimbot.lockedTarget = nil
    aimbot.smoothCF = nil
end

local function getUnstretchedCameraCFrame(cam)
    cam = cam or Camera
    if not cam then return nil end
    local cf = cam.CFrame
    local pos = cf.Position
    local look = cf.LookVector
    local right = cf.RightVector
    local up = right:Cross(look).Unit
    return CFrame.fromMatrix(pos, right, up, -look)
end

local camController
pcall(function()
    local ctrl = Player.PlayerScripts:WaitForChild("Controllers", 10)
    local cm = ctrl:FindFirstChild("CameraController")
    if cm and cm:IsA("ModuleScript") then camController = require(cm) end
end)

local function updaimbot()
    aimbotFOVContainer.Visible = aimbot.showFov
    if not aimbot.enabled then
        clearAimbotLock()
        return
    end
end

local function stepAimbot(dt)
    dt = dt or (1 / 240)
    if not aimbot.enabled then
        clearAimbotLock()
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    Camera = cam

    if not aimbot.lockedTarget then
        aimbot.lockedTarget = closesttocursor()
        aimbot.smoothCF = getUnstretchedCameraCFrame(cam)
        if not aimbot.lockedTarget then return end
    end

    if not aimbot.lockedTarget.Parent or not aimbot.lockedTarget:IsDescendantOf(workspace) then
        clearAimbotLock()
        return
    end

    local targetPlayer = Players:GetPlayerFromCharacter(aimbot.lockedTarget.Parent)
    if targetPlayer then
        if not aimbotIsValidTarget(targetPlayer) then
            clearAimbotLock()
            return
        end
    end

    local myChar = Player.Character
    if not myChar then return end
    local myHead = myChar:FindFirstChild("Head")
    if not myHead then
        clearAimbotLock()
        return
    end
    if not camController then return end

    if not aimbot.smoothCF then
        aimbot.smoothCF = getUnstretchedCameraCFrame(cam)
    end

    local lookCF = CFrame.lookAt(cam.CFrame.Position, aimbot.lockedTarget.Position)
    local alpha = getAimbotLerpAlpha(dt)
    aimbot.smoothCF = aimbot.smoothCF:Lerp(lookCF, alpha)

    if camController and camController.MimicRotation then
        pcall(function()
            camController:MimicRotation(aimbot.smoothCF)
        end)
    end
end

RunService:BindToRenderStep("InstanceAimbotUpdate", Enum.RenderPriority.Camera.Value + 1, stepAimbot)

RunService.RenderStepped:Connect(function()
    if aimbotFOVContainer.Visible then
        local c = aimbotfovcenter()
        local r = aimbot.fovRadius
        aimbotFOVContainer.Size = UDim2.fromOffset(r * 2, r * 2)
        aimbotFOVContainer.Position = UDim2.fromOffset(c.X - r, c.Y - r)
        if aimbotFOVCfg.FilledAnimated then
            aimbotFOVFillGrad.Rotation = math.sin(tick() * aimbotFOVCfg.FilledSpeed) * 180 + aimbotFOVCfg.FilledRotation
        elseif aimbotFOVCfg.SpinOn then
            aimbotFOVFillGrad.Rotation = aimbotFOVCfg.FilledRotation + (tick() * aimbotFOVCfg.SpinSpd * 90) % 360
        end
        if aimbotFOVCfg.SpinOn then
            aimbotFOVStrokeGrad.Rotation = aimbotFOVCfg.OutlineRotation + (tick() * aimbotFOVCfg.SpinSpd * 90) % 360
        end
    end
end)

updaimbot()

local function ToggleAimbot(enabled)
    aimbot.enabled = enabled
    SaveData.AimbotEnabled = enabled
    SaveSettings()
    if not enabled then
        clearAimbotLock()
    end
end

local function ToggleAimbotFOV(enabled)
    aimbot.showFov = enabled
    SaveData.AimbotShowFOV = enabled
    SaveSettings()
    aimbotFOVContainer.Visible = enabled
end

local function OnAimbotTargetPartChanged(part)
    aimbot.targetPart = part    SaveData.AimbotTargetPart = part
    SaveSettings()
    clearAimbotLock()
end

local function OnAimbotFOVRadiusChanged(value)
    aimbot.fovRadius = value
    SaveData.AimbotFOVRadius = value
    SaveSettings()
end

local function OnAimbotSmoothnessChanged(value)
    aimbot.smoothness = value
    SaveData.AimbotSmoothness = value
    SaveSettings()
end

local function OnAimbotCurveChanged(curve)
    aimbot.aimCurve = curve
    SaveData.AimbotCurve = curve
    SaveSettings()
end

local function ToggleAimbotFollowMuzzle(enabled)
    aimbot.followMuzzle = enabled
    SaveData.AimbotFollowMuzzle = enabled
    SaveSettings()
end

local function ToggleAimbotTeamCheck(enabled)
    aimbot.teamCheck = enabled
    SaveData.AimbotTeamCheck = enabled
    SaveSettings()
end

local function ToggleAimbotAliveCheck(enabled)
    aimbot.aliveCheck = enabled
    SaveData.AimbotAliveCheck = enabled
    SaveSettings()
end

local function ToggleAimbotWallCheck(enabled)
    aimbot.wallCheck = enabled
    SaveData.AimbotWallCheck = enabled
    SaveSettings()
end

--========================
-- CREATE UI ELEMENTS WITH COLLAPSIBLE
--========================
local toggleReferences = {}

-- Main Tab (Aimbot)
toggleReferences.AimbotToggle = CreateToggle("Main", "Enable Aimbot", SaveData.AimbotEnabled, ToggleAimbot, "left", true)
if toggleReferences.AimbotToggle.collapsible then
    CreateToggle("Main", "Show FOV Circle", SaveData.AimbotShowFOV, ToggleAimbotFOV, "left")
    CreateDropdownInCollapsible(toggleReferences.AimbotToggle.collapsible, "Target Part", {
        "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"
    }, SaveData.AimbotTargetPart, OnAimbotTargetPartChanged)
    CreateSliderInCollapsible(toggleReferences.AimbotToggle.collapsible, "FOV Radius", 50, 1000, SaveData.AimbotFOVRadius, OnAimbotFOVRadiusChanged)
    CreateSliderInCollapsible(toggleReferences.AimbotToggle.collapsible, "Smoothness", 0.1, 10, SaveData.AimbotSmoothness, OnAimbotSmoothnessChanged)
    CreateDropdownInCollapsible(toggleReferences.AimbotToggle.collapsible, "Aim Curve", {
        "Linear", "Instant", "Expo", "EaseIn", "EaseOut", "EaseInOut", "Cubic"
    }, SaveData.AimbotCurve, OnAimbotCurveChanged)
    CreateToggle("Main", "Follow Muzzle", SaveData.AimbotFollowMuzzle, ToggleAimbotFollowMuzzle, "left")
    CreateToggle("Main", "Team Check", SaveData.AimbotTeamCheck, ToggleAimbotTeamCheck, "left")
    CreateToggle("Main", "Alive Check", SaveData.AimbotAliveCheck, ToggleAimbotAliveCheck, "left")
    CreateToggle("Main", "Wall Check", SaveData.AimbotWallCheck, ToggleAimbotWallCheck, "left")
end

-- Ragebot Tab
toggleReferences.RagebotToggle = CreateToggle("Ragebot", "Ragebot", SaveData.Ragebot, ToggleWallbang, "left")

toggleReferences.AutoShootToggle = CreateToggle("Ragebot", "Auto Shoot", SaveData.AutoShoot, ToggleAutoShoot, "left", true)
if toggleReferences.AutoShootToggle.collapsible then
    CreateSliderInCollapsible(toggleReferences.AutoShootToggle.collapsible, "Shoot Delay", 0.0005, 5, SaveData.AutoShootDelay, OnAutoShootDelay)
end

toggleReferences.RapidFireToggle = CreateToggle("Ragebot", "Rapid Fire", SaveData.RapidFire, ToggleRapidFire, "left")

-- ESP Tab
toggleReferences.EspToggle = CreateToggle("ESP", "Enable ESP", SaveData.Esp, ToggleEsp, "left", true)
if toggleReferences.EspToggle.collapsible then
    local boxEsp = CreateToggle("ESP", "Box ESP", SaveData.EspBoxes, ToggleEspBoxes, "left", true)
    if boxEsp.collapsible then
        boxEsp.collapsible.container.Parent = toggleReferences.EspToggle.collapsible.container
        CreateColorPickerInCollapsible(boxEsp.collapsible, "Box Color", SaveData.EspBoxColor, OnEspBoxColorChange)
        CreateToggle("ESP", "Box Outline", SaveData.EspBoxOutline, ToggleEspBoxOutline, "left")
    end
    
    local healthEsp = CreateToggle("ESP", "Health Bar ESP", SaveData.EspHealth, ToggleEspHealth, "left", true)
    if healthEsp.collapsible then
        healthEsp.collapsible.container.Parent = toggleReferences.EspToggle.collapsible.container
        CreateColorPickerInCollapsible(healthEsp.collapsible, "Health Color", SaveData.EspHealthColor, OnEspHealthColorChange)
    end
    
    local nameEsp = CreateToggle("ESP", "Name ESP", SaveData.EspNames, ToggleEspNames, "left", true)
    if nameEsp.collapsible then
        nameEsp.collapsible.container.Parent = toggleReferences.EspToggle.collapsible.container
        CreateColorPickerInCollapsible(nameEsp.collapsible, "Name Color", SaveData.EspNameColor, OnEspNameColorChange)
    end
    
    local healthNumEsp = CreateToggle("ESP", "Health Number", SaveData.EspHealthNumber, ToggleEspHealthNumber, "left", true)
    if healthNumEsp.collapsible then
        healthNumEsp.collapsible.container.Parent = toggleReferences.EspToggle.collapsible.container
        CreateColorPickerInCollapsible(healthNumEsp.collapsible, "Health Number Color", SaveData.EspHealthNumberColor, OnEspHealthNumberColorChange)
    end
    
    local distEsp = CreateToggle("ESP", "Distance ESP", SaveData.EspDistance, ToggleEspDistance, "left", true)
    if distEsp.collapsible then
        distEsp.collapsible.container.Parent = toggleReferences.EspToggle.collapsible.container
        CreateColorPickerInCollapsible(distEsp.collapsible, "Distance Color", SaveData.EspDistanceColor, OnEspDistanceColorChange)
    end
    
    local tracerEsp = CreateToggle("ESP", "Tracer ESP", SaveData.EspTracers, ToggleEspTracers, "left", true)
    if tracerEsp.collapsible then
        tracerEsp.collapsible.container.Parent = toggleReferences.EspToggle.collapsible.container
        CreateColorPickerInCollapsible(tracerEsp.collapsible, "Tracer Color", SaveData.EspTracerColor, OnEspTracerColorChange)
    end
end

-- Misc Tab
toggleReferences.FlyToggle = CreateToggle("Misc", "Fly", SaveData.Fly, ToggleFly, "left", true)
if toggleReferences.FlyToggle.collapsible then
    CreateSliderInCollapsible(toggleReferences.FlyToggle.collapsible, "Fly Speed", 1, 500, SaveData.FlySpeed, OnFlySpeed)
end

toggleReferences.InfiniteJumpToggle = CreateToggle("Misc", "Infinite Jump", SaveData.InfiniteJump, ToggleInfiniteJump, "right")
toggleReferences.NoclipToggle = CreateToggle("Misc", "Noclip", SaveData.Noclip, ToggleNoclip, "right")

-- Animation Tab
toggleReferences.AnimationToggle = CreateToggle("Animation", "Enable Animation", SaveData.AnimationEnabled, ToggleAnimation, "left", true)
if toggleReferences.AnimationToggle.collapsible then
    CreateSliderInCollapsible(toggleReferences.AnimationToggle.collapsible, "Animation Speed", 1, 500, SaveData.AnimationSpeed, OnAnimationSpeedChange)
    CreateDropdownInCollapsible(toggleReferences.AnimationToggle.collapsible, "Anim Preset", {
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
task.spawn(function()
    task.wait(0.5)
    
    if SaveData.AimbotEnabled then
        ToggleAimbot(true)
        if toggleReferences.AimbotToggle and toggleReferences.AimbotToggle.setState then
            toggleReferences.AimbotToggle.setState(true)
        end
    end
    
    if SaveData.Ragebot then
        EnableWallbang()
        if toggleReferences.RagebotToggle and toggleReferences.RagebotToggle.setState then
            toggleReferences.RagebotToggle.setState(true)
        end
    end
    
    if SaveData.AutoShoot then
        EnableAutoShoot()
        if toggleReferences.AutoShootToggle and toggleReferences.AutoShootToggle.setState then
            toggleReferences.AutoShootToggle.setState(true)
        end
    end
    
    if SaveData.RapidFire then
        EnableRapidFire()
        if toggleReferences.RapidFireToggle and toggleReferences.RapidFireToggle.setState then
            toggleReferences.RapidFireToggle.setState(true)
        end
    end
    
    if SaveData.Fly then
        EnableFly()
        if toggleReferences.FlyToggle and toggleReferences.FlyToggle.setState then
            toggleReferences.FlyToggle.setState(true)
        end
    end
    
    if SaveData.InfiniteJump then
        EnableInfiniteJump()
        if toggleReferences.InfiniteJumpToggle and toggleReferences.InfiniteJumpToggle.setState then
            toggleReferences.InfiniteJumpToggle.setState(true)
        end
    end
    
    if SaveData.Noclip then
        EnableNoclip()
        if toggleReferences.NoclipToggle and toggleReferences.NoclipToggle.setState then
            toggleReferences.NoclipToggle.setState(true)
        end
    end
    
    if SaveData.Esp then
        EnableEsp()
        if toggleReferences.EspToggle and toggleReferences.EspToggle.setState then
            toggleReferences.EspToggle.setState(true)
        end
    end
    
    if SaveData.AnimationEnabled then
        ToggleAnimation(true)
        if toggleReferences.AnimationToggle and toggleReferences.AnimationToggle.setState then
            toggleReferences.AnimationToggle.setState(true)
        end
    end
end)

-- Restore aimbot settings
aimbot.targetPart = SaveData.AimbotTargetPart or "Head"
aimbot.fovRadius = SaveData.AimbotFOVRadius or 500
aimbot.smoothness = SaveData.AimbotSmoothness or 2
aimbot.aimCurve = SaveData.AimbotCurve or "Linear"
aimbot.followMuzzle = SaveData.AimbotFollowMuzzle or false
aimbot.teamCheck = SaveData.AimbotTeamCheck or true
aimbot.aliveCheck = SaveData.AimbotAliveCheck or true
aimbot.wallCheck = SaveData.AimbotWallCheck or false
aimbot.showFov = SaveData.AimbotShowFOV or false

updaimbot()

--========================
-- SETUP AUTO-EXECUTE
--========================
SetupAutoExecute()

-- Open UI on first load
OpenUI()

print("[Oishi Hub V1.02] Loaded! Main tab with Aimbot added! Collapsible UI pushes content down!")
print("[Instance Aimbot] Loaded with Wall Check + Team Check + Alive Check!")
