--//==============================================================
--// OISHI HUB UI LIBRARY
--// Main + Settings
--// Smooth Circular Color Picker
--// PC + MOBILE
--//==============================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local isPC = not UIS.TouchEnabled

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
    Accent = Color3.fromRGB(0,150,255),

    Background = Color3.fromRGB(7,7,9),
    Surface = Color3.fromRGB(15,15,18),
    SurfaceLight = Color3.fromRGB(25,25,29),

    Text = Color3.fromRGB(225,225,230),
    TextSecondary = Color3.fromRGB(125,125,130),

    ToggleOn = Color3.fromRGB(0,150,255),
    ToggleOff = Color3.fromRGB(45,45,50),

    Border = Color3.fromRGB(45,45,52),

    AnimationSpeed = 0.22,
    UITransparency = 0
}

--==============================================================
-- REMOVE OLD
--==============================================================

if PlayerGui:FindFirstChild("OishiHubExample") then
    PlayerGui.OishiHubExample:Destroy()
end

--==============================================================
-- SCREEN GUI
--==============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OishiHubExample"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==============================================================
-- SIZE
--==============================================================

local viewport = Camera.ViewportSize

local uiWidth = isPC
    and 600
    or math.min(650, viewport.X - 20)

local uiHeight = isPC
    and 450
    or math.min(400, viewport.Y * 0.5)

--==============================================================
-- MAIN
--==============================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,uiWidth,0,uiHeight)
Main.Position = UDim2.new(
    0.5,
    -uiWidth/2,
    0.5,
    -uiHeight/2
)
Main.BackgroundColor3 = CONFIG.Background
Main.BackgroundTransparency = CONFIG.UITransparency
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.ZIndex = 10
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.Border
MainStroke.Thickness = 1
MainStroke.Transparency = 0.15
MainStroke.Parent = Main

--==============================================================
-- OPEN ANIMATION
--==============================================================

Main.Size = UDim2.new(0,uiWidth * 0.85,0,uiHeight * 0.85)
Main.BackgroundTransparency = 1

task.delay(0.05,function()

    Main.Visible = isPC

    TweenService:Create(
        Main,
        TweenInfo.new(
            CONFIG.AnimationSpeed,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.new(0,uiWidth,0,uiHeight),
            BackgroundTransparency = CONFIG.UITransparency
        }
    ):Play()

end)

--==============================================================
-- HEADER
--==============================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,36)
Header.BackgroundColor3 = CONFIG.Surface
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0,10)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1,-60,1,0)
HeaderTitle.Position = UDim2.new(0,12,0,0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "OISHI HUB"
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 13
HeaderTitle.TextColor3 = CONFIG.Accent
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 12
HeaderTitle.Parent = Header

--==============================================================
-- CLOSE
--==============================================================

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,24,0,24)
CloseBtn.Position = UDim2.new(1,-30,0,6)
CloseBtn.BackgroundColor3 = CONFIG.SurfaceLight
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = CONFIG.Text
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 12
CloseBtn.Parent = Header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1,0)
closeCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()

    TweenService:Create(
        Main,
        TweenInfo.new(
            CONFIG.AnimationSpeed,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.In
        ),
        {
            Size = UDim2.new(
                0,
                uiWidth * 0.85,
                0,
                uiHeight * 0.85
            ),
            BackgroundTransparency = 1
        }
    ):Play()

    task.delay(CONFIG.AnimationSpeed,function()

        if isPC then
            Main.Visible = false
        else
            Main.Visible = false
        end

    end)

end)

--==============================================================
-- TAB BAR
--==============================================================

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,32)
TabBar.Position = UDim2.new(0,0,0,36)
TabBar.BackgroundColor3 = CONFIG.Surface
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 11
TabBar.Parent = Main

local MainTab = Instance.new("TextButton")
MainTab.Size = UDim2.new(0.5,-2,1,0)
MainTab.Position = UDim2.new(0,0,0,0)
MainTab.BackgroundColor3 = CONFIG.Accent
MainTab.BackgroundTransparency = 0.25
MainTab.BorderSizePixel = 0
MainTab.Text = "MAIN"
MainTab.Font = Enum.Font.GothamBold
MainTab.TextSize = 10
MainTab.TextColor3 = Color3.new(1,1,1)
MainTab.AutoButtonColor = false
MainTab.ZIndex = 12
MainTab.Parent = TabBar

