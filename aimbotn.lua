local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local window = Rayfield:CreateWindow({
    name = "Oishi hub",
    subtitle = "Oishi",
})

local tab = window:CreateTab({ name = "Home" })
local espTab = window:CreateTab({ name = "ESP" })
local visualTab = window:CreateTab({ name = "Visual" })
local worldTab = window:CreateTab({ name = "World" })
local spooferTab = window:CreateTab({ name = "Spoofer" })
local settingsTab = window:CreateTab({ name = "Settings" })

-- ============ SERVICES ============
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ============ CONFIG SYSTEM ============
local configFolder = "OishiHub/Configs"
local lastConfigFile = "OishiHub/lastConfig.txt"

if isfolder and makefolder then
    if not isfolder("OishiHub") then makefolder("OishiHub") end
    if not isfolder(configFolder) then makefolder(configFolder) end
end

local flagRegistry = {}
local currentConfigName = ""

local function registerFlag(flag, elementType, defaultValue)
    flagRegistry[flag] = {elementType = elementType, defaultValue = defaultValue, currentValue = defaultValue}
end

local function updateFlag(flag, value)
    if flagRegistry[flag] then
        flagRegistry[flag].currentValue = value
    end
end

local function getConfigList()
    local list = {}
    if isfolder and isfile and listfiles then
        if isfolder(configFolder) then
            local files = listfiles(configFolder)
            for _, file in ipairs(files) do
                if file:match("%.json$") then
                    local name = file:gsub(".json$", ""):match("[^\\/]+$")
                    table.insert(list, name)
                end
            end
        end
    else
        for k, v in pairs(_G) do
            if type(k) == "string" and k:match("^OishiConfig_") then
                table.insert(list, k:gsub("^OishiConfig_", ""))
            end
        end
    end
    table.sort(list)
    return list
end

local function saveConfig(name)
    if not name or name == "" then name = "Default" end
    local config = {}
    for flag, data in pairs(flagRegistry) do
        config[flag] = data.currentValue
    end
    local json = HttpService:JSONEncode(config)
    
    if isfolder and makefolder and isfile and writefile then
        if not isfolder(configFolder) then makefolder(configFolder) end
        local filePath = configFolder .. "/" .. name .. ".json"
        writefile(filePath, json)
        if isfolder("OishiHub") then
            writefile(lastConfigFile, name)
        end
        print("[Config] Saved: " .. name)
        return true
    else
        _G["OishiConfig_" .. name] = json
        _G["OishiHub_lastConfig"] = name
        print("[Config] Saved to _G: " .. name)
        return true
    end
end

local function loadConfig(name)
    if not name or name == "" then return false end
    local json = nil
    
    if isfile and readfile then
        local filePath = configFolder .. "/" .. name .. ".json"
        if isfile(filePath) then
            json = readfile(filePath)
            print("[Config] Loaded: " .. name)
        end
    else
        if _G["OishiConfig_" .. name] then
            json = _G["OishiConfig_" .. name]
            print("[Config] Loaded from _G: " .. name)
        end
    end
    
    if not json then
        print("[Config] Config not found: " .. name)
        return false
    end
    
    local success, config = pcall(HttpService.JSONDecode, HttpService, json)
    if not success then
        print("[Config] Failed to parse config: " .. name)
        return false
    end
    
    for flag, value in pairs(config) do
        if flagRegistry[flag] then
            flagRegistry[flag].currentValue = value
        end
    end
    
    applyConfigToVariables()
    print("[Config] Loaded successfully: " .. name)
    return true
end

local function deleteConfig(name)
    if isfile and delfile then
        local filePath = configFolder .. "/" .. name .. ".json"
        if isfile(filePath) then
            delfile(filePath)
            print("[Config] Deleted: " .. name)
            if isfile(lastConfigFile) and readfile(lastConfigFile) == name then
                delfile(lastConfigFile)
            end
            return true
        end
    else
        if _G["OishiConfig_" .. name] then
            _G["OishiConfig_" .. name] = nil
            if _G["OishiHub_lastConfig"] == name then _G["OishiHub_lastConfig"] = nil end
            print("[Config] Deleted from _G: " .. name)
            return true
        end
    end
    print("[Config] Config not found for deletion: " .. name)
    return false
end

local function resetConfig()
    for flag, data in pairs(flagRegistry) do
        data.currentValue = data.defaultValue
    end
    applyConfigToVariables()
    print("[Config] Reset to defaults")
end

