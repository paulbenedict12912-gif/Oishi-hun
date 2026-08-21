--==================================================
-- OISHI HUB UI LIBRARY
-- Main + Settings Edition
-- Mobile + PC
-- Animated UI
-- Circular Rainbow Color Picker
-- Slider Knobs
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local isPC = not UIS.TouchEnabled

--==================================================
-- CONFIGURATION
--==================================================

local CONFIG = {

    Accent = Color3.fromRGB(0,150,255),

    Background = Color3.fromRGB(5,5,5),
    Surface = Color3.fromRGB(15,15,15),
    SurfaceLight = Color3.fromRGB(25,25,25),

    Text = Color3.fromRGB(220,220,220),
    TextSecondary = Color3.fromRGB(110,110,110),

    ToggleOn = Color3.fromRGB(0,150,255),
    ToggleOff = Color3.fromRGB(40,40,40),

    Border = Color3.fromRGB(0,150,255),

    TabActive = Color3.fromRGB(0,150,255),
    TabInactive = Color3.fromRGB(30,30,30),

    HoverAccent = Color3.fromRGB(30,180,255),
    HoverSurface = Color3.fromRGB(40,40,40),

    Font = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,

    AnimationSpeed = 0.20,

    CornerRadius = 6,

    UITransparency = 0,

    UIScale = 1
}

--==================================================
-- REMOVE OLD UI
--==================================================

if PlayerGui:FindFirstChild("OishiHubExample") then
    PlayerGui.OishiHubExample:Destroy()
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
-- UI SCALE
--==================================================

local UIScale = Instance.new("UIScale")
UIScale.Scale = CONFIG.UIScale
UIScale.Parent = ScreenGui

--==================================================
-- SIZE
--==================================================

local uiWidth = isPC
    and 600
    or math.min(650,Camera.ViewportSize.X - 20)

local uiHeight = isPC
    and 450
    or math.min(400,Camera.ViewportSize.Y * 0.5)

--==================================================
-- MAIN FRAME
--==================================================

local Main = Instance.new("Frame")

Main.Size = UDim2.new(
    0,
    uiWidth,
    0,
    uiHeight
)

Main.Position = UDim2.new(
    0.5,
    -uiWidth/2,
    0.5,
    -uiHeight/2
)

Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.ZIndex = 10
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(
    0,
    CONFIG.CornerRadius
)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.Border
MainStroke.Thickness = 2
MainStroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")

Header.Size = UDim2.new(
    1,
    0,
    0,
    34
)

Header.BackgroundColor3 = CONFIG.Surface
Header.BorderSizePixel = 0
Header.ZIndex = 20
Header.Active = true
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(
    0,
    CONFIG.CornerRadius
)
HeaderCorner.Parent = Header

local HeaderTitle = Instance.new("TextLabel")

HeaderTitle.Size = UDim2.new(
    1,
    -70,
    0,
    24
)

HeaderTitle.Position = UDim2.new(
    0,
    12,
    0,
    5
)

HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "OISHI HUB UI LIBRARY"
HeaderTitle.Font = CONFIG.Font
HeaderTitle.TextSize = 12
HeaderTitle.TextColor3 = CONFIG.Accent
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 21
HeaderTitle.Parent = Header

--==================================================
-- CLOSE
--==================================================

local CloseBtn = Instance.new("TextButton")

CloseBtn.Size = UDim2.new(
    0,
    22,
    0,
    22
)

CloseBtn.Position = UDim2.new(
    1,
    -28,
    0,
    6
)

CloseBtn.BackgroundColor3 = CONFIG.SurfaceLight
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.Font = CONFIG.Font
CloseBtn.TextSize = 14
CloseBtn.TextColor3 = CONFIG.Text
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 22
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0,4)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()

    if isPC then

        Main.Visible = false

    else

        Main.Visible = false

    end

end)

--==================================================
-- CONTENT AREA
--==================================================

local LeftSide = Instance.new("Frame")

LeftSide.Size = UDim2.new(
    0.5,
    -1,
    1,
    -34
)

LeftSide.Position = UDim2.new(
    0,
    0,
    0,
    34
)

LeftSide.BackgroundColor3 = CONFIG.Background
LeftSide.BorderSizePixel = 0
LeftSide.ZIndex = 11
LeftSide.Parent = Main

local RightSide = Instance.new("Frame")

RightSide.Size = UDim2.new(
    0.5,
    -1,
    1,
    -34
)

RightSide.Position = UDim2.new(
    0.5,
    1,
    0,
    34
)

RightSide.BackgroundColor3 = CONFIG.Surface
RightSide.BorderSizePixel = 0
RightSide.ZIndex = 11
RightSide.Parent = Main

--==================================================
-- TABS
--==================================================

local TabFrame = Instance.new("Frame")

TabFrame.Size = UDim2.new(
    1,
    0,
    0,
    30
)

TabFrame.BackgroundColor3 = CONFIG.Surface
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex = 20
TabFrame.Parent = LeftSide

local Tabs = {
    "Main",
    "Settings"
}

local CurrentTab = "Main"

local TabButtons = {}
local TabContents = {}

local ContentContainer = Instance.new("Frame")

ContentContainer.Size = UDim2.new(
    1,
    0,
    1,
    -30
)

ContentContainer.Position = UDim2.new(
    0,
    0,
    0,
    30
)

ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 11
ContentContainer.Parent = LeftSide

--==================================================
-- CREATE TABS
--==================================================

