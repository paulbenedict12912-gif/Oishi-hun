-- Oishi Hub v1.02 - Private UI (LocalScript) with Auto-Execute
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
    Font = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    HoverAccent = Color3.fromRGB(30, 180, 255),
    HoverSurface = Color3.fromRGB(40, 40, 40),
    ClickAccent = Color3.fromRGB(0, 100, 200),
    ClickSurface = Color3.fromRGB(35, 35, 35),
    DropdownHover = Color3.fromRGB(40, 40, 40),
    DropdownSelected = Color3.fromRGB(0, 150, 255),
}

local SaveData = {
    Aimbot = false,
    AimbotShowFov = false,
    AimbotTargetPart = "Head",
    AimbotFovRadius = 500,
    AimbotSmoothness = 2,
    AimbotTeamCheck = true,
    AimbotAliveCheck = true,
    AimbotCheckForceField = true,
}

local function LoadSettings()
    local success, result = pcall(function()
        if not isfolder or not makefolder then return nil end
        if not isfolder("oishi_hub") then makefolder("oishi_hub") end
        if isfile("oishi_hub/settings.json") then
            return HttpService:JSONDecode(readfile("oishi_hub/settings.json"))
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
        writefile("oishi_hub/settings.json", HttpService:JSONEncode(SaveData))
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

-- Check for existing UI
if PlayerGui:FindFirstChild("OishiHub") then
    PlayerGui.OishiHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OishiHub"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local uiWidth = isPC and 400 or math.min(500, Camera.ViewportSize.X - 20)
local uiHeight = isPC and 400 or math.min(350, Camera.ViewportSize.Y * 0.4)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, uiWidth, 0, uiHeight)
Main.Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2)
Main.BackgroundColor3 = CONFIG.Background
Main.BackgroundTransparency = 1
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.ZIndex = 10
Main.Parent = ScreenGui

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = CONFIG.Border
MainStroke.Thickness = 2
MainStroke.Transparency = 0
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 24)
Header.BackgroundColor3 = CONFIG.Surface
Header.BackgroundTransparency = 0
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = Main

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 140, 0, 14)
HeaderTitle.Position = UDim2.new(0, 10, 0, 5)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "OISHI HUB V1.02"
HeaderTitle.Font = CONFIG.Font
HeaderTitle.TextSize = 10
HeaderTitle.TextColor3 = CONFIG.Accent
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 12
HeaderTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 16, 0, 16)
CloseBtn.Position = UDim2.new(1, -22, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.Font = CONFIG.Font
CloseBtn.TextSize = 9
CloseBtn.TextColor3 = CONFIG.TextSecondary
CloseBtn.ZIndex = 12
CloseBtn.Parent = Header

-- UI Animation functions
local function OpenUIAnimation()
    Main.Visible = true
    Main.BackgroundTransparency = 1
    Main.Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2 + 30)
    MainStroke.Transparency = 1
    
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2)
    }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0
    }):Play()
end

local function CloseUIAnimation()
    TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -uiWidth/2, 0.5, -uiHeight/2 + 30)
    }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 1
    }):Play()
    task.wait(0.2)
    Main.Visible = false
end

CloseBtn.MouseButton1Click:Connect(function()
    CloseUIAnimation()
    if isMobile and ToggleBtn then
        ToggleBtn.Text = ">"
    end
end)

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, 0, 0, 22)
TabFrame.Position = UDim2.new(0, 0, 0, 24)
TabFrame.BackgroundColor3 = CONFIG.Surface
TabFrame.BackgroundTransparency = 0
TabFrame.BorderSizePixel = 0
TabFrame.ZIndex = 11
TabFrame.Parent = Main

local Tabs = {
    {name = "Main"},
}

local currentTab = "Main"
local TabButtons = {}
local TabContents = {}

-- Create clipping container for tab content
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -46)
ContentContainer.Position = UDim2.new(0, 0, 0, 46)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.ClipsDescendants = true
ContentContainer.ZIndex = 11
ContentContainer.Parent = Main

