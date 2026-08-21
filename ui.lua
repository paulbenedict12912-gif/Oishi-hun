--==============================================================
-- OISHI HUB UI LIBRARY
-- Clean Mobile + PC Edition
-- Main + Settings
-- Circular Color Picker
-- Hue + Brightness Controls
-- Animated Tabs / Popup / UI Opening
-- Mobile Friendly
--==============================================================

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
    SurfaceLight = Color3.fromRGB(24,24,28),

    Text = Color3.fromRGB(235,235,240),
    TextSecondary = Color3.fromRGB(145,145,150),

    ToggleOn = Color3.fromRGB(0,150,255),
    ToggleOff = Color3.fromRGB(42,42,47),

    Border = Color3.fromRGB(35,35,42),

    HoverSurface = Color3.fromRGB(28,28,33),
    ClickSurface = Color3.fromRGB(34,34,40),

    Font = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,

    AnimationSpeed = 0.20,
    UITransparency = 0,
    Rounded = true,
}

--==============================================================
-- SETTINGS STATE
--==============================================================

local UISettings = {
    Accent = CONFIG.Accent,
    Background = CONFIG.Background,
    Surface = CONFIG.Surface,
    Text = CONFIG.Text,

    AnimationSpeed = 0.20,
    Transparency = 0,

    Rounded = true,
    ShowBorders = true,
    SmoothAnimations = true,
    CompactMode = false,
}

--==============================================================
-- REMOVE OLD UI
--==============================================================

local old = PlayerGui:FindFirstChild("OishiHubExample")

if old then
    old:Destroy()
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

local uiWidth
local uiHeight

if isPC then
    uiWidth = 620
    uiHeight = 440
else
    uiWidth = math.min(650, viewport.X - 20)
    uiHeight = math.min(420, viewport.Y * 0.62)
end

--==============================================================
-- UTILITY
--==============================================================

local function tween(obj, properties, duration)
    duration = duration or UISettings.AnimationSpeed

    return TweenService:Create(
        obj,
        TweenInfo.new(
            duration,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        properties
    )
end

local function addCorner(obj, radius)
    local corner = Instance.new("UICorner")

    if UISettings.Rounded then
        corner.CornerRadius = UDim.new(0, radius or 7)
    else
        corner.CornerRadius = UDim.new(0, 0)
    end

    corner.Parent = obj

    return corner
end

local function addStroke(obj)
    local stroke = Instance.new("UIStroke")

    stroke.Color = UISettings.Border
    stroke.Thickness = 1
    stroke.Transparency = UISettings.ShowBorders and 0 or 1

    stroke.Parent = obj

    return stroke
end

local function updateCorner(obj, radius)
    local corner = obj:FindFirstChildOfClass("UICorner")

    if corner then
        corner.CornerRadius =
            UISettings.Rounded
            and UDim.new(0, radius or 7)
            or UDim.new(0, 0)
    end
end

--==============================================================
-- MAIN FRAME
--==============================================================

local Main = Instance.new("Frame")

Main.Size = UDim2.new(0,uiWidth,0,uiHeight)

Main.Position = UDim2.new(
    0.5,
    -uiWidth / 2,
    0.5,
    -uiHeight / 2
)

Main.BackgroundColor3 = UISettings.Background
Main.BackgroundTransparency = UISettings.Transparency
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.ZIndex = 10
Main.Parent = ScreenGui

local MainCorner = addCorner(Main,10)
local MainStroke = addStroke(Main)

--==============================================================
-- HEADER
--==============================================================

local Header = Instance.new("Frame")

Header.Size = UDim2.new(1,0,0,36)
Header.BackgroundColor3 = UISettings.Surface
Header.BackgroundTransparency = UISettings.Transparency
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = Main

addCorner(Header,10)

local HeaderCover = Instance.new("Frame")

HeaderCover.Size = UDim2.new(1,0,0,10)
HeaderCover.Position = UDim2.new(0,0,1,-10)
HeaderCover.BackgroundColor3 = UISettings.Surface
HeaderCover.BorderSizePixel = 0
HeaderCover.ZIndex = 11
HeaderCover.Parent = Header

--==============================================================
-- HEADER TITLE
--==============================================================

local HeaderTitle = Instance.new("TextLabel")

HeaderTitle.Size = UDim2.new(1,-80,0,20)
HeaderTitle.Position = UDim2.new(0,12,0,8)

HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "OISHI HUB"
HeaderTitle.Font = CONFIG.Font
HeaderTitle.TextSize = 12
HeaderTitle.TextColor3 = UISettings.Accent
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 13
HeaderTitle.Parent = Header

--==============================================================
-- CLOSE BUTTON
--==============================================================

local CloseBtn = Instance.new("TextButton")

CloseBtn.Size = UDim2.new(0,24,0,24)
CloseBtn.Position = UDim2.new(1,-31,0,6)

CloseBtn.BackgroundColor3 = UISettings.SurfaceLight
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.Font = CONFIG.Font
CloseBtn.TextSize = 15
CloseBtn.TextColor3 = UISettings.Text
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 14
CloseBtn.Parent = Header

addCorner(CloseBtn,7)

CloseBtn.MouseButton1Click:Connect(function()

    if isPC then
        Main.Visible = false
    else
        Main.Visible = false
    end

end)

--==============================================================
-- BODY
--==============================================================

local Body = Instance.new("Frame")

Body.Size = UDim2.new(1,0,1,-36)
Body.Position = UDim2.new(0,0,0,36)

Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.ZIndex = 11
Body.Parent = Main

--==============================================================
-- TAB BAR
--==============================================================

local TabBar = Instance.new("Frame")

TabBar.Size = UDim2.new(0,130,1,-16)
TabBar.Position = UDim2.new(0,8,0,8)

TabBar.BackgroundColor3 = UISettings.Surface
TabBar.BackgroundTransparency = UISettings.Transparency
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 12
TabBar.Parent = Body

addCorner(TabBar,9)
addStroke(TabBar)

--==============================================================
-- CONTENT
--==============================================================

local Content = Instance.new("Frame")

Content.Size = UDim2.new(1,-154,1,-16)
Content.Position = UDim2.new(0,146,0,8)

Content.BackgroundColor3 = UISettings.Background
Content.BackgroundTransparency = UISettings.Transparency
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.ZIndex = 12
Content.Parent = Body

addCorner(Content,9)
addStroke(Content)

--==============================================================
-- TABS
--==============================================================

local Tabs = {
    "Main",
    "Settings"
}

local CurrentTab = "Main"
local TabButtons = {}
local TabPages = {}

--==============================================================
-- CREATE TAB
--==============================================================

for i, tabName in ipairs(Tabs) do

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1,-16,0,38)
    button.Position = UDim2.new(0,8,0,10 + ((i-1)*44))

    button.BackgroundColor3 =
        tabName == "Main"
        and UISettings.Accent
        or UISettings.SurfaceLight

    button.BackgroundTransparency =
        tabName == "Main"
        and 0
        or 0.35

    button.BorderSizePixel = 0
    button.Text = tabName
    button.Font = CONFIG.Font
    button.TextSize = 10

    button.TextColor3 =
        tabName == "Main"
        and Color3.new(1,1,1)
        or UISettings.TextSecondary

    button.AutoButtonColor = false
    button.ZIndex = 13
    button.Parent = TabBar

    addCorner(button,7)

    TabButtons[tabName] = button

    local page = Instance.new("Frame")

    page.Size = UDim2.new(1,0,1,0)
    page.Position = UDim2.new(0,0,0,0)

    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = tabName == "Main"
    page.ZIndex = 13
    page.Parent = Content

    TabPages[tabName] = page

