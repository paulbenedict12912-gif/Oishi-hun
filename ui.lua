-- Oishi Hub UI Library Example
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
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

local uiWidth = isPC and 450 or math.min(550, Camera.ViewportSize.X - 20)
local uiHeight = isPC and 450 or math.min(400, Camera.ViewportSize.Y * 0.5)

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, uiWidth, 0, uiHeight)
Main.Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.Active = true
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
HeaderTitle.Size = UDim2.new(0, 200, 0, 20)
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

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = CONFIG.Border
closeStroke.Thickness = 1
closeStroke.Transparency = 0.3
closeStroke.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tab Frame
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 26)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = CONFIG.Surface
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex = 11
TabFrame.Parent = Main

-- Tabs
local Tabs = {
    {name = "Tab 1"},
    {name = "Tab 2"},
    {name = "Tab 3"},
}

local currentTab = "Tab 1"
local TabButtons = {}
local TabContents = {}

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -56)
ContentContainer.Position = UDim2.new(0, 0, 0, 56)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 11
ContentContainer.Parent = Main

-- Create Tabs
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
    
    -- Content Frame
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Position = UDim2.new(0, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = tab.name == currentTab
    content.ZIndex = 11
    content.Parent = ContentContainer
    
    -- Scrolling Frame
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
    
    -- Layout
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
    
    -- Tab Button Click
    btn.MouseButton1Click:Connect(function()
        if currentTab == tab.name then return end
        local oldTab = currentTab
        currentTab = tab.name
        
        -- Update tab buttons
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
        
        -- Switch content
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

-- Section Label
local function CreateSectionLabel(tabName, text)
    local content = TabContents[tabName]
    if not content then return end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = CONFIG.Font
    label.TextSize = 10
    label.TextColor3 = CONFIG.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 13
    label.Parent = content.scroll
    
    return label
end

-- Toggle Button
local function CreateToggle(tabName, name, default, callback)
    local content = TabContents[tabName]
    if not content then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = CONFIG.Border
    containerStroke.Thickness = 1
    containerStroke.Transparency = 0.5
    containerStroke.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.7, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 10, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = CONFIG.FontMedium
    nameLabel.TextSize = 10
    nameLabel.TextColor3 = CONFIG.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 36, 0, 20)
    toggleBtn.Position = UDim2.new(1, -46, 0, 8)
    toggleBtn.BackgroundColor3 = default and CONFIG.ToggleOn or CONFIG.ToggleOff
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.ZIndex = 13
    toggleBtn.Parent = container
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = CONFIG.Border
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = default and 0.3 or 0.8
    toggleStroke.Parent = toggleBtn
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(0, 19, 0, 3) or UDim2.new(0, 3, 0, 3)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = toggleBtn
    
    local state = default or false
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        
        TweenService:Create(toggleStroke, TweenInfo.new(0.2), {
            Transparency = state and 0.3 or 0.8
        }):Play()
        
        if state then
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.ToggleOn}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 19, 0, 3)}):Play()
        else
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.ToggleOff}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0, 3)}):Play()
        end
        
        if callback then callback(state) end
    end)
    
    return container
end

-- Button
local function CreateButton(tabName, name, callback)
    local content = TabContents[tabName]
    if not content then return end
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = CONFIG.Surface
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = CONFIG.Font
    btn.TextSize = 10
    btn.TextColor3 = CONFIG.Text
    btn.ZIndex = 12
    btn.AutoButtonColor = false
    btn.Parent = content.scroll
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = CONFIG.Border
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.5
    btnStroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.HoverSurface}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Surface}):Play()
    end)
    
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundColor3 = CONFIG.ClickSurface}):Play()
    end)
    
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = CONFIG.HoverSurface}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return btn
end