for i, tab in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -2, 0, 18)
    btn.Position = UDim2.new(0, 1, 0, 2)
    btn.BackgroundColor3 = tab.name == currentTab and CONFIG.TabActive or CONFIG.TabInactive
    btn.BackgroundTransparency = tab.name == currentTab and 0.3 or 0.5
    btn.BorderSizePixel = 0
    btn.Text = tab.name
    btn.Font = CONFIG.Font
    btn.TextSize = 6
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
    scrollFrame.ScrollBarThickness = 2
    scrollFrame.ScrollBarImageColor3 = CONFIG.Accent
    scrollFrame.ScrollBarImageTransparency = 0.5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
    scrollFrame.ZIndex = 12
    scrollFrame.Parent = content
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = scrollFrame
    
    local layout = Instance.new("UIGridLayout")
    layout.CellPadding = UDim2.new(0, 4, 0, 3)
    layout.CellSize = UDim2.new(0.5, -6, 0, 32)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    TabContents[tab.name] = {
        frame = content,
        scroll = scrollFrame,
        layout = layout
    }
end

--========================
-- UI COMPONENTS
--========================
local function CreateToggle(tabName, name, saveKey, onToggle)
    local content = TabContents[tabName]
    if not content then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = CONFIG.Surface
    container.BackgroundTransparency = 0
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 80, 0, 12)
    nameLabel.Position = UDim2.new(0, 6, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = CONFIG.FontMedium
    nameLabel.TextSize = 9
    nameLabel.TextColor3 = CONFIG.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 28, 0, 16)
    toggleBtn.Position = UDim2.new(1, -34, 0, 4)
    toggleBtn.BackgroundColor3 = SaveData[saveKey] and CONFIG.ToggleOn or CONFIG.ToggleOff
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.ZIndex = 13
    toggleBtn.Parent = container
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = CONFIG.Border
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = SaveData[saveKey] and 0.3 or 0.8
    toggleStroke.Parent = toggleBtn
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = SaveData[saveKey] and UDim2.new(0, 15, 0, 2) or UDim2.new(0, 1, 0, 2)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    knob.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        SaveData[saveKey] = not SaveData[saveKey]
        SaveSettings()
        
        TweenService:Create(toggleStroke, TweenInfo.new(0.2), {
            Transparency = SaveData[saveKey] and 0.3 or 0.8
        }):Play()
        
        if SaveData[saveKey] then
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.ToggleOn}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 15, 0, 2)}):Play()
        else
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.ToggleOff}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 1, 0, 2)}):Play()
        end
        
        if onToggle then
            onToggle(SaveData[saveKey])
        end
    end)
    
    return container
end

local function CreateSlider(tabName, name, rangeMin, rangeMax, rangeSaveKey, suffix, onRangeChange)
    local content = TabContents[tabName]
    if not content then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = CONFIG.Surface
    container.BackgroundTransparency = 0
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 80, 0, 10)
    nameLabel.Position = UDim2.new(0, 6, 0, 3)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = CONFIG.FontMedium
    nameLabel.TextSize = 8
    nameLabel.TextColor3 = CONFIG.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 10)
    valueLabel.Position = UDim2.new(1, -46, 0, 3)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(SaveData[rangeSaveKey] or rangeMin) .. (suffix or "")
    valueLabel.Font = CONFIG.FontMedium
    valueLabel.TextSize = 8
    valueLabel.TextColor3 = CONFIG.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 13
    valueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -12, 0, 2)
    sliderBg.Position = UDim2.new(0, 6, 0, 17)
    sliderBg.BackgroundColor3 = CONFIG.SurfaceLight
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = 13
    sliderBg.Parent = container
    
    local sliderFill = Instance.new("Frame")
    local percentage = ((SaveData[rangeSaveKey] or rangeMin) - rangeMin) / (rangeMax - rangeMin)
    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    sliderFill.BackgroundColor3 = CONFIG.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 14
    sliderFill.Parent = sliderBg
    
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Size = UDim2.new(0, 10, 0, 10)
    sliderHandle.Position = UDim2.new(1, -5, 0.5, -5)
    sliderHandle.BackgroundColor3 = Color3.new(1, 1, 1)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.ZIndex = 15
    sliderHandle.Parent = sliderFill
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(rangeMin + (rangeMax - rangeMin) * relativeX)
        SaveData[rangeSaveKey] = value
        SaveSettings()
        valueLabel.Text = tostring(value) .. (suffix or "")
        TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(relativeX, 0, 1, 0)}):Play()
        if onRangeChange then onRangeChange(value) end
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