end

--==============================================================
-- TAB SWITCH ANIMATION
--==============================================================

local function switchTab(tabName)

    if CurrentTab == tabName then
        return
    end

    local oldPage = TabPages[CurrentTab]
    local newPage = TabPages[tabName]

    local oldButton = TabButtons[CurrentTab]
    local newButton = TabButtons[tabName]

    CurrentTab = tabName

    tween(
        oldButton,
        {
            BackgroundColor3 = UISettings.SurfaceLight,
            BackgroundTransparency = 0.35,
            TextColor3 = UISettings.TextSecondary
        }
    ):Play()

    tween(
        newButton,
        {
            BackgroundColor3 = UISettings.Accent,
            BackgroundTransparency = 0,
            TextColor3 = Color3.new(1,1,1)
        }
    ):Play()

    oldPage.Visible = false

    newPage.Position = UDim2.new(0,25,0,0)
    newPage.Visible = true

    tween(
        newPage,
        {
            Position = UDim2.new(0,0,0,0)
        }
    ):Play()

end

for tabName, button in pairs(TabButtons) do

    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)

end

--==============================================================
-- SCROLL CONTAINERS
--==============================================================

local function createScroll(parent)

    local scroll = Instance.new("ScrollingFrame")

    scroll.Size = UDim2.new(1,0,1,0)

    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0

    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = UISettings.Accent
    scroll.ScrollBarImageTransparency = 0.25

    scroll.CanvasSize = UDim2.new(0,0,0,0)

    scroll.ZIndex = 14
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")

    layout.Padding = UDim.new(0,7)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")

    padding.PaddingTop = UDim.new(0,12)
    padding.PaddingBottom = UDim.new(0,12)
    padding.PaddingLeft = UDim.new(0,12)
    padding.PaddingRight = UDim.new(0,12)

    padding.Parent = scroll

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

        scroll.CanvasSize = UDim2.new(
            0,
            0,
            0,
            layout.AbsoluteContentSize.Y + 24
        )

    end)

    return scroll
end

local MainScroll = createScroll(TabPages.Main)
local SettingsScroll = createScroll(TabPages.Settings)

--==============================================================
-- SECTION
--==============================================================

local function CreateSection(parent,text)

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1,0,0,22)

    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = CONFIG.Font
    label.TextSize = 9
    label.TextColor3 = UISettings.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 15
    label.Parent = parent

    return label
end

--==============================================================
-- BUTTON
--==============================================================

local function CreateButton(parent,name,callback)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1,0,0,36)

    button.BackgroundColor3 = UISettings.Surface
    button.BackgroundTransparency = UISettings.Transparency

    button.BorderSizePixel = 0
    button.Text = name

    button.Font = CONFIG.FontMedium
    button.TextSize = 9
    button.TextColor3 = UISettings.Text

    button.AutoButtonColor = false
    button.ZIndex = 15
    button.Parent = parent

    addCorner(button,7)

    button.MouseEnter:Connect(function()

        tween(
            button,
            {
                BackgroundColor3 = UISettings.SurfaceLight
            }
        ):Play()

    end)

    button.MouseLeave:Connect(function()

        tween(
            button,
            {
                BackgroundColor3 = UISettings.Surface
            }
        ):Play()

    end)

    button.MouseButton1Click:Connect(function()

        tween(
            button,
            {
                BackgroundColor3 = UISettings.Accent
            },
            0.08
        ):Play()

        task.delay(0.1,function()

            if button.Parent then
                tween(
                    button,
                    {
                        BackgroundColor3 = UISettings.Surface
                    }
                ):Play()
            end

        end)

        if callback then
            callback()
        end

    end)

    return button
end

--==============================================================
-- TOGGLE
--==============================================================