for i,tabName in ipairs(Tabs) do

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(
        0.5,
        -2,
        0,
        26
    )

    Button.Position = UDim2.new(
        (i-1)*0.5,
        1,
        0,
        2
    )

    Button.BackgroundColor3 =
        tabName == CurrentTab
        and CONFIG.TabActive
        or CONFIG.TabInactive

    Button.BackgroundTransparency =
        tabName == CurrentTab
        and 0.2
        or 0.55

    Button.BorderSizePixel = 0
    Button.Text = tabName
    Button.Font = CONFIG.Font
    Button.TextSize = 9
    Button.TextColor3 =
        tabName == CurrentTab
        and Color3.new(1,1,1)
        or CONFIG.Text

    Button.AutoButtonColor = false
    Button.ZIndex = 21
    Button.Parent = TabFrame

    local buttonCorner = Instance.new("UICorner")

    buttonCorner.CornerRadius = UDim.new(
        0,
        4
    )

    buttonCorner.Parent = Button

    TabButtons[tabName] = Button

    local Content = Instance.new("Frame")

    Content.Size = UDim2.new(
        1,
        0,
        1,
        0
    )

    Content.BackgroundTransparency = 1
    Content.Visible = tabName == CurrentTab
    Content.ZIndex = 11
    Content.Parent = ContentContainer

    local Scroll = Instance.new("ScrollingFrame")

    Scroll.Size = UDim2.new(
        1,
        0,
        1,
        0
    )

    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = CONFIG.Accent
    Scroll.ScrollBarImageTransparency = 0.3
    Scroll.CanvasSize = UDim2.new(0,0,0,0)
    Scroll.ZIndex = 12
    Scroll.Parent = Content

    local Layout = Instance.new("UIListLayout")

    Layout.Padding = UDim.new(
        0,
        6
    )

    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll

    local Padding = Instance.new("UIPadding")

    Padding.PaddingTop = UDim.new(0,10)
    Padding.PaddingLeft = UDim.new(0,10)
    Padding.PaddingRight = UDim.new(0,10)
    Padding.PaddingBottom = UDim.new(0,10)

    Padding.Parent = Scroll

    TabContents[tabName] = {
        frame = Content,
        scroll = Scroll,
        layout = Layout
    }

    Button.MouseButton1Click:Connect(function()

        if CurrentTab == tabName then
            return
        end

        local oldTab = CurrentTab

        CurrentTab = tabName

        for name,btn in pairs(TabButtons) do

            if name == tabName then

                TweenService:Create(
                    btn,
                    TweenInfo.new(
                        CONFIG.AnimationSpeed,
                        Enum.EasingStyle.Quint,
                        Enum.EasingDirection.Out
                    ),
                    {
                        BackgroundColor3 = CONFIG.TabActive,
                        BackgroundTransparency = 0.2,
                        TextColor3 = Color3.new(1,1,1)
                    }
                ):Play()

            else

                TweenService:Create(
                    btn,
                    TweenInfo.new(
                        CONFIG.AnimationSpeed,
                        Enum.EasingStyle.Quint,
                        Enum.EasingDirection.Out
                    ),
                    {
                        BackgroundColor3 = CONFIG.TabInactive,
                        BackgroundTransparency = 0.55,
                        TextColor3 = CONFIG.Text
                    }
                ):Play()

            end

        end

        local OldContent =
            TabContents[oldTab].frame

        local NewContent =
            TabContents[tabName].frame

        OldContent.Visible = false

        NewContent.Visible = true

        NewContent.Position =
            UDim2.new(
                0,
                20,
                0,
                0
            )

        TweenService:Create(
            NewContent,
            TweenInfo.new(
                CONFIG.AnimationSpeed,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                Position = UDim2.new(
                    0,
                    0,
                    0,
                    0
                )
            }
        ):Play()

    end)
end

--==================================================
-- UPDATE CANVAS
--==================================================

local function UpdateCanvas()

    for _,content in pairs(TabContents) do

        content.scroll.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                content.layout.AbsoluteContentSize.Y + 20
            )

    end

end

--==================================================
-- SECTION
--==================================================

local function CreateSectionLabel(tabName,text)

    local content = TabContents[tabName]

    if not content then
        return
    end

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(
        1,
        0,
        0,
        22
    )

    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = CONFIG.Font
    Label.TextSize = 9
    Label.TextColor3 = CONFIG.Accent
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 13
    Label.Parent = content.scroll

    return Label
end

--==================================================
-- TOGGLE
--==================================================

local function CreateToggle(
    tabName,
    name,
    default,
    callback
)

    local content = TabContents[tabName]

    if not content then
        return
    end

    local Container = Instance.new("Frame")

    Container.Size = UDim2.new(
        1,
        0,
        0,
        36
    )

    Container.BackgroundColor3 = CONFIG.Surface
    Container.BorderSizePixel = 0
    Container.ZIndex = 12
    Container.Parent = content.scroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,CONFIG.CornerRadius)
    Corner.Parent = Container

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(
        0.65,
        0,
        0,
        20
    )

    Label.Position = UDim2.new(
        0,
        8,
        0,
        8
    )

    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = CONFIG.FontMedium
    Label.TextSize = 9
    Label.TextColor3 = CONFIG.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 13
    Label.Parent = Container

    local Toggle = Instance.new("TextButton")

    Toggle.Size = UDim2.new(
        0,
        34,
        0,
        18
    )

    Toggle.Position = UDim2.new(
        1,
        -42,
        0,
        9
    )

    Toggle.BackgroundColor3 =
        default
        and CONFIG.ToggleOn
        or CONFIG.ToggleOff

    Toggle.BorderSizePixel = 0
    Toggle.Text = ""
    Toggle.AutoButtonColor = false
    Toggle.ZIndex = 14
    Toggle.Parent = Container

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1,0)
    ToggleCorner.Parent = Toggle

    local Knob = Instance.new("Frame")

    Knob.Size = UDim2.new(
        0,
        12,
        0,
        12
    )

    Knob.Position =
        default
        and UDim2.new(0,19,0,3)
        or UDim2.new(0,3,0,3)

    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 15
    Knob.Parent = Toggle

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1,0)
    KnobCorner.Parent = Knob

    local State = default or false

    Toggle.MouseButton1Click:Connect(function()

        State = not State

        TweenService:Create(
            Toggle,
            TweenInfo.new(
                CONFIG.AnimationSpeed
            ),
            {
                BackgroundColor3 =
                    State
                    and CONFIG.ToggleOn
                    or CONFIG.ToggleOff
            }
        ):Play()

        TweenService:Create(
            Knob,
            TweenInfo.new(
                CONFIG.AnimationSpeed,
                Enum.EasingStyle.Quint
            ),
            {
                Position =
                    State
                    and UDim2.new(0,19,0,3)
                    or UDim2.new(0,3,0,3)
            }
        ):Play()

        if callback then
            callback(State)
        end

    end)

    return Container
end

--==================================================
-- BUTTON
--==================================================

