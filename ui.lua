-- Oishi Hub UI Library Example - With Rainbow Color Wheel, Toggle & Lock
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local isPC = not UIS.TouchEnabled

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
    Font = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    HoverAccent = Color3.fromRGB(30, 180, 255),
    HoverSurface = Color3.fromRGB(40, 40, 40),
    ClickAccent = Color3.fromRGB(0, 100, 200),
    ClickSurface = Color3.fromRGB(35, 35, 35),
    DropdownHover = Color3.fromRGB(40, 40, 40),
    DropdownSelected = Color3.fromRGB(0, 150, 255),
}

-- Check for existing UI
if PlayerGui:FindFirstChild("OishiHubExample") then
    PlayerGui.OishiHubExample:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OishiHubExample"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local uiWidth = isPC and 600 or math.min(650, Camera.ViewportSize.X - 20)
local uiHeight = isPC and 450 or math.min(400, Camera.ViewportSize.Y * 0.5)

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, uiWidth, 0, uiHeight)
Main.Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = isPC
Main.ZIndex = 10
Main.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.Border
MainStroke.Thickness = 2
MainStroke.Transparency = 0
MainStroke.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = CONFIG.Surface
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = Main

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 300, 0, 20)
HeaderTitle.Position = UDim2.new(0, 10, 0, 5)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "OISHI HUB UI LIBRARY"
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

CloseBtn.MouseButton1Click:Connect(function()
    if isPC then
        ScreenGui:Destroy()
    else
        Main.Visible = false
    end
end)

--========================
-- TWO SIDED LAYOUT
--========================

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

-- Tab Frame
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 26)
TabFrame.BackgroundColor3 = CONFIG.Surface
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex = 11
TabFrame.Parent = LeftSide

local Tabs = {
    {name = "Tab 1"},
    {name = "Tab 2"},
    {name = "Tab 3"},
}

local currentTab = "Tab 1"
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

for i, tab in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/3, -1, 0, 22)
    btn.Position = UDim2.new((i-1) * (1/3), 0.5, 0, 2)
    btn.BackgroundColor3 = tab.name == currentTab and CONFIG.TabActive or CONFIG.TabInactive
    btn.BackgroundTransparency = tab.name == currentTab and 0.3 or 0.5
    btn.BorderSizePixel = 0
    btn.Text = tab.name
    btn.Font = CONFIG.Font
    btn.TextSize = 8
    btn.TextColor3 = tab.name == currentTab and Color3.new(1, 1, 1) or CONFIG.Text
    btn.ZIndex = 12
    btn.AutoButtonColor = false
    btn.Parent = TabFrame
    
    TabButtons[tab.name] = btn
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Position = UDim2.new(0, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = tab.name == currentTab
    content.ZIndex = 11
    content.Parent = ContentContainer
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = CONFIG.Accent
    scrollFrame.ScrollBarImageTransparency = 0.3
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
    scrollFrame.ZIndex = 12
    scrollFrame.Parent = content
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = scrollFrame
    
    TabContents[tab.name] = {
        frame = content,
        scroll = scrollFrame,
        layout = layout
    }
    
    btn.MouseButton1Click:Connect(function()
        if currentTab == tab.name then return end
        local oldTab = currentTab
        currentTab = tab.name
        
        for name, b in pairs(TabButtons) do
            if name == tab.name then
                TweenService:Create(b, TweenInfo.new(0.2), {
                    BackgroundColor3 = CONFIG.TabActive,
                    BackgroundTransparency = 0.3,
                    TextColor3 = Color3.new(1, 1, 1)
                }):Play()
            else
                TweenService:Create(b, TweenInfo.new(0.2), {
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
        end
    end)
end

--========================
-- UI COMPONENT FUNCTIONS
--========================

local function CreateSectionLabel(tabName, text)
    local content = TabContents[tabName]
    if not content then return end
    
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

local function CreateToggle(tabName, name, default, callback)
    local content = TabContents[tabName]
    if not content then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.65, 0, 0, 14)
    nameLabel.Position = UDim2.new(0, 8, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = CONFIG.FontMedium
    nameLabel.TextSize = 9
    nameLabel.TextColor3 = CONFIG.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 32, 0, 18)
    toggleBtn.Position = UDim2.new(1, -40, 0, 8)
    toggleBtn.BackgroundColor3 = default and CONFIG.ToggleOn or CONFIG.ToggleOff
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.ZIndex = 13
    toggleBtn.Parent = container
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = default and UDim2.new(0, 17, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = toggleBtn
    
    local state = default or false
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.ToggleOn}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 17, 0, 3)}):Play()
        else
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.ToggleOff}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0, 3)}):Play()
        end
        if callback then callback(state) end
    end)
    
    return container
