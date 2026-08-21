-- Oishi Hub UI Library - Linoria Style
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Library = {
    Options = {},
    Toggles = {},
    ThemeObjects = {},
    Keybinds = {},
    Connections = {},
    Fonts = {},
    Flags = {},
    CurrentColorPicker = nil,
    ColorPickerOpened = false,
    KeybindFrame = nil,
    Unloaded = false,
    ShowCustomCursor = true,
}

-- Services
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI
local OishiHub = Instance.new("ScreenGui")
OishiHub.Name = "OishiHub"
OishiHub.Parent = CoreGui
OishiHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Notification System
function Library:Notify(NotificationProps)
    local Title = NotificationProps.Title or "Notification"
    local Content = NotificationProps.Description or ""
    local Duration = NotificationProps.Time or 5
    local Side = NotificationProps.Side or "Left"
    
    spawn(function()
        local NotifyFrame = Instance.new("Frame")
        NotifyFrame.Size = UDim2.new(0, 295, 0, 80)
        NotifyFrame.Position = Side == "Left" and UDim2.new(0, 15, 1, -15) or UDim2.new(1, -310, 1, -15)
        NotifyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.ZIndex = 999
        NotifyFrame.Parent = OishiHub
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 6)
        UICorner.Parent = NotifyFrame
        
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = Color3.fromRGB(0, 150, 255)
        UIStroke.Thickness = 1
        UIStroke.Parent = NotifyFrame
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Size = UDim2.new(1, -20, 0, 25)
        TitleLabel.Position = UDim2.new(0, 10, 0, 8)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = Title
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 14
        TitleLabel.TextColor3 = Color3.new(1, 1, 1)
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = NotifyFrame
        
        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Size = UDim2.new(1, -20, 0, 35)
        ContentLabel.Position = UDim2.new(0, 10, 0, 35)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Text = Content
        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.TextSize = 12
        ContentLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.TextWrapped = true
        ContentLabel.Parent = NotifyFrame
        
        TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = Side == "Left" and UDim2.new(0, 15, 1, -95) or UDim2.new(1, -310, 1, -95)
        }):Play()
        
        task.wait(Duration)
        
        TweenService:Create(NotifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = Side == "Left" and UDim2.new(0, 15, 1, -15) or UDim2.new(1, -310, 1, -15)
        }):Play()
        
        task.wait(0.3)
        NotifyFrame:Destroy()
    end)
end