local function CreateToggle(parent,name,default,callback)

    local container = Instance.new("Frame")

    container.Size = UDim2.new(1,0,0,38)

    container.BackgroundColor3 = UISettings.Surface
    container.BackgroundTransparency = UISettings.Transparency

    container.BorderSizePixel = 0
    container.ZIndex = 15
    container.Parent = parent

    addCorner(container,7)

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(1,-65,1,0)
    label.Position = UDim2.new(0,10,0,0)

    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CONFIG.FontMedium
    label.TextSize = 9
    label.TextColor3 = UISettings.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 16
    label.Parent = container

    local toggle = Instance.new("TextButton")

    toggle.Size = UDim2.new(0,36,0,20)
    toggle.Position = UDim2.new(1,-46,0.5,-10)

    toggle.BackgroundColor3 =
        default
        and UISettings.Accent
        or CONFIG.ToggleOff

    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.ZIndex = 17
    toggle.Parent = container

    addCorner(toggle,20)

    local knob = Instance.new("Frame")

    knob.Size = UDim2.new(0,14,0,14)

    knob.Position =
        default
        and UDim2.new(1,-17,0.5,-7)
        or UDim2.new(0,3,0.5,-7)

    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 18
    knob.Parent = toggle

    addCorner(knob,20)

    local state = default == true

    toggle.MouseButton1Click:Connect(function()

        state = not state

        tween(
            toggle,
            {
                BackgroundColor3 =
                    state
                    and UISettings.Accent
                    or CONFIG.ToggleOff
            }
        ):Play()

        tween(
            knob,
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
-- SLIDER
--==============================================================

local function CreateSlider(
    parent,
    name,
    min,
    max,
    default,
    callback
)

    local container = Instance.new("Frame")

    container.Size = UDim2.new(1,0,0,52)

    container.BackgroundColor3 = UISettings.Surface
    container.BackgroundTransparency = UISettings.Transparency

    container.BorderSizePixel = 0
    container.ZIndex = 15
    container.Parent = parent

    addCorner(container,7)

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(0.7,0,0,18)
    label.Position = UDim2.new(0,10,0,5)

    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CONFIG.FontMedium
    label.TextSize = 9
    label.TextColor3 = UISettings.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 16
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")

    valueLabel.Size = UDim2.new(0.25,0,0,18)
    valueLabel.Position = UDim2.new(0.72,0,0,5)

    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.Font = CONFIG.FontMedium
    valueLabel.TextSize = 9
    valueLabel.TextColor3 = UISettings.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 16
    valueLabel.Parent = container

    --==========================================================
    -- SLIDER TRACK
    --==========================================================

    local track = Instance.new("Frame")

    track.Size = UDim2.new(1,-24,0,5)
    track.Position = UDim2.new(0,12,0,34)

    track.BackgroundColor3 = UISettings.SurfaceLight
    track.BorderSizePixel = 0
    track.ZIndex = 16
    track.Parent = container

    addCorner(track,10)

    local percent =
        math.clamp(
            (default-min)/(max-min),
            0,
            1
        )

    local fill = Instance.new("Frame")

    fill.Size = UDim2.new(percent,0,1,0)

    fill.BackgroundColor3 = UISettings.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 17
    fill.Parent = track

    addCorner(fill,10)

    --==========================================================
    -- WHITE CIRCLE KNOB
    --==========================================================

    local knob = Instance.new("TextButton")

    knob.Size = UDim2.new(0,16,0,16)

    knob.AnchorPoint = Vector2.new(0.5,0.5)

    knob.Position = UDim2.new(
        percent,
        0,
        0.5,
        0
    )

    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.ZIndex = 20
    knob.Parent = track

    addCorner(knob,20)

    local knobStroke = Instance.new("UIStroke")

    knobStroke.Color = UISettings.Accent
    knobStroke.Thickness = 2
    knobStroke.Parent = knob

    --==========================================================
    -- SLIDER DRAG
    --==========================================================

    local sliding = false
    local sliderInput

    local function updateSlider(input)

        local x =
            math.clamp(
                input.Position.X -
                track.AbsolutePosition.X,
                0,
                track.AbsoluteSize.X
            )

        local ratio =
            math.clamp(
                x / track.AbsoluteSize.X,
                0,
                1
            )

        local value =
            math.floor(
                min +
                ((max-min)*ratio)
                + 0.5
            )

        fill.Size =
            UDim2.new(
                ratio,
                0,
                1,
                0
            )

        knob.Position =
            UDim2.new(
                ratio,
                0,
                0.5,
                0
            )

        valueLabel.Text = tostring(value)

        if callback then
            callback(value)
        end
    end

    local function beginSlider(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or
            input.UserInputType ==
            Enum.UserInputType.Touch then

            sliding = true
            sliderInput = input

            updateSlider(input)

        end
    end

    track.InputBegan:Connect(beginSlider)
    knob.InputBegan:Connect(beginSlider)

    UIS.InputChanged:Connect(function(input)

        if not sliding then
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

            sliding = false
            sliderInput = nil

        end

    end)

    return container
end

--==============================================================
-- DROPDOWN
--==============================================================

local function CreateDropdown(
    parent,
    name,
    options,
    default,
    callback
)

    local container = Instance.new("Frame")

    container.Size = UDim2.new(1,0,0,38)

    container.BackgroundColor3 = UISettings.Surface
    container.BackgroundTransparency = UISettings.Transparency

    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.ZIndex = 30
    container.Parent = parent

    addCorner(container,7)

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(0.45,0,1,0)
    label.Position = UDim2.new(0,10,0,0)

    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = CONFIG.FontMedium
    label.TextSize = 9
    label.TextColor3 = UISettings.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 31
    label.Parent = container

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(0,110,0,26)
    button.Position = UDim2.new(1,-120,0.5,-13)

    button.BackgroundColor3 = UISettings.SurfaceLight
    button.BorderSizePixel = 0

    button.Text = tostring(default).."  ▾"
    button.Font = CONFIG.FontMedium
    button.TextSize = 8
    button.TextColor3 = UISettings.Text

    button.AutoButtonColor = false
    button.ZIndex = 32
    button.Parent = container

    addCorner(button,6)

    local opened = false
    local popup

    local function closeDropdown()

        if not popup then
            return
        end

        opened = false

        tween(
            popup,
            {
                Size = UDim2.new(0,110,0,0)
            }
        ):Play()

        task.delay(
            UISettings.AnimationSpeed,
            function()

                if popup then
                    popup:Destroy()
                    popup = nil
                end

            end
        )

    end

    local function openDropdown()

        if popup then
            closeDropdown()
            return
        end

        opened = true

        popup = Instance.new("Frame")

        popup.Size = UDim2.new(0,110,0,0)

        popup.Position = UDim2.new(
            1,-120,
            0,68
        )

        popup.BackgroundColor3 = UISettings.Surface
        popup.BorderSizePixel = 0
        popup.ClipsDescendants = true
        popup.ZIndex = 100
        popup.Parent = container

        addCorner(popup,6)
        addStroke(popup)

        local layout = Instance.new("UIListLayout")

        layout.Padding = UDim.new(0,2)
        layout.Parent = popup

        for _, option in ipairs(options) do

            local optionButton =
                Instance.new("TextButton")

            optionButton.Size =
                UDim2.new(1,-8,0,28)

            optionButton.Position =
                UDim2.new(0,4,0,0)

            optionButton.BackgroundColor3 =
                UISettings.Surface

            optionButton.BorderSizePixel = 0

            optionButton.Text = tostring(option)

            optionButton.Font =
                CONFIG.FontMedium

            optionButton.TextSize = 8

            optionButton.TextColor3 =
                UISettings.Text

            optionButton.AutoButtonColor = false

            optionButton.ZIndex = 101
            optionButton.Parent = popup

            addCorner(optionButton,5)

            optionButton.MouseEnter:Connect(function()

                tween(
                    optionButton,
                    {
                        BackgroundColor3 =
                            UISettings.Accent
                    },
                    0.12
                ):Play()

            end)

            optionButton.MouseLeave:Connect(function()

                tween(
                    optionButton,
                    {
                        BackgroundColor3 =
                            UISettings.Surface
                    },
                    0.12
                ):Play()

            end)

            optionButton.MouseButton1Click:Connect(function()

                button.Text =
                    tostring(option).."  ▾"

                if callback then
                    callback(option)
                end

                closeDropdown()

            end)

        end

        local height =
            math.min(
                #options * 30 + 8,
                180
            )

        tween(
            popup,
            {
                Size = UDim2.new(0,110,0,height)
            }
        ):Play()

    end

    button.MouseButton1Click:Connect(openDropdown)

    return container
end

--==============================================================
-- CIRCULAR COLOR PICKER
--==============================================================

local function CreateColorPicker(
    parent,
    name,
    callback
)

    local container = Instance.new("Frame")

    container.Size = UDim2.new(1,0,0,38)

    container.BackgroundColor3 = UISettings.Surface
    container.BackgroundTransparency = UISettings.Transparency

    container.BorderSizePixel = 0
    container.ZIndex = 20
    container.Parent = parent

    addCorner(container,7)

    local label = Instance.new("TextLabel")

    label.Size = UDim2.new(0.6,0,1,0)
    label.Position = UDim2.new(0,10,0,0)

    label.BackgroundTransparency = 1
    label.Text = name

    label.Font = CONFIG.FontMedium
    label.TextSize = 9
    label.TextColor3 = UISettings.Text
    label.TextXAlignment = Enum.TextXAlignment.Left

    label.ZIndex = 21
    label.Parent = container

    --==========================================================
    -- PREVIEW
    --==========================================================

    local preview = Instance.new("TextButton")

    preview.Size = UDim2.new(0,22,0,22)

    preview.Position =
        UDim2.new(
            1,-32,
            0.5,-11
        )

    preview.BackgroundColor3 =
        Color3.fromRGB(255,0,0)

    preview.BorderSizePixel = 0
    preview.Text = ""
    preview.AutoButtonColor = false
    preview.ZIndex = 22
    preview.Parent = container

    addCorner(preview,20)

    local previewStroke = Instance.new("UIStroke")

    previewStroke.Color = Color3.fromRGB(255,255,255)
    previewStroke.Transparency = 0.45
    previewStroke.Thickness = 1

    previewStroke.Parent = preview

    local currentColor =
        Color3.fromRGB(255,0,0)

    local popup

    --==========================================================
    -- CREATE CIRCULAR COLOR SAMPLE
    --==========================================================

    local function createCircle(parent,size,color,z)

        local circle = Instance.new("Frame")

        circle.Size = UDim2.new(0,size,0,size)

        circle.BackgroundColor3 = color
        circle.BorderSizePixel = 0
        circle.ZIndex = z or 1
        circle.Parent = parent

        local corner = Instance.new("UICorner")

        corner.CornerRadius = UDim.new(1,0)
        corner.Parent = circle

        return circle
    end

    --==========================================================
    -- OPEN PICKER
    --==========================================================

    preview.MouseButton1Click:Connect(function()

        if popup then

            tween(
                popup,
                {
                    Size = UDim2.new(0,0,0,0)
                },
                0.16
            ):Play()

            task.delay(0.17,function()

                if popup then
                    popup:Destroy()
                    popup = nil
                end

            end)

            return
        end

        --======================================================
        -- POPUP
        --======================================================

        popup = Instance.new("Frame")

        local popupWidth = 260
        local popupHeight = 335

        local posX =
            preview.AbsolutePosition.X -
            225

        local posY =
            preview.AbsolutePosition.Y -
            popupHeight -
            8

        local screenSize =
            Camera.ViewportSize

        posX =
            math.clamp(
                posX,
                5,
                screenSize.X-popupWidth-5
            )

        posY =
            math.clamp(
                posY,
                5,
                screenSize.Y-popupHeight-5
            )

        popup.Size = UDim2.new(0,0,0,0)

        popup.Position =
            UDim2.new(
                0,
                posX,
                0,
                posY
            )

        popup.BackgroundColor3 =
            Color3.fromRGB(12,12,15)

        popup.BorderSizePixel = 0
        popup.ClipsDescendants = false
        popup.ZIndex = 500
        popup.Parent = ScreenGui

        addCorner(popup,12)
        addStroke(popup)

        --======================================================
        -- POPUP TITLE
        --======================================================

        local popupTitle =
            Instance.new("TextLabel")

        popupTitle.Size =
            UDim2.new(1,-45,0,28)

        popupTitle.Position =
            UDim2.new(0,12,0,7)

        popupTitle.BackgroundTransparency = 1
        popupTitle.Text = name

        popupTitle.Font = CONFIG.Font
        popupTitle.TextSize = 10
        popupTitle.TextColor3 = UISettings.Text

        popupTitle.TextXAlignment =
            Enum.TextXAlignment.Left

        popupTitle.ZIndex = 510
        popupTitle.Parent = popup

        --======================================================
        -- CLOSE
        --======================================================

        local close =
            Instance.new("TextButton")

        close.Size =
            UDim2.new(0,24,0,24)

        close.Position =
            UDim2.new(1,-31,0,7)

        close.BackgroundColor3 =
            UISettings.SurfaceLight

        close.BorderSizePixel = 0
        close.Text = "×"

        close.Font = CONFIG.Font
        close.TextSize = 14
        close.TextColor3 = UISettings.Text

        close.AutoButtonColor = false
        close.ZIndex = 511
        close.Parent = popup

        addCorner(close,7)

        close.MouseButton1Click:Connect(function()

            if popup then

                tween(
                    popup,
                    {
                        Size =
                            UDim2.new(
                                0,
                                0,
                                0,
                                0
                            )
                    },
                    0.16
                ):Play()

                task.delay(0.17,function()

                    if popup then
                        popup:Destroy()
                        popup = nil
                    end

                end)

            end

        end)

        --======================================================
        -- WHEEL HOLDER
        --======================================================

        local wheelSize = 190

        local wheel =
            Instance.new("Frame")

        wheel.Size =
            UDim2.new(
                0,
                wheelSize,
                0,
                wheelSize
            )

        wheel.Position =
            UDim2.new(
                0.5,
                -wheelSize/2,
                0,
                38
            )

        wheel.BackgroundColor3 =
            Color3.fromRGB(255,255,255)

        wheel.BorderSizePixel = 0
        wheel.ClipsDescendants = true
        wheel.ZIndex = 501
        wheel.Parent = popup

        addCorner(wheel,wheelSize)

        --======================================================
        -- CLEAN CIRCULAR WHEEL
        --
        -- Uses ONLY CIRCULAR pieces.
        -- No square rainbow blocks.
        --======================================================

        local centerX = wheelSize/2
        local centerY = wheelSize/2

        local rings = 30
        local dotsPerRing = 96

        for ring = 1,rings do

            local saturation =
                ring/rings

            local radius =
                (wheelSize/2) *
                saturation

            local dotSize =
                math.max(
                    5,
                    (2*math.pi*radius)/
                    dotsPerRing*1.35
                )

            for i = 1,dotsPerRing do

                local hue =
                    (i-1)/dotsPerRing

                local angle =
                    hue*math.pi*2

                local x =
                    centerX +
                    math.cos(angle)*radius

                local y =
                    centerY +
                    math.sin(angle)*radius

                local dot =
                    Instance.new("Frame")

                dot.Size =
                    UDim2.new(
                        0,
                        dotSize,
                        0,
                        dotSize
                    )

                dot.Position =
                    UDim2.new(
                        0,
                        x-dotSize/2,
                        0,
                        y-dotSize/2
                    )

                dot.BackgroundColor3 =
                    Color3.fromHSV(
                        hue,
                        saturation,
                        1
                    )

                dot.BorderSizePixel = 0
                dot.ZIndex = 502
                dot.Parent = wheel

                local dc =
                    Instance.new("UICorner")

                dc.CornerRadius =
                    UDim.new(1,0)

                dc.Parent = dot
            end
        end

        --======================================================
        -- CENTER
        --======================================================

        local center =
            createCircle(
                wheel,
                34,
                Color3.fromRGB(255,255,255),
                505
            )

        center.AnchorPoint =
            Vector2.new(0.5,0.5)

        center.Position =
            UDim2.new(
                0.5,
                0,
                0.5,
                0
            )

        --======================================================
        -- SELECTOR
        --======================================================

        local selector =
            createCircle(
                wheel,
                14,
                Color3.fromRGB(255,255,255),
                510
            )

        selector.AnchorPoint =
            Vector2.new(0.5,0.5)

        selector.Position =
            UDim2.new(
                0.5,
                0,
                0.5,
                0
            )

        local selectorStroke =
            Instance.new("UIStroke")

        selectorStroke.Color =
            Color3.fromRGB(0,0,0)

        selectorStroke.Thickness = 2
        selectorStroke.Parent = selector

        --======================================================
        -- HSV
        --======================================================

        local hue = 0
        local saturation = 1
        local value = 1

        --======================================================
        -- PICK COLOR
        --======================================================

        local function updateColor()

            currentColor =
                Color3.fromHSV(
                    hue,
                    saturation,
                    value
                )

            preview.BackgroundColor3 =
                currentColor

            if callback then
                callback(currentColor)
            end

        end

        --======================================================
        -- WHEEL INPUT
        --======================================================

        local wheelDragging = false

        local function pickWheel(input)

            local absPos =
                wheel.AbsolutePosition

            local absSize =
                wheel.AbsoluteSize

            local cx =
                absPos.X +
                absSize.X/2

            local cy =
                absPos.Y +
                absSize.Y/2

            local dx =
                input.Position.X-cx

            local dy =
                input.Position.Y-cy

            local distance =
                math.sqrt(
                    dx*dx+
                    dy*dy
                )

            local radius =
                absSize.X/2

            distance =
                math.clamp(
                    distance,
                    0,
                    radius
                )

            if distance > 0 then

                local angle =
                    math.atan2(
                        dy,
                        dx
                    )

                hue =
                    angle/
                    (math.pi*2)

                if hue < 0 then
                    hue = hue+1
                end

            end

            saturation =
                math.clamp(
                    distance/radius,
                    0,
                    1
                )

            local cursorX =
                absSize.X/2 +
                math.cos(
                    hue*math.pi*2
                ) *
                radius *
                saturation

            local cursorY =
                absSize.Y/2 +
                math.sin(
                    hue*math.pi*2
                ) *
                radius *
                saturation

            selector.Position =
                UDim2.new(
                    0,
                    cursorX,
                    0,
                    cursorY
                )

            updateColor()

        end

        wheel.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                wheelDragging = true
                pickWheel(input)

            end

        end)

        --======================================================
        -- HUE BAR
        --======================================================

        local hueLabel =
            Instance.new("TextLabel")

        hueLabel.Size =
            UDim2.new(1,-24,0,15)

        hueLabel.Position =
            UDim2.new(0,12,0,234)

        hueLabel.BackgroundTransparency = 1
        hueLabel.Text = "HUE"

        hueLabel.Font =
            CONFIG.FontMedium

        hueLabel.TextSize = 8
        hueLabel.TextColor3 =
            UISettings.TextSecondary

        hueLabel.TextXAlignment =
            Enum.TextXAlignment.Left

        hueLabel.ZIndex = 510
        hueLabel.Parent = popup

        local hueBar =
            Instance.new("Frame")

        hueBar.Size =
            UDim2.new(1,-24,0,10)

        hueBar.Position =
            UDim2.new(0,12,0,251)

        hueBar.BackgroundColor3 =
            Color3.new(1,1,1)

        hueBar.BorderSizePixel = 0
        hueBar.ZIndex = 510
        hueBar.Parent = popup

        addCorner(hueBar,10)

        local hueGradient =
            Instance.new("UIGradient")

        hueGradient.Color =
            ColorSequence.new({

                ColorSequenceKeypoint.new(
                    0,
                    Color3.fromHSV(0,1,1)
                ),

                ColorSequenceKeypoint.new(
                    0.166,
                    Color3.fromHSV(1/6,1,1)
                ),

                ColorSequenceKeypoint.new(
                    0.333,
                    Color3.fromHSV(1/3,1,1)
                ),

                ColorSequenceKeypoint.new(
                    0.5,
                    Color3.fromHSV(0.5,1,1)
                ),

                ColorSequenceKeypoint.new(
                    0.666,
                    Color3.fromHSV(2/3,1,1)
                ),

                ColorSequenceKeypoint.new(
                    0.833,
                    Color3.fromHSV(5/6,1,1)
                ),

                ColorSequenceKeypoint.new(
                    1,
                    Color3.fromHSV(1,1,1)
                )
            })

        hueGradient.Parent = hueBar

        local hueKnob =
            createCircle(
                popup,
                16,
                Color3.new(1,1,1),
                515
            )

        hueKnob.AnchorPoint =
            Vector2.new(0.5,0.5)

        hueKnob.Position =
            UDim2.new(
                hue,
                0,
                0,
                256
            )

        local hueStroke =
            Instance.new("UIStroke")

        hueStroke.Color =
            Color3.new(0,0,0)

        hueStroke.Thickness = 2
        hueStroke.Parent = hueKnob

        --======================================================
        -- VALUE BAR
        --======================================================

        local valueLabel =
            Instance.new("TextLabel")

        valueLabel.Size =
            UDim2.new(1,-24,0,15)

        valueLabel.Position =
            UDim2.new(0,12,0,270)

        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = "BRIGHTNESS"

        valueLabel.Font =
            CONFIG.FontMedium

        valueLabel.TextSize = 8
        valueLabel.TextColor3 =
            UISettings.TextSecondary

        valueLabel.TextXAlignment =
            Enum.TextXAlignment.Left

        valueLabel.ZIndex = 510
        valueLabel.Parent = popup

        local valueBar =
            Instance.new("Frame")

        valueBar.Size =
            UDim2.new(1,-24,0,10)

        valueBar.Position =
            UDim2.new(0,12,0,287)

        valueBar.BackgroundColor3 =
            Color3.new(0,0,0)

        valueBar.BorderSizePixel = 0
        valueBar.ZIndex = 510
        valueBar.Parent = popup

        addCorner(valueBar,10)

        local valueGradient =
            Instance.new("UIGradient")

        valueGradient.Color =
            ColorSequence.new({

                ColorSequenceKeypoint.new(
                    0,
                    Color3.new(0,0,0)
                ),

                ColorSequenceKeypoint.new(
                    1,
                    Color3.fromHSV(
                        hue,
                        saturation,
                        1
                    )
                )
            })

        valueGradient.Parent = valueBar

        local valueKnob =
            createCircle(
                popup,
                16,
                Color3.new(1,1,1),
                515
            )

        valueKnob.AnchorPoint =
            Vector2.new(0.5,0.5)

        valueKnob.Position =
            UDim2.new(
                value,
                0,
                0,
                292
            )

        local valueStroke =
            Instance.new("UIStroke")

        valueStroke.Color =
            Color3.new(0,0,0)

        valueStroke.Thickness = 2
        valueStroke.Parent = valueKnob

        --======================================================
        -- RGB
        --======================================================

        local rgb =
            Instance.new("TextLabel")

        rgb.Size =
            UDim2.new(1,-24,0,18)

        rgb.Position =
            UDim2.new(0,12,0,307)

        rgb.BackgroundTransparency = 1
        rgb.Text = "RGB: 255, 0, 0"

        rgb.Font =
            CONFIG.FontMedium

        rgb.TextSize = 8
        rgb.TextColor3 =
            UISettings.Text

        rgb.TextXAlignment =
            Enum.TextXAlignment.Center

        rgb.ZIndex = 510
        rgb.Parent = popup

        --======================================================
        -- UPDATE INFO
        --======================================================

        local function updateDisplay()

            local c =
                Color3.fromHSV(
                    hue,
                    saturation,
                    value
                )

            currentColor = c

            preview.BackgroundColor3 = c

            hueKnob.Position =
                UDim2.new(
                    hue,
                    0,
                    0,
                    256
                )

            valueKnob.Position =
                UDim2.new(
                    value,
                    0,
                    0,
                    292
                )

            valueGradient.Color =
                ColorSequence.new({

                    ColorSequenceKeypoint.new(
                        0,
                        Color3.new(0,0,0)
                    ),

                    ColorSequenceKeypoint.new(
                        1,
                        Color3.fromHSV(
                            hue,
                            saturation,
                            1
                        )
                    )
                })

            local r =
                math.floor(c.R*255+0.5)

            local g =
                math.floor(c.G*255+0.5)

            local b =
                math.floor(c.B*255+0.5)

            rgb.Text =
                string.format(
                    "RGB: %d, %d, %d",
                    r,g,b
                )

            if callback then
                callback(c)
            end

        end

        --======================================================
        -- HUE INPUT
        --======================================================

        local hueDragging = false

        local function pickHue(input)

            local x =
                math.clamp(
                    input.Position.X -
                    hueBar.AbsolutePosition.X,
                    0,
                    hueBar.AbsoluteSize.X
                )

            hue =
                x /
                hueBar.AbsoluteSize.X

            updateDisplay()

        end

        hueBar.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                hueDragging = true
                pickHue(input)

            end

        end)

        hueKnob.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                hueDragging = true

            end

        end)

        --======================================================
        -- VALUE INPUT
        --======================================================

        local valueDragging = false

        local function pickValue(input)

            local x =
                math.clamp(
                    input.Position.X -
                    valueBar.AbsolutePosition.X,
                    0,
                    valueBar.AbsoluteSize.X
                )

            value =
                x /
                valueBar.AbsoluteSize.X

            updateDisplay()

        end

        valueBar.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                valueDragging = true
                pickValue(input)

            end

        end)

        valueKnob.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or
                input.UserInputType ==
                Enum.UserInputType.Touch then

                valueDragging = true

            end

        end)

        --======================================================
        -- GLOBAL PICKER INPUT
        --======================================================

        local moveConnection

        moveConnection =
            UIS.InputChanged:Connect(function(input)

                if
                    input.UserInputType ==
                    Enum.UserInputType.MouseMovement
                    or
                    input.UserInputType ==
                    Enum.UserInputType.Touch
                then

                    if wheelDragging then
                        pickWheel(input)

                    elseif hueDragging then
                        pickHue(input)

                    elseif valueDragging then
                        pickValue(input)
                    end

                end

            end)

        local endConnection

        endConnection =
            UIS.InputEnded:Connect(function(input)

                if
                    input.UserInputType ==
                    Enum.UserInputType.MouseButton1
                    or
                    input.UserInputType ==
                    Enum.UserInputType.Touch
                then

                    wheelDragging = false
                    hueDragging = false
                    valueDragging = false

                end

            end)

        --======================================================
        -- CLEANUP
        --======================================================

        popup.Destroying:Connect(function()

            if moveConnection then
                moveConnection:Disconnect()
            end

            if endConnection then
                endConnection:Disconnect()
            end

        end)

        --======================================================
        -- OPEN ANIMATION
        --======================================================

        tween(
            popup,
            {
                Size =
                    UDim2.new(
                        0,
                        popupWidth,
                        0,
                        popupHeight
                    )
            },
            0.22
        ):Play()

    end)

    return container