end

local function CreateButton(tabName, name, callback)
    local content = TabContents[tabName]
    if not content then return end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = CONFIG.Surface
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = CONFIG.Font
    btn.TextSize = 9
    btn.TextColor3 = CONFIG.Text
    btn.ZIndex = 12
    btn.AutoButtonColor = false
    btn.Parent = content.scroll
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return btn
end

local function CreateSlider(tabName, name, min, max, default, callback)
    local content = TabContents[tabName]
    if not content then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.55, 0, 0, 14)
    nameLabel.Position = UDim2.new(0, 8, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = CONFIG.FontMedium
    nameLabel.TextSize = 8
    nameLabel.TextColor3 = CONFIG.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = container
    
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
    sliderBg.Size = UDim2.new(1, -16, 0, 4)
    sliderBg.Position = UDim2.new(0, 8, 0, 25)
    sliderBg.BackgroundColor3 = CONFIG.SurfaceLight
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = 13
    sliderBg.Parent = container
    
    local sliderFill = Instance.new("Frame")
    local percentage = (default - min) / (max - min)
    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    sliderFill.BackgroundColor3 = CONFIG.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 14
    sliderFill.Parent = sliderBg
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * relativeX)
        valueLabel.Text = tostring(value)
        TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(relativeX, 0, 1, 0)}):Play()
        if callback then callback(value) end
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
            local moveConn, endConn
            moveConn = UIS.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    updateSlider(moveInput)
                end
            end)
            endConn = UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    if moveConn then moveConn:Disconnect() end
                    if endConn then endConn:Disconnect() end
                end
            end)
        end
    end)
    
    return container
end

--========================
-- RAINBOW COLOR WHEEL PICKER
--========================