-- ============ AIMBOT ============
local aimbot = {
    enabled = false,
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

local function worldToScreen(wp, cam)
    cam = cam or Camera; if not cam or not wp then return nil, false end
    local v, on = cam:WorldToViewportPoint(wp); if not on or v.Z <= 0 then return v, false end; return v, true
end

local function screenCenter(cam) cam = cam or Camera; if not cam then return Vector2.zero end; local vs = cam.ViewportSize; return Vector2.new(vs.X * 0.5, vs.Y * 0.5) end

local function screenpos2(wp) if not wp then return nil end; local sp, ok = worldToScreen(wp, Camera); if not ok then return nil end; return Vector2.new(sp.X, sp.Y) end

local function findShotMuzzlePosition()
    local mc = LocalPlayer.Character; if not mc then local cam = workspace.CurrentCamera; return cam and (cam.CFrame.Position + cam.CFrame.LookVector * 4) or Vector3.zero end
    local vm = Workspace:FindFirstChild("ViewModels"); if vm then local fp = vm:FindFirstChild("FirstPerson")
        if fp then for _, m in ipairs(fp:GetChildren()) do if m:IsA("Model") then
            local iv = m:FindFirstChild("ItemVisual"); if iv then local b = iv:FindFirstChild("Body"); if b then local bp = b:FindFirstChild("BodyPrimary")
                if bp then local mz = bp:FindFirstChild("_muzzle"); if mz and mz:IsA("Attachment") then return mz.WorldPosition end end end end
            local mz = m:FindFirstChild("Muzzle") or m:FindFirstChild("MuzzleFlash") or m:FindFirstChild("Barrel") or m:FindFirstChild("GunTip")
            if mz then if mz:IsA("Attachment") then return mz.WorldPosition end; if mz:IsA("BasePart") then return mz.Position end end
            for _, p in ipairs(m:GetChildren()) do if p:IsA("BasePart") then local pn = p.Name:lower(); if pn:find("tip") or pn:find("barrel") or pn:find("muzzle") then return p.Position end end end
            local pp = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart"); if pp then return pp.Position end
        end end end
    end; local cam = workspace.CurrentCamera; if cam then return cam.CFrame.Position + cam.CFrame.LookVector * 4 end
    local root = mc:FindFirstChild("HumanoidRootPart"); return root and root.Position or Vector3.zero
end

local function getAimbotScreenPoint()
    if aimbot.followMuzzle then local s = screenpos2(findShotMuzzlePosition()); if s then return s end; return screenCenter(Camera) end
    local loc = UserInputService:GetMouseLocation(); return Vector2.new(loc.X, loc.Y)
end

local function isTeammateAimbot(player)
    if not aimbot.teamCheck then return false end
    local mt = LocalPlayer:GetAttribute("TeamID"); local tt = player:GetAttribute("TeamID")
    if mt and tt and mt == tt then return true end
    if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return true end
    return false
end

local function isAlive(player)
    if not aimbot.aliveCheck then return true end
    local c = player.Character; if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid"); if not h or h.Health <= 0 then return false end
    return true
end

local function isVisible(player)
    if not aimbot.wallCheck then return true end
    if not player.Character then return false end
    local part = player.Character:FindFirstChild(aimbot.targetPart) or player.Character:FindFirstChild("Head")
    if not part then return false end
    local cp = Camera.CFrame.Position; local tp = part.Position
    local dir = (tp - cp).Unit; local dist = (tp - cp).Magnitude
    local rp = RaycastParams.new(); rp.FilterDescendantsInstances = { LocalPlayer.Character }; rp.FilterType = Enum.RaycastFilterType.Blacklist
    local rr = workspace:Raycast(cp, dir * dist, rp); if not rr then return true end
    local hm = rr.Instance:FindFirstAncestorOfClass("Model"); if hm == player.Character then return true end
    return rr.Instance:IsDescendantOf(player.Character)
end

local function isValidTarget(player)
    if not player then return false end; if player == LocalPlayer then return false end
    if isTeammateAimbot(player) then return false end; if not isAlive(player) then return false end
    if not isVisible(player) then return false end; return true
end

local function closesttocursor()
    local best, bestDist = nil, aimbot.fovRadius; local mp = getAimbotScreenPoint(); if not mp then return nil end; local cam = Camera
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and isValidTarget(p) then
            local part = p.Character:FindFirstChild(aimbot.targetPart)
            if part and part:IsDescendantOf(workspace) then
                local scr, on = worldToScreen(part.Position, cam)
                if on then local dx = scr.X - mp.X; local dy = scr.Y - mp.Y; local dist = math.sqrt(dx * dx + dy * dy)
                    if dist < bestDist then bestDist = dist; best = part end
                end
            end
        end
    end; return best
end

local function getAimbotLerpAlpha(dt)
    if aimbot.smoothness <= 0.1 then return 1 end
    local s = math.clamp(tonumber(aimbot.smoothness) or 2, 0.2, 10); local speed = 6 / s
    return math.clamp(speed * dt, 0, 1)
end

local function clearAimbotLock() aimbot.lockedTarget = nil; aimbot.smoothCF = nil end

local function getUnstretchedCameraCFrame(cam)
    cam = cam or Camera; if not cam then return nil end
    local cf = cam.CFrame; local pos = cf.Position; local look = cf.LookVector; local right = cf.RightVector; local up = right:Cross(look).Unit
    return CFrame.fromMatrix(pos, right, up, -look)
end

local camController
pcall(function()
    local ctrl = LocalPlayer.PlayerScripts:WaitForChild("Controllers", 10)
    local cm = ctrl:FindFirstChild("CameraController")
    if cm and cm:IsA("ModuleScript") then camController = require(cm) end
end)

local function stepAimbot(dt)
    dt = dt or (1 / 240)
    if not aimbot.enabled then clearAimbotLock(); return end
    local cam = workspace.CurrentCamera; if not cam then return end; Camera = cam
    if not aimbot.lockedTarget then
        aimbot.lockedTarget = closesttocursor()
        aimbot.smoothCF = getUnstretchedCameraCFrame(cam)
        if not aimbot.lockedTarget then return end
    end
    if not aimbot.lockedTarget.Parent or not aimbot.lockedTarget:IsDescendantOf(workspace) then clearAimbotLock(); return end
    local targetPlayer = Players:GetPlayerFromCharacter(aimbot.lockedTarget.Parent)
    if targetPlayer then if not isValidTarget(targetPlayer) then clearAimbotLock(); return end end
    if not aimbot.smoothCF then aimbot.smoothCF = getUnstretchedCameraCFrame(cam) end
    local lookCF = CFrame.lookAt(cam.CFrame.Position, aimbot.lockedTarget.Position)
    local alpha = getAimbotLerpAlpha(dt)
    aimbot.smoothCF = aimbot.smoothCF:Lerp(lookCF, alpha)
    if camController and camController.MimicRotation then
        pcall(function() camController:MimicRotation(aimbot.smoothCF) end)
    end
end

RunService:BindToRenderStep("InstanceAimbot", Enum.RenderPriority.Camera.Value + 1, stepAimbot)

-- ============ FULL ESP FUNCTION ============
local esp = {
    enabled = false,
    boxes = false, boxColor1 = Color3.fromRGB(255,255,255), boxColor2 = Color3.fromRGB(255,255,255), boxOutline = false,
    filled = false, filledColor1 = Color3.fromRGB(255,255,255), filledColor2 = Color3.fromRGB(255,255,255), filledTransparency = 0.7, filledAnimated = false, filledSpeed = 1,
    glow = false, glowColor1 = Color3.fromRGB(255,255,255), glowColor2 = Color3.fromRGB(255,255,255), glowTransparency = 0.5,
    healthBar = false, healthHigh = Color3.fromRGB(0,255,0), healthMid = Color3.fromRGB(255,255,0), healthLow = Color3.fromRGB(255,0,0),
    names = false, nameColor1 = Color3.fromRGB(255,255,255), nameColor2 = Color3.fromRGB(255,255,255),
    distance = false, distanceColor1 = Color3.fromRGB(255,255,255), distanceColor2 = Color3.fromRGB(255,255,255),
    weapon = false, weaponColor1 = Color3.fromRGB(255,255,255), weaponColor2 = Color3.fromRGB(255,255,255),
    skeleton = false, skeletonColor1 = Color3.fromRGB(255,255,255), skeletonColor2 = Color3.fromRGB(255,255,255), skeletonThickness = 1,
    tracers = false, tracerColor1 = Color3.fromRGB(255,255,255), tracerColor2 = Color3.fromRGB(255,255,255), tracerThickness = 1, tracerFromBottom = true,
    chams = false, chamColor1 = Color3.fromRGB(255,255,255), chamColor2 = Color3.fromRGB(255,255,255), chamTransparency = 0,
}

local ESPObjects = {}
local espGui = Instance.new("ScreenGui"); espGui.Name = "ESP"; espGui.DisplayOrder = 9e9; espGui.ResetOnSpawn = false; espGui.IgnoreGuiInset = true; espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; espGui.Parent = game.CoreGui

local function getDistance(player)
    if not player or not player.Character then return math.huge end
    local mc = LocalPlayer.Character; if not mc then return math.huge end
    local mr = mc:FindFirstChild("HumanoidRootPart"); local tr = player.Character:FindFirstChild("HumanoidRootPart")
    if not mr or not tr then return math.huge end
    return (mr.Position - tr.Position).Magnitude
end

local function espIsTeammate(player)
    if not player then return true end
    local mt = LocalPlayer:GetAttribute("TeamID"); local tt = player:GetAttribute("TeamID")
    if mt and tt and mt == tt then return true end
    if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return true end
    return false
end

local function getWeapon(player)
    if not player then return "None" end
    local vm = Workspace:FindFirstChild("ViewModels"); if not vm then return "None" end
    local fp = vm:FindFirstChild("FirstPerson"); if not fp then return "None" end
    for _, child in ipairs(fp:GetChildren()) do
        if child:IsA("Model") then
            local parts = {}; for p in child.Name:gmatch("[^-]+") do table.insert(parts, p:match("^%s*(.-)%s*$")) end
            if #parts >= 2 and parts[1] == player.Name then return parts[2] end
        end
    end
    return "None"
end

local function lerpColor(c1, c2, t)
    return Color3.new(c1.R+(c2.R-c1.R)*t, c1.G+(c2.G-c1.G)*t, c1.B+(c2.B-c1.B)*t)
end

local function hpColor(pct)
    if pct > 0.5 then return lerpColor(esp.healthMid, esp.healthHigh, (pct-0.5)*2)
    else return lerpColor(esp.healthLow, esp.healthMid, pct*2) end
end

local function getBounds(char)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge; local found = false
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            local cf = part.CFrame; local sz = part.Size/2
            local corners = {cf*Vector3.new(-sz.X,-sz.Y,-sz.Z),cf*Vector3.new(sz.X,-sz.Y,-sz.Z),cf*Vector3.new(-sz.X,sz.Y,-sz.Z),cf*Vector3.new(sz.X,sz.Y,-sz.Z),cf*Vector3.new(-sz.X,-sz.Y,sz.Z),cf*Vector3.new(sz.X,-sz.Y,sz.Z),cf*Vector3.new(-sz.X,sz.Y,sz.Z),cf*Vector3.new(sz.X,sz.Y,sz.Z)}
            for _, c in ipairs(corners) do local s, o = worldToScreen(c, Camera); if o then found=true; minX=math.min(minX,s.X); minY=math.min(minY,s.Y); maxX=math.max(maxX,s.X); maxY=math.max(maxY,s.Y) end end
        end
    end
    if not found then return nil, nil end
    return Vector2.new(maxX-minX, maxY-minY), Vector2.new(minX, minY)
end

local r15 = {{"UpperTorso","Head"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local r6 = {{"Torso","Head"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

local function hideESPBox(box)
    if not box then return end
    box.box.square.Visible = false; box.box.outline.Visible = false; box.box.inline.Visible = false
    box.bars.hpOutline.Visible = false; for _, l in ipairs(box.bars.hpBars) do l.Visible = false end
    for i = 1, 15 do box.skeleton.lines[i].Visible = false; box.skeleton.outlines[i].Visible = false end
    box.tracer.Visible = false; box.nameLabel.Visible = false; box.distLabel.Visible = false; box.weaponLabel.Visible = false
    box.filled.Visible = false; box.glow.Visible = false
    if box.cham then box.cham.Enabled = false end
end

local function CreateBox(player)
    if ESPObjects[player] then return end
    local box = {}
    box.box = {square = Drawing.new("Square"), outline = Drawing.new("Square"), inline = Drawing.new("Square")}
    box.bars = {hpOutline = Drawing.new("Square"), hpBars = {}}
    for i = 1, 50 do box.bars.hpBars[i] = Drawing.new("Line") end
    box.skeleton = {lines = {}, outlines = {}}
    for i = 1, 15 do
        box.skeleton.outlines[i] = Drawing.new("Line"); box.skeleton.outlines[i].Color = Color3.new(0,0,0); box.skeleton.outlines[i].Thickness = 3
        box.skeleton.lines[i] = Drawing.new("Line")
    end
    box.tracer = Drawing.new("Line")
    box.nameLabel = Drawing.new("Text"); box.nameLabel.Size = 13; box.nameLabel.Font = 2; box.nameLabel.Outline = true; box.nameLabel.Center = true
    box.distLabel = Drawing.new("Text"); box.distLabel.Size = 13; box.distLabel.Font = 2; box.distLabel.Outline = true; box.distLabel.Center = true
    box.weaponLabel = Drawing.new("Text"); box.weaponLabel.Size = 13; box.weaponLabel.Font = 2; box.weaponLabel.Outline = true; box.weaponLabel.Center = true
    box.filled = Instance.new("Frame"); box.filled.BackgroundColor3 = Color3.new(1,1,1); box.filled.BackgroundTransparency = esp.filledTransparency; box.filled.BorderSizePixel = 0; box.filled.Visible = false; box.filled.ZIndex = 2; box.filled.Parent = espGui
    box.filledGrad = Instance.new("UIGradient"); box.filledGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,esp.filledColor1),ColorSequenceKeypoint.new(1,esp.filledColor2)}); box.filledGrad.Parent = box.filled
    box.glow = Instance.new("ImageLabel"); box.glow.Image = "rbxassetid://110204605000367"; box.glow.ScaleType = Enum.ScaleType.Slice; box.glow.SliceCenter = Rect.new(Vector2.new(21,21),Vector2.new(79,79)); box.glow.BackgroundTransparency = 1; box.glow.Visible = false; box.glow.ZIndex = 1; box.glow.Parent = espGui
    box.glowGrad = Instance.new("UIGradient"); box.glowGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,esp.glowColor1),ColorSequenceKeypoint.new(1,esp.glowColor2)}); box.glowGrad.Parent = box.glow
    ESPObjects[player] = box
