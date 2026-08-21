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
    AimbotAimCurve = "Linear",
    AimbotFollowMuzzle = false,
    AimbotTeamCheck = true,
    AimbotAliveCheck = true,
    AimbotWallCheck = false,
    AimbotCheckForceField = true,
    AimbotCheckAttachment = true,
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
-- FULL INSTANCE AIMBOT
--========================
local aimbot = {
    enabled = false,
    masterEnabled = false,
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
    checkForceField = true,
    checkAttachment = true,
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

-- Build FOV
local fovScreenGui = Instance.new("ScreenGui")
fovScreenGui.Name = "AimbotFOV"
fovScreenGui.ResetOnSpawn = false
fovScreenGui.IgnoreGuiInset = true
fovScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fovScreenGui.Parent = game.CoreGui

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
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local fillgrad = Instance.new("UIGradient")
    fillgrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, cfg.FilledColor1),
        ColorSequenceKeypoint.new(1, cfg.FilledColor2)
    })
    fillgrad.Rotation = cfg.FilledRotation
    fillgrad.Parent = fill

    local outline = Instance.new("Frame")
    outline.Size = UDim2.new(1, 0, 1, 0)
    outline.BackgroundTransparency = 1
    outline.BorderSizePixel = 0
    outline.ZIndex = 2
    outline.Parent = container
    Instance.new("UICorner", outline).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = cfg.OutlineThickness
    stroke.Transparency = cfg.OutlineTransparency
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = outline

    local strokegrad = Instance.new("UIGradient")
    strokegrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, cfg.OutlineColor1),
        ColorSequenceKeypoint.new(1, cfg.OutlineColor2)
    })
    strokegrad.Rotation = cfg.OutlineRotation
    strokegrad.Parent = stroke

    return {container = container, fill = fill, fillgrad = fillgrad, stroke = stroke, strokegrad = strokegrad}
end

local aFOV = buildfov("AimbotFOV", aimbotFOVCfg)
local aimbotFOVContainer = aFOV.container
local aimbotFOVFill = aFOV.fill
local aimbotFOVFillGrad = aFOV.fillgrad
local aimbotFOVStroke = aFOV.stroke
local aimbotFOVStrokeGrad = aFOV.strokegrad

-- Helpers
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
    local mc = LocalPlayer.Character
    if not mc then
        local cam = Workspace.CurrentCamera
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
    
    local cam = Workspace.CurrentCamera
    if cam then return cam.CFrame.Position + cam.CFrame.LookVector * 4 end
    local root = mc:FindFirstChild("HumanoidRootPart")
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
    local loc = UserInputService:GetMouseLocation()
    return Vector2.new(loc.X, loc.Y)
end

-- Target validation
local function isValidTarget(player)
    if not player then return false end
    if player == LocalPlayer then return false end
    
    if aimbot.teamCheck then
        local mt = LocalPlayer:GetAttribute("TeamID")
        local tt = player:GetAttribute("TeamID")
        if mt and tt and mt == tt then return false end
        if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return false end
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
    
    if aimbot.checkAttachment then
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, child in ipairs(hrp:GetChildren()) do
                    if child:IsA("Attachment") then return false end
                end
            end
        end
    end
    
    return true
end

-- Wall check
local function isTargetVisible(player)
    if not aimbot.wallCheck then return true end
    if not player or not player.Character then return false end
    
    local targetPart = player.Character:FindFirstChild(aimbot.targetPart) or player.Character:FindFirstChild("Head")
    if not targetPart then return false end
    
    local cp = Camera.CFrame.Position
    local tp = targetPart.Position
    local dir = (tp - cp).Unit
    local dist = (tp - cp).Magnitude
    
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LocalPlayer.Character}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    
    local rr = Workspace:Raycast(cp, dir * dist, rp)
    if not rr then return true end
    
    local hm = rr.Instance:FindFirstAncestorOfClass("Model")
    if hm == player.Character then return true end
    
    return rr.Instance:IsDescendantOf(player.Character)
end

-- Closest target
local function closesttocursor()
    local best, bd = nil, aimbot.fovRadius
    local mp = getAimbotScreenPoint()
    if not mp then return nil end
    
    local cam = Camera
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isValidTarget(p) then
            local part = p.Character:FindFirstChild(aimbot.targetPart)
            if part and part:IsDescendantOf(Workspace) then
                local scr, on = worldToScreen(part.Position, cam)
                if on then
                    local dx = scr.X - mp.X
                    local dy = scr.Y - mp.Y
                    local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < bd then
                        if isTargetVisible(p) then
                            bd = dist
                            best = part
                        end
                    end
                end
            end
        end
    end
    
    return best
end

-- Lerp alpha
local function getAimbotLerpAlpha(dt)
    local s = math.clamp(tonumber(aimbot.smoothness) or 2, 0.1, 10)
    local curve = aimbot.aimCurve or "Linear"
    local speed = 6 / s
    
    if curve == "Instant" then return 1
    elseif curve == "Expo" then return 1 - math.exp(-(4 / s) * dt)
    elseif curve == "EaseIn" then local t = math.clamp(speed * dt, 0, 1); return t * t
    elseif curve == "EaseOut" then local t = math.clamp(speed * dt, 0, 1); return 1 - (1 - t) * (1 - t)
    elseif curve == "EaseInOut" then local t = math.clamp(speed * dt, 0, 1); if t < 0.5 then return 2 * t * t end; return 1 - ((-2 * t + 2) ^ 2) / 2
    elseif curve == "Cubic" then local t = math.clamp(speed * dt, 0, 1); return t * t * t end
    
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