local SettingsTab = Instance.new("TextButton")
SettingsTab.Size = UDim2.new(0.5,-2,1,0)
SettingsTab.Position = UDim2.new(0.5,2,0,0)
SettingsTab.BackgroundColor3 = CONFIG.SurfaceLight
SettingsTab.BackgroundTransparency = 0.2
SettingsTab.BorderSizePixel = 0
SettingsTab.Text = "SETTINGS"
SettingsTab.Font = Enum.Font.GothamBold
SettingsTab.TextSize = 10
SettingsTab.TextColor3 = CONFIG.TextSecondary
SettingsTab.AutoButtonColor = false
SettingsTab.ZIndex = 12
SettingsTab.Parent = TabBar

--==============================================================
-- CONTENT
--==============================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,0,1,-68)
Content.Position = UDim2.new(0,0,0,68)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 11
Content.Parent = Main

local MainContent = Instance.new("ScrollingFrame")
MainContent.Size = UDim2.new(1,0,1,0)
MainContent.BackgroundTransparency = 1
MainContent.BorderSizePixel = 0
MainContent.ScrollBarThickness = 3
MainContent.ScrollBarImageColor3 = CONFIG.Accent
MainContent.CanvasSize = UDim2.new(0,0,0,0)
MainContent.ZIndex = 12
MainContent.Parent = Content

local MainLayout = Instance.new("UIListLayout")
MainLayout.Padding = UDim.new(0,6)
MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainLayout.Parent = MainContent

local MainPadding = Instance.new("UIPadding")
MainPadding.PaddingTop = UDim.new(0,10)
MainPadding.PaddingBottom = UDim.new(0,10)
MainPadding.PaddingLeft = UDim.new(0,10)
MainPadding.PaddingRight = UDim.new(0,10)
MainPadding.Parent = MainContent

local SettingsContent = Instance.new("ScrollingFrame")
SettingsContent.Size = UDim2.new(1,0,1,0)
SettingsContent.BackgroundTransparency = 1
SettingsContent.BorderSizePixel = 0
SettingsContent.ScrollBarThickness = 3
SettingsContent.ScrollBarImageColor3 = CONFIG.Accent
SettingsContent.CanvasSize = UDim2.new(0,0,0,0)
SettingsContent.Visible = false
SettingsContent.ZIndex = 12
SettingsContent.Parent = Content

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0,6)
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsLayout.Parent = SettingsContent

local SettingsPadding = Instance.new("UIPadding")
SettingsPadding.PaddingTop = UDim.new(0,10)
SettingsPadding.PaddingBottom = UDim.new(0,10)
SettingsPadding.PaddingLeft = UDim.new(0,10)
SettingsPadding.PaddingRight = UDim.new(0,10)
SettingsPadding.Parent = SettingsContent

--==============================================================
-- TAB ANIMATION
--==============================================================

local function SwitchTab(tab)

    if tab == "Main" then

        MainTab.BackgroundColor3 = CONFIG.Accent
        MainTab.BackgroundTransparency = 0.25
        MainTab.TextColor3 = Color3.new(1,1,1)

        SettingsTab.BackgroundColor3 = CONFIG.SurfaceLight
        SettingsTab.BackgroundTransparency = 0.2
        SettingsTab.TextColor3 = CONFIG.TextSecondary

        MainContent.Visible = true
        SettingsContent.Visible = false

    else

        SettingsTab.BackgroundColor3 = CONFIG.Accent
        SettingsTab.BackgroundTransparency = 0.25
        SettingsTab.TextColor3 = Color3.new(1,1,1)

        MainTab.BackgroundColor3 = CONFIG.SurfaceLight
        MainTab.BackgroundTransparency = 0.2
        MainTab.TextColor3 = CONFIG.TextSecondary

        SettingsContent.Visible = true
        MainContent.Visible = false

    end