-- Slider
local function CreateSlider(tabName, name, min, max, default, callback)
    local content = TabContents[tabName]
    if not content then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = CONFIG.Border
    containerStroke.Thickness = 1
    containerStroke.Transparency = 0.5
    containerStroke.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.6, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 10, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = CONFIG.FontMedium
    nameLabel.TextSize = 9
    nameLabel.TextColor3 = CONFIG.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 16)
    valueLabel.Position = UDim2.new(0.7, -10, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.Font = CONFIG.FontMedium
    valueLabel.TextSize = 9
    valueLabel.TextColor3 = CONFIG.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 13
    valueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 4)
    sliderBg.Position = UDim2.new(0, 10, 0, 28)
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
    
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Size = UDim2.new(0, 12, 0, 12)
    sliderHandle.Position = UDim2.new(1, -6, 0.5, -6)
    sliderHandle.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.ZIndex = 15
    sliderHandle.Parent = sliderFill
    
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

-- Dropdown
local function CreateDropdown(tabName, name, options, default, callback)
    local content = TabContents[tabName]
    if not content then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundColor3 = CONFIG.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = CONFIG.Border
    containerStroke.Thickness = 1
    containerStroke.Transparency = 0.5
    containerStroke.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 16)
    nameLabel.Position = UDim2.new(0, 10, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = CONFIG.FontMedium
    nameLabel.TextSize = 9
    nameLabel.TextColor3 = CONFIG.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = container
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, -20, 0, 24)
    dropdownBtn.Position = UDim2.new(0, 10, 0, 20)
    dropdownBtn.BackgroundColor3 = CONFIG.SurfaceLight
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = default or options[1]
    dropdownBtn.Font = CONFIG.FontMedium
    dropdownBtn.TextSize = 9
    dropdownBtn.TextColor3 = CONFIG.Text
    dropdownBtn.ZIndex = 13
    dropdownBtn.AutoButtonColor = false
    dropdownBtn.Parent = container
    
    local dropdownStroke = Instance.new("UIStroke")
    dropdownStroke.Color = CONFIG.Border
    dropdownStroke.Thickness = 1
    dropdownStroke.Transparency = 0.3
    dropdownStroke.Parent = dropdownBtn
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -20, 0, 4)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = CONFIG.Font
    arrow.TextSize = 8
    arrow.TextColor3 = CONFIG.Accent
    arrow.ZIndex = 14
    arrow.Parent = dropdownBtn
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, -20, 0, 0)
    dropdownList.Position = UDim2.new(0, 10, 0, 46)
    dropdownList.BackgroundColor3 = CONFIG.Surface
    dropdownList.BorderSizePixel = 0
    dropdownList.ClipsDescendants = true
    dropdownList.Visible = false
    dropdownList.ZIndex = 100
    dropdownList.Parent = container
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = CONFIG.Accent
    listStroke.Thickness = 1
    listStroke.Transparency = 0.3
    listStroke.Parent = dropdownList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList
    
    local isOpen = false
    
    local function closeDropdown()
        isOpen = false
        TweenService:Create(dropdownList, TweenInfo.new(0.15), {Size = UDim2.new(1, -20, 0, 0)}):Play()
        task.wait(0.15)
        dropdownList.Visible = false
        container.Size = UDim2.new(1, 0, 0, 48)
        TweenService:Create(arrow, TweenInfo.new(0.15), {Rotation = 0}):Play()
    end
    
    local function openDropdown()
        isOpen = true
        dropdownList.Visible = true
        local listHeight = math.min(#options * 26, 130)
        TweenService:Create(dropdownList, TweenInfo.new(0.15), {Size = UDim2.new(1, -20, 0, listHeight)}):Play()
        container.Size = UDim2.new(1, 0, 0, 48 + listHeight + 4)
        TweenService:Create(arrow, TweenInfo.new(0.15), {Rotation = 180}):Play()
    end
    
    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, 0, 0, 24)
        optionBtn.BackgroundColor3 = option == default and CONFIG.DropdownSelected or CONFIG.SurfaceLight
        optionBtn.BackgroundTransparency = option == default and 0.3 or 0.1
        optionBtn.BorderSizePixel = 0
        optionBtn.Text = option
        optionBtn.Font = CONFIG.FontMedium
        optionBtn.TextSize = 9
        optionBtn.TextColor3 = option == default and Color3.new(1, 1, 1) or CONFIG.Text
        optionBtn.ZIndex = 102
        optionBtn.AutoButtonColor = false
        optionBtn.Parent = dropdownList
        
        optionBtn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = option
            
            for _, btn in ipairs(dropdownList:GetChildren()) do
                if btn:IsA("TextButton") then
                    if btn.Text == option then
                        btn.BackgroundColor3 = CONFIG.DropdownSelected
                        btn.BackgroundTransparency = 0.3
                        btn.TextColor3 = Color3.new(1, 1, 1)
                    else
                        btn.BackgroundColor3 = CONFIG.SurfaceLight
                        btn.BackgroundTransparency = 0.1
                        btn.TextColor3 = CONFIG.Text
                    end
                end
            end
            
            closeDropdown()
            if callback then callback(option) end
        end)
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
        else
            openDropdown()
        end
    end)
    
    return container