end

local function RemoveBox(player)
    if not ESPObjects[player] then return end
    local box = ESPObjects[player]
    box.box.square:Remove(); box.box.outline:Remove(); box.box.inline:Remove()
    box.bars.hpOutline:Remove(); for _, l in ipairs(box.bars.hpBars) do l:Remove() end
    for i = 1, 15 do box.skeleton.lines[i]:Remove(); box.skeleton.outlines[i]:Remove() end
    box.tracer:Remove(); box.nameLabel:Remove(); box.distLabel:Remove(); box.weaponLabel:Remove()
    box.filled:Destroy(); box.glow:Destroy()
    if box.cham then box.cham:Destroy() end
    ESPObjects[player] = nil
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateBox(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateBox(p) end end)
Players.PlayerRemoving:Connect(RemoveBox)

local function updateESP(dt)
    if not esp.enabled then
        for _, box in pairs(ESPObjects) do hideESPBox(box) end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        if espIsTeammate(player) then hideESPBox(ESPObjects[player]); continue end
        
        local char = player.Character
        if not char then hideESPBox(ESPObjects[player]); continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then hideESPBox(ESPObjects[player]); continue end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then hideESPBox(ESPObjects[player]); continue end
        
        local pos, onScreen = worldToScreen(root.Position, Camera)
        if not onScreen then hideESPBox(ESPObjects[player]); continue end
        
        local box = ESPObjects[player]
        if not box then continue end
        
        local dist = getDistance(player)
        local size, position = getBounds(char)
        if not size then hideESPBox(box); continue end
        
        size = Vector2.new(math.max(size.X,4), math.max(size.Y,8))
        position = Vector2.new(math.floor(position.X), math.floor(position.Y))
        
        if esp.boxes then
            box.box.square.Visible = true; box.box.square.Position = position; box.box.square.Size = size
            box.box.square.Color = lerpColor(esp.boxColor1, esp.boxColor2, 0.5); box.box.square.Thickness = 1; box.box.square.Filled = false
            if esp.boxOutline then
                box.box.outline.Visible = true; box.box.outline.Position = position-Vector2.new(1,1); box.box.outline.Size = size+Vector2.new(2,2)
                box.box.outline.Color = Color3.new(0,0,0); box.box.outline.Thickness = 1; box.box.outline.Filled = false
                box.box.inline.Visible = true; box.box.inline.Position = position+Vector2.new(1,1); box.box.inline.Size = Vector2.new(math.max(size.X-2,2),math.max(size.Y-2,4))
                box.box.inline.Color = Color3.new(0,0,0); box.box.inline.Thickness = 1; box.box.inline.Filled = false
            else box.box.outline.Visible = false; box.box.inline.Visible = false end
        else box.box.square.Visible = false; box.box.outline.Visible = false; box.box.inline.Visible = false end
        
        if esp.filled then
            box.filled.Visible = true; box.filled.Position = UDim2.fromOffset(position.X, position.Y); box.filled.Size = UDim2.fromOffset(size.X, size.Y)
            box.filledGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,esp.filledColor1),ColorSequenceKeypoint.new(1,esp.filledColor2)})
            if esp.filledAnimated then box.filledGrad.Rotation = math.sin(tick()*esp.filledSpeed)*180 end
        else box.filled.Visible = false end
        
        if esp.glow and esp.boxes then
            box.glow.Visible = true; box.glow.ImageTransparency = esp.glowTransparency
            box.glow.Position = UDim2.fromOffset(position.X-21, position.Y-21); box.glow.Size = UDim2.fromOffset(size.X+42, size.Y+42)
            box.glowGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,esp.glowColor1),ColorSequenceKeypoint.new(1,esp.glowColor2)})
        else box.glow.Visible = false end
        
        if esp.healthBar then
            local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1); local h = math.ceil(size.Y*hp)
            local hpx = position.X-5; local hpStartY = position.Y+(size.Y-h)
            box.bars.hpOutline.Visible = true; box.bars.hpOutline.Position = Vector2.new(hpx-1, position.Y-1); box.bars.hpOutline.Size = Vector2.new(3, size.Y+2)
            box.bars.hpOutline.Color = Color3.new(0,0,0); box.bars.hpOutline.Filled = false
            local segs = math.max(math.min(math.floor(h/2),50),10)
            for i = 1, 50 do
                if i <= segs then
                    local segH = h/segs; local yOff = (i-1)*segH; local pct = 1-((yOff+(size.Y-h))/size.Y)
                    box.bars.hpBars[i].Visible = true; box.bars.hpBars[i].From = Vector2.new(hpx, hpStartY+yOff); box.bars.hpBars[i].To = Vector2.new(hpx+1, hpStartY+yOff)
                    box.bars.hpBars[i].Color = hpColor(pct); box.bars.hpBars[i].Thickness = math.max(segH,1)
                else box.bars.hpBars[i].Visible = false end
            end
        else box.bars.hpOutline.Visible = false; for _, l in ipairs(box.bars.hpBars) do l.Visible = false end end
        
        if esp.names then
            box.nameLabel.Visible = true; box.nameLabel.Text = player.Name; box.nameLabel.Position = Vector2.new(position.X+size.X/2, position.Y-15)
            box.nameLabel.Color = lerpColor(esp.nameColor1, esp.nameColor2, 0.5)
        else box.nameLabel.Visible = false end
        
        if esp.distance then
            box.distLabel.Visible = true; box.distLabel.Text = string.format("%.0f studs", dist); box.distLabel.Position = Vector2.new(position.X+size.X/2, position.Y+size.Y+2)
            box.distLabel.Color = lerpColor(esp.distanceColor1, esp.distanceColor2, 0.5)
        else box.distLabel.Visible = false end
        
        if esp.weapon then
            box.weaponLabel.Visible = true; box.weaponLabel.Text = getWeapon(player); box.weaponLabel.Position = Vector2.new(position.X+size.X+5, position.Y)
            box.weaponLabel.Color = lerpColor(esp.weaponColor1, esp.weaponColor2, 0.5)
        else box.weaponLabel.Visible = false end
        
        if esp.skeleton then
            local bones = (hum.RigType == Enum.HumanoidRigType.R15) and r15 or r6
            for i = 1, 15 do
                local bone = bones[i]; local line = box.skeleton.lines[i]; local outline = box.skeleton.outlines[i]
                if bone then
                    local pa = char:FindFirstChild(bone[1]); local pb = char:FindFirstChild(bone[2])
                    if pa and pb then
                        local va, oa = worldToScreen(pa.Position, Camera); local vb, ob = worldToScreen(pb.Position, Camera)
                        if oa and ob then
                            local f = Vector2.new(va.X,va.Y); local t = Vector2.new(vb.X,vb.Y)
                            outline.Visible = true; outline.From = f; outline.To = t; outline.Thickness = esp.skeletonThickness+2
                            line.Visible = true; line.From = f; line.To = t; line.Thickness = esp.skeletonThickness
                            line.Color = lerpColor(esp.skeletonColor1, esp.skeletonColor2, (f.X+t.X)*0.5/(position.X+size.X))
                        else line.Visible = false; outline.Visible = false end
                    else line.Visible = false; outline.Visible = false end
                else line.Visible = false; outline.Visible = false end
            end
        else for i = 1, 15 do box.skeleton.lines[i].Visible = false; box.skeleton.outlines[i].Visible = false end end
        
        if esp.tracers then
            box.tracer.Visible = true; box.tracer.To = Vector2.new(pos.X, pos.Y)
            box.tracer.From = esp.tracerFromBottom and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X/2, 0)
            box.tracer.Color = lerpColor(esp.tracerColor1, esp.tracerColor2, 0.5); box.tracer.Thickness = esp.tracerThickness
        else box.tracer.Visible = false end
        
        if esp.chams then
            if not box.cham then
                box.cham = Instance.new("Highlight"); box.cham.Parent = char; box.cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
            box.cham.Enabled = true; box.cham.FillColor = esp.chamColor1; box.cham.OutlineColor = esp.chamColor2
            box.cham.FillTransparency = esp.chamTransparency; box.cham.OutlineTransparency = math.clamp(esp.chamTransparency,0,1)
        elseif box.cham then box.cham.Enabled = false end
    end
    
    for player, box in pairs(ESPObjects) do
        if not Players:FindFirstChild(player.Name) then
            hideESPBox(box)
            if box.cham then box.cham:Destroy(); box.cham = nil end
        end
    end
end

RunService:BindToRenderStep("ESPUpdate", Enum.RenderPriority.Last.Value, updateESP)

-- ============ CROSSHAIR FUNCTION ============
local crosshair = {
    enabled = false,
    showLines = true,
    showWatermark = true,
    showAmmo = false,
    color = Color3.fromRGB(255, 255, 255),
    color1 = Color3.fromRGB(255, 255, 255),
    color2 = Color3.fromRGB(255, 255, 255),
    color3 = Color3.fromRGB(255, 255, 255),
    spinSpeed = 0,
    gradientRotation = 0,
    mode = "static",
    radius = 8,
    gap = 6,
    length = 12,
    thickness = 1.5,
    outlineThickness = 3,
    outlineColor = Color3.new(0, 0, 0),
}