end

MainTab.MouseButton1Click:Connect(function()
    SwitchTab("Main")
end)

SettingsTab.MouseButton1Click:Connect(function()
    SwitchTab("Settings")
end)

--==============================================================
-- SECTION
--==============================================================

local function Section(parent,text)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,22)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 9
    label.TextColor3 = CONFIG.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = parent

    return label

end

--==============================================================
-- TOGGLE
--==============================================================

local function Toggle(parent,name,default,callback)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,36)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-60,1,0)
    label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 9
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = container

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0,36,0,20)
    button.Position = UDim2.new(1,-46,0.5,-10)
    button.BackgroundColor3 = default and CONFIG.ToggleOn or CONFIG.ToggleOff
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 13
    button.Parent = container

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1,0)
    buttonCorner.Parent = button

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,14,0,14)
    knob.Position = default
        and UDim2.new(1,-17,0.5,-7)
        or UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = button

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1,0)
    knobCorner.Parent = knob

    local state = default

    button.MouseButton1Click:Connect(function()

        state = not state

        TweenService:Create(
            button,
            TweenInfo.new(0.18),
            {
                BackgroundColor3 =
                    state and CONFIG.ToggleOn or CONFIG.ToggleOff
            }
        ):Play()

        TweenService:Create(
            knob,
            TweenInfo.new(0.18,Enum.EasingStyle.Quint),
            {
                Position =
                    state
                    and UDim2.new(1,-17,0.5,-7)
                    or UDim2.new(0,3,0.5,-7)
            }
        ):Play()

        if callback then
            callback(state)
        end

    end)

    return container

end

--==============================================================
-- BUTTON
--==============================================================

local function Button(parent,name,callback)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,36)
    btn.BackgroundColor3 = CONFIG.Surface
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = CONFIG.Text
    btn.AutoButtonColor = false
    btn.ZIndex = 12
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()

        TweenService:Create(
            btn,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 = CONFIG.SurfaceLight
            }
        ):Play()

    end)

    btn.MouseLeave:Connect(function()

        TweenService:Create(
            btn,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 = CONFIG.Surface
            }
        ):Play()

    end)

    btn.MouseButton1Click:Connect(function()

        if callback then
            callback()
        end

    end)

    return btn

end

--==============================================================
-- SLIDER
--==============================================================

local function Slider(parent,name,min,max,default,callback)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,48)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.Active = true
    container.ZIndex = 12
    container.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65,0,0,18)
    label.Position = UDim2.new(0,10,0,4)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 9
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3,0,0,18)
    valueLabel.Position = UDim2.new(0.68,0,0,4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 9
    valueLabel.TextColor3 = CONFIG.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 13
    valueLabel.Parent = container

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-20,0,5)
    bar.Position = UDim2.new(0,10,0,32)
    bar.BackgroundColor3 = CONFIG.SurfaceLight
    bar.BorderSizePixel = 0
    bar.Active = true
    bar.ZIndex = 13
    bar.Parent = container

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1,0)
    barCorner.Parent = bar

    local percent = math.clamp(
        (default-min)/(max-min),
        0,
        1
    )

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(percent,0,1,0)
    fill.BackgroundColor3 = CONFIG.Accent
    fill.BorderSizePixel = 0
    fill.Active = false
    fill.ZIndex = 14
    fill.Parent = bar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1,0)
    fillCorner.Parent = fill

    -- WHITE CIRCLE KNOB

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,14,0,14)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new(percent,0,0.5,0)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.Active = false
    knob.ZIndex = 15
    knob.Parent = bar

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1,0)
    knobCorner.Parent = knob

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Color3.fromRGB(80,80,85)
    knobStroke.Thickness = 1
    knobStroke.Parent = knob

    local draggingSlider = false

    local function update(input)

        local x = input.Position.X
        local left = bar.AbsolutePosition.X
        local width = bar.AbsoluteSize.X

        local p = math.clamp(
            (x-left)/width,
            0,
            1
        )

        local value = math.floor(
            min+(max-min)*p+0.5
        )

        fill.Size = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p,0,0.5,0)
        valueLabel.Text = tostring(value)

        if callback then
            callback(value)
        end

    end

    bar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            draggingSlider = true
            update(input)

        end

    end)

    UIS.InputChanged:Connect(function(input)

        if not draggingSlider then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

            update(input)

        end

    end)

    UIS.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            draggingSlider = false

        end

    end)

    return container