end

--==============================================================
-- MAIN CONTENT
--==============================================================

CreateSection(
    MainScroll,
    "EXAMPLE CONTROLS"
)

CreateToggle(
    MainScroll,
    "Toggle Test 1",
    false,
    function(state)
        print("Toggle 1:",state)
    end
)

CreateToggle(
    MainScroll,
    "Toggle Test 2",
    true,
    function(state)
        print("Toggle 2:",state)
    end
)

CreateSection(
    MainScroll,
    "BUTTONS"
)

CreateButton(
    MainScroll,
    "Button Test",
    function()
        print("Button clicked")
    end
)

CreateSection(
    MainScroll,
    "SLIDERS"
)

CreateSlider(
    MainScroll,
    "Slider Test",
    0,
    100,
    50,
    function(value)
        print("Slider:",value)
    end
)

CreateSection(
    MainScroll,
    "DROPDOWN"
)

CreateDropdown(
    MainScroll,
    "Example Dropdown",
    {
        "Option 1",
        "Option 2",
        "Option 3",
        "Option 4"
    },
    "Option 1",
    function(value)
        print("Selected:",value)
    end
)

CreateSection(
    MainScroll,
    "COLOR PICKER"
)

CreateColorPicker(
    MainScroll,
    "Color 1",
    function(color)
        print("Color 1:",color)
    end
)