-- Window
function Library:CreateWindow(options)
    local Window = {}
    Window.Tabs = {}
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 10
    MainFrame.Parent = OishiHub
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 150, 255)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 11
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = options.Title or "Oishi Hub"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 12
    TitleLabel.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "×"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.ZIndex = 12
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        Library:Unload()
    end)
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.Position = UDim2.new(0, 0, 0, 35)
    TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TabBar.BorderSizePixel = 0
    TabBar.ZIndex = 11
    TabBar.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 2)
    TabList.Parent = TabBar
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingTop = UDim.new(0, 4)
    TabPadding.Parent = TabBar
    
    -- Content
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -65)
    ContentFrame.Position = UDim2.new(0, 0, 0, 65)
    ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ZIndex = 11
    ContentFrame.Parent = MainFrame
    
    -- Tab Functions
    function Window:AddTab(name, icon)
        local Tab = {}
        Tab.LeftGroupboxes = {}
        Tab.RightGroupboxes = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 80, 0, 22)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 11
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.ZIndex = 12
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabBar
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("Frame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Visible = #Window.Tabs == 0
        TabContent.ZIndex = 11
        TabContent.Parent = ContentFrame
        
        -- Left/Right containers
        local LeftContainer = Instance.new("ScrollingFrame")
        LeftContainer.Size = UDim2.new(0.5, -5, 1, 0)
        LeftContainer.Position = UDim2.new(0, 0, 0, 0)
        LeftContainer.BackgroundTransparency = 1
        LeftContainer.BorderSizePixel = 0
        LeftContainer.ScrollBarThickness = 3
        LeftContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
        LeftContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftContainer.ZIndex = 11
        LeftContainer.Parent = TabContent
        
        local LeftList = Instance.new("UIListLayout")
        LeftList.Padding = UDim.new(0, 8)
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Parent = LeftContainer
        
        local LeftPadding = Instance.new("UIPadding")
        LeftPadding.PaddingTop = UDim.new(0, 8)
        LeftPadding.PaddingLeft = UDim.new(0, 8)
        LeftPadding.PaddingRight = UDim.new(0, 8)
        LeftPadding.PaddingBottom = UDim.new(0, 8)
        LeftPadding.Parent = LeftContainer
        
        local RightContainer = Instance.new("ScrollingFrame")
        RightContainer.Size = UDim2.new(0.5, -5, 1, 0)
        RightContainer.Position = UDim2.new(0.5, 5, 0, 0)
        RightContainer.BackgroundTransparency = 1
        RightContainer.BorderSizePixel = 0
        RightContainer.ScrollBarThickness = 3
        RightContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
        RightContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightContainer.ZIndex = 11
        RightContainer.Parent = TabContent
        
        local RightList = Instance.new("UIListLayout")
        RightList.Padding = UDim.new(0, 8)
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Parent = RightContainer
        
        local RightPadding = Instance.new("UIPadding")
        RightPadding.PaddingTop = UDim.new(0, 8)
        RightPadding.PaddingLeft = UDim.new(0, 8)
        RightPadding.PaddingRight = UDim.new(0, 8)
        RightPadding.PaddingBottom = UDim.new(0, 8)
        RightPadding.Parent = RightContainer
        
        -- Tab Button Click
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
                tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            TabButton.TextColor3 = Color3.new(1, 1, 1)
        end)
        
        -- Groupbox Functions
        function Tab:AddLeftGroupbox(title, icon)
            local Groupbox = Library:CreateGroupbox(LeftContainer, LeftList, title)
            table.insert(Tab.LeftGroupboxes, Groupbox)
            return Groupbox
        end
        
        function Tab:AddRightGroupbox(title, icon)
            local Groupbox = Library:CreateGroupbox(RightContainer, RightList, title)
            table.insert(Tab.RightGroupboxes, Groupbox)
            return Groupbox
        end
        
        function Tab:AddLeftTabbox()
            local Tabbox = Library:CreateTabbox(LeftContainer, LeftList)
            return Tabbox
        end
        
        function Tab:AddRightTabbox()
            local Tabbox = Library:CreateTabbox(RightContainer, RightList)
            return Tabbox
        end
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Window.Tabs[name] = Tab
        table.insert(Window.Tabs, Tab)
        
        return Tab
    end
    
    -- Drag System
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return Window
end