-- COMPACT DROPDOWN
local function CreateDropdown(tabName, name, saveKey, options, onChange)
    local content = TabContents[tabName]
    if not content then return end
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundColor3 = CONFIG.Surface
    container.BackgroundTransparency = 0
    container.BorderSizePixel = 0
    container.ZIndex = 12
    container.Parent = content.scroll
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 80, 0, 10)
    nameLabel.Position = UDim2.new(0, 6, 0, 3)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.Font = CONFIG.FontMedium
    nameLabel.TextSize = 8
    nameLabel.TextColor3 = CONFIG.Text
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = container
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Size = UDim2.new(1, -12, 0, 20)
    dropdownBtn.Position = UDim2.new(0, 6, 0, 16)
    dropdownBtn.BackgroundColor3 = CONFIG.SurfaceLight
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Text = SaveData[saveKey] or options[1]
    dropdownBtn.Font = CONFIG.FontMedium
    dropdownBtn.TextSize = 8
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
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.Position = UDim2.new(1, -18, 0, 3)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.Font = CONFIG.Font
    arrow.TextSize = 8
    arrow.TextColor3 = CONFIG.Accent
    arrow.ZIndex = 14
    arrow.Parent = dropdownBtn
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, -12, 0, 0)
    dropdownList.Position = UDim2.new(0, 6, 0, 38)
    dropdownList.BackgroundColor3 = CONFIG.Surface
    dropdownList.BackgroundTransparency = 0
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
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 2
    scrollFrame.ScrollBarImageColor3 = CONFIG.Accent
    scrollFrame.ScrollBarImageTransparency = 0.3
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 20)
    scrollFrame.ZIndex = 101
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.Parent = dropdownList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 1)
    listLayout.Parent = scrollFrame
    
    local isOpen = false
    local optionButtons = {}
    
    local function closeDropdown()
        isOpen = false
        TweenService:Create(dropdownList, TweenInfo.new(0.1), {Size = UDim2.new(1, -12, 0, 0)}):Play()
        task.wait(0.1)
        dropdownList.Visible = false
        container.Size = UDim2.new(1, 0, 0, 48)
        TweenService:Create(arrow, TweenInfo.new(0.1), {Rotation = 0}):Play()
    end
    
    local function openDropdown()
        isOpen = true
        dropdownList.Visible = true
        local listHeight = math.min(#options * 20 + 2, 100)
        TweenService:Create(dropdownList, TweenInfo.new(0.1), {Size = UDim2.new(1, -12, 0, listHeight)}):Play()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 20)
        container.Size = UDim2.new(1, 0, 0, 48)
        TweenService:Create(arrow, TweenInfo.new(0.1), {Rotation = 180}):Play()
    end
    
    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, 0, 0, 18)
        optionBtn.BackgroundColor3 = option == SaveData[saveKey] and CONFIG.DropdownSelected or CONFIG.SurfaceLight
        optionBtn.BackgroundTransparency = option == SaveData[saveKey] and 0.3 or 0.1
        optionBtn.BorderSizePixel = 0
        optionBtn.Text = option
        optionBtn.Font = CONFIG.FontMedium
        optionBtn.TextSize = 8
        optionBtn.TextColor3 = option == SaveData[saveKey] and Color3.new(1, 1, 1) or CONFIG.Text
        optionBtn.ZIndex = 102
        optionBtn.AutoButtonColor = false
        optionBtn.Parent = scrollFrame
        
        optionBtn.MouseEnter:Connect(function()
            if option ~= SaveData[saveKey] then
                TweenService:Create(optionBtn, TweenInfo.new(0.1), {
                    BackgroundColor3 = CONFIG.DropdownHover,
                    BackgroundTransparency = 0.2
                }):Play()
            end
        end)
        
        optionBtn.MouseLeave:Connect(function()
            if option ~= SaveData[saveKey] then
                TweenService:Create(optionBtn, TweenInfo.new(0.1), {
                    BackgroundColor3 = CONFIG.SurfaceLight,
                    BackgroundTransparency = 0.1
                }):Play()
            end
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            SaveData[saveKey] = option
            SaveSettings()
            dropdownBtn.Text = option
            
            for _, btn in ipairs(optionButtons) do
                if btn.Text == option then
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = CONFIG.DropdownSelected,
                        BackgroundTransparency = 0.3,
                        TextColor3 = Color3.new(1, 1, 1)
                    }):Play()
                else
                    TweenService:Create(btn, TweenInfo.new(0.1), {
                        BackgroundColor3 = CONFIG.SurfaceLight,
                        BackgroundTransparency = 0.1,
                        TextColor3 = CONFIG.Text
                    }):Play()
                end
            end
            
            closeDropdown()
            if onChange then onChange(option) end
        end)
        
        table.insert(optionButtons, optionBtn)
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
        else
            openDropdown()
        end
    end)
    
    content.scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if isOpen then closeDropdown() end
    end)
    
    return container