end

--==============================================================
-- SMOOTH CIRCULAR COLOR PICKER
--==============================================================

local function ColorPicker(parent,name,callback)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,38)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-60,1,0)
    label.Position = UDim2.new(0,10,0,0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 9
    label.TextColor3 = CONFIG.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = container

    local preview = Instance.new("TextButton")
    preview.Size = UDim2.new(0,24,0,24)
    preview.Position = UDim2.new(1,-34,0.5,-12)
    preview.BackgroundColor3 = CONFIG.Accent
    preview.BorderSizePixel = 0
    preview.Text = ""
    preview.AutoButtonColor = false
    preview.ZIndex = 13
    preview.Parent = container

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(1,0)
    previewCorner.Parent = preview

    local previewStroke = Instance.new("UIStroke")
    previewStroke.Color = Color3.fromRGB(255,255,255)
    previewStroke.Transparency = 0.55
    previewStroke.Thickness = 1
    previewStroke.Parent = preview

    local popup

    preview.MouseButton1Click:Connect(function()

        if popup then
            popup:Destroy()
            popup = nil
            return
        end

        --======================================================
        -- POPUP
        --======================================================

        popup = Instance.new("Frame")
        popup.Size = UDim2.new(0,250,0,350)

        local pos = preview.AbsolutePosition
        local vp = Camera.ViewportSize

        local px = math.clamp(
            pos.X-210,
            5,
            vp.X-255
        )

        local py = math.clamp(
            pos.Y-355,
            5,
            vp.Y-355
        )

        popup.Position = UDim2.new(0,px,0,py)
        popup.BackgroundColor3 = Color3.fromRGB(12,12,15)
        popup.BorderSizePixel = 0
        popup.ZIndex = 1000
        popup.Parent = ScreenGui

        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = UDim.new(0,10)
        popupCorner.Parent = popup

        local popupStroke = Instance.new("UIStroke")
        popupStroke.Color = CONFIG.Border
        popupStroke.Thickness = 1
        popupStroke.Transparency = 0.15
        popupStroke.Parent = popup

        -- OPEN ANIMATION

        popup.Size = UDim2.new(0,250,0,0)

        TweenService:Create(
            popup,
            TweenInfo.new(
                CONFIG.AnimationSpeed,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(0,250,0,350)
            }
        ):Play()

        --======================================================
        -- TITLE
        --======================================================

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1,-45,0,30)
        title.Position = UDim2.new(0,12,0,4)
        title.BackgroundTransparency = 1
        title.Text = name
        title.Font = Enum.Font.GothamBold
        title.TextSize = 10
        title.TextColor3 = CONFIG.Text
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 1002
        title.Parent = popup

        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0,22,0,22)
        close.Position = UDim2.new(1,-28,0,7)
        close.BackgroundColor3 = CONFIG.SurfaceLight
        close.BorderSizePixel = 0
        close.Text = "×"
        close.Font = Enum.Font.GothamBold
        close.TextSize = 13
        close.TextColor3 = CONFIG.Text
        close.AutoButtonColor = false
        close.ZIndex = 1003
        close.Parent = popup

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(1,0)
        closeCorner.Parent = close

        close.MouseButton1Click:Connect(function()
            popup:Destroy()
            popup = nil
        end)

        --======================================================
        -- CIRCULAR WHEEL
        --======================================================

        local wheelSize = 190

        local wheel = Instance.new("Frame")
        wheel.Size = UDim2.new(0,wheelSize,0,wheelSize)
        wheel.Position = UDim2.new(0.5,-wheelSize/2,0,38)
        wheel.BackgroundColor3 = Color3.new(1,1,1)
        wheel.BorderSizePixel = 0
        wheel.ClipsDescendants = true
        wheel.Active = true
        wheel.ZIndex = 1001
        wheel.Parent = popup

        local wheelCorner = Instance.new("UICorner")
        wheelCorner.CornerRadius = UDim.new(1,0)
        wheelCorner.Parent = wheel

        --======================================================
        -- RADIAL RAINBOW
        --
        -- Uses very thin radial strips instead of square blocks.
        -- The circular clipping removes the outside edges.
        --======================================================

        local centerX = wheelSize/2
        local centerY = wheelSize/2

        local spokes = 360

        for i = 0,spokes-1 do

            local hue = i/spokes
            local angle = hue*math.pi*2

            local line = Instance.new("Frame")

            line.AnchorPoint = Vector2.new(0,0.5)

            line.Size = UDim2.new(
                0,
                wheelSize/2,
                0,
                2
            )

            line.Position = UDim2.new(
                0,
                centerX,
                0,
                centerY
            )

            line.Rotation = math.deg(angle)

            line.BackgroundColor3 =
                Color3.fromHSV(
                    hue,
                    1,
                    1
                )

            line.BorderSizePixel = 0
            line.ZIndex = 1001
            line.Parent = wheel

        end

        -- WHITE CENTER

        local center = Instance.new("Frame")
        center.Size = UDim2.new(0,44,0,44)
        center.AnchorPoint = Vector2.new(0.5,0.5)
        center.Position = UDim2.new(0.5,0,0.5,0)
        center.BackgroundColor3 = Color3.new(1,1,1)
        center.BorderSizePixel = 0
        center.ZIndex = 1003
        center.Parent = wheel

        local centerCorner = Instance.new("UICorner")
        centerCorner.CornerRadius = UDim.new(1,0)
        centerCorner.Parent = center

        --======================================================
        -- WHEEL CURSOR
        --======================================================

        local cursor = Instance.new("Frame")
        cursor.Size = UDim2.new(0,14,0,14)
        cursor.AnchorPoint = Vector2.new(0.5,0.5)
        cursor.Position = UDim2.new(0.5,0,0.5,0)
        cursor.BackgroundColor3 = Color3.new(1,1,1)
        cursor.BorderSizePixel = 0
        cursor.ZIndex = 1005
        cursor.Parent = wheel

        local cursorCorner = Instance.new("UICorner")
        cursorCorner.CornerRadius = UDim.new(1,0)
        cursorCorner.Parent = cursor

        local cursorStroke = Instance.new("UIStroke")
        cursorStroke.Color = Color3.new(0,0,0)
        cursorStroke.Thickness = 2
        cursorStroke.Parent = cursor

        --======================================================
        -- CURRENT COLOR
        --======================================================

        local rgb = Instance.new("TextLabel")
        rgb.Size = UDim2.new(1,-20,0,22)
        rgb.Position = UDim2.new(0,10,0,232)
        rgb.BackgroundTransparency = 1
        rgb.Text = "RGB: 0, 150, 255"
        rgb.Font = Enum.Font.GothamMedium
        rgb.TextSize = 9
        rgb.TextColor3 = CONFIG.Text
        rgb.TextXAlignment = Enum.TextXAlignment.Center
        rgb.ZIndex = 1002
        rgb.Parent = popup

        --======================================================
        -- HUE BAR
        --======================================================

        local hueBar = Instance.new("Frame")
        hueBar.Size = UDim2.new(1,-30,0,12)
        hueBar.Position = UDim2.new(0,15,0,262)
        hueBar.BackgroundColor3 = Color3.new(1,1,1)
        hueBar.BorderSizePixel = 0
        hueBar.Active = true
        hueBar.ZIndex = 1002
        hueBar.Parent = popup

        local hueCorner = Instance.new("UICorner")
        hueCorner.CornerRadius = UDim.new(1,0)
        hueCorner.Parent = hueBar

        local hueGradient = Instance.new("UIGradient")

        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),
            ColorSequenceKeypoint.new(0.166,Color3.fromHSV(0.166,1,1)),
            ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
            ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),
            ColorSequenceKeypoint.new(0.666,Color3.fromHSV(0.666,1,1)),
            ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
            ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))
        })

        hueGradient.Parent = hueBar

        local hueKnob = Instance.new("Frame")
        hueKnob.Size = UDim2.new(0,16,0,16)
        hueKnob.AnchorPoint = Vector2.new(0.5,0.5)
        hueKnob.Position = UDim2.new(0.58,0,0.5,0)
        hueKnob.BackgroundColor3 = Color3.new(1,1,1)
        hueKnob.BorderSizePixel = 0
        hueKnob.ZIndex = 1004
        hueKnob.Parent = hueBar

        local hueKnobCorner = Instance.new("UICorner")
        hueKnobCorner.CornerRadius = UDim.new(1,0)
        hueKnobCorner.Parent = hueKnob

        local hueStroke = Instance.new("UIStroke")
        hueStroke.Color = Color3.fromRGB(50,50,50)
        hueStroke.Thickness = 1
        hueStroke.Parent = hueKnob

        --======================================================
        -- VALUE BAR
        --======================================================

        local valueBar = Instance.new("Frame")
        valueBar.Size = UDim2.new(1,-30,0,12)
        valueBar.Position = UDim2.new(0,15,0,292)
        valueBar.BackgroundColor3 = Color3.new(1,1,1)
        valueBar.BorderSizePixel = 0
        valueBar.Active = true
        valueBar.ZIndex = 1002
        valueBar.Parent = popup

        local valueCorner = Instance.new("UICorner")
        valueCorner.CornerRadius = UDim.new(1,0)
        valueCorner.Parent = valueBar

        local valueGradient = Instance.new("UIGradient")
        valueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
            ColorSequenceKeypoint.new(0.5,Color3.new(0.5,0.5,0.5)),
            ColorSequenceKeypoint.new(1,Color3.new(1,1,1))
        })
        valueGradient.Parent = valueBar

        local valueKnob = Instance.new("Frame")
        valueKnob.Size = UDim2.new(0,16,0,16)
        valueKnob.AnchorPoint = Vector2.new(0.5,0.5)
        valueKnob.Position = UDim2.new(1,0,0.5,0)
        valueKnob.BackgroundColor3 = Color3.new(1,1,1)
        valueKnob.BorderSizePixel = 0
        valueKnob.ZIndex = 1004
        valueKnob.Parent = valueBar

        local valueKnobCorner = Instance.new("UICorner")
        valueKnobCorner.CornerRadius = UDim.new(1,0)
        valueKnobCorner.Parent = valueKnob

        local valueStroke = Instance.new("UIStroke")
        valueStroke.Color = Color3.fromRGB(50,50,50)
        valueStroke.Thickness = 1
        valueStroke.Parent = valueKnob

        --======================================================
        -- COLOR STATE
        --======================================================

        local hue = 0.58
        local saturation = 1
        local value = 1

        local draggingWheel = false
        local draggingHue = false
        local draggingValue = false

        local function updateColor()

            local color =
                Color3.fromHSV(
                    hue,
                    saturation,
                    value
                )

            preview.BackgroundColor3 = color

            rgb.Text = string.format(
                "RGB: %d, %d, %d",
                math.floor(color.R*255+0.5),
                math.floor(color.G*255+0.5),
                math.floor(color.B*255+0.5)
            )

            valueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
                ColorSequenceKeypoint.new(1,Color3.fromHSV(hue,saturation,1))
            })

            if callback then
                callback(color)
            end

        end

        --======================================================
        -- WHEEL INPUT
        --======================================================

        local function updateWheel(input)

            local center =
                wheel.AbsolutePosition +
                wheel.AbsoluteSize/2

            local dx =
                input.Position.X-center.X

            local dy =
                input.Position.Y-center.Y

            local radius =
                wheel.AbsoluteSize.X/2

            local distance =
                math.sqrt(dx*dx+dy*dy)

            if distance > radius then

                local scale = radius/distance

                dx *= scale
                dy *= scale

                distance = radius

            end

            hue =
                math.atan2(dy,dx)/(math.pi*2)

            if hue < 0 then
                hue += 1
            end

            saturation =
                math.clamp(
                    distance/radius,
                    0,
                    1
                )

            cursor.Position =
                UDim2.new(
                    0.5,
                    dx,
                    0.5,
                    dy
                )

            updateColor()

        end

        wheel.InputBegan:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

                draggingWheel = true
                updateWheel(input)

            end

        end)

        --======================================================
        -- HUE INPUT
        --======================================================

        local function updateHue(input)

            local x =
                math.clamp(
                    input.Position.X-hueBar.AbsolutePosition.X,
                    0,
                    hueBar.AbsoluteSize.X
                )

            hue =
                x/hueBar.AbsoluteSize.X

            hueKnob.Position =
                UDim2.new(
                    hue,
                    0,
                    0.5,
                    0
                )

            updateColor()

        end

        hueBar.InputBegan:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

                draggingHue = true
                updateHue(input)

            end

        end)

        --======================================================
        -- VALUE INPUT
        --======================================================

        local function updateValue(input)

            local x =
                math.clamp(
                    input.Position.X-valueBar.AbsolutePosition.X,
                    0,
                    valueBar.AbsoluteSize.X
                )

            value =
                x/valueBar.AbsoluteSize.X

            valueKnob.Position =
                UDim2.new(
                    value,
                    0,
                    0.5,
                    0
                )

            updateColor()

        end

        valueBar.InputBegan:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

                draggingValue = true
                updateValue(input)

            end

        end)

        --======================================================
        -- GLOBAL DRAGGING
        --======================================================

        local moveConnection

        moveConnection = UIS.InputChanged:Connect(function(input)

            if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end

            if draggingWheel then
                updateWheel(input)
            elseif draggingHue then
                updateHue(input)
            elseif draggingValue then
                updateValue(input)
            end

        end)

        local endConnection

        endConnection = UIS.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

                draggingWheel = false
                draggingHue = false
                draggingValue = false

            end

        end)

        popup.Destroying:Connect(function()

            if moveConnection then
                moveConnection:Disconnect()
            end

            if endConnection then
                endConnection:Disconnect()
            end

            popup = nil

        end)

        updateColor()

    end)

    return container