-- Create Groupbox
function Library:CreateGroupbox(parent, layout, title)
    local Groupbox = {}
    
    local GroupboxFrame = Instance.new("Frame")
    GroupboxFrame.Size = UDim2.new(1, 0, 0, 30)
    GroupboxFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    GroupboxFrame.BorderSizePixel = 0
    GroupboxFrame.ZIndex = 12
    GroupboxFrame.Parent = parent
    
    local GroupboxCorner = Instance.new("UICorner")
    GroupboxCorner.CornerRadius = UDim.new(0, 6)
    GroupboxCorner.Parent = GroupboxFrame
    
    local GroupboxStroke = Instance.new("UIStroke")
    GroupboxStroke.Color = Color3.fromRGB(40, 40, 45)
    GroupboxStroke.Thickness = 1
    GroupboxStroke.Parent = GroupboxFrame
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 12
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 13
    TitleLabel.Parent = GroupboxFrame
    
    -- Content
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -10, 0, 0)
    ContentFrame.Position = UDim2.new(0, 5, 0, 25)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ZIndex = 13
    ContentFrame.Parent = GroupboxFrame
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 4)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = ContentFrame
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingBottom = UDim.new(0, 5)
    ContentPadding.Parent = ContentFrame
    
    -- Update size when content changes
    local function UpdateSize()
        local contentHeight = ContentList.AbsoluteContentSize.Y
        GroupboxFrame.Size = UDim2.new(1, 0, 0, contentHeight + 30)
    end
    
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
    
    -- Element Functions
    function Groupbox:AddToggle(idx, options)
        return Library:CreateToggle(ContentFrame, ContentList, idx, options)
    end
    
    function Groupbox:AddButton(options)
        return Library:CreateButton(ContentFrame, ContentList, options)
    end
    
    function Groupbox:AddLabel(text, wrap, idx)
        return Library:CreateLabel(ContentFrame, ContentList, text, wrap, idx)
    end
    
    function Groupbox:AddSlider(idx, options)
        return Library:CreateSlider(ContentFrame, ContentList, idx, options)
    end
    
    function Groupbox:AddDropdown(idx, options)
        return Library:CreateDropdown(ContentFrame, ContentList, idx, options)
    end
    
    function Groupbox:AddDivider()
        return Library:CreateDivider(ContentFrame, ContentList)
    end
    
    function Groupbox:AddInput(idx, options)
        return Library:CreateInput(ContentFrame, ContentList, idx, options)
    end
    
    function Groupbox:AddColorPicker(idx, options)
        return Library:CreateColorPicker(ContentFrame, ContentList, idx, options)
    end
    
    function Groupbox:AddKeyPicker(idx, options)
        return Library:CreateKeyPicker(ContentFrame, ContentList, idx, options)
    end
    
    return Groupbox
end

-- Toggle with Color Picker support
function Library:CreateToggle(parent, layout, idx, options)
    local Toggle = {}
    Toggle.Value = options.Default or false
    Toggle.ColorPickers = {}
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.ZIndex = 14
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleFrame
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -60, 0, 20)
    TextLabel.Position = UDim2.new(0, 8, 0, 5)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = options.Text or idx
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 11
    TextLabel.TextColor3 = options.Risky and Color3.fromRGB(255, 60, 60) or Color3.new(1, 1, 1)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.ZIndex = 15
    TextLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 36, 0, 18)
    ToggleButton.Position = UDim2.new(1, -44, 0, 6)
    ToggleButton.BackgroundColor3 = Toggle.Value and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 45)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.ZIndex = 15
    ToggleButton.Parent = ToggleFrame
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 12, 0, 12)
    ToggleKnob.Position = Toggle.Value and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
    ToggleKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.ZIndex = 16
    ToggleKnob.Parent = ToggleButton
    
    local function SetValue(value)
        Toggle.Value = value
        ToggleButton.BackgroundColor3 = value and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 45)
        ToggleKnob.Position = value and UDim2.new(0, 21, 0, 3) or UDim2.new(0, 3, 0, 3)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        SetValue(not Toggle.Value)
        if options.Callback then
            options.Callback(Toggle.Value)
        end
    end)
    
    function Toggle:SetValue(value)
        SetValue(value)
    end
    
    function Toggle:OnChanged(callback)
        table.insert(Library.Connections, {Toggle, callback})
    end
    
    function Toggle:AddColorPicker(idx, colorOptions)
        local colorPicker = Library:CreateColorPicker(ToggleFrame, nil, idx, colorOptions)
        colorPicker.Position = UDim2.new(0, 0, 0, 30)
        table.insert(Toggle.ColorPickers, colorPicker)
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30 + #Toggle.ColorPickers * 30)
        return Toggle
    end
    
    Library.Toggles[idx] = Toggle
    Library.Options[idx] = Toggle
    
    return Toggle
end