local function CreateRainbowColorPicker(tabName, name, callback)
    local content = TabContents[tabName]
    if not content then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 34)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.5, 0, 0, 24)
    nameLabel.Position = UDim2.new(0, 8, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = CONFIG.FontMedium
    nameLabel.TextSize = 9
    nameLabel.TextColor3 = CONFIG.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = container
    
    local previewBtn = Instance.new("TextButton")
    previewBtn.Size = UDim2.new(0, 30, 0, 20)
    previewBtn.Position = UDim2.new(1, -38, 0, 7)
    previewBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    previewBtn.BorderSizePixel = 0
    previewBtn.Text = ""
    previewBtn.AutoButtonColor = false
    previewBtn.ZIndex = 13
    previewBtn.Parent = container
    
    local currentColor = Color3.fromRGB(255, 0, 0)
    
    previewBtn.MouseButton1Click:Connect(function()
        local PickerPopup = Instance.new("Frame")
        PickerPopup.Size = UDim2.new(0, 170, 0, 170)
        PickerPopup.Position = UDim2.new(0, previewBtn.AbsolutePosition.X - 140, 0, previewBtn.AbsolutePosition.Y - 170)
        PickerPopup.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        PickerPopup.BorderSizePixel = 0
        PickerPopup.ZIndex = 999
        PickerPopup.Parent = ScreenGui
        
        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = UDim.new(0, 6)
        popupCorner.Parent = PickerPopup
        
        local popupStroke = Instance.new("UIStroke")
        popupStroke.Color = CONFIG.Accent
        popupStroke.Thickness = 1
        popupStroke.Parent = PickerPopup
        
        -- Rainbow Color Wheel (static circle with gradient)
        local colorWheel = Instance.new("ImageLabel")
        colorWheel.Size = UDim2.new(0, 120, 0, 120)
        colorWheel.Position = UDim2.new(0, 25, 0, 15)
        colorWheel.BackgroundTransparency = 1
        colorWheel.Image = "rbxassetid://4155801252" -- Rainbow color wheel image
        colorWheel.ZIndex = 1000
        colorWheel.Parent = PickerPopup
        
        local wheelCorner = Instance.new("UICorner")
        wheelCorner.CornerRadius = UDim.new(1, 0)
        wheelCorner.Parent = colorWheel
        
        -- Color selection cursor
        local cursor = Instance.new("Frame")
        cursor.Size = UDim2.new(0, 8, 0, 8)
        cursor.Position = UDim2.new(0.5, -4, 0.5, -4)
        cursor.BackgroundColor3 = Color3.new(1, 1, 1)
        cursor.BorderSizePixel = 0
        cursor.ZIndex = 1001
        cursor.Parent = colorWheel
        
        local cursorCorner = Instance.new("UICorner")
        cursorCorner.CornerRadius = UDim.new(1, 0)
        cursorCorner.Parent = cursor
        
        local cursorStroke = Instance.new("UIStroke")
        cursorStroke.Color = Color3.new(0, 0, 0)
        cursorStroke.Thickness = 1
        cursorStroke.Parent = cursor
        
        -- Click on wheel to pick color
        colorWheel.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local function updateColor(position)
                    local wheelPos = colorWheel.AbsolutePosition
                    local wheelSize = colorWheel.AbsoluteSize
                    local centerX = wheelPos.X + wheelSize.X / 2
                    local centerY = wheelPos.Y + wheelSize.Y / 2
                    
                    local dx = position.X - centerX
                    local dy = position.Y - centerY
                    local distance = math.sqrt(dx * dx + dy * dy)
                    local radius = wheelSize.X / 2
                    
                    if distance <= radius then
                        -- Calculate angle for hue
                        local angle = math.atan2(dy, dx)
                        local hue = (angle + math.pi) / (2 * math.pi)
                        
                        -- Calculate saturation based on distance from center
                        local saturation = math.clamp(distance / radius, 0, 1)
                        
                        -- Set color
                        currentColor = Color3.fromHSV(hue, saturation, 1)
                        previewBtn.BackgroundColor3 = currentColor
                        
                        -- Update cursor position
                        local relX = math.clamp((position.X - wheelPos.X) / wheelSize.X, 0, 1)
                        local relY = math.clamp((position.Y - wheelPos.Y) / wheelSize.Y, 0, 1)
                        cursor.Position = UDim2.new(relX, -4, relY, -4)
                        
                        if callback then callback(currentColor) end
                    end
                end
                
                updateColor(input.Position)
                
                local moveConn, endConn
                moveConn = UIS.InputChanged:Connect(function(moveInput)
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                        updateColor(moveInput.Position)
                    end
                end)
                endConn = UIS.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        if moveConn then moveConn:Disconnect() end
                        if endConn then endConn:Disconnect() end
                    end
                end)
            end
        end)
        
        -- RGB Display
        local rgbLabel = Instance.new("TextLabel")
        rgbLabel.Size = UDim2.new(1, -20, 0, 20)
        rgbLabel.Position = UDim2.new(0, 10, 0, 140)
        rgbLabel.BackgroundTransparency = 1
        rgbLabel.Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
        rgbLabel.Font = CONFIG.FontMedium
        rgbLabel.TextSize = 8
        rgbLabel.TextColor3 = CONFIG.Text
        rgbLabel.TextXAlignment = Enum.TextXAlignment.Center
        rgbLabel.ZIndex = 1000
        rgbLabel.Parent = PickerPopup
        
        -- Update RGB label when color changes
        local function updateRGBLabel()
            rgbLabel.Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
        end
        
        -- Override callback to update label
        local originalCallback = callback
        callback = function(color)
            updateRGBLabel()
            if originalCallback then originalCallback(color) end
        end
        
        -- Close button
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 18, 0, 18)
        closeBtn.Position = UDim2.new(1, -22, 0, 3)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "×"
        closeBtn.Font = CONFIG.Font
        closeBtn.TextSize = 10
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.ZIndex = 1000
        closeBtn.AutoButtonColor = false
        closeBtn.Parent = PickerPopup
        
        closeBtn.MouseButton1Click:Connect(function()
            PickerPopup:Destroy()
        end)
        
        task.delay(10, function()
            if PickerPopup.Parent then
                PickerPopup:Destroy()
            end
        end)
    end)
    
    return container