local function CreateButton(
    tabName,
    name,
    callback
)

    local content = TabContents[tabName]

    if not content then
        return
    end

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(
        1,
        0,
        0,
        36
    )

    Button.BackgroundColor3 = CONFIG.Surface
    Button.BorderSizePixel = 0
    Button.Text = name
    Button.Font = CONFIG.Font
    Button.TextSize = 9
    Button.TextColor3 = CONFIG.Text
    Button.AutoButtonColor = false
    Button.ZIndex = 12
    Button.Parent = content.scroll

    local Corner = Instance.new("UICorner")

    Corner.CornerRadius = UDim.new(
        0,
        CONFIG.CornerRadius
    )

    Corner.Parent = Button

    Button.MouseEnter:Connect(function()

        TweenService:Create(
            Button,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 =
                    CONFIG.HoverSurface
            }
        ):Play()

    end)

    Button.MouseLeave:Connect(function()

        TweenService:Create(
            Button,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 =
                    CONFIG.Surface
            }
        ):Play()

    end)

    Button.MouseButton1Click:Connect(function()

        if callback then
            callback()
        end

    end)

    return Button
end

--==================================================
-- SLIDER
--==================================================

local function CreateSlider(
    tabName,
    name,
    min,
    max,
    default,
    callback
)

    local content = TabContents[tabName]

    if not content then
        return
    end

    local Container = Instance.new("Frame")

    Container.Size = UDim2.new(
        1,
        0,
        0,
        48
    )

    Container.BackgroundColor3 = CONFIG.Surface
    Container.BorderSizePixel = 0
    Container.Active = true
    Container.ZIndex = 12
    Container.Parent = content.scroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,CONFIG.CornerRadius)
    Corner.Parent = Container

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(
        0.6,
        0,
        0,
        18
    )

    Label.Position = UDim2.new(
        0,
        8,
        0,
        5
    )

    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = CONFIG.FontMedium
    Label.TextSize = 8
    Label.TextColor3 = CONFIG.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 13
    Label.Parent = Container

    local ValueLabel = Instance.new("TextLabel")

    ValueLabel.Size = UDim2.new(
        0.3,
        0,
        0,
        18
    )

    ValueLabel.Position = UDim2.new(
        0.65,
        0,
        0,
        5
    )

    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = CONFIG.FontMedium
    ValueLabel.TextSize = 8
    ValueLabel.TextColor3 = CONFIG.Accent
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.ZIndex = 13
    ValueLabel.Parent = Container

    local SliderBg = Instance.new("Frame")

    SliderBg.Size = UDim2.new(
        1,
        -22,
        0,
        5
    )

    SliderBg.Position = UDim2.new(
        0,
        11,
        0,
        32
    )

    SliderBg.BackgroundColor3 = CONFIG.SurfaceLight
    SliderBg.BorderSizePixel = 0
    SliderBg.Active = true
    SliderBg.ZIndex = 14
    SliderBg.Parent = Container

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1,0)
    SliderCorner.Parent = SliderBg

    local Percentage =
        math.clamp(
            (default-min)/(max-min),
            0,
            1
        )

    local Fill = Instance.new("Frame")

    Fill.Size = UDim2.new(
        Percentage,
        0,
        1,
        0
    )

    Fill.BackgroundColor3 = CONFIG.Accent
    Fill.BorderSizePixel = 0
    Fill.Active = false
    Fill.ZIndex = 15
    Fill.Parent = SliderBg

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1,0)
    FillCorner.Parent = Fill

    -- WHITE CIRCLE KNOB

    local Knob = Instance.new("Frame")

    Knob.Size = UDim2.new(
        0,
        14,
        0,
        14
    )

    Knob.AnchorPoint = Vector2.new(
        0.5,
        0.5
    )

    Knob.Position = UDim2.new(
        Percentage,
        0,
        0.5,
        0
    )

    Knob.BackgroundColor3 = Color3.new(
        1,
        1,
        1
    )

    Knob.BorderSizePixel = 0
    Knob.Active = false
    Knob.ZIndex = 16
    Knob.Parent = SliderBg

    local KnobCorner = Instance.new("UICorner")

    KnobCorner.CornerRadius =
        UDim.new(1,0)

    KnobCorner.Parent = Knob

    local KnobStroke = Instance.new("UIStroke")

    KnobStroke.Color = CONFIG.Accent
    KnobStroke.Thickness = 1
    KnobStroke.Parent = Knob

    local draggingSlider = false

    local function updateSlider(input)

        local x =
            input.Position.X -
            SliderBg.AbsolutePosition.X

        local percent =
            math.clamp(
                x /
                SliderBg.AbsoluteSize.X,
                0,
                1
            )

        local value =
            min +
            (max-min)*percent

        value = math.floor(
            value + 0.5
        )

        ValueLabel.Text =
            tostring(value)

        Fill.Size =
            UDim2.new(
                percent,
                0,
                1,
                0
            )

        Knob.Position =
            UDim2.new(
                percent,
                0,
                0.5,
                0
            )

        if callback then
            callback(value)
        end
    end

    SliderBg.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or
            input.UserInputType ==
            Enum.UserInputType.Touch then

            draggingSlider = true

            updateSlider(input)
        end

    end)

    UIS.InputChanged:Connect(function(input)

        if not draggingSlider then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.MouseMovement
            or
            input.UserInputType ==
            Enum.UserInputType.Touch then

            updateSlider(input)

        end

    end)

    UIS.InputEnded:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or
            input.UserInputType ==
            Enum.UserInputType.Touch then

            draggingSlider = false

        end

    end)

    return Container
end

--==================================================
-- DROPDOWN
--==================================================