-- Color Picker
function Library:CreateColorPicker(parent, layout, idx, options)
    local ColorPicker = {}
    ColorPicker.Value = options.Default or Color3.new(1, 0, 0)
    ColorPicker.Transparency = options.Transparency or 0
    
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Size = UDim2.new(1, 0, 0, 25)
    ColorFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ColorFrame.BorderSizePixel = 0
    ColorFrame.ZIndex = 14
    ColorFrame.Parent = parent
    
    local ColorPreview = Instance.new("Frame")
    ColorPreview.Size = UDim2.new(0, 15, 0, 15)
    ColorPreview.Position = UDim2.new(0, 8, 0, 5)
    ColorPreview.BackgroundColor3 = ColorPicker.Value
    ColorPreview.BorderSizePixel = 0
    ColorPreview.ZIndex = 15
    ColorPreview.Parent = ColorFrame
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(1, -70, 0, 20)
    ColorLabel.Position = UDim2.new(0, 28, 0, 2)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = options.Title or idx or "Color Picker"
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextSize = 10
    ColorLabel.TextColor3 = Color3.new(1, 1, 1)
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.ZIndex = 15
    ColorLabel.Parent = ColorFrame
    
    ColorFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Open color picker popup
            local PickerFrame = Instance.new("Frame")
            PickerFrame.Size = UDim2.new(0, 180, 0, 150)
            PickerFrame.Position = UDim2.new(0, 0, 0, ColorFrame.AbsolutePosition.Y - 150)
            PickerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            PickerFrame.BorderSizePixel = 0
            PickerFrame.ZIndex = 999
            PickerFrame.Parent = OishiHub
            
            -- RGB Sliders
            local function CreateRGBSlider(name, color, yPos)
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0, 15, 0, 20)
                Label.Position = UDim2.new(0, 5, 0, yPos)
                Label.BackgroundTransparency = 1
                Label.Text = name
                Label.Font = Enum.Font.GothamBold
                Label.TextSize = 10
                Label.TextColor3 = color
                Label.ZIndex = 1000
                Label.Parent = PickerFrame
                
                local Slider = Instance.new("Frame")
                Slider.Size = UDim2.new(1, -50, 0, 15)
                Slider.Position = UDim2.new(0, 25, 0, yPos + 2)
                Slider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                Slider.BorderSizePixel = 0
                Slider.ZIndex = 1000
                Slider.Parent = PickerFrame
                
                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(0.5, 0, 1, 0)
                Fill.BackgroundColor3 = color
                Fill.BorderSizePixel = 0
                Fill.ZIndex = 1001
                Fill.Parent = Slider
                
                return Slider, Fill
            end
            
            local RSlider, RFill = CreateRGBSlider("R", Color3.new(1, 0, 0), 40)
            local GSlider, GFill = CreateRGBSlider("G", Color3.new(0, 1, 0), 70)
            local BSlider, BFill = CreateRGBSlider("B", Color3.new(0, 0, 1), 100)
            
            -- Preset Colors
            local Presets = {
                Color3.new(1, 0, 0), Color3.new(0, 1, 0), Color3.new(0, 0, 1),
                Color3.new(1, 1, 0), Color3.new(1, 0, 1), Color3.new(0, 1, 1),
                Color3.new(1, 1, 1), Color3.new(0, 0, 0),
            }
            
            for i, preset in ipairs(Presets) do
                local PresetBtn = Instance.new("TextButton")
                PresetBtn.Size = UDim2.new(0, 18, 0, 18)
                PresetBtn.Position = UDim2.new(0, 5 + ((i - 1) % 8) * 21, 0, 128)
                PresetBtn.BackgroundColor3 = preset
                PresetBtn.BorderSizePixel = 0
                PresetBtn.Text = ""
                PresetBtn.AutoButtonColor = false
                PresetBtn.ZIndex = 1000
                PresetBtn.Parent = PickerFrame
                
                PresetBtn.MouseButton1Click:Connect(function()
                    ColorPicker.Value = preset
                    ColorPreview.BackgroundColor3 = preset
                    RFill.Size = UDim2.new(preset.R, 0, 1, 0)
                    GFill.Size = UDim2.new(preset.G, 0, 1, 0)
                    BFill.Size = UDim2.new(preset.B, 0, 1, 0)
                    if options.Callback then options.Callback(preset) end
                end)
            end
            
            -- Close on click outside
            local function ClosePicker()
                PickerFrame:Destroy()
            end
            
            task.delay(5, ClosePicker)
        end
    end)
    
    function ColorPicker:SetValueRGB(color)
        ColorPicker.Value = color
        ColorPreview.BackgroundColor3 = color
    end
    
    Library.Options[idx] = ColorPicker
    
    return ColorPicker