end

--==============================================================
-- MAIN EXAMPLE
--==============================================================

Section(MainContent,"EXAMPLE CONTROLS")

Toggle(
    MainContent,
    "Toggle Example",
    false,
    function(state)
        print("Toggle:",state)
    end
)

Button(
    MainContent,
    "Button Example",
    function()
        print("Button clicked")
    end
)

Slider(
    MainContent,
    "Slider Example",
    0,
    100,
    50,
    function(value)
        print("Slider:",value)
    end
)

ColorPicker(
    MainContent,
    "Color Example",
    function(color)
        print("Color:",color)
    end
)

Section(MainContent,"MORE EXAMPLES")

Toggle(
    MainContent,
    "Another Toggle",
    true,
    function(state)
        print("Another:",state)
    end
)

Button(
    MainContent,
    "Test Notification",
    function()
        print("Notification!")
    end
)

--==============================================================
-- SETTINGS
--==============================================================

Section(SettingsContent,"UI SETTINGS")

ColorPicker(
    SettingsContent,
    "UI Accent",
    function(color)

        CONFIG.Accent = color

        MainStroke.Color = color
        HeaderTitle.TextColor3 = color

        MainTab.BackgroundColor3 = color

        MainContent.ScrollBarImageColor3 = color
        SettingsContent.ScrollBarImageColor3 = color

    end
)