local function CreateDropdown(
    tabName,
    name,
    options,
    default,
    callback
)

    local content = TabContents[tabName]

    if not content then
        return
    end

    local Container = Instance.new("Frame")

    Container.Size = UDim2.new(
        1,
        0,
        0,
        36
    )

    Container.BackgroundColor3 =
        CONFIG.Surface

    Container.BorderSizePixel = 0
    Container.ZIndex = 12
    Container.ClipsDescendants = true
    Container.Parent = content.scroll

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,CONFIG.CornerRadius)
    Corner.Parent = Container

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(
        1,
        0,
        0,
        36
    )

    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.ZIndex = 15
    Button.Parent = Container

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(
        0.55,
        0,
        1,
        0
    )

    Label.Position = UDim2.new(
        0,
        8,
        0,
        0
    )

    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = CONFIG.FontMedium
    Label.TextSize = 9
    Label.TextColor3 = CONFIG.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 16
    Label.Parent = Button

    local Selected = Instance.new("TextLabel")

    Selected.Size = UDim2.new(
        0.35,
        0,
        1,
        0
    )

    Selected.Position = UDim2.new(
        0.55,
        0,
        0,
        0
    )

    Selected.BackgroundTransparency = 1
    Selected.Text = tostring(default)
    Selected.Font = CONFIG.FontMedium
    Selected.TextSize = 8
    Selected.TextColor3 = CONFIG.Accent
    Selected.TextXAlignment = Enum.TextXAlignment.Right
    Selected.ZIndex = 16
    Selected.Parent = Button

    local Arrow = Instance.new("TextLabel")

    Arrow.Size = UDim2.new(
        0,
        20,
        0,
        20
    )

    Arrow.Position = UDim2.new(
        1,
        -25,
        0,
        8
    )

    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.Font = CONFIG.Font
    Arrow.TextSize = 8
    Arrow.TextColor3 = CONFIG.TextSecondary
    Arrow.ZIndex = 16
    Arrow.Parent = Button

    local Open = false

    local optionButtons = {}

    for i,option in ipairs(options) do

        local Option = Instance.new("TextButton")

        Option.Size = UDim2.new(
            1,
            -16,
            0,
            28
        )

        Option.Position = UDim2.new(
            0,
            8,
            0,
            38 + ((i-1)*30)
        )

        Option.BackgroundColor3 =
            CONFIG.SurfaceLight

        Option.BorderSizePixel = 0
        Option.Text = tostring(option)
        Option.Font = CONFIG.FontMedium
        Option.TextSize = 8
        Option.TextColor3 = CONFIG.Text
        Option.AutoButtonColor = false
        Option.ZIndex = 17
        Option.Parent = Container

        local OptionCorner = Instance.new("UICorner")

        OptionCorner.CornerRadius =
            UDim.new(0,4)

        OptionCorner.Parent = Option

        optionButtons[i] = Option

        Option.MouseButton1Click:Connect(function()

            Selected.Text =
                tostring(option)

            Open = false

            local targetHeight = 36

            TweenService:Create(
                Container,
                TweenInfo.new(
                    CONFIG.AnimationSpeed,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.Out
                ),
                {
                    Size = UDim2.new(
                        1,
                        0,
                        0,
                        targetHeight
                    )
                }
            ):Play()

            TweenService:Create(
                Arrow,
                TweenInfo.new(
                    CONFIG.AnimationSpeed
                ),
                {
                    Rotation = 0
                }
            ):Play()

            if callback then
                callback(option)
            end

        end)
    end

    Button.MouseButton1Click:Connect(function()

        Open = not Open

        local height =
            Open
            and (
                40 +
                (#options*30)
            )
            or 36

        TweenService:Create(
            Container,
            TweenInfo.new(
                CONFIG.AnimationSpeed,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    1,
                    0,
                    0,
                    height
                )
            }
        ):Play()

        TweenService:Create(
            Arrow,
            TweenInfo.new(
                CONFIG.AnimationSpeed
            ),
            {
                Rotation =
                    Open
                    and 180
                    or 0
            }
        ):Play()

    end)

    return Container
end

--==================================================
-- RAINBOW COLOR PICKER
--==================================================