end

-- Slider
function Library:CreateSlider(parent, layout, idx, options)
    local Slider = {}
    Slider.Value = options.Default or 0
    Slider.Min = options.Min or 0
    Slider.Max = options.Max or 100
    
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 35)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.ZIndex = 14
    SliderFrame.Parent = parent
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -20, 0, 15)
    TextLabel.Position = UDim2.new(0, 8, 0, 3)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = options.Text or idx
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 10
    TextLabel.TextColor3 = Color3.new(1, 1, 1)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.ZIndex = 15
    TextLabel.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 40, 0, 15)
    ValueLabel.Position = UDim2.new(1, -45, 0, 3)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(Slider.Value)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 10
    ValueLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.ZIndex = 15
    ValueLabel.Parent = SliderFrame
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 4)
    SliderBg.Position = UDim2.new(0, 10, 0, 25)
    SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    SliderBg.BorderSizePixel = 0
    SliderBg.ZIndex = 15
    SliderBg.Parent = SliderFrame
    
    local SliderFill = Instance.new("Frame")
    local percentage = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
    SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.ZIndex = 16
    SliderFill.Parent = SliderBg
    
    local function UpdateSlider(input)
        local relativeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        local value = Slider.Min + (Slider.Max - Slider.Min) * relativeX
        local rounding = options.Rounding or 0
        value = math.floor(value * (10 ^ rounding)) / (10 ^ rounding)
        Slider.Value = value
        ValueLabel.Text = tostring(value)
        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        if options.Callback then options.Callback(value) end
    end
    
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            UpdateSlider(input)
            local moveConn, endConn
            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    UpdateSlider(moveInput)
                end
            end)
            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    if moveConn then moveConn:Disconnect() end
                    if endConn then endConn:Disconnect() end
                end
            end)
        end
    end)
    
    function Slider:SetValue(value)
        Slider.Value = value
        ValueLabel.Text = tostring(value)
        local percentage = (value - Slider.Min) / (Slider.Max - Slider.Min)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    end
    
    function Slider:OnChanged(callback)
        table.insert(Library.Connections, {Slider, callback})
    end
    
    Library.Options[idx] = Slider
    
    return Slider
end