local lines = {}
local texts = {}
local outlineLines = {}

for i = 1, 8 do
    outlineLines[i] = Drawing.new("Line")
    outlineLines[i].Color = Color3.new(0, 0, 0)
    outlineLines[i].Thickness = crosshair.thickness + crosshair.outlineThickness
    outlineLines[i].Visible = false
end

for i = 1, 8 do
    lines[i] = Drawing.new("Line")
    lines[i].Thickness = crosshair.thickness
    lines[i].Visible = false
end

texts[1] = Drawing.new("Text"); texts[1].Size = 16; texts[1].Font = 2; texts[1].Outline = true; texts[1].Center = true; texts[1].Visible = false
texts[2] = Drawing.new("Text"); texts[2].Size = 14; texts[2].Font = 2; texts[2].Outline = true; texts[2].Center = true; texts[2].Visible = false

local function findMuzzleCH()
    local char = LocalPlayer.Character
    if not char then local cam = workspace.CurrentCamera; return cam and (cam.CFrame.Position + cam.CFrame.LookVector * 4) or Vector3.zero end
    local vm = Workspace:FindFirstChild("ViewModels")
    if vm then
        local fp = vm:FindFirstChild("FirstPerson")
        if fp then
            for _, model in ipairs(fp:GetChildren()) do
                if not model:IsA("Model") then continue end
                local iv = model:FindFirstChild("ItemVisual")
                if iv then local b = iv:FindFirstChild("Body"); if b then local bp = b:FindFirstChild("BodyPrimary"); if bp then local mz = bp:FindFirstChild("_muzzle"); if mz and mz:IsA("Attachment") then return mz.WorldPosition end end end end end
                local muzzle = model:FindFirstChild("Muzzle") or model:FindFirstChild("MuzzleFlash") or model:FindFirstChild("Barrel") or model:FindFirstChild("GunTip")
                if muzzle then if muzzle:IsA("Attachment") then return muzzle.WorldPosition end; if muzzle:IsA("BasePart") then return muzzle.Position end end
                for _, part in ipairs(model:GetChildren()) do if part:IsA("BasePart") then local name = part.Name:lower(); if name:find("tip") or name:find("barrel") or name:find("muzzle") then return part.Position end end end
                local pp = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart"); if pp then return pp.Position end
            end
        end
    end
    local cam = workspace.CurrentCamera; if cam then return cam.CFrame.Position + cam.CFrame.LookVector * 4 end
    local root = char:FindFirstChild("HumanoidRootPart"); return root and root.Position or Vector3.zero
end

local function getCenter()
    if crosshair.mode == "follow muzzle" then
        local mp = findMuzzleCH(); local sp, on = worldToScreen(mp, Camera); if on then return sp end
    end
    local vs = Camera.ViewportSize; return Vector2.new(vs.X * 0.5, vs.Y * 0.5)
end

local function getAmmo()
    pcall(function()
        local ps = LocalPlayer:FindFirstChild("PlayerScripts"); if ps then
            local ctrl = ps:FindFirstChild("Controllers"); if ctrl then
                local fm = ctrl:FindFirstChild("FighterController"); if fm and fm:IsA("ModuleScript") then
                    local fc = require(fm); if fc and fc.LocalFighter and fc.LocalFighter.EquippedItem then
                        local item = fc.LocalFighter.EquippedItem
                        local current = item:Get("CurrentAmmo") or item:Get("Ammo") or item:Get("Bullets")
                        local maxAmmo = item:Get("MaxAmmo") or item:Get("MaxBullets") or 0
                        return current, maxAmmo
                    end
                end
            end
        end
    end)
    return nil, nil
end

local function lerpColor3(c1, c2, c3, t)
    if t < 0.33 then return c1:Lerp(c2, t / 0.33)
    elseif t < 0.66 then return c2:Lerp(c3, (t - 0.33) / 0.33)
    else return c3:Lerp(c1, (t - 0.66) / 0.34) end
end

local function getGradientColor(pos)
    local t = crosshair.gradientRotation / 360 + (crosshair.spinSpeed > 0 and (tick() * crosshair.spinSpeed * 90 % 360) / 360 or 0)
    if pos then t = t + pos end
    t = t % 1
    return lerpColor3(crosshair.color1, crosshair.color2, crosshair.color3, t)
end

RunService.RenderStepped:Connect(function()
    if not crosshair.enabled then
        for i = 1, 8 do lines[i].Visible = false; outlineLines[i].Visible = false end
        texts[1].Visible = false; texts[2].Visible = false
        return
    end
    local center = getCenter(); local cfg = crosshair
    if cfg.showLines then
        local dirs = {Vector2.new(0,-1), Vector2.new(0,1), Vector2.new(-1,0), Vector2.new(1,0)}
        for i = 1, 4 do
            local startPos = center + dirs[i] * cfg.gap; local endPos = center + dirs[i] * (cfg.gap + cfg.length)
            outlineLines[i].Visible = true; outlineLines[i].From = startPos; outlineLines[i].To = endPos; outlineLines[i].Thickness = cfg.thickness + cfg.outlineThickness
            lines[i].Visible = true; lines[i].From = startPos; lines[i].To = endPos; lines[i].Color = getGradientColor(i * 0.25); lines[i].Thickness = cfg.thickness
        end
    else for i = 1, 8 do lines[i].Visible = false; outlineLines[i].Visible = false end end
    if cfg.showWatermark then texts[1].Visible = true; texts[1].Text = "instance"; texts[1].Position = Vector2.new(center.X, center.Y + cfg.gap + cfg.length + 15); texts[1].Color = getGradientColor(nil) else texts[1].Visible = false end
    if cfg.showAmmo then local ammo, maxAmmo = getAmmo(); texts[2].Visible = true; texts[2].Text = (ammo and maxAmmo) and (tostring(ammo) .. " / " .. tostring(maxAmmo)) or ""; texts[2].Position = Vector2.new(center.X, center.Y - cfg.gap - cfg.length - 15); texts[2].Color = getGradientColor(0.5) else texts[2].Visible = false end
end)

-- ============ SPOOFER FUNCTIONS ============
-- Device Spoof
local deviceSpoof = {
    enabled = false,
    device = "Console",
    lastApplied = 0,
}

local deviceCodes = {
    ["Mobile"] = "Touch",
    ["Console"] = "Gamepad",
    ["VR"] = "VR",
    ["PC"] = "MouseKeyboard",
}

local function applyDevice()
    if not deviceSpoof.enabled then return end
    local code = deviceCodes[deviceSpoof.device]; if not code then return end
    local now = tick(); if now - deviceSpoof.lastApplied < 0.5 then return end; deviceSpoof.lastApplied = now
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            remotes = remotes:FindFirstChild("Replication")
            if remotes then
                remotes = remotes:FindFirstChild("Fighter")
                if remotes and remotes:FindFirstChild("SetControls") then
                    remotes.SetControls:FireServer(code)
                end
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function() task.wait(1); applyDevice() end)
task.spawn(function() while true do task.wait(10); applyDevice() end end)

-- Level Spoof
local levelSpoof = { enabled = false, value = 9999 }
local function applyLevel()
    if not levelSpoof.enabled then return end
    pcall(function() LocalPlayer:SetAttribute("Level", levelSpoof.value) end)
end

-- Win Streak Spoof
local winStreakSpoof = { enabled = false, value = 9999 }
local function applyWinStreak()
    if not winStreakSpoof.enabled then return end
    pcall(function()
        local ls = LocalPlayer:FindFirstChild("CustomLeaderstats")
        if ls then local ws = ls:FindFirstChild("Win Streak"); if ws then ws.Value = winStreakSpoof.value end end
    end)
end

-- Name Spoof
local nameSpoof = { enabled = false, value = "hi", verified = false, premium = false }
local function applyName(char)
    if not nameSpoof.enabled then return end
    local baseName = nameSpoof.value:gsub(utf8.char(0xE000), ""):gsub(utf8.char(0xE001), "")
    local badges = ""
    if nameSpoof.premium then badges = badges .. utf8.char(0xE001) end
    if nameSpoof.verified then badges = badges .. utf8.char(0xE000) end
    local displayName = baseName .. badges
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
        if hum then
            hum.DisplayName = displayName
            local oldDistType = hum.DisplayDistanceType
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            hum.DisplayDistanceType = oldDistType
        end
    end
end

RunService.Heartbeat:Connect(function() applyLevel(); applyWinStreak() end)
LocalPlayer.CharacterAdded:Connect(function(char) task.wait(0.3); applyName(char) end)
if LocalPlayer.Character then applyName(LocalPlayer.Character) end