end

--========================
-- SIMPLE AIMBOT (Works on Mobile)
--========================
local aimbot = {
    enabled = false,
    showFov = false,
    targetPart = "Head",
    fovRadius = 500,
    smoothness = 2,
    teamCheck = true,
    aliveCheck = true,
    checkForceField = true,
}

-- Build FOV Circle
local fovScreenGui = Instance.new("ScreenGui")
fovScreenGui.Name = "AimbotFOV"
fovScreenGui.ResetOnSpawn = false
fovScreenGui.IgnoreGuiInset = true
fovScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fovScreenGui.Parent = game.CoreGui

local fovContainer = Instance.new("Frame")
fovContainer.BackgroundTransparency = 1
fovContainer.BorderSizePixel = 0
fovContainer.Visible = false
fovContainer.Parent = fovScreenGui

local fovOutline = Instance.new("Frame")
fovOutline.Size = UDim2.new(1, 0, 1, 0)
fovOutline.BackgroundTransparency = 1
fovOutline.BorderSizePixel = 0
fovOutline.ZIndex = 2
fovOutline.Parent = fovContainer
Instance.new("UICorner", fovOutline).CornerRadius = UDim.new(1, 0)

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0
fovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
fovStroke.Parent = fovOutline

-- Helper functions
local function worldToScreen(wp)
    if not Camera or not wp then return nil, false end
    local v, on = Camera:WorldToViewportPoint(wp)
    if not on or v.Z <= 0 then return v, false end
    return v, true
end

local function screenCenter()
    if not Camera then return Vector2.zero end
    local vs = Camera.ViewportSize
    return Vector2.new(vs.X * 0.5, vs.Y * 0.5)
end

-- Target validation
local function isValidTarget(player)
    if not player then return false end
    if player == Player then return false end
    
    if aimbot.teamCheck then
        local mt = Player:GetAttribute("TeamID")
        local tt = player:GetAttribute("TeamID")
        if mt and tt and mt == tt then return false end
        if Player.Team and player.Team and Player.Team == player.Team then return false end
    end
    
    if aimbot.aliveCheck then
        local char = player.Character
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
    end
    
    if aimbot.checkForceField then
        local char = player.Character
        if char and char:FindFirstChildOfClass("ForceField") then return false end
    end
    
    return true
end

-- Find closest target to screen center
local function findClosestTarget()
    local best = nil
    local bestDist = aimbot.fovRadius
    local center = screenCenter()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and isValidTarget(p) then
            local part = p.Character:FindFirstChild(aimbot.targetPart) or p.Character:FindFirstChild("Head")
            if part then
                local scr, on = worldToScreen(part.Position)
                if on then
                    local dx = scr.X - center.X
                    local dy = scr.Y - center.Y
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

-- Main aimbot loop - rotates character toward target
RunService.RenderStepped:Connect(function()
    if not aimbot.enabled then return end
    
    local char = Player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    local target = findClosestTarget()
    if not target then return end
    
    -- Calculate smooth rotation
    local smoothness = aimbot.smoothness or 2
    local alpha = 1 / smoothness
    
    -- Create look CFrame
    local lookCF = CFrame.lookAt(root.Position, target.Position)
    local targetCF = CFrame.new(root.Position) * lookCF.Rotation
    
    -- Smoothly rotate character
    root.CFrame = root.CFrame:Lerp(targetCF, alpha)
end)