local function CreateRainbowColorPicker(
    tabName,
    name,
    callback
)

    local content = TabContents[tabName]

    if not content then
        return
    end

    local Container = Instance.new("Frame")

    Container.Size = UDim2.new(
        1,
        0,
        0,
        36
    )

    Container.BackgroundColor3 =
        CONFIG.Surface

    Container.BorderSizePixel = 0
    Container.ZIndex = 12
    Container.Parent = content.scroll

    local Corner = Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            CONFIG.CornerRadius
        )

    Corner.Parent = Container

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(
        0.6,
        0,
        1,
        0
    )

    Label.Position = UDim2.new(
        0,
        8,
        0,
        0
    )

    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = CONFIG.FontMedium
    Label.TextSize = 9
    Label.TextColor3 = CONFIG.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 13
    Label.Parent = Container

    local Preview = Instance.new("TextButton")

    Preview.Size = UDim2.new(
        0,
        22,
        0,
        22
    )

    Preview.Position = UDim2.new(
        1,
        -32,
        0,
        7
    )

    Preview.BackgroundColor3 =
        Color3.fromRGB(255,0,0)

    Preview.BorderSizePixel = 0
    Preview.Text = ""
    Preview.AutoButtonColor = false
    Preview.ZIndex = 14
    Preview.Parent = Container

    local PreviewCorner = Instance.new("UICorner")

    PreviewCorner.CornerRadius =
        UDim.new(1,0)

    PreviewCorner.Parent = Preview

    local PreviewStroke = Instance.new("UIStroke")

    PreviewStroke.Color =
        Color3.fromRGB(255,255,255)

    PreviewStroke.Transparency = 0.3
    PreviewStroke.Thickness = 1
    PreviewStroke.Parent = Preview

    local CurrentColor =
        Color3.fromRGB(
            255,
            0,
            0
        )

    local ActivePopup

    Preview.MouseButton1Click:Connect(function()

        if ActivePopup then

            local old = ActivePopup

            ActivePopup = nil

            TweenService:Create(
                old,
                TweenInfo.new(
                    CONFIG.AnimationSpeed,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.In
                ),
                {
                    Size = UDim2.new(
                        0,
                        210,
                        0,
                        0
                    )
                }
            ):Play()

            task.delay(
                CONFIG.AnimationSpeed,
                function()

                    if old then
                        old:Destroy()
                    end

                end
            )

            return
        end

        --==================================================
        -- POPUP
        --==================================================

        local Popup = Instance.new("Frame")

        ActivePopup = Popup

        local popupWidth = 220
        local popupHeight = 265

        local viewport =
            Camera.ViewportSize

        local popupX =
            Preview.AbsolutePosition.X -
            190

        local popupY =
            Preview.AbsolutePosition.Y -
            popupHeight -
            8

        popupX = math.clamp(
            popupX,
            5,
            viewport.X-popupWidth-5
        )

        popupY = math.clamp(
            popupY,
            5,
            viewport.Y-popupHeight-5
        )

        Popup.Size = UDim2.new(
            0,
            popupWidth,
            0,
            0
        )

        Popup.Position = UDim2.new(
            0,
            popupX,
            0,
            popupY
        )

        Popup.BackgroundColor3 =
            Color3.fromRGB(
                18,
                18,
                22
            )

        Popup.BorderSizePixel = 0
        Popup.ClipsDescendants = true
        Popup.ZIndex = 999
        Popup.Parent = ScreenGui

        local PopupCorner = Instance.new("UICorner")

        PopupCorner.CornerRadius =
            UDim.new(0,9)

        PopupCorner.Parent = Popup

        local PopupStroke = Instance.new("UIStroke")

        PopupStroke.Color =
            CONFIG.Accent

        PopupStroke.Thickness = 1
        PopupStroke.Transparency = 0.1
        PopupStroke.Parent = Popup

        -- OPEN ANIMATION

        TweenService:Create(
            Popup,
            TweenInfo.new(
                CONFIG.AnimationSpeed,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    0,
                    popupWidth,
                    0,
                    popupHeight
                )
            }
        ):Play()

        --==================================================
        -- TITLE
        --==================================================

        local Title = Instance.new("TextLabel")

        Title.Size = UDim2.new(
            1,
            -50,
            0,
            25
        )

        Title.Position = UDim2.new(
            0,
            10,
            0,
            4
        )

        Title.BackgroundTransparency = 1
        Title.Text = name
        Title.Font = CONFIG.Font
        Title.TextSize = 10
        Title.TextColor3 = CONFIG.Text
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 1002
        Title.Parent = Popup

        --==================================================
        -- CLOSE
        --==================================================

        local Close = Instance.new("TextButton")

        Close.Size = UDim2.new(
            0,
            22,
            0,
            22
        )

        Close.Position = UDim2.new(
            1,
            -28,
            0,
            5
        )

        Close.BackgroundColor3 =
            CONFIG.SurfaceLight

        Close.BorderSizePixel = 0
        Close.Text = "×"
        Close.Font = CONFIG.Font
        Close.TextSize = 13
        Close.TextColor3 = CONFIG.Text
        Close.AutoButtonColor = false
        Close.ZIndex = 1003
        Close.Parent = Popup

        local CloseCorner = Instance.new("UICorner")

        CloseCorner.CornerRadius =
            UDim.new(1,0)

        CloseCorner.Parent = Close

        --==================================================
        -- CIRCLE WHEEL
        --==================================================

        local wheelSize = 160

        local Wheel = Instance.new("Frame")

        Wheel.Size = UDim2.new(
            0,
            wheelSize,
            0,
            wheelSize
        )

        Wheel.Position = UDim2.new(
            0.5,
            -wheelSize/2,
            0,
            32
        )

        Wheel.BackgroundColor3 =
            Color3.new(
                1,
                1,
                1
            )

        Wheel.BorderSizePixel = 0
        Wheel.ClipsDescendants = true
        Wheel.Active = true
        Wheel.ZIndex = 1000
        Wheel.Parent = Popup

        local WheelCorner = Instance.new("UICorner")

        WheelCorner.CornerRadius =
            UDim.new(1,0)

        WheelCorner.Parent = Wheel

        --==================================================
        -- TRUE CIRCULAR HSV WHEEL
        --==================================================

        local segments = 90
        local rings = 50

        local centerPoint =
            wheelSize/2

        local radius =
            wheelSize/2

        for ring=1,rings do

            local saturation =
                ring/rings

            local ringRadius =
                radius*saturation

            local circumference =
                2*math.pi*
                math.max(
                    ringRadius,
                    1
                )

            local segmentSize =
                circumference/
                segments

            for segment=1,segments do

                local hue =
                    (segment-1)/
                    segments

                local angle =
                    hue*
                    math.pi*2

                local x =
                    centerPoint+
                    math.cos(angle)*
                    ringRadius

                local y =
                    centerPoint+
                    math.sin(angle)*
                    ringRadius

                local piece =
                    Instance.new("Frame")

                piece.Size = UDim2.new(
                    0,
                    math.max(
                        3,
                        segmentSize+1
                    ),
                    0,
                    math.max(
                        3,
                        segmentSize+1
                    )
                )

                piece.Position = UDim2.new(
                    0,
                    x-segmentSize/2,
                    0,
                    y-segmentSize/2
                )

                piece.BackgroundColor3 =
                    Color3.fromHSV(
                        hue,
                        saturation,
                        1
                    )

                piece.BorderSizePixel = 0
                piece.ZIndex = 1000
                piece.Parent = Wheel

            end
        end

        --==================================================
        -- WHITE CENTER
        --==================================================

        local Center = Instance.new("Frame")

        Center.Size = UDim2.new(
            0,
            36,
            0,
            36
        )

        Center.AnchorPoint =
            Vector2.new(
                0.5,
                0.5
            )

        Center.Position = UDim2.new(
            0.5,
            0,
            0.5,
            0
        )

        Center.BackgroundColor3 =
            Color3.new(
                1,
                1,
                1
            )

        Center.BorderSizePixel = 0
        Center.ZIndex = 1001
        Center.Parent = Wheel

        local CenterCorner =
            Instance.new("UICorner")

        CenterCorner.CornerRadius =
            UDim.new(1,0)

        CenterCorner.Parent = Center

        --==================================================
        -- CURSOR
        --==================================================

        local Cursor = Instance.new("Frame")

        Cursor.Size = UDim2.new(
            0,
            13,
            0,
            13
        )

        Cursor.AnchorPoint =
            Vector2.new(
                0.5,
                0.5
            )

        Cursor.Position =
            UDim2.new(
                0.5,
                0,
                0.5,
                0
            )

        Cursor.BackgroundColor3 =
            Color3.new(
                1,
                1,
                1
            )

        Cursor.BorderSizePixel = 0
        Cursor.ZIndex = 1005
        Cursor.Parent = Wheel

        local CursorCorner =
            Instance.new("UICorner")

        CursorCorner.CornerRadius =
            UDim.new(1,0)

        CursorCorner.Parent = Cursor

        local CursorStroke =
            Instance.new("UIStroke")

        CursorStroke.Color =
            Color3.new(
                0,
                0,
                0
            )

        CursorStroke.Thickness = 2
        CursorStroke.Parent = Cursor

        --==================================================
        -- RGB
        --==================================================

        local RGB = Instance.new("TextLabel")

        RGB.Size = UDim2.new(
            1,
            -20,
            0,
            20
        )

        RGB.Position = UDim2.new(
            0,
            10,
            0,
            197
        )

        RGB.BackgroundTransparency = 1

        RGB.Text =
            "RGB: 255, 0, 0"

        RGB.Font =
            CONFIG.FontMedium

        RGB.TextSize = 9
        RGB.TextColor3 = CONFIG.Text
        RGB.TextXAlignment =
            Enum.TextXAlignment.Center

        RGB.ZIndex = 1002
        RGB.Parent = Popup

        --==================================================
        -- PICKER
        --==================================================

        local dragging = false

        local function pickColor(input)

            local absolute =
                Wheel.AbsolutePosition

            local size =
                Wheel.AbsoluteSize

            local cx =
                absolute.X+
                size.X/2

            local cy =
                absolute.Y+
                size.Y/2

            local dx =
                input.Position.X-cx

            local dy =
                input.Position.Y-cy

            local distance =
                math.sqrt(
                    dx*dx+
                    dy*dy
                )

            local maxRadius =
                size.X/2

            if distance >
                maxRadius then

                local scale =
                    maxRadius/
                    distance

                dx = dx*scale
                dy = dy*scale

                distance =
                    maxRadius

            end

            local angle =
                math.atan2(
                    dy,
                    dx
                )

            local hue =
                angle/
                (math.pi*2)

            if hue < 0 then
                hue = hue+1
            end

            local saturation =
                math.clamp(
                    distance/
                    maxRadius,
                    0,
                    1
                )

            local color =
                Color3.fromHSV(
                    hue,
                    saturation,
                    1
                )

            CurrentColor = color

            Preview.BackgroundColor3 =
                color

            RGB.Text =
                string.format(
                    "RGB: %d, %d, %d",
                    math.floor(color.R*255),
                    math.floor(color.G*255),
                    math.floor(color.B*255)
                )

            Cursor.Position =
                UDim2.new(
                    0.5,
                    dx,
                    0.5,
                    dy
                )

            if callback then
                callback(color)
            end

        end

        Wheel.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = true

                pickColor(input)

            end

        end)

        local MoveConnection

        MoveConnection =
            UIS.InputChanged:Connect(function(input)

                if not dragging then
                    return
                end

                if input.UserInputType ==
                    Enum.UserInputType.MouseMovement
                    or
                    input.UserInputType ==
                    Enum.UserInputType.Touch then

                    pickColor(input)

                end

            end)

        local EndConnection

        EndConnection =
            UIS.InputEnded:Connect(function(input)

                if input.UserInputType ==
                    Enum.UserInputType.MouseButton1
                    or
                    input.UserInputType ==
                    Enum.UserInputType.Touch then

                    dragging = false

                end

            end)

        --==================================================
        -- PRESETS
        --==================================================

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
            Color3.fromRGB(0,0,0)

        }

        for i,color in ipairs(presets) do

            local Button =
                Instance.new("TextButton")

            Button.Size = UDim2.new(
                0,
                14,
                0,
                14
            )

            Button.Position = UDim2.new(
                0,
                8+(i-1)*18,
                0,
                222
            )

            Button.BackgroundColor3 =
                color

            Button.BorderSizePixel = 0
            Button.Text = ""
            Button.AutoButtonColor = false
            Button.ZIndex = 1003
            Button.Parent = Popup

            local Corner =
                Instance.new("UICorner")

            Corner.CornerRadius =
                UDim.new(1,0)

            Corner.Parent = Button

            Button.MouseButton1Click:Connect(function()

                CurrentColor = color

                Preview.BackgroundColor3 =
                    color

                local h,s,v =
                    color:ToHSV()

                Cursor.Position =
                    UDim2.new(
                        0.5,
                        math.cos(h*math.pi*2)*
                            (wheelSize/2*s),

                        0.5,
                        math.sin(h*math.pi*2)*
                            (wheelSize/2*s)
                    )

                RGB.Text =
                    string.format(
                        "RGB: %d, %d, %d",
                        math.floor(color.R*255),
                        math.floor(color.G*255),
                        math.floor(color.B*255)
                    )

                if callback then
                    callback(color)
                end

            end)

        end

        --==================================================
        -- CLOSE
        --==================================================

        Close.MouseButton1Click:Connect(function()

            if not Popup then
                return
            end

            ActivePopup = nil

            TweenService:Create(
                Popup,
                TweenInfo.new(
                    CONFIG.AnimationSpeed,
                    Enum.EasingStyle.Quint,
                    Enum.EasingDirection.In
                ),
                {
                    Size = UDim2.new(
                        0,
                        popupWidth,
                        0,
                        0
                    )
                }
            ):Play()

            task.delay(
                CONFIG.AnimationSpeed,
                function()

                    if Popup then
                        Popup:Destroy()
                    end

                end
            )

        end)

        Popup.Destroying:Connect(function()

            if MoveConnection then
                MoveConnection:Disconnect()
            end

            if EndConnection then
                EndConnection:Disconnect()
            end

        end)

    end)

    return Container