-- Dropdown
function Library:CreateDropdown(parent, layout, idx, options)
    local Dropdown = {}
    Dropdown.Value = options.Default or options.Values[1]
    Dropdown.Values = options.Values
    
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ZIndex = 14
    DropdownFrame.Parent = parent
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -20, 0, 15)
    TextLabel.Position = UDim2.new(0, 8, 0, 3)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = options.Text or idx
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 10
    TextLabel.TextColor3 = Color3.new(1, 1, 1)
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.ZIndex = 15
    TextLabel.Parent = DropdownFrame
    
    local DropdownBtn = Instance.new("TextButton")
    DropdownBtn.Size = UDim2.new(1, -20, 0, 22)
    DropdownBtn.Position = UDim2.new(0, 10, 0, 18)
    DropdownBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    DropdownBtn.BorderSizePixel = 0
    DropdownBtn.Text = tostring(Dropdown.Value)
    DropdownBtn.Font = Enum.Font.Gotham
    DropdownBtn.TextSize = 10
    DropdownBtn.TextColor3 = Color3.new(1, 1, 1)
    DropdownBtn.ZIndex = 15
    DropdownBtn.AutoButtonColor = false
    DropdownBtn.Parent = DropdownFrame
    
    DropdownBtn.MouseButton1Click:Connect(function()
        -- Create dropdown list
        local ListFrame = Instance.new("Frame")
        ListFrame.Size = UDim2.new(1, -20, 0, #options.Values * 25)
        ListFrame.Position = UDim2.new(0, 10, 0, 18)
        ListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        ListFrame.BorderSizePixel = 0
        ListFrame.ZIndex = 999
        ListFrame.Parent = DropdownFrame
        
        for i, value in ipairs(options.Values) do
            local OptionBtn = Instance.new("TextButton")
            OptionBtn.Size = UDim2.new(1, 0, 0, 25)
            OptionBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
            OptionBtn.BackgroundColor3 = value == Dropdown.Value and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(35, 35, 40)
            OptionBtn.BorderSizePixel = 0
            OptionBtn.Text = tostring(value)
            OptionBtn.Font = Enum.Font.Gotham
            OptionBtn.TextSize = 10
            OptionBtn.TextColor3 = Color3.new(1, 1, 1)
            OptionBtn.ZIndex = 1000
            OptionBtn.AutoButtonColor = false
            OptionBtn.Parent = ListFrame
            
            OptionBtn.MouseButton1Click:Connect(function()
                Dropdown.Value = value
                DropdownBtn.Text = tostring(value)
                ListFrame:Destroy()
                if options.Callback then options.Callback(value) end
            end)
        end
        
        task.delay(3, function()
            if ListFrame and ListFrame.Parent then
                ListFrame:Destroy()
            end
        end)
    end)
    
    function Dropdown:SetValue(value)
        Dropdown.Value = value
        DropdownBtn.Text = tostring(value)
    end
    
    Library.Options[idx] = Dropdown
    
    return Dropdown
end

-- Button
function Library:CreateButton(parent, layout, options)
    local Button = {}
    
    local ButtonFrame = Instance.new("TextButton")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Text = options.Text or "Button"
    ButtonFrame.Font = Enum.Font.GothamBold
    ButtonFrame.TextSize = 11
    ButtonFrame.TextColor3 = Color3.new(1, 1, 1)
    ButtonFrame.ZIndex = 14
    ButtonFrame.AutoButtonColor = false
    ButtonFrame.Parent = parent
    
    ButtonFrame.MouseEnter:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}):Play()
    end)
    
    ButtonFrame.MouseLeave:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}):Play()
    end)
    
    ButtonFrame.MouseButton1Click:Connect(function()
        if options.Func then options.Func() end
    end)
    
    return Button
end

-- Label
function Library:CreateLabel(parent, layout, text, wrap, idx)
    local Label = {}
    
    local LabelFrame = Instance.new("TextLabel")
    LabelFrame.Size = UDim2.new(1, 0, 0, wrap and 40 or 20)
    LabelFrame.BackgroundTransparency = 1
    LabelFrame.Text = text
    LabelFrame.Font = Enum.Font.Gotham
    LabelFrame.TextSize = 11
    LabelFrame.TextColor3 = Color3.fromRGB(180, 180, 180)
    LabelFrame.TextXAlignment = Enum.TextXAlignment.Left
    LabelFrame.TextWrapped = wrap or false
    LabelFrame.ZIndex = 14
    LabelFrame.Parent = parent
    
    function Label:SetText(newText)
        LabelFrame.Text = newText
    end
    
    if idx then
        Library.Options[idx] = Label
    end
    
    return Label
end

-- Divider
function Library:CreateDivider(parent, layout)
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Divider.BorderSizePixel = 0
    Divider.ZIndex = 14
    Divider.Parent = parent
    
    return Divider
end

-- Unload
function Library:Unload()
    Library.Unloaded = true
    OishiHub:Destroy()
end

function Library:OnUnload(callback)
    table.insert(Library.Connections, callback)
end

-- Return Library
return Library