-- FOV render
RunService.RenderStepped:Connect(function()
    if fovContainer.Visible then
        local c = screenCenter()
        local r = aimbot.fovRadius
        fovContainer.Size = UDim2.fromOffset(r * 2, r * 2)
        fovContainer.Position = UDim2.fromOffset(c.X - r, c.Y - r)
    end
end)

-- Aimbot toggle functions
local function ToggleAimbot(enabled)
    aimbot.enabled = enabled
    SaveData.Aimbot = enabled
    SaveSettings()
end

local function ToggleAimbotShowFov(enabled)
    aimbot.showFov = enabled
    fovContainer.Visible = enabled
    SaveData.AimbotShowFov = enabled
    SaveSettings()
end

local function OnAimbotTargetPartChange(part)
    aimbot.targetPart = part
    SaveData.AimbotTargetPart = part
    SaveSettings()
end

local function OnAimbotFovRadiusChange(value)
    aimbot.fovRadius = value
    SaveData.AimbotFovRadius = value
    SaveSettings()
end

local function OnAimbotSmoothnessChange(value)
    aimbot.smoothness = value
    SaveData.AimbotSmoothness = value
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

local function ToggleAimbotCheckForceField(enabled)
    aimbot.checkForceField = enabled
    SaveData.AimbotCheckForceField = enabled
    SaveSettings()
end

--========================
-- CREATE ALL FEATURES (Main Tab)
--========================
CreateToggle("Main", "Aimbot", "Aimbot", ToggleAimbot)
CreateToggle("Main", "Show FOV", "AimbotShowFov", ToggleAimbotShowFov)
CreateDropdown("Main", "Target Part", "AimbotTargetPart", {
    "Head",
    "HumanoidRootPart",
}, OnAimbotTargetPartChange)
CreateSlider("Main", "FOV Radius", 50, 1000, "AimbotFovRadius", "", OnAimbotFovRadiusChange)
CreateSlider("Main", "Smoothness", 1, 10, "AimbotSmoothness", "", OnAimbotSmoothnessChange)
CreateToggle("Main", "Team Check", "AimbotTeamCheck", ToggleAimbotTeamCheck)
CreateToggle("Main", "Alive Check", "AimbotAliveCheck", ToggleAimbotAliveCheck)
CreateToggle("Main", "ForceField Check", "AimbotCheckForceField", ToggleAimbotCheckForceField)

-- Update canvas sizes
task.wait(0.1)
for _, content in pairs(TabContents) do
    content.scroll.CanvasSize = UDim2.new(0, 0, 0, content.layout.AbsoluteContentSize.Y + 10)
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
local ToggleBtn = nil

if isMobile then
    ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
    ToggleBtn.Position = UDim2.new(0, 6, 0.5, -12)
    ToggleBtn.BackgroundColor3 = CONFIG.Surface
    ToggleBtn.BackgroundTransparency = 0
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
        if Main.Visible then
            CloseUIAnimation()
            ToggleBtn.Text = ">"
        else
            OpenUIAnimation()
            ToggleBtn.Text = "X"
        end
    end)
end

if isPC then
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if Main.Visible then
                CloseUIAnimation()
            else
                OpenUIAnimation()
            end
        end
    end)
end

--========================
-- AUTO-ENABLE SAVED FEATURES
--========================
aimbot.enabled = SaveData.Aimbot
aimbot.showFov = SaveData.AimbotShowFov
aimbot.targetPart = SaveData.AimbotTargetPart
aimbot.fovRadius = SaveData.AimbotFovRadius
aimbot.smoothness = SaveData.AimbotSmoothness
aimbot.teamCheck = SaveData.AimbotTeamCheck
aimbot.aliveCheck = SaveData.AimbotAliveCheck
aimbot.checkForceField = SaveData.AimbotCheckForceField

-- Apply FOV visibility
fovContainer.Visible = aimbot.showFov

--========================
-- SETUP AUTO-EXECUTE
--========================
SetupAutoExecute()

-- Open UI on first load
OpenUIAnimation()

print("[Oishi Hub v1.02] Loaded with Simple Aimbot!")