end

--==================================================
-- MAIN TAB
--==================================================

CreateSectionLabel(
    "Main",
    "TOGGLES"
)

CreateToggle(
    "Main",
    "Toggle Test 1",
    false,
    function(state)

        print(
            "Toggle 1:",
            state
        )

    end
)

CreateToggle(
    "Main",
    "Toggle Test 2",
    true,
    function(state)

        print(
            "Toggle 2:",
            state
        )

    end
)

CreateToggle(
    "Main",
    "Enable Feature",
    false,
    function(state)

        print(
            "Feature:",
            state
        )

    end
)

CreateSectionLabel(
    "Main",
    "BUTTONS"
)

CreateButton(
    "Main",
    "Button Test 1",
    function()

        print(
            "Button clicked!"
        )

    end
)

CreateButton(
    "Main",
    "Test Notification",
    function()

        print(
            "[Oishi] Notification!"
        )

    end
)

CreateSectionLabel(
    "Main",
    "SLIDERS"
)

CreateSlider(
    "Main",
    "Slider Test 1",
    0,
    100,
    50,
    function(value)

        print(
            "Slider:",
            value
        )

    end
)

CreateSlider(
    "Main",
    "Speed",
    1,
    200,
    80,
    function(value)

        print(
            "Speed:",
            value
        )

    end
)