Slider(
    SettingsContent,
    "UI Transparency",
    0,
    80,
    0,
    function(value)

        CONFIG.UITransparency = value/100

        Main.BackgroundTransparency =
            CONFIG.UITransparency

    end
)

Slider(
    SettingsContent,
    "Animation Speed",
    5,
    100,
    22,
    function(value)

        CONFIG.AnimationSpeed =
            value/100

    end
)

Section(SettingsContent,"WINDOW")

Toggle(
    SettingsContent,
    "Rounded UI",
    true,
    function(state)

        if state then
            MainCorner.CornerRadius = UDim.new(0,10)
        else
            MainCorner.CornerRadius = UDim.new(0,0)
        end

    end
)

Toggle(
    SettingsContent,
    "UI Border",
    true,
    function(state)

        MainStroke.Transparency =
            state and 0.15 or 1

    end
)

Toggle(
    SettingsContent,
    "Dark Surface",
    true,
    function(state)

        if state then

            CONFIG.Surface =
                Color3.fromRGB(15,15,18)

        else

            CONFIG.Surface =
                Color3.fromRGB(30,30,35)

        end

        Header.BackgroundColor3 = CONFIG.Surface

    end
)

Section(SettingsContent,"CONTROLS")

Button(
    SettingsContent,
    "Reset UI Settings",
    function()

        CONFIG.Accent =
            Color3.fromRGB(0,150,255)

        CONFIG.Background =
            Color3.fromRGB(7,7,9)

        CONFIG.Surface =
            Color3.fromRGB(15,15,18)

        CONFIG.UITransparency = 0
        CONFIG.AnimationSpeed = 0.22

        Main.BackgroundColor3 =
            CONFIG.Background

        Main.BackgroundTransparency = 0

        MainStroke.Color =
            CONFIG.Border

        HeaderTitle.TextColor3 =
            CONFIG.Accent

        MainTab.BackgroundColor3 =
            CONFIG.Accent

        MainContent.ScrollBarImageColor3 =
            CONFIG.Accent

        SettingsContent.ScrollBarImageColor3 =
            CONFIG.Accent

    end
)