-- ============ WORLD FUNCTIONS ============
local skybox = { enabled = false, current = "Default" }
local Skyboxes = {
    Default={SkyboxBk="rbxassetid://91458024",SkyboxDn="rbxassetid://91457980",SkyboxFt="rbxassetid://91458024",SkyboxLf="rbxassetid://91458024",SkyboxRt="rbxassetid://91458024",SkyboxUp="rbxassetid://91458002"},
    Neptune={SkyboxBk="rbxassetid://218955819",SkyboxDn="rbxassetid://218953419",SkyboxFt="rbxassetid://218954524",SkyboxLf="rbxassetid://218958493",SkyboxRt="rbxassetid://218957134",SkyboxUp="rbxassetid://218950090"},
    ["Among Us"]={SkyboxBk="rbxassetid://5752463190",SkyboxDn="rbxassetid://5752463190",SkyboxFt="rbxassetid://5752463190",SkyboxLf="rbxassetid://5752463190",SkyboxRt="rbxassetid://5752463190",SkyboxUp="rbxassetid://5752463190"},
    Nebula={SkyboxBk="rbxassetid://159454299",SkyboxDn="rbxassetid://159454296",SkyboxFt="rbxassetid://159454293",SkyboxLf="rbxassetid://159454286",SkyboxRt="rbxassetid://159454300",SkyboxUp="rbxassetid://159454288"},
    Minecraft={SkyboxBk="rbxassetid://1876545003",SkyboxDn="rbxassetid://1876544331",SkyboxFt="rbxassetid://1876542941",SkyboxLf="rbxassetid://1876543392",SkyboxRt="rbxassetid://1876543764",SkyboxUp="rbxassetid://1876544642"},
    Realistic={SkyboxBk="rbxassetid://144933338",SkyboxDn="rbxassetid://144931530",SkyboxFt="rbxassetid://144933262",SkyboxLf="rbxassetid://144933244",SkyboxRt="rbxassetid://144933299",SkyboxUp="rbxassetid://144931564"},
    Jungle={SkyboxBk="rbxassetid://214399891",SkyboxDn="rbxassetid://214399887",SkyboxFt="rbxassetid://214399894",SkyboxLf="rbxassetid://214405668",SkyboxRt="rbxassetid://214399899",SkyboxUp="rbxassetid://214399889"},
    Aurora={SkyboxBk="rbxassetid://340908398",SkyboxDn="rbxassetid://340908450",SkyboxFt="rbxassetid://340908468",SkyboxLf="rbxassetid://340908504",SkyboxRt="rbxassetid://340908530",SkyboxUp="rbxassetid://340908586"},
}
local customSky = nil
local function applySkybox()
    if customSky then customSky:Destroy(); customSky = nil end
    if not skybox.enabled then return end
    customSky = Instance.new("Sky"); customSky.Name = "CustomSkybox"; customSky.Parent = Lighting
    local t = Skyboxes[skybox.current] or Skyboxes["Default"]
    customSky.SkyboxBk, customSky.SkyboxDn, customSky.SkyboxFt = t.SkyboxBk, t.SkyboxDn, t.SkyboxFt
    customSky.SkyboxLf, customSky.SkyboxRt, customSky.SkyboxUp = t.SkyboxLf, t.SkyboxRt, t.SkyboxUp
end

local weather = { enabled = false, color = Color3.fromRGB(255,255,255), rate = 100, sizeScale = 1 }
local weatherCfgs = {
    rain = {enabled=false,texture="rbxassetid://1822883048",baseRate=600,speedMin=60,speedMax=60,sizeMin=10,sizeMax=10,lifetimeMin=0.8,lifetimeMax=0.8,locked=true,orientation=Enum.ParticleOrientation.FacingCameraWorldUp,lightInfluence=0.9},
    snow = {enabled=false,texture="http://www.roblox.com/asset/?id=99851851",baseRate=1000,speedMin=30,speedMax=30,sizeMin=0.33,sizeMax=0.40,lifetimeMin=4,lifetimeMax=4,locked=false,orientation=Enum.ParticleOrientation.FacingCamera,lightInfluence=1},
}
local weatherParts, weatherParticles = {}, {}
local function buildWeather(key)
    local cfg = weatherCfgs[key]; if not cfg then return end
    if weatherParts[key] then weatherParts[key]:Destroy(); weatherParticles[key] = nil end
    local part = Instance.new("Part"); part.Size, part.CanCollide, part.Massless, part.CastShadow, part.Transparency, part.Anchored, part.Name, part.Parent = Vector3.new(40,1,85), false, true, false, 1, true, "\0", workspace
    weatherParts[key] = part
    local p = Instance.new("ParticleEmitter"); p.Texture, p.Rate, p.Speed, p.Lifetime, p.LockedToPart, p.Orientation, p.Color = cfg.texture, cfg.baseRate*(weather.rate/100), NumberRange.new(cfg.speedMin,cfg.speedMax), NumberRange.new(cfg.lifetimeMin,cfg.lifetimeMax), cfg.locked, cfg.orientation, ColorSequence.new(weather.color)
    p.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,cfg.sizeMin*weather.sizeScale),NumberSequenceKeypoint.new(1,cfg.sizeMax*weather.sizeScale)}); p.Parent = part; weatherParticles[key] = p
end
local function destroyWeather(key) if weatherParts[key] then weatherParts[key]:Destroy(); weatherParts[key] = nil; weatherParticles[key] = nil end end
RunService.PostSimulation:Connect(function()
    if not weather.enabled then return end
    local pos = Camera.CFrame.Position + Vector3.new(0,20,0)
    for _, part in pairs(weatherParts) do part.CFrame = CFrame.new(pos) end
end)

local hitEffects = { enabled = false, color = Color3.fromRGB(159,133,195) }
local function doHitEffect(adornee)
    if not hitEffects.enabled then return end
    local targetPart = adornee:IsA("BasePart") and adornee or (adornee:IsA("Model") and adornee.PrimaryPart)
    if not targetPart then return end
    local emitter = Instance.new("ParticleEmitter"); emitter.Texture, emitter.Color, emitter.LightEmission, emitter.Brightness, emitter.Rate, emitter.Parent = "rbxassetid://6603835352", ColorSequence.new(hitEffects.color), 1, 13, 0, targetPart
    emitter:Emit(64); task.delay(5, function() if emitter.Parent then emitter:Destroy() end end)
end
workspace.DescendantAdded:Connect(function(obj)
    if not hitEffects.enabled then return end; if not obj:IsA("BillboardGui") then return end
    task.defer(function() if obj.Parent then obj.Enabled = false; doHitEffect(obj.Adornee or obj.Parent) end end)
end)

local hitSounds = { enabled = false, sound = "Rust HS", volume = 50, pitch = 100 }
local hitSoundsAssets = {["Rust HS"]="rbxassetid://5043539486",["Neverlose"]="rbxassetid://97643101798871",["Minecraft"]="rbxassetid://5869422451",["Bruh"]="rbxassetid://4578740568",["Fart"]="rbxassetid://130833677",["Among Us"]="rbxassetid://5700183626",["Bonk"]="rbxassetid://5766898159",["Osu"]="rbxassetid://7149255551"}
local hitSoundLast = 0
local function playHitSound()
    if not hitSounds.enabled then return end
    local now = tick(); if now - hitSoundLast < 0.05 then return end; hitSoundLast = now
    local id = hitSoundsAssets[hitSounds.sound]; if not id then return end
    local snd = Instance.new("Sound"); snd.SoundId, snd.Volume, snd.Pitch, snd.Parent = id, hitSounds.volume/100, hitSounds.pitch/100, Camera
    snd:Play(); task.delay(5, function() if snd.Parent then snd:Destroy() end end)
end
workspace.DescendantAdded:Connect(function(obj)
    if not hitSounds.enabled then return end; if not obj:IsA("BillboardGui") then return end
    task.defer(function() if obj.Parent then obj.Enabled = false; playHitSound() end end)
end)

local tracers = { enabled = true, color = Color3.fromRGB(255,255,255), style = "Line", size = 1, duration = 3, fadeTime = 0.5, glow = 0 }
local textureAssets = {["Line"]="",["Beam"]="rbxassetid://12781852245",["Lightning"]="rbxassetid://446111271",["Heartrate"]="rbxassetid://5830549480",["Chain"]="rbxassetid://9632168658",["Glitch"]="rbxassetid://8089467613",["Swirl"]="rbxassetid://5638168605",["Neon"]="rbxassetid://6361963422",["Plasma"]="rbxassetid://8993645509",["Laser"]="rbxassetid://14549123968"}
local activeTracers, trackedAmmo = {}, nil
local function findMuzzleTR()
    local mc = LocalPlayer.Character; if not mc then return Camera.CFrame.Position + Camera.CFrame.LookVector * 4 end
    local vm = Workspace:FindFirstChild("ViewModels")
    if vm then local fp = vm:FindFirstChild("FirstPerson")
        if fp then for _, m in ipairs(fp:GetChildren()) do if m:IsA("Model") then
            local iv = m:FindFirstChild("ItemVisual"); if iv then local b = iv:FindFirstChild("Body"); if b then local bp = b:FindFirstChild("BodyPrimary")
                if bp then local mz = bp:FindFirstChild("_muzzle"); if mz and mz:IsA("Attachment") then return mz.WorldPosition end end end end
            local mz = m:FindFirstChild("Muzzle") or m:FindFirstChild("MuzzleFlash") or m:FindFirstChild("Barrel") or m:FindFirstChild("GunTip")
            if mz then if mz:IsA("Attachment") then return mz.WorldPosition elseif mz:IsA("BasePart") then return mz.Position end end
        end end end
    end
    return Camera.CFrame.Position + Camera.CFrame.LookVector * 4