CreateColorPicker(
    MainScroll,
    "Color 2",
    function(color)
        print("Color 2:",color)
    end
)

--==============================================================
-- SETTINGS
--==============================================================

CreateSection(
    SettingsScroll,
    "UI APPEARANCE"
)

CreateColorPicker(
    SettingsScroll,
    "Accent Color",
    function(color)

        UISettings.Accent = color
        CONFIG.Accent = color

        HeaderTitle.TextColor3 = color

        for _,button in pairs(TabButtons) do

            if button.Text == CurrentTab then
                button.BackgroundColor3 = color
            end

        end

    end
)

CreateColorPicker(
    SettingsScroll,
    "Background Color",
    function(color)

        UISettings.Background = color

        Main.BackgroundColor3 = color
        Content.BackgroundColor3 = color

    end
)

CreateColorPicker(
    SettingsScroll,
    "Surface Color",
    function(color)

        UISettings.Surface = color

        Header.BackgroundColor3 = color
        TabBar.BackgroundColor3 = color

    end
)

CreateColorPicker(
    SettingsScroll,
    "Text Color",
    function(color)

        UISettings.Text = color
        HeaderTitle.TextColor3 = UISettings.Accent

    end
)

CreateSection(
    SettingsScroll,
    "UI OPTIONS"
)