--==============================================================
-- CANVAS UPDATE
--==============================================================

local function updateCanvas()

    task.wait()

    MainContent.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            MainLayout.AbsoluteContentSize.Y+20
        )

    SettingsContent.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            SettingsLayout.AbsoluteContentSize.Y+20
        )

end

MainLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
SettingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

updateCanvas()

--==============================================================
-- DRAG MAIN UI
--==============================================================

local dragging = false
local dragStart
local startPos

Header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

    end

end)

UIS.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta =
            input.Position-dragStart

        Main.Position =
            UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset+delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset+delta.Y
            )

    end

end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false

    end

end)

--==============================================================
-- MOBILE TOGGLE
--==============================================================

if isMobile then

    local ToggleBtn = Instance.new("TextButton")

    ToggleBtn.Size = UDim2.new(0,88,0,30)
    ToggleBtn.Position = UDim2.new(0,10,0,150)
    ToggleBtn.BackgroundColor3 = CONFIG.Accent
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = "Toggle UI"
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 10
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.ZIndex = 999999
    ToggleBtn.Parent = ScreenGui

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0,6)
    tc.Parent = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()

        if Main.Visible then

            TweenService:Create(
                Main,
                TweenInfo.new(
                    CONFIG.AnimationSpeed,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.In
                ),
                {
                    Size = UDim2.new(
                        0,
                        uiWidth*0.85,
                        0,
                        uiHeight*0.85
                    ),
                    BackgroundTransparency = 1
                }
            ):Play()

            task.delay(CONFIG.AnimationSpeed,function()
                Main.Visible = false
            end)

        else

            Main.Visible = true
            Main.Size =
                UDim2.new(
                    0,
                    uiWidth*0.85,
                    0,
                    uiHeight*0.85
                )

            Main.BackgroundTransparency = 1

            TweenService:Create(
                Main,
                TweenInfo.new(
                    CONFIG.AnimationSpeed,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = UDim2.new(0,uiWidth,0,uiHeight),
                    BackgroundTransparency =
                        CONFIG.UITransparency
                }
            ):Play()

        end

    end)

else

    -- PC starts visible after animation
    Main.Visible = true

end

--==============================================================
-- PC KEYBIND
--==============================================================

if isPC then

    UIS.InputBegan:Connect(function(input,gp)

        if gp then
            return
        end

        if input.KeyCode == Enum.KeyCode.RightShift then

            Main.Visible = not Main.Visible

        end

    end)

end

--==============================================================
-- DONE
--==============================================================

print("[Oishi Hub] Loaded - Smooth Circular Color Picker")