end
local function makeTracer(p3, ep)
    if not tracers.enabled then return end
    local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment"); a0.Parent, a1.Parent = workspace.Terrain, workspace.Terrain
    local beam = Instance.new("Beam"); beam.Attachment0, beam.Attachment1 = a0, a1; beam.Color = ColorSequence.new(tracers.color)
    local bw = tracers.style=="Laser" and 0.02 or 0.15; beam.Width0, beam.Width1 = bw*tracers.size, bw*tracers.size
    beam.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.8,0.1),NumberSequenceKeypoint.new(1,0.5)})
    beam.FaceCamera, beam.LightEmission, beam.LightInfluence = false, tracers.glow, 1-tracers.glow
    if tracers.style=="Line" then beam.Texture, beam.TextureLength, beam.TextureSpeed = "", 1, 0
    elseif textureAssets[tracers.style] then beam.Texture, beam.TextureLength, beam.TextureSpeed = textureAssets[tracers.style], 4, 1 end
    beam.Parent = workspace.Terrain; a0.WorldPosition, a1.WorldPosition = p3, ep
    local t = {Line=beam,Attachment0=a0,Attachment1=a1,Lifetime=tracers.duration,CreatedTime=tick(),FadeStartTime=tick()+tracers.duration-tracers.fadeTime}
    table.insert(activeTracers, t); return t
end
local function handleShot()
    if not tracers.enabled then return end
    local mp = findMuzzleTR(); local ep = Camera.CFrame.Position + Camera.CFrame.LookVector * 1000
    local params = RaycastParams.new(); params.FilterDescendantsInstances, params.FilterType = {LocalPlayer.Character}, Enum.RaycastFilterType.Blacklist
    local res = workspace:Raycast(mp, (ep-mp).Unit*1000, params); if res then ep = res.Position end
    makeTracer(mp, ep)
end
RunService.RenderStepped:Connect(function()
    local now = tick()
    for i = #activeTracers, 1, -1 do
        local tr = activeTracers[i]
        if tr and now - tr.CreatedTime >= tr.Lifetime then
            if tr.Line then tr.Line:Destroy() end
            if tr.Attachment0 then tr.Attachment0:Destroy() end; if tr.Attachment1 then tr.Attachment1:Destroy() end
            table.remove(activeTracers, i)
        elseif tr and now >= tr.FadeStartTime then
            local fp = math.clamp((now-tr.FadeStartTime)/(tr.Lifetime-(tr.FadeStartTime-tr.CreatedTime)),0,1)
            tr.Line.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,fp),NumberSequenceKeypoint.new(0.8,fp+0.1),NumberSequenceKeypoint.new(1,1)})
        end
    end
end)
RunService.Heartbeat:Connect(function()
    if not tracers.enabled then return end
    pcall(function()
        local ps = LocalPlayer:FindFirstChild("PlayerScripts"); if not ps then return end
        local ctrl = ps:FindFirstChild("Controllers"); if not ctrl then return end
        local fm = ctrl:FindFirstChild("FighterController"); if not fm or not fm:IsA("ModuleScript") then return end
        local fc = require(fm)
        if fc and fc.LocalFighter and fc.LocalFighter.EquippedItem then
            local ammo = fc.LocalFighter.EquippedItem:Get("CurrentAmmo") or fc.LocalFighter.EquippedItem:Get("Ammo") or fc.LocalFighter.EquippedItem:Get("Bullets")
            if ammo and trackedAmmo and ammo < trackedAmmo then for i = 1, math.floor(trackedAmmo-ammo) do handleShot() end end
            trackedAmmo = ammo
        end
    end)
end)

-- ============ CONFIG APPLY FUNCTION ============
function applyConfigToVariables()
    if flagRegistry["AimbotEnabled"] then aimbot.enabled = flagRegistry["AimbotEnabled"].currentValue end
    if flagRegistry["Smoothness"] then aimbot.smoothness = flagRegistry["Smoothness"].currentValue end
    if flagRegistry["WallCheck"] then aimbot.wallCheck = flagRegistry["WallCheck"].currentValue end
    if flagRegistry["ESPEnabled"] then esp.enabled = flagRegistry["ESPEnabled"].currentValue end
    if flagRegistry["ESPBoxes"] then esp.boxes = flagRegistry["ESPBoxes"].currentValue end
    if flagRegistry["ESPBoxOutline"] then esp.boxOutline = flagRegistry["ESPBoxOutline"].currentValue end
    if flagRegistry["ESPFilled"] then esp.filled = flagRegistry["ESPFilled"].currentValue end
    if flagRegistry["ESPFilledAnimated"] then esp.filledAnimated = flagRegistry["ESPFilledAnimated"].currentValue end
    if flagRegistry["ESPGlow"] then esp.glow = flagRegistry["ESPGlow"].currentValue end
    if flagRegistry["ESPHealthBar"] then esp.healthBar = flagRegistry["ESPHealthBar"].currentValue end
    if flagRegistry["ESPNames"] then esp.names = flagRegistry["ESPNames"].currentValue end
    if flagRegistry["ESPDistance"] then esp.distance = flagRegistry["ESPDistance"].currentValue end
    if flagRegistry["ESPWeapon"] then esp.weapon = flagRegistry["ESPWeapon"].currentValue end
    if flagRegistry["ESPSkeleton"] then esp.skeleton = flagRegistry["ESPSkeleton"].currentValue end
    if flagRegistry["ESPTracers"] then esp.tracers = flagRegistry["ESPTracers"].currentValue end
    if flagRegistry["ESPChams"] then esp.chams = flagRegistry["ESPChams"].currentValue end
    if flagRegistry["CrosshairEnabled"] then crosshair.enabled = flagRegistry["CrosshairEnabled"].currentValue end
    if flagRegistry["CrosshairLines"] then crosshair.showLines = flagRegistry["CrosshairLines"].currentValue end
    if flagRegistry["CrosshairWatermark"] then crosshair.showWatermark = flagRegistry["CrosshairWatermark"].currentValue end
    if flagRegistry["CrosshairAmmo"] then crosshair.showAmmo = flagRegistry["CrosshairAmmo"].currentValue end
    if flagRegistry["CrosshairMode"] then crosshair.mode = flagRegistry["CrosshairMode"].currentValue end
    if flagRegistry["CrosshairGap"] then crosshair.gap = flagRegistry["CrosshairGap"].currentValue end
    if flagRegistry["CrosshairLength"] then crosshair.length = flagRegistry["CrosshairLength"].currentValue end
    if flagRegistry["CrosshairThickness"] then crosshair.thickness = flagRegistry["CrosshairThickness"].currentValue end
    if flagRegistry["CrosshairSpin"] then crosshair.spinSpeed = flagRegistry["CrosshairSpin"].currentValue end
    if flagRegistry["DeviceSpoofEnabled"] then deviceSpoof.enabled = flagRegistry["DeviceSpoofEnabled"].currentValue; applyDevice() end
    if flagRegistry["DeviceSpoofType"] then deviceSpoof.device = flagRegistry["DeviceSpoofType"].currentValue end
    if flagRegistry["LevelSpoofEnabled"] then levelSpoof.enabled = flagRegistry["LevelSpoofEnabled"].currentValue end
    if flagRegistry["LevelSpoofValue"] then levelSpoof.value = flagRegistry["LevelSpoofValue"].currentValue end
    if flagRegistry["WinStreakEnabled"] then winStreakSpoof.enabled = flagRegistry["WinStreakEnabled"].currentValue end
    if flagRegistry["WinStreakValue"] then winStreakSpoof.value = flagRegistry["WinStreakValue"].currentValue end
    if flagRegistry["NameSpoofEnabled"] then nameSpoof.enabled = flagRegistry["NameSpoofEnabled"].currentValue; applyName(LocalPlayer.Character) end
    if flagRegistry["NameSpoofVerified"] then nameSpoof.verified = flagRegistry["NameSpoofVerified"].currentValue end
    if flagRegistry["NameSpoofPremium"] then nameSpoof.premium = flagRegistry["NameSpoofPremium"].currentValue end
    if flagRegistry["SkyboxEnabled"] then skybox.enabled = flagRegistry["SkyboxEnabled"].currentValue; applySkybox() end
    if flagRegistry["SkyboxType"] then skybox.current = flagRegistry["SkyboxType"].currentValue; applySkybox() end
    if flagRegistry["WeatherEnabled"] then weather.enabled = flagRegistry["WeatherEnabled"].currentValue end
    if flagRegistry["RainEnabled"] then weatherCfgs.rain.enabled = flagRegistry["RainEnabled"].currentValue; if weather.enabled then if weatherCfgs.rain.enabled then buildWeather("rain") else destroyWeather("rain") end end end
    if flagRegistry["SnowEnabled"] then weatherCfgs.snow.enabled = flagRegistry["SnowEnabled"].currentValue; if weather.enabled then if weatherCfgs.snow.enabled then buildWeather("snow") else destroyWeather("snow") end end end
    if flagRegistry["HitEffectsEnabled"] then hitEffects.enabled = flagRegistry["HitEffectsEnabled"].currentValue end
    if flagRegistry["HitSoundsEnabled"] then hitSounds.enabled = flagRegistry["HitSoundsEnabled"].currentValue end
    if flagRegistry["HitSound"] then hitSounds.sound = flagRegistry["HitSound"].currentValue end
    if flagRegistry["HitSoundVolume"] then hitSounds.volume = flagRegistry["HitSoundVolume"].currentValue end
    if flagRegistry["HitSoundPitch"] then hitSounds.pitch = flagRegistry["HitSoundPitch"].currentValue end
    if flagRegistry["TracersEnabled"] then tracers.enabled = flagRegistry["TracersEnabled"].currentValue end
    if flagRegistry["TracerStyle"] then tracers.style = flagRegistry["TracerStyle"].currentValue end
    if flagRegistry["TracerSize"] then tracers.size = flagRegistry["TracerSize"].currentValue end
    if flagRegistry["TracerDuration"] then tracers.duration = flagRegistry["TracerDuration"].currentValue end