CreateToggle(
    SettingsScroll,
    "Smooth Animations",
    true,
    function(state)

        UISettings.SmoothAnimations = state

    end
)

CreateToggle(
    SettingsScroll,
    "Rounded UI",
    true,
    function(state)

        UISettings.Rounded = state

        updateCorner(Main,10)
        updateCorner(Header,10)
        updateCorner(TabBar,9)
        updateCorner(Content,9)

        for _,button in pairs(TabButtons) do
            updateCorner(button,7)
        end

    end
)

CreateToggle(
    SettingsScroll,
    "Show UI Borders",
    true,
    function(state)

        UISettings.ShowBorders = state

        MainStroke.Transparency =
            state and 0 or 1

    end
)

CreateSlider(
    SettingsScroll,
    "UI Transparency",
    0,
    80,
    0,
    function(value)

        UISettings.Transparency =
            value/100

        Main.BackgroundTransparency =
            UISettings.Transparency

        Header.BackgroundTransparency =
            UISettings.Transparency

        TabBar.BackgroundTransparency =
            UISettings.Transparency

        Content.BackgroundTransparency =
            UISettings.Transparency

    end
)

CreateSlider(
    SettingsScroll,
    "Animation Speed",
    5,
    100,
    20,
    function(value)

        UISettings.AnimationSpeed =
            value/100

    end
)