CreateSectionLabel(
    "Main",
    "DROPDOWNS"
)

CreateDropdown(
    "Main",
    "Select Mode",
    {
        "Default",
        "Fast",
        "Smooth",
        "Extreme"
    },
    "Default",
    function(value)

        print(
            "Selected:",
            value
        )

    end
)

CreateSectionLabel(
    "Main",
    "COLOR PICKERS"
)

CreateRainbowColorPicker(
    "Main",
    "Color 1",
    function(color)

        print(
            "Color 1:",
            color
        )

    end
)

CreateRainbowColorPicker(
    "Main",
    "Color 2",
    function(color)

        print(
            "Color 2:",
            color
        )

    end
)

--==================================================
-- SETTINGS TAB
--==================================================

CreateSectionLabel(
    "Settings",
    "UI APPEARANCE"
)

CreateRainbowColorPicker(
    "Settings",
    "Accent Color",
    function(color)

        CONFIG.Accent = color
        CONFIG.ToggleOn = color
        CONFIG.TabActive = color
        CONFIG.Border = color

        MainStroke.Color = color
        HeaderTitle.TextColor3 = color

        for _,btn in pairs(TabButtons) do

            if btn == TabButtons[CurrentTab] then
                btn.BackgroundColor3 = color
            end

        end

    end
)

CreateRainbowColorPicker(
    "Settings",
    "Background Color",
    function(color)

        CONFIG.Background = color

        Main.BackgroundColor3 = color
        LeftSide.BackgroundColor3 = color

    end
)

CreateRainbowColorPicker(
    "Settings",
    "Surface Color",
    function(color)

        CONFIG.Surface = color

        Header.BackgroundColor3 = color
        RightSide.BackgroundColor3 = color

        for _,content in pairs(TabContents) do

            for _,object in ipairs(
                content.scroll:GetChildren()
            ) do

                if object:IsA("Frame") then

                    object.BackgroundColor3 =
                        color

                end

            end

        end

    end
)

CreateRainbowColorPicker(
    "Settings",
    "Text Color",
    function(color)

        CONFIG.Text = color

        HeaderTitle.TextColor3 =
            CONFIG.Accent

    end
)

CreateSectionLabel(
    "Settings",
    "UI CONTROLS"
)

CreateSlider(
    "Settings",
    "UI Scale",
    70,
    130,
    100,
    function(value)

        CONFIG.UIScale =
            value/100

        UIScale.Scale =
            CONFIG.UIScale

    end
)

CreateSlider(
    "Settings",
    "Corner Radius",
    0,
    15,
    6,
    function(value)

        CONFIG.CornerRadius =
            value

        MainCorner.CornerRadius =
            UDim.new(
                0,
                value
            )

    end
)

CreateSlider(
    "Settings",
    "Animation Speed",
    5,
    100,
    20,
    function(value)

        CONFIG.AnimationSpeed =
            value/100

    end
)

CreateSlider(
    "Settings",
    "Border Thickness",
    0,
    5,
    2,
    function(value)

        MainStroke.Thickness =
            value

    end
)

CreateSectionLabel(
    "Settings",
    "EXTRA OPTIONS"
)

CreateToggle(
    "Settings",
    "Show UI Border",
    true,
    function(state)

        MainStroke.Enabled =
            state

    end
)

CreateToggle(
    "Settings",
    "Rounded UI",
    true,
    function(state)

        MainCorner.CornerRadius =
            UDim.new(
                0,
                state
                and CONFIG.CornerRadius
                or 0
            )

    end
)

CreateToggle(
    "Settings",
    "Animated UI",
    true,
    function(state)

        if state then

            CONFIG.AnimationSpeed = 0.20

        else

            CONFIG.AnimationSpeed = 0

        end

    end
)

CreateToggle(
    "Settings",
    "Compact Mode",
    false,
    function(state)

        if state then

            UIScale.Scale = 0.85

        else

            UIScale.Scale =
                CONFIG.UIScale

        end

    end
)

CreateDropdown(
    "Settings",
    "Font",
    {
        "GothamBold",
        "GothamMedium",
        "SourceSans",
        "Arial"
    },
    "GothamBold",
    function(value)

        local fontMap = {

            GothamBold =
                Enum.Font.GothamBold,

            GothamMedium =
                Enum.Font.GothamMedium,

            SourceSans =
                Enum.Font.SourceSans,

            Arial =
                Enum.Font.Arial

        }

        if fontMap[value] then

            CONFIG.Font =
                fontMap[value]

        end

    end
)

CreateDropdown(
    "Settings",
    "UI Theme",
    {
        "Blue",
        "Purple",
        "Red",
        "Green",
        "White"
    },
    "Blue",
    function(value)

        local themes = {

            Blue =
                Color3.fromRGB(
                    0,
                    150,
                    255
                ),

            Purple =
                Color3.fromRGB(
                    150,
                    70,
                    255
                ),

            Red =
                Color3.fromRGB(
                    255,
                    60,
                    60
                ),

            Green =
                Color3.fromRGB(
                    50,
                    220,
                    120
                ),

            White =
                Color3.fromRGB(
                    255,
                    255,
                    255
                )

        }

        if themes[value] then

            local color =
                themes[value]

            CONFIG.Accent = color
            CONFIG.ToggleOn = color
            CONFIG.TabActive = color
            CONFIG.Border = color

            MainStroke.Color =
                color

            HeaderTitle.TextColor3 =
                color

            for name,button in pairs(
                TabButtons
            ) do

                if name == CurrentTab then

                    button.BackgroundColor3 =
                        color

                end

            end

        end

    end
)

CreateSectionLabel(
    "Settings",
    "RESET"
)