end

--========================
-- EXAMPLE CONTENT
--========================

CreateSectionLabel("Tab 1", "TOGGLES")
CreateToggle("Tab 1", "Toggle Test 1", false, function(state) print("Toggle 1:", state) end)
CreateToggle("Tab 1", "Toggle Test 2", true, function(state) print("Toggle 2:", state) end)

CreateSectionLabel("Tab 1", "BUTTONS")
CreateButton("Tab 1", "Button Test 1", function() print("Button clicked!") end)

CreateSectionLabel("Tab 2", "SLIDERS")
CreateSlider("Tab 2", "Slider Test 1", 0, 100, 50, function(value) print("Slider:", value) end)

CreateSectionLabel("Tab 3", "COLOR PICKERS")
CreateRainbowColorPicker("Tab 3", "Color 1", function(color) print("Color 1:", color) end)
CreateRainbowColorPicker("Tab 3", "Color 2", function(color) print("Color 2:", color) end)

-- Update canvas sizes
task.wait(0.1)
for _, content in pairs(TabContents) do
    content.scroll.CanvasSize = UDim2.new(0, 0, 0, content.layout.AbsoluteContentSize.Y + 20)
end

--========================
-- DRAG SYSTEM
--========================
local dragging = false
local dragStart, startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--========================
-- MOBILE TOGGLE & LOCK BUTTONS (Positioned lower)
--========================
if isMobile then
    local isUnlocked = false
    
    -- Toggle UI Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 88, 0, 30)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 150) -- Moved down
    ToggleBtn.BackgroundColor3 = CONFIG.Accent
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = "Toggle UI"
    ToggleBtn.Font = CONFIG.Font
    ToggleBtn.TextSize = 10
    ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
    ToggleBtn.ZIndex = 999999
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = ScreenGui
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    
    -- Lock/Unlock UI Button
    local LockBtn = Instance.new("TextButton")
    LockBtn.Size = UDim2.new(0, 88, 0, 30)
    LockBtn.Position = UDim2.new(0, 10, 0, 190) -- Moved down
    LockBtn.BackgroundColor3 = CONFIG.Surface
    LockBtn.BorderSizePixel = 0
    LockBtn.Text = "Unlock UI"
    LockBtn.Font = CONFIG.Font
    LockBtn.TextSize = 10
    LockBtn.TextColor3 = Color3.new(1, 1, 1)
    LockBtn.ZIndex = 999999
    LockBtn.AutoButtonColor = false
    LockBtn.Parent = ScreenGui
    
    LockBtn.MouseButton1Click:Connect(function()
        isUnlocked = not isUnlocked
        LockBtn.Text = isUnlocked and "Lock UI" or "Unlock UI"
        LockBtn.BackgroundColor3 = isUnlocked and CONFIG.Accent or CONFIG.Surface
    end)
    
    -- Make buttons draggable when unlocked
    local function makeDraggable(btn)
        local btnDragging = false
        local btnDragStart = nil
        local btnStartPos = nil
        local hasMoved = false
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                btnDragging = true
                hasMoved = false
                btnDragStart = input.Position
                btnStartPos = btn.Position
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - btnDragStart
                if delta.Magnitude > 3 then
                    hasMoved = true
                end
                if isUnlocked and hasMoved then
                    btn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
                end
            end
        end)
        
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                btnDragging = false
            end
        end)
    end
    
    makeDraggable(ToggleBtn)
    makeDraggable(LockBtn)
end

-- PC Keybind
if isPC then
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            Main.Visible = not Main.Visible
        end
    end)
end

print("[Oishi Hub UI Library] Loaded with Rainbow Color Wheel!")