end

-- ============ HOME TAB UI ============
tab:CreateToggle({ name = "Aimbot", flag = "AimbotEnabled", callback = function(v) aimbot.enabled = v; updateFlag("AimbotEnabled", v); if not v then clearAimbotLock() end end })
registerFlag("AimbotEnabled", "Toggle", false)
tab:CreateSlider({ name = "Smoothness", flag = "Smoothness", range = {0.1,10}, increment = 0.1, value = 2, callback = function(v) aimbot.smoothness = v; updateFlag("Smoothness", v) end })
registerFlag("Smoothness", "Slider", 2)
tab:CreateToggle({ name = "Wall check", flag = "WallCheck", callback = function(v) aimbot.wallCheck = v; updateFlag("WallCheck", v); if v then clearAimbotLock() end end })
registerFlag("WallCheck", "Toggle", false)

-- ============ ESP TAB UI ============
espTab:CreateToggle({ name = "ESP", flag = "ESPEnabled", callback = function(v) esp.enabled = v; updateFlag("ESPEnabled", v) end })
registerFlag("ESPEnabled", "Toggle", false)
espTab:CreateToggle({ name = "Boxes", flag = "ESPBoxes", callback = function(v) esp.boxes = v; updateFlag("ESPBoxes", v) end })
registerFlag("ESPBoxes", "Toggle", false)
espTab:CreateColorPicker({ name = "Box Color", flag = "ESPBoxColor1", color = Color3.fromRGB(255,255,255), callback = function(c) esp.boxColor1 = c; esp.boxColor2 = c end })
espTab:CreateToggle({ name = "Box Outline", flag = "ESPBoxOutline", callback = function(v) esp.boxOutline = v; updateFlag("ESPBoxOutline", v) end })
registerFlag("ESPBoxOutline", "Toggle", false)
espTab:CreateToggle({ name = "Filled", flag = "ESPFilled", callback = function(v) esp.filled = v; updateFlag("ESPFilled", v) end })
registerFlag("ESPFilled", "Toggle", false)
espTab:CreateColorPicker({ name = "Filled Color", flag = "ESPFilledColor1", color = Color3.fromRGB(255,255,255), callback = function(c) esp.filledColor1 = c; esp.filledColor2 = c end })
espTab:CreateToggle({ name = "Filled Animated", flag = "ESPFilledAnimated", callback = function(v) esp.filledAnimated = v; updateFlag("ESPFilledAnimated", v) end })
registerFlag("ESPFilledAnimated", "Toggle", false)
espTab:CreateToggle({ name = "Glow", flag = "ESPGlow", callback = function(v) esp.glow = v; updateFlag("ESPGlow", v) end })
registerFlag("ESPGlow", "Toggle", false)
espTab:CreateColorPicker({ name = "Glow Color", flag = "ESPGlowColor1", color = Color3.fromRGB(255,255,255), callback = function(c) esp.glowColor1 = c; esp.glowColor2 = c end })
espTab:CreateToggle({ name = "Health Bar", flag = "ESPHealthBar", callback = function(v) esp.healthBar = v; updateFlag("ESPHealthBar", v) end })
registerFlag("ESPHealthBar", "Toggle", false)
espTab:CreateToggle({ name = "Names", flag = "ESPNames", callback = function(v) esp.names = v; updateFlag("ESPNames", v) end })
registerFlag("ESPNames", "Toggle", false)
espTab:CreateColorPicker({ name = "Name Color", flag = "ESPNameColor1", color = Color3.fromRGB(255,255,255), callback = function(c) esp.nameColor1 = c; esp.nameColor2 = c end })
espTab:CreateToggle({ name = "Distance", flag = "ESPDistance", callback = function(v) esp.distance = v; updateFlag("ESPDistance", v) end })
registerFlag("ESPDistance", "Toggle", false)
espTab:CreateColorPicker({ name = "Distance Color", flag = "ESPDistanceColor1", color = Color3.fromRGB(255,255,255), callback = function(c) esp.distanceColor1 = c; esp.distanceColor2 = c end })
espTab:CreateToggle({ name = "Weapon", flag = "ESPWeapon", callback = function(v) esp.weapon = v; updateFlag("ESPWeapon", v) end })
registerFlag("ESPWeapon", "Toggle", false)
espTab:CreateColorPicker({ name = "Weapon Color", flag = "ESPWeaponColor1", color = Color3.fromRGB(255,255,255), callback = function(c) esp.weaponColor1 = c; esp.weaponColor2 = c end })
espTab:CreateToggle({ name = "Skeleton", flag = "ESPSkeleton", callback = function(v) esp.skeleton = v; updateFlag("ESPSkeleton", v) end })
registerFlag("ESPSkeleton", "Toggle", false)
espTab:CreateColorPicker({ name = "Skeleton Color", flag = "ESPSkeletonColor1", color = Color3.fromRGB(255,255,255), callback = function(c) esp.skeletonColor1 = c; esp.skeletonColor2 = c end })
espTab:CreateToggle({ name = "Tracers", flag = "ESPTracers", callback = function(v) esp.tracers = v; updateFlag("ESPTracers", v) end })
registerFlag("ESPTracers", "Toggle", false)
espTab:CreateColorPicker({ name = "Tracer Color", flag = "ESPTracerColor1", color = Color3.fromRGB(255,255,255), callback = function(c) esp.tracerColor1 = c; esp.tracerColor2 = c end })
espTab:CreateToggle({ name = "Chams", flag = "ESPChams", callback = function(v) esp.chams = v; updateFlag("ESPChams", v) end })
registerFlag("ESPChams", "Toggle", false)
espTab:CreateColorPicker({ name = "Cham Color", flag = "ESPChamColor1", color = Color3.fromRGB(255,255,255), callback = function(c) esp.chamColor1 = c; esp.chamColor2 = c end })

-- ============ VISUAL TAB UI ============
visualTab:CreateToggle({ name = "Crosshair", flag = "CrosshairEnabled", callback = function(v) crosshair.enabled = v; updateFlag("CrosshairEnabled", v) end })
registerFlag("CrosshairEnabled", "Toggle", false)
visualTab:CreateToggle({ name = "Show Lines", flag = "CrosshairLines", currentValue = true, callback = function(v) crosshair.showLines = v; updateFlag("CrosshairLines", v) end })
registerFlag("CrosshairLines", "Toggle", true)
visualTab:CreateToggle({ name = "Show Watermark", flag = "CrosshairWatermark", currentValue = true, callback = function(v) crosshair.showWatermark = v; updateFlag("CrosshairWatermark", v) end })
registerFlag("CrosshairWatermark", "Toggle", true)
visualTab:CreateToggle({ name = "Show Ammo", flag = "CrosshairAmmo", callback = function(v) crosshair.showAmmo = v; updateFlag("CrosshairAmmo", v) end })
registerFlag("CrosshairAmmo", "Toggle", false)
visualTab:CreateDropdown({ name = "Mode", flag = "CrosshairMode", options = {"static", "follow muzzle"}, callback = function(v) crosshair.mode = v; updateFlag("CrosshairMode", v) end })
registerFlag("CrosshairMode", "Dropdown", "static")
visualTab:CreateSlider({ name = "Gap", flag = "CrosshairGap", range = {0,30}, increment = 1, value = 6, callback = function(v) crosshair.gap = v; updateFlag("CrosshairGap", v) end })
registerFlag("CrosshairGap", "Slider", 6)
visualTab:CreateSlider({ name = "Length", flag = "CrosshairLength", range = {1,50}, increment = 1, value = 12, callback = function(v) crosshair.length = v; updateFlag("CrosshairLength", v) end })
registerFlag("CrosshairLength", "Slider", 12)
visualTab:CreateSlider({ name = "Thickness", flag = "CrosshairThickness", range = {0.5,5}, increment = 0.1, value = 1.5, callback = function(v) crosshair.thickness = v; updateFlag("CrosshairThickness", v) end })
registerFlag("CrosshairThickness", "Slider", 1.5)
visualTab:CreateSlider({ name = "Spin Speed", flag = "CrosshairSpin", range = {0,10}, increment = 0.1, value = 0, callback = function(v) crosshair.spinSpeed = v; updateFlag("CrosshairSpin", v) end })
registerFlag("CrosshairSpin", "Slider", 0)
visualTab:CreateColorPicker({ name = "Color 1", flag = "CrosshairColor1", color = Color3.fromRGB(255,255,255), callback = function(c) crosshair.color1 = c end })
visualTab:CreateColorPicker({ name = "Color 2", flag = "CrosshairColor2", color = Color3.fromRGB(255,255,255), callback = function(c) crosshair.color2 = c end })
visualTab:CreateColorPicker({ name = "Color 3", flag = "CrosshairColor3", color = Color3.fromRGB(255,255,255), callback = function(c) crosshair.color3 = c end })

-- ============ SPOOFER TAB UI ============
-- Device Spoof
spooferTab:CreateToggle({ name = "Device Spoof", flag = "DeviceSpoofEnabled", callback = function(v) deviceSpoof.enabled = v; updateFlag("DeviceSpoofEnabled", v); applyDevice() end })
registerFlag("DeviceSpoofEnabled", "Toggle", false)
spooferTab:CreateDropdown({ name = "Device Type", flag = "DeviceSpoofType", options = {"Mobile", "Console", "VR", "PC"}, callback = function(v) deviceSpoof.device = v; updateFlag("DeviceSpoofType", v); applyDevice() end })
registerFlag("DeviceSpoofType", "Dropdown", "Console")