-- Camera controller
local camController
pcall(function()
    local ctrl = LocalPlayer.PlayerScripts:WaitForChild("Controllers", 10)
    local cm = ctrl:FindFirstChild("CameraController")
    if cm and cm:IsA("ModuleScript") then
        camController = require(cm)
    end
end)

-- Main loop
local function stepAimbot(dt)
    dt = dt or (1 / 240)
    if not aimbot.enabled then clearAimbotLock(); return end
    
    local cam = Workspace.CurrentCamera
    if not cam then return end
    Camera = cam

    if not aimbot.lockedTarget then
        aimbot.lockedTarget = closesttocursor()
        aimbot.smoothCF = getUnstretchedCameraCFrame(cam)
        if not aimbot.lockedTarget then return end
    end

    if not aimbot.lockedTarget.Parent or not aimbot.lockedTarget:IsDescendantOf(Workspace) then
        clearAimbotLock()
        return
    end

    local targetPlayer = Players:GetPlayerFromCharacter(aimbot.lockedTarget.Parent)
    if targetPlayer then
        if not isValidTarget(targetPlayer) then clearAimbotLock(); return end
        if aimbot.wallCheck and not isTargetVisible(targetPlayer) then clearAimbotLock(); return end
    end

    local myChar = LocalPlayer.Character
    if not myChar then return end
    
    local myHead = myChar:FindFirstChild("Head")
    if not myHead then clearAimbotLock(); return end
    
    if not camController then return end
    if not aimbot.smoothCF then aimbot.smoothCF = getUnstretchedCameraCFrame(cam) end

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

-- FOV render
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

-- Aimbot toggle functions
local function ToggleAimbot(enabled)
    aimbot.enabled = enabled
    SaveData.Aimbot = enabled
    SaveSettings()
end

local function ToggleAimbotShowFov(enabled)
    aimbot.showFov = enabled
    aimbotFOVContainer.Visible = enabled
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

local function OnAimbotAimCurveChange(curve)
    aimbot.aimCurve = curve
    SaveData.AimbotAimCurve = curve
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

local function ToggleAimbotCheckForceField(enabled)
    aimbot.checkForceField = enabled
    SaveData.AimbotCheckForceField = enabled
    SaveSettings()
end

local function ToggleAimbotCheckAttachment(enabled)
    aimbot.checkAttachment = enabled
    SaveData.AimbotCheckAttachment = enabled
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
    "Torso",
    "UpperTorso",
    "LowerTorso",
}, OnAimbotTargetPartChange)
CreateSlider("Main", "FOV Radius", 50, 1000, "AimbotFovRadius", "", OnAimbotFovRadiusChange)
CreateSlider("Main", "Smoothness", 1, 10, "AimbotSmoothness", "", OnAimbotSmoothnessChange)
CreateDropdown("Main", "Aim Curve", "AimbotAimCurve", {
    "Linear",
    "Instant",
    "Expo",
    "EaseIn",
    "EaseOut",
    "EaseInOut",
    "Cubic",
}, OnAimbotAimCurveChange)
CreateToggle("Main", "Follow Muzzle", "AimbotFollowMuzzle", ToggleAimbotFollowMuzzle)
CreateToggle("Main", "Team Check", "AimbotTeamCheck", ToggleAimbotTeamCheck)
CreateToggle("Main", "Alive Check", "AimbotAliveCheck", ToggleAimbotAliveCheck)
CreateToggle("Main", "Wall Check", "AimbotWallCheck", ToggleAimbotWallCheck)
CreateToggle("Main", "ForceField Check", "AimbotCheckForceField", ToggleAimbotCheckForceField)
CreateToggle("Main", "Attachment Check", "AimbotCheckAttachment", ToggleAimbotCheckAttachment)

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
-- Load aimbot settings
aimbot.enabled = SaveData.Aimbot
aimbot.showFov = SaveData.AimbotShowFov
aimbot.targetPart = SaveData.AimbotTargetPart
aimbot.fovRadius = SaveData.AimbotFovRadius
aimbot.smoothness = SaveData.AimbotSmoothness
aimbot.aimCurve = SaveData.AimbotAimCurve
aimbot.followMuzzle = SaveData.AimbotFollowMuzzle
aimbot.teamCheck = SaveData.AimbotTeamCheck
aimbot.aliveCheck = SaveData.AimbotAliveCheck
aimbot.wallCheck = SaveData.AimbotWallCheck
aimbot.checkForceField = SaveData.AimbotCheckForceField
aimbot.checkAttachment = SaveData.AimbotCheckAttachment

-- Apply FOV visibility
aimbotFOVContainer.Visible = aimbot.showFov

--========================
-- SETUP AUTO-EXECUTE
--========================
SetupAutoExecute()

-- Open UI on first load
OpenUIAnimation()

print("[Oishi Hub v1.02] Loaded with Full Instance Aimbot!")