CreateButton(
    "Settings",
    "Reset UI Settings",
    function()

        CONFIG.Accent =
            Color3.fromRGB(
                0,
                150,
                255
            )

        CONFIG.Background =
            Color3.fromRGB(
                5,
                5,
                5
            )

        CONFIG.Surface =
            Color3.fromRGB(
                15,
                15,
                15
            )

        CONFIG.Text =
            Color3.fromRGB(
                220,
                220,
                220
            )

        CONFIG.Border =
            CONFIG.Accent

        CONFIG.UIScale = 1

        CONFIG.CornerRadius = 6

        CONFIG.AnimationSpeed = 0.20

        UIScale.Scale = 1

        Main.BackgroundColor3 =
            CONFIG.Background

        LeftSide.BackgroundColor3 =
            CONFIG.Background

        RightSide.BackgroundColor3 =
            CONFIG.Surface

        Header.BackgroundColor3 =
            CONFIG.Surface

        MainStroke.Color =
            CONFIG.Accent

        MainStroke.Thickness = 2

        HeaderTitle.TextColor3 =
            CONFIG.Accent

        MainCorner.CornerRadius =
            UDim.new(
                0,
                CONFIG.CornerRadius
            )

    end
)

--==================================================
-- CANVAS UPDATE
--==================================================

task.wait(0.1)

UpdateCanvas()

for _,content in pairs(TabContents) do

    content.layout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(function()

        content.scroll.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                content.layout.AbsoluteContentSize.Y+20
            )

    end)

end

--==================================================
-- HEADER ONLY DRAG SYSTEM
--==================================================

local draggingMain = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
        Enum.UserInputType.Touch then

        draggingMain = true

        dragStart =
            input.Position

        startPosition =
            Main.Position

    end

end)

UIS.InputChanged:Connect(function(input)

    if not draggingMain then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or
        input.UserInputType ==
        Enum.UserInputType.Touch then

        local delta =
            input.Position -
            dragStart

        Main.Position =
            UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset+
                    delta.X,

                startPosition.Y.Scale,
                startPosition.Y.Offset+
                    delta.Y
            )

    end

end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
        Enum.UserInputType.Touch then

        draggingMain = false

    end

end)

--==================================================
-- OPEN UI ANIMATION
--==================================================

local function OpenUI()

    Main.Visible = true

    Main.Size = UDim2.new(
        0,
        uiWidth*0.85,
        0,
        uiHeight*0.85
    )

    Main.BackgroundTransparency = 1

    TweenService:Create(
        Main,
        TweenInfo.new(
            0.35,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.new(
                0,
                uiWidth,
                0,
                uiHeight
            ),
            BackgroundTransparency = 0
        }
    ):Play()

end

--==================================================
-- MOBILE BUTTONS
--==================================================

if isMobile then

    local unlocked = false

    local ToggleBtn = Instance.new("TextButton")

    ToggleBtn.Size = UDim2.new(
        0,
        90,
        0,
        32
    )

    ToggleBtn.Position = UDim2.new(
        0,
        10,
        0,
        150
    )

    ToggleBtn.BackgroundColor3 =
        CONFIG.Accent

    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = "Toggle UI"
    ToggleBtn.Font = CONFIG.Font
    ToggleBtn.TextSize = 10
    ToggleBtn.TextColor3 =
        Color3.new(1,1,1)

    ToggleBtn.AutoButtonColor = false
    ToggleBtn.ZIndex = 999999
    ToggleBtn.Parent = ScreenGui

    local ToggleCorner =
        Instance.new("UICorner")

    ToggleCorner.CornerRadius =
        UDim.new(0,6)

    ToggleCorner.Parent =
        ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()

        if Main.Visible then

            Main.Visible = false

        else

            OpenUI()

        end

    end)

    local LockBtn = Instance.new("TextButton")

    LockBtn.Size = UDim2.new(
        0,
        90,
        0,
        32
    )

    LockBtn.Position = UDim2.new(
        0,
        10,
        0,
        190
    )

    LockBtn.BackgroundColor3 =
        CONFIG.Surface

    LockBtn.BorderSizePixel = 0
    LockBtn.Text = "Unlock UI"
    LockBtn.Font = CONFIG.Font
    LockBtn.TextSize = 10
    LockBtn.TextColor3 =
        Color3.new(1,1,1)

    LockBtn.AutoButtonColor = false
    LockBtn.ZIndex = 999999
    LockBtn.Parent = ScreenGui

    local LockCorner =
        Instance.new("UICorner")

    LockCorner.CornerRadius =
        UDim.new(0,6)

    LockCorner.Parent =
        LockBtn

    LockBtn.MouseButton1Click:Connect(function()

        unlocked = not unlocked

        LockBtn.Text =
            unlocked
            and "Lock UI"
            or "Unlock UI"

        LockBtn.BackgroundColor3 =
            unlocked
            and CONFIG.Accent
            or CONFIG.Surface

    end)

    local function MakeButtonDraggable(Button)

        local dragging = false
        local dragStart
        local startPos
        local moved = false

        Button.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = true
                moved = false

                dragStart =
                    input.Position

                startPos =
                    Button.Position

            end

        end)

        UIS.InputChanged:Connect(function(input)

            if not dragging then
                return
            end

            if not unlocked then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                local delta =
                    input.Position-
                    dragStart

                if delta.Magnitude > 3 then
                    moved = true
                end

                Button.Position =
                    UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset+
                            delta.X,

                        startPos.Y.Scale,
                        startPos.Y.Offset+
                            delta.Y
                    )

            end

        end)

        UIS.InputEnded:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                dragging = false

            end

        end)

    end

    MakeButtonDraggable(
        ToggleBtn
    )

    MakeButtonDraggable(
        LockBtn
    )

else

    --==================================================
    -- PC RIGHT SHIFT
    --==================================================

    UIS.InputBegan:Connect(function(
        input,
        processed
    )

        if processed then
            return
        end

        if input.KeyCode ==
            Enum.KeyCode.RightShift then

            if Main.Visible then
                Main.Visible = false
            else
                OpenUI()
            end

        end

    end)

end

--==================================================
-- INITIAL OPEN
--==================================================

if isPC then

    task.delay(
        0.15,
        function()
            OpenUI()
        end
    )

end

print(
    "[Oishi Hub] Loaded - Main + Settings Edition"
)