-- Level Spoof
spooferTab:CreateToggle({ name = "Level Spoof", flag = "LevelSpoofEnabled", callback = function(v) levelSpoof.enabled = v; updateFlag("LevelSpoofEnabled", v) end })
registerFlag("LevelSpoofEnabled", "Toggle", false)
spooferTab:CreateInput({ name = "Level Value", flag = "LevelSpoofValueInput", placeholder = "9999", callback = function(v) levelSpoof.value = tonumber(v) or 9999; updateFlag("LevelSpoofValue", tonumber(v) or 9999) end })
registerFlag("LevelSpoofValue", "Input", 9999)

-- Win Streak Spoof
spooferTab:CreateToggle({ name = "Win Streak Spoof", flag = "WinStreakEnabled", callback = function(v) winStreakSpoof.enabled = v; updateFlag("WinStreakEnabled", v) end })
registerFlag("WinStreakEnabled", "Toggle", false)
spooferTab:CreateInput({ name = "Win Streak Value", flag = "WinStreakValueInput", placeholder = "9999", callback = function(v) winStreakSpoof.value = tonumber(v) or 9999; updateFlag("WinStreakValue", tonumber(v) or 9999) end })
registerFlag("WinStreakValue", "Input", 9999)

-- Name Spoof
spooferTab:CreateToggle({ name = "Name Spoof", flag = "NameSpoofEnabled", callback = function(v) nameSpoof.enabled = v; updateFlag("NameSpoofEnabled", v); applyName(LocalPlayer.Character) end })
registerFlag("NameSpoofEnabled", "Toggle", false)
spooferTab:CreateInput({ name = "Spoof Name", flag = "NameSpoofInput", placeholder = "hi", callback = function(v) nameSpoof.value = v; applyName(LocalPlayer.Character) end })
spooferTab:CreateToggle({ name = "Verified Badge", flag = "NameSpoofVerified", callback = function(v) nameSpoof.verified = v; updateFlag("NameSpoofVerified", v); applyName(LocalPlayer.Character) end })
registerFlag("NameSpoofVerified", "Toggle", false)
spooferTab:CreateToggle({ name = "Premium Badge", flag = "NameSpoofPremium", callback = function(v) nameSpoof.premium = v; updateFlag("NameSpoofPremium", v); applyName(LocalPlayer.Character) end })
registerFlag("NameSpoofPremium", "Toggle", false)

-- ============ WORLD TAB UI ============
local skyboxOptions = {}; for k,_ in pairs(Skyboxes) do table.insert(skyboxOptions, k) end
worldTab:CreateToggle({ name = "Skybox", flag = "SkyboxEnabled", callback = function(v) skybox.enabled = v; updateFlag("SkyboxEnabled", v); applySkybox() end })
registerFlag("SkyboxEnabled", "Toggle", false)
worldTab:CreateDropdown({ name = "Skybox Type", flag = "SkyboxType", options = skyboxOptions, callback = function(v) skybox.current = v; updateFlag("SkyboxType", v); applySkybox() end })
registerFlag("SkyboxType", "Dropdown", "Default")

worldTab:CreateToggle({ name = "Weather", flag = "WeatherEnabled", callback = function(v) weather.enabled = v; updateFlag("WeatherEnabled", v); if not v then for k,_ in pairs(weatherCfgs) do destroyWeather(k) end end end })
registerFlag("WeatherEnabled", "Toggle", false)
worldTab:CreateToggle({ name = "Rain", flag = "RainEnabled", callback = function(v) weatherCfgs.rain.enabled = v; updateFlag("RainEnabled", v); if weather.enabled then if v then buildWeather("rain") else destroyWeather("rain") end end end })
registerFlag("RainEnabled", "Toggle", false)
worldTab:CreateToggle({ name = "Snow", flag = "SnowEnabled", callback = function(v) weatherCfgs.snow.enabled = v; updateFlag("SnowEnabled", v); if weather.enabled then if v then buildWeather("snow") else destroyWeather("snow") end end end })
registerFlag("SnowEnabled", "Toggle", false)

worldTab:CreateToggle({ name = "Hit Effects", flag = "HitEffectsEnabled", callback = function(v) hitEffects.enabled = v; updateFlag("HitEffectsEnabled", v) end })
registerFlag("HitEffectsEnabled", "Toggle", false)
worldTab:CreateColorPicker({ name = "Hit Effect Color", flag = "HitEffectColor", color = Color3.fromRGB(159,133,195), callback = function(c) hitEffects.color = c end })

worldTab:CreateToggle({ name = "Hit Sounds", flag = "HitSoundsEnabled", callback = function(v) hitSounds.enabled = v; updateFlag("HitSoundsEnabled", v) end })
registerFlag("HitSoundsEnabled", "Toggle", false)
local hitSoundOpts = {}; for k,_ in pairs(hitSoundsAssets) do table.insert(hitSoundOpts, k) end
worldTab:CreateDropdown({ name = "Hit Sound", flag = "HitSound", options = hitSoundOpts, callback = function(v) hitSounds.sound = v; updateFlag("HitSound", v) end })
registerFlag("HitSound", "Dropdown", "Rust HS")
worldTab:CreateSlider({ name = "Hit Sound Volume", flag = "HitSoundVolume", range = {0,100}, increment = 1, value = 50, suffix = "%", callback = function(v) hitSounds.volume = v; updateFlag("HitSoundVolume", v) end })
registerFlag("HitSoundVolume", "Slider", 50)
worldTab:CreateSlider({ name = "Hit Sound Pitch", flag = "HitSoundPitch", range = {50,200}, increment = 1, value = 100, suffix = "%", callback = function(v) hitSounds.pitch = v; updateFlag("HitSoundPitch", v) end })
registerFlag("HitSoundPitch", "Slider", 100)

worldTab:CreateToggle({ name = "Bullet Tracers", flag = "TracersEnabled", currentValue = true, callback = function(v) tracers.enabled = v; updateFlag("TracersEnabled", v) end })
registerFlag("TracersEnabled", "Toggle", true)
local tracerOpts = {}; for k,_ in pairs(textureAssets) do table.insert(tracerOpts, k) end
worldTab:CreateDropdown({ name = "Tracer Style", flag = "TracerStyle", options = tracerOpts, callback = function(v) tracers.style = v; updateFlag("TracerStyle", v) end })
registerFlag("TracerStyle", "Dropdown", "Line")
worldTab:CreateColorPicker({ name = "Tracer Color", flag = "TracerColor", color = Color3.fromRGB(255,255,255), callback = function(c) tracers.color = c end })
worldTab:CreateSlider({ name = "Tracer Size", flag = "TracerSize", range = {0.5,5}, increment = 0.1, value = 1, callback = function(v) tracers.size = v; updateFlag("TracerSize", v) end })
registerFlag("TracerSize", "Slider", 1)
worldTab:CreateSlider({ name = "Tracer Duration", flag = "TracerDuration", range = {1,10}, increment = 0.5, value = 3, suffix = "s", callback = function(v) tracers.duration = v; updateFlag("TracerDuration", v) end })
registerFlag("TracerDuration", "Slider", 3)

-- ============ SETTINGS TAB UI ============
settingsTab:CreateInput({ name = "Config Name", placeholder = "Enter config name...", callback = function(text) currentConfigName = text end })
local configDropdown = settingsTab:CreateDropdown({ name = "Saved Configs", options = getConfigList(), flag = "ConfigListDropdown", callback = function(selected) currentConfigName = selected end })
settingsTab:CreateButton({ name = "Refresh List", callback = function() local newList = getConfigList(); if #newList == 0 then newList = {"No configs found"} end; if configDropdown.Set then configDropdown:Set(newList) end end })
settingsTab:CreateButton({ name = "Save Config", callback = function() local name = currentConfigName; if not name or name == "" then print("[Config] Please enter a config name first"); return end; saveConfig(name); local newList = getConfigList(); if #newList == 0 then newList = {"No configs found"} end; if configDropdown.Set then configDropdown:Set(newList) end end })
settingsTab:CreateButton({ name = "Load Config", callback = function() local name = currentConfigName; if not name or name == "" then print("[Config] Please select a config to load"); return end; if name == "No configs found" then return end; loadConfig(name) end })
settingsTab:CreateButton({ name = "Delete Config", callback = function() local name = currentConfigName; if not name or name == "" or name == "No configs found" then print("[Config] Please select a config to delete"); return end; deleteConfig(name); local newList = getConfigList(); if #newList == 0 then newList = {"No configs found"} end; if configDropdown.Set then configDropdown:Set(newList) end end })
settingsTab:CreateButton({ name = "Reset to Defaults", callback = function() resetConfig() end })

-- ============ AUTO-LOAD LAST CONFIG ON STARTUP ============
task.spawn(function()
    task.wait(1)
    local lastName = nil
    if isfile and readfile then
        if isfile(lastConfigFile) then lastName = readfile(lastConfigFile) end
    else
        if _G["OishiHub_lastConfig"] then lastName = _G["OishiHub_lastConfig"] end
    end
    if lastName and lastName ~= "" then
        local success = loadConfig(lastName)
        if success then currentConfigName = lastName end
    end
    local newList = getConfigList()
    if #newList == 0 then newList = {"No configs found"} end
    if configDropdown.Set then configDropdown:Set(newList) end
end)

print("[Oishi Hub] Fully loaded with Spoofer tab!")