CreateDropdown(
    SettingsScroll,
    "UI Style",
    {
        "Rounded",
        "Sharp"
    },
    "Rounded",
    function(value)

        UISettings.Rounded =
            value == "Rounded"

        updateCorner(Main,10)
        updateCorner(Header,10)
        updateCorner(TabBar,9)
        updateCorner(Content,9)

    end
)

CreateSection(
    SettingsScroll,
    "WINDOW"
)

CreateButton(
    SettingsScroll,
    "Center UI",
    function()

        Main.Position =
            UDim2.new(
                0.5,
                -Main.AbsoluteSize.X/2,
                0.5,
                -Main.AbsoluteSize.Y/2
            )

    end
)

CreateButton(
    SettingsScroll,
    "Reset UI Settings",
    function()

        UISettings.Accent =
            Color3.fromRGB(0,150,255)

        UISettings.Background =
            Color3.fromRGB(7,7,9)

        UISettings.Surface =
            Color3.fromRGB(15,15,18)

        UISettings.Text =
            Color3.fromRGB(235,235,240)

        UISettings.Transparency = 0

        UISettings.Rounded = true
        UISettings.ShowBorders = true

        UISettings.AnimationSpeed = 0.20

        Main.BackgroundColor3 =
            UISettings.Background

        Header.BackgroundColor3 =
            UISettings.Surface

        TabBar.BackgroundColor3 =
            UISettings.Surface

        Content.BackgroundColor3 =
            UISettings.Background

        HeaderTitle.TextColor3 =
            UISettings.Accent

    end
)