end

--========================
-- EXAMPLE CONTENT
--========================

-- TAB 1
CreateSectionLabel("Tab 1", "TOGGLES")
CreateToggle("Tab 1", "Toggle Test 1", false, function(state)
    print("Toggle 1: " .. tostring(state))
end)
CreateToggle("Tab 1", "Toggle Test 2", true, function(state)
    print("Toggle 2: " .. tostring(state))
end)
CreateToggle("Tab 1", "Toggle Test 3", false, function(state)
    print("Toggle 3: " .. tostring(state))
end)

CreateSectionLabel("Tab 1", "BUTTONS")
CreateButton("Tab 1", "Button Test 1", function()
    print("Button 1 clicked!")
end)
CreateButton("Tab 1", "Button Test 2", function()
    print("Button 2 clicked!")
end)

-- TAB 2
CreateSectionLabel("Tab 2", "SLIDERS")
CreateSlider("Tab 2", "Slider Test 1", 0, 100, 50, function(value)
    print("Slider 1: " .. value)
end)
CreateSlider("Tab 2", "Slider Test 2", 1, 10, 5, function(value)
    print("Slider 2: " .. value)
end)
CreateSlider("Tab 2", "Slider Test 3", -50, 50, 0, function(value)
    print("Slider 3: " .. value)
end)

CreateSectionLabel("Tab 2", "DROPDOWNS")
CreateDropdown("Tab 2", "Dropdown Test 1", {"Option 1", "Option 2", "Option 3", "Option 4"}, "Option 1", function(option)
    print("Dropdown 1: " .. option)
end)
CreateDropdown("Tab 2", "Dropdown Test 2", {"Low", "Medium", "High", "Ultra"}, "Medium", function(option)
    print("Dropdown 2: " .. option)
end)

-- TAB 3
CreateSectionLabel("Tab 3", "MIXED COMPONENTS")
CreateToggle("Tab 3", "Toggle Test 4", false, function(state)
    print("Toggle 4: " .. tostring(state))
end)
CreateSlider("Tab 3", "Slider Test 4", 1, 20, 10, function(value)
    print("Slider 4: " .. value)
end)
CreateButton("Tab 3", "Button Test 3", function()
    print("Button 3 clicked!")
end)
CreateDropdown("Tab 3", "Dropdown Test 3", {"Choice A", "Choice B", "Choice C"}, "Choice A", function(option)
    print("Dropdown 3: " .. option)
end)
CreateToggle("Tab 3", "Toggle Test 5", true, function(state)
    print("Toggle 5: " .. tostring(state))
end)
CreateButton("Tab 3", "Button Test 4", function()
    print("Button 4 clicked!")
end)

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
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--========================
-- TOGGLE BUTTON (MOBILE ONLY)
--========================
if isMobile then
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
    ToggleBtn.Position = UDim2.new(0, 6, 0.5, -12)
    ToggleBtn.BackgroundColor3 = CONFIG.Surface
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = ">"
    ToggleBtn.Font = CONFIG.Font
    ToggleBtn.TextSize = 12
    ToggleBtn.TextColor3 = CONFIG.Accent
    ToggleBtn.ZIndex = 999999
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = ScreenGui
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = CONFIG.Border
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0
    toggleStroke.Parent = ToggleBtn
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
        ToggleBtn.Text = Main.Visible and "X" or ">"
    end)
end

print("[Oishi Hub UI Library] Loaded!")