--==============================================================
-- OPEN ANIMATION
--==============================================================

local function openUI()

    Main.Visible = true

    local originalSize =
        UDim2.new(
            0,
            uiWidth,
            0,
            uiHeight
        )

    Main.Size =
        UDim2.new(
            0,
            uiWidth*0.88,
            0,
            uiHeight*0.88
        )

    Main.BackgroundTransparency = 1

    tween(
        Main,
        {
            Size = originalSize,
            BackgroundTransparency =
                UISettings.Transparency
        },
        0.25
    ):Play()

end

--==============================================================
-- MOBILE TOGGLE
--==============================================================

if isMobile then

    local toggle =
        Instance.new("TextButton")

    toggle.Size =
        UDim2.new(0,92,0,32)

    toggle.Position =
        UDim2.new(
            0,
            10,
            0,
            150
        )

    toggle.BackgroundColor3 =
        UISettings.Accent

    toggle.BorderSizePixel = 0
    toggle.Text = "OISHI"
    toggle.Font = CONFIG.Font
    toggle.TextSize = 10
    toggle.TextColor3 =
        Color3.new(1,1,1)

    toggle.AutoButtonColor = false
    toggle.ZIndex = 999999
    toggle.Parent = ScreenGui

    addCorner(toggle,7)

    toggle.MouseButton1Click:Connect(function()

        if Main.Visible then

            Main.Visible = false

        else

            openUI()

        end

    end)

    --==========================================================
    -- LOCK
    --==========================================================

    local unlocked = false

    local lock =
        Instance.new("TextButton")

    lock.Size =
        UDim2.new(0,92,0,32)

    lock.Position =
        UDim2.new(
            0,
            10,
            0,
            190
        )

    lock.BackgroundColor3 =
        UISettings.Surface

    lock.BorderSizePixel = 0
    lock.Text = "Unlock"
    lock.Font = CONFIG.Font
    lock.TextSize = 9
    lock.TextColor3 =
        UISettings.Text

    lock.AutoButtonColor = false
    lock.ZIndex = 999999
    lock.Parent = ScreenGui

    addCorner(lock,7)

    lock.MouseButton1Click:Connect(function()

        unlocked = not unlocked

        lock.Text =
            unlocked
            and "Lock"
            or "Unlock"

        lock.BackgroundColor3 =
            unlocked
            and UISettings.Accent
            or UISettings.Surface

    end)

    --==========================================================
    -- DRAG MOBILE BUTTONS
    --==========================================================

    local function draggable(button)

        local dragging = false
        local start
        local startPos
        local moved = false

        button.InputBegan:Connect(function(input)

            if
                input.UserInputType ==
                Enum.UserInputType.Touch
                or
                input.UserInputType ==
                Enum.UserInputType.MouseButton1
            then

                dragging = true
                moved = false

                start = input.Position
                startPos = button.Position

            end

        end)

        UIS.InputChanged:Connect(function(input)

            if
                dragging
                and
                unlocked
                and
                (
                    input.UserInputType ==
                    Enum.UserInputType.Touch
                    or
                    input.UserInputType ==
                    Enum.UserInputType.MouseMovement
                )
            then

                local delta =
                    input.Position-start

                if delta.Magnitude > 3 then
                    moved = true
                end

                if moved then

                    button.Position =
                        UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset+
                                delta.X,

                            startPos.Y.Scale,
                            startPos.Y.Offset+
                                delta.Y
                        )

                end

            end

        end)

        UIS.InputEnded:Connect(function(input)

            if
                input.UserInputType ==
                Enum.UserInputType.Touch
                or
                input.UserInputType ==
                Enum.UserInputType.MouseButton1
            then

                dragging = false

            end

        end)

    end

    draggable(toggle)
    draggable(lock)

else

    --==========================================================
    -- PC RIGHT SHIFT
    --==========================================================

    UIS.InputBegan:Connect(function(input,gp)

        if gp then
            return
        end

        if input.KeyCode ==
            Enum.KeyCode.RightShift then

            if Main.Visible then
                Main.Visible = false
            else
                openUI()
            end

        end

    end)

end

--==============================================================
-- MAIN WINDOW DRAG
--
-- IMPORTANT:
-- Slider/color-picker input is NOT connected to Main.
-- This prevents sliders from dragging the UI.
--==============================================================

local draggingWindow = false
local dragStart
local windowStart

Header.InputBegan:Connect(function(input)

    if
        input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
        Enum.UserInputType.Touch
    then

        draggingWindow = true
        dragStart = input.Position
        windowStart = Main.Position

    end

end)

UIS.InputChanged:Connect(function(input)

    if not draggingWindow then
        return
    end

    if
        input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or
        input.UserInputType ==
        Enum.UserInputType.Touch
    then

        local delta =
            input.Position -
            dragStart

        Main.Position =
            UDim2.new(
                windowStart.X.Scale,
                windowStart.X.Offset+
                    delta.X,

                windowStart.Y.Scale,
                windowStart.Y.Offset+
                    delta.Y
            )

    end

end)

UIS.InputEnded:Connect(function(input)

    if
        input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        input.UserInputType ==
        Enum.UserInputType.Touch
    then

        draggingWindow = false

    end

end)

--==============================================================
-- INITIAL OPEN
--==============================================================

if isPC then
    openUI()
end

--==============================================================
-- DONE
--==============================================================

print(
    "[Oishi Hub] Clean Circular Color Picker UI Loaded"
)
