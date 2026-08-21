-- Oishi Hub v1.02 - Linoria UI Library Version
-- Load Linoria Library first, then this script

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if not getgenv().Library then
    warn("Linoria Library not found!")
    return
end

local Library = getgenv().Library

--========================
-- UTILITY FUNCTIONS
--========================
local function isTeammate(player)
    if not player then return false end
    if Player.Team and player.Team and Player.Team == player.Team then return true end
    if Player:GetAttribute("TeamID") and player:GetAttribute("TeamID") then
        if Player:GetAttribute("TeamID") == player:GetAttribute("TeamID") then return true end
    end
    return false
end

--========================
-- CREATE WINDOW
--========================
local Window = Library:CreateWindow({
    Title = 'Oishi Hub V1.02',
    Center = true,
    AutoShow = true,
    Resizable = true,
    Size = UDim2.fromOffset(600, 500),
})

--========================
-- CREATE TABS
--========================
local CombatTab = Window:AddTab('Combat')
local VisualsTab = Window:AddTab('Visuals')
local MovementTab = Window:AddTab('Movement')
local AnimationTab = Window:AddTab('Animation')
local SettingsTab = Window:AddTab('Settings')

--========================
-- COMBAT TAB GROUPS
--========================
local AimbotGroup = CombatTab:AddLeftGroupbox('Aimbot')
local TriggerGroup = CombatTab:AddRightGroupbox('Trigger & Weapons')

--========================
-- VISUALS TAB GROUPS
--========================
local ESPSettingsGroup = VisualsTab:AddLeftGroupbox('ESP Features')
local ESPVisualsGroup = VisualsTab:AddLeftGroupbox('ESP Visuals')
local ESPColorsGroup = VisualsTab:AddRightGroupbox('ESP Colors')

--========================
-- MOVEMENT TAB GROUPS
--========================
local FlyGroup = MovementTab:AddLeftGroupbox('Fly')
local MovementModsGroup = MovementTab:AddRightGroupbox('Movement Mods')

--========================
-- ANIMATION TAB GROUPS
--========================
local AnimControlGroup = AnimationTab:AddLeftGroupbox('Animation Control')
local AnimPresetsGroup = AnimationTab:AddRightGroupbox('Animation Presets')

--========================
-- SETTINGS TAB GROUPS
--========================
local ConfigGroup = SettingsTab:AddLeftGroupbox('Configuration')
local InfoGroup = SettingsTab:AddRightGroupbox('Information')

--========================
-- SAVE/LOAD SYSTEM
--========================
local SaveManager = {}

function SaveManager:Save()
    if not writefile then return end
    pcall(function()
        if not isfolder("oishi_hub") then makefolder("oishi_hub") end
        
        local data = {}
        for idx, toggle in pairs(getgenv().Toggles) do
            if type(idx) == 'string' then
                data[idx] = toggle.Value
            end
        end
        for idx, option in pairs(getgenv().Options) do
            if type(idx) == 'string' then
                if option.Type == 'Slider' or option.Type == 'Dropdown' then
                    data[idx] = option.Value
                elseif option.Type == 'ColorPicker' then
                    data[idx] = {option.Value.R, option.Value.G, option.Value.B}
                elseif option.Type == 'KeyPicker' then
                    data[idx] = {option.Value, option.Mode}
                end
            end
        end
        
        writefile("oishi_hub/config.json", HttpService:JSONEncode(data))
    end)
end

function SaveManager:Load()
    if not readfile or not isfile then return end
    local success, result = pcall(function()
        if isfile("oishi_hub/config.json") then
            return HttpService:JSONDecode(readfile("oishi_hub/config.json"))
        end
    end)
    if success and result then
        return result
    end
    return nil
end

--========================
-- RAGEBOT SYSTEM
--========================
local RagebotSystem = {
    Enabled = false,
    Connection = nil,
    Target = nil,
    desyncShootPos = nil,
}

local function EnableRagebot()
    if RagebotSystem.Enabled then return end
    RagebotSystem.Enabled = true
    
    pcall(function()
        local GunModule = require(Player.PlayerScripts.Modules.ItemTypes.Gun)
        local UtilityModule = require(ReplicatedStorage.Modules.Utility)
        
        local function FindTarget()
            local myChar = Player.Character
            if not myChar then return nil end
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if not myRoot then return nil end
            
            local closest = nil
            local closestDist = math.huge
            
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and not isTeammate(plr) then
                    local char = plr.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        local root = char:FindFirstChild("HumanoidRootPart")
                        local head = char:FindFirstChild("Head")
                        
                        if hum and hum.Health > 0 and root and head then
                            local dist = (myRoot.Position - root.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = plr
                            end
                        end
                    end
                end
            end
            
            return closest
        end
        
        RagebotSystem.Connection = RunService.Heartbeat:Connect(function()
            if not RagebotSystem.Enabled then return end
            
            RagebotSystem.Target = FindTarget()
            
            if RagebotSystem.Target and RagebotSystem.Target.Character then
                local enemyHead = RagebotSystem.Target.Character:FindFirstChild("Head")
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                
                if enemyHead and root then
                    local savedCF = root.CFrame
                    local savedVel = root.Velocity
                    
                    root.CFrame = enemyHead.CFrame
                    root.Velocity = Vector3.zero
                    RagebotSystem.desyncShootPos = enemyHead.Position
                    
                    RunService:BindToRenderStep("RagebotRestore", 101, function()
                        root.CFrame = savedCF
                        root.Velocity = savedVel
                        RunService:UnbindFromRenderStep("RagebotRestore")
                    end)
                end
            end
        end)
        
        local OriginalShoot = GunModule.StartShooting
        RagebotSystem.OldShootFunc = OriginalShoot
        
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
            
            local target = RagebotSystem.Target
            if not RagebotSystem.Enabled or not target or not target.Character then
                return unpack(results)
            end
            
            local head = target.Character:FindFirstChild("Head")
            if not head then return unpack(results) end
            
            data[utf8.char(0)] = UtilityModule:EncodeCFrame(head.CFrame)
            data[utf8.char(1)] = UtilityModule:EncodeCFrame(head.CFrame)
            data[utf8.char(2)] = head
            data[utf8.char(3)] = UtilityModule:EncodeCFrame(CFrame.new(0.43, 0.25, 0.42))
            
            return unpack(results)
        end
    end)
end

local function DisableRagebot()
    RagebotSystem.Enabled = false
    RagebotSystem.Target = nil
    RagebotSystem.desyncShootPos = nil
    
    if RagebotSystem.Connection then
        RagebotSystem.Connection:Disconnect()
        RagebotSystem.Connection = nil
    end
    
    pcall(function()
        if RagebotSystem.OldShootFunc then
            local GunModule = require(Player.PlayerScripts.Modules.ItemTypes.Gun)
            GunModule.StartShooting = RagebotSystem.OldShootFunc
            RagebotSystem.OldShootFunc = nil
        end
    end)
    
    RunService:UnbindFromRenderStep("RagebotRestore")
end

--========================
-- AUTO SHOOT SYSTEM
--========================
local AutoShoot = {
    Enabled = false,
    Connection = nil,
    lastFire = 0,
}

local restricted = {
    "Medkit", "Grenade", "Flashbang", "Jump Pad", "Molotov", "Satchel",
    "Smoke Grenade", "War Horn", "Subspace Tripmine", "Warpstone"
}

local function isRestricted(weapon)
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
        if plr ~= Player and not isTeammate(plr) then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                
                if hum and hum.Health > 0 and root then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = char
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

local function fire()
    if not AutoShoot.Enabled then return end
    
    local weap = getWeapon()
    if weap and isRestricted(weap) then return end
    
    local now = tick()
    local delay = getgenv().Options.AutoShootDelay and getgenv().Options.AutoShootDelay.Value or 0.1
    if now - AutoShoot.lastFire < delay then return end
    
    local target = getClosestEnemy()
    if not target then return end
    
    local head = target:FindFirstChild("Head")
    if not head then return end
    
    local targetPlayer = Players:GetPlayerFromCharacter(target)
    if not targetPlayer or isTeammate(targetPlayer) then return end
    
    pcall(function()
        local Utility = require(ReplicatedStorage.Modules.Utility)
        local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
        local fighterController = require(Player.PlayerScripts.Controllers.FighterController)
        local equipped = fighterController.LocalFighter and fighterController.LocalFighter.EquippedItem
        
        if not equipped then return end
        
        local objId = equipped:Get("ObjectID")
        if not objId then return end
        
        AutoShoot.lastFire = now
        
        local myChar = Player.Character
        local root = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local shootPos = root and root.Position or head.Position
        
        if RagebotSystem.Enabled and RagebotSystem.desyncShootPos then
            shootPos = RagebotSystem.desyncShootPos
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
    if AutoShoot.Enabled then return end
    AutoShoot.Enabled = true
    
    AutoShoot.Connection = RunService.Heartbeat:Connect(fire)
end

local function DisableAutoShoot()
    AutoShoot.Enabled = false
    
    if AutoShoot.Connection then
        AutoShoot.Connection:Disconnect()
        AutoShoot.Connection = nil
    end
end

--========================
-- RAPID FIRE SYSTEM
--========================
local RapidFire = {
    Enabled = false,
}

local function EnableRapidFire()
    if RapidFire.Enabled then return end
    RapidFire.Enabled = true
    
    pcall(function()
        local Items = require(ReplicatedStorage.Modules.ItemLibrary).Items
        
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
    RapidFire.Enabled = false
end

--========================
-- FLY SYSTEM
--========================
local Fly = {
    Enabled = false,
    Attachment = nil,
    Velocity = nil,
    Align = nil,
    Humanoid = nil,
    Root = nil,
}

local function setupFlyPhysics()
    local char = Player.Character or Player.CharacterAdded:Wait()
    Fly.Humanoid = char:WaitForChild("Humanoid")
    Fly.Root = char:WaitForChild("HumanoidRootPart")
    
    if Fly.Enabled then
        if Fly.Attachment then Fly.Attachment:Destroy() end
        Fly.Humanoid.PlatformStand = true
        
        Fly.Attachment = Instance.new("Attachment", Fly.Root)
        Fly.Velocity = Instance.new("LinearVelocity", Fly.Attachment)
        Fly.Velocity.MaxForce = 9e9
        Fly.Velocity.VectorVelocity = Vector3.zero
        Fly.Velocity.Attachment0 = Fly.Attachment
        
        Fly.Align = Instance.new("AlignOrientation", Fly.Attachment)
        Fly.Align.MaxTorque = 9e9
        Fly.Align.Responsiveness = 200
        Fly.Align.Mode = Enum.OrientationAlignmentMode.OneAttachment
        Fly.Align.Attachment0 = Fly.Attachment
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
    if Fly.Enabled and Fly.Root and Camera and Fly.Velocity and Fly.Align then
        local moveVector = Controls:GetMoveVector()
        local speed = getgenv().Options.FlySpeed and getgenv().Options.FlySpeed.Value or 80
        
        if moveVector.Magnitude > 0 then
            Fly.Velocity.VectorVelocity = (Camera.CFrame.LookVector * -moveVector.Z + Camera.CFrame.RightVector * moveVector.X).Unit * speed
        else
            Fly.Velocity.VectorVelocity = Vector3.zero
        end
        
        Fly.Align.CFrame = Camera.CFrame
    end
end)

local function EnableFly()
    Fly.Enabled = true
    setupFlyPhysics()
end

local function DisableFly()
    Fly.Enabled = false
    
    if Fly.Humanoid then Fly.Humanoid.PlatformStand = false end
    if Fly.Attachment then Fly.Attachment:Destroy() end
    
    Fly.Attachment = nil
    Fly.Velocity = nil
    Fly.Align = nil
end

--========================
-- INFINITE JUMP SYSTEM
--========================
local InfiniteJump = {
    Enabled = false,
    Connection = nil,
}

local function EnableInfiniteJump()
    if InfiniteJump.Enabled then return end
    InfiniteJump.Enabled = true
    
    InfiniteJump.Connection = UIS.JumpRequest:Connect(function()
        if not InfiniteJump.Enabled then return end
        
        local char = Player.Character
        if not char then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function DisableInfiniteJump()
    InfiniteJump.Enabled = false
    
    if InfiniteJump.Connection then
        InfiniteJump.Connection:Disconnect()
        InfiniteJump.Connection = nil
    end
end

--========================
-- NOCLIP SYSTEM
--========================
local Noclip = {
    Enabled = false,
    Connection = nil,
}

local function EnableNoclip()
    if Noclip.Enabled then return end
    Noclip.Enabled = true
    
    Noclip.Connection = RunService.Stepped:Connect(function()
        if not Noclip.Enabled then return end
        
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
    Noclip.Enabled = false
    
    if Noclip.Connection then
        Noclip.Connection:Disconnect()
        Noclip.Connection = nil
    end
end

--========================
-- ESP SYSTEM
--========================
local ESP = {
    Enabled = false,
    Objects = {},
    Connection = nil,
}

local function newDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function createESPElements()
    local elements = {}
    local toggles = getgenv().Toggles
    local options = getgenv().Options
    
    if toggles.EspBoxes and toggles.EspBoxes.Value then
        if toggles.EspBoxOutline and toggles.EspBoxOutline.Value then
            elements.BoxOutline = newDrawing("Square", {
                Visible = false, Thickness = 3, Filled = false, Color = Color3.new(0, 0, 0)
            })
        end
        elements.Box = newDrawing("Square", {
            Visible = false, Thickness = 1.5, Filled = false,
            Color = options.EspBoxColor and options.EspBoxColor.Value or Color3.fromRGB(0, 150, 255)
        })
    end
    
    if toggles.EspNames and toggles.EspNames.Value then
        elements.Name = newDrawing("Text", {
            Visible = false, Center = true, Outline = true,
            OutlineColor = Color3.new(0, 0, 0), Size = 13, Font = 2,
            Color = options.EspNameColor and options.EspNameColor.Value or Color3.new(1, 1, 1)
        })
    end
    
    if toggles.EspHealth and toggles.EspHealth.Value then
        elements.HealthBarBG = newDrawing("Line", {
            Visible = false, Thickness = 5, Color = Color3.new(0, 0, 0)
        })
        elements.HealthBar = newDrawing("Line", {
            Visible = false, Thickness = 3,
            Color = options.EspHealthColor and options.EspHealthColor.Value or Color3.new(0, 1, 0)
        })
    end
    
    if toggles.EspDistance and toggles.EspDistance.Value then
        elements.Distance = newDrawing("Text", {
            Visible = false, Center = true, Outline = true,
            OutlineColor = Color3.new(0, 0, 0), Size = 11, Font = 2,
            Color = options.EspDistanceColor and options.EspDistanceColor.Value or Color3.new(1, 1, 1)
        })
    end
    
    if toggles.EspHealthNumber and toggles.EspHealthNumber.Value then
        elements.HealthNumber = newDrawing("Text", {
            Visible = false, Center = true, Outline = true,
            OutlineColor = Color3.new(0, 0, 0), Size = 11, Font = 2,
            Color = options.EspHealthNumberColor and options.EspHealthNumberColor.Value or Color3.new(1, 1, 1)
        })
    end
    
    if toggles.EspTracers and toggles.EspTracers.Value then
        elements.Tracer = newDrawing("Line", {
            Visible = false, Thickness = 1,
            Color = options.EspTracerColor and options.EspTracerColor.Value or Color3.fromRGB(0, 150, 255)
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
    if not character then return end
    local options = getgenv().Options
    
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
            part.Color = options.EspChamsColor and options.EspChamsColor.Value or Color3.fromRGB(0, 150, 255)
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
    if not ESP.Enabled then
        for _, data in pairs(ESP.Objects) do
            hideAll(data)
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Player then continue end
        
        if isTeammate(player) then
            if ESP.Objects[player] then hideAll(ESP.Objects[player]) end
            if player.Character then removeChams(player.Character) end
            continue
        end
        
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if character and humanoid and humanoid.Health > 0 then
            if getgenv().Toggles.EspChams and getgenv().Toggles.EspChams.Value then
                applyChams(character)
            else
                removeChams(character)
            end
            
            local success, cframe, size = pcall(character.GetBoundingBox, character)
            
            if success and cframe and size then
                local points, visible = getBoxScreenPoints(cframe, size)
                
                if not visible then
                    if ESP.Objects[player] then hideAll(ESP.Objects[player]) end
                else
                    local data = ESP.Objects[player] or createESPElements()
                    ESP.Objects[player] = data
                    
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
                    
                    if data.BoxOutline and getgenv().Toggles.EspBoxes.Value and getgenv().Toggles.EspBoxOutline.Value then
                        data.BoxOutline.Visible = true
                        data.BoxOutline.Position = Vector2.new(slimX - 1, minY - 1)
                        data.BoxOutline.Size = Vector2.new(slimWidth + 2, boxHeight + 2)
                    end
                    
                    if data.Box and getgenv().Toggles.EspBoxes.Value then
                        data.Box.Visible = true
                        data.Box.Position = Vector2.new(slimX, minY)
                        data.Box.Size = Vector2.new(slimWidth, boxHeight)
                    end
                    
                    if data.Name and getgenv().Toggles.EspNames.Value then
                        data.Name.Visible = true
                        data.Name.Text = player.Name
                        data.Name.Position = Vector2.new(slimX + slimWidth / 2, minY - 16)
                    end
                    
                    if data.HealthBarBG and getgenv().Toggles.EspHealth.Value then
                        data.HealthBarBG.Visible = true
                        data.HealthBarBG.From = Vector2.new(slimX - 6, maxY)
                        data.HealthBarBG.To = Vector2.new(slimX - 6, minY)
                    end
                    
                    if data.HealthBar and getgenv().Toggles.EspHealth.Value then
                        data.HealthBar.Visible = true
                        
                        if healthRatio > 0.7 then
                            data.HealthBar.Color = getgenv().Options.EspHealthColor and getgenv().Options.EspHealthColor.Value or Color3.fromRGB(0, 255, 0)
                        elseif healthRatio > 0.3 then
                            data.HealthBar.Color = Color3.fromRGB(255, 165, 0)
                        else
                            data.HealthBar.Color = Color3.fromRGB(255, 0, 0)
                        end
                        
                        data.HealthBar.From = Vector2.new(slimX - 6, maxY)
                        data.HealthBar.To = Vector2.new(slimX - 6, maxY - (boxHeight * healthRatio))
                    end
                    
                    if data.Distance and getgenv().Toggles.EspDistance.Value and head then
                        local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            local dist = math.floor((myRoot.Position - head.Position).Magnitude)
                            data.Distance.Visible = true
                            data.Distance.Text = dist .. "m"
                            data.Distance.Position = Vector2.new(slimX + slimWidth / 2, maxY + 4)
                        end
                    end
                    
                    if data.HealthNumber and getgenv().Toggles.EspHealthNumber.Value then
                        data.HealthNumber.Visible = true
                        data.HealthNumber.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                        data.HealthNumber.Position = Vector2.new(slimX + slimWidth / 2, maxY + 16)
                    end
                    
                    if data.Tracer and getgenv().Toggles.EspTracers.Value then
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
        else
            if ESP.Objects[player] then hideAll(ESP.Objects[player]) end
            if character then removeChams(character) end
        end
    end
end

local function EnableESP()
    ESP.Enabled = true
    if ESP.Connection then ESP.Connection:Disconnect() end
    ESP.Connection = RunService.RenderStepped:Connect(updateESP)
end

local function DisableESP()
    ESP.Enabled = false
    
    if ESP.Connection then
        ESP.Connection:Disconnect()
        ESP.Connection = nil
    end
    
    for _, data in pairs(ESP.Objects) do
        pcall(function()
            for _, obj in pairs(data) do
                if obj and obj.Remove then obj:Remove() end
            end
        end)
    end
    
    ESP.Objects = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            removeChams(player.Character)
        end
    end
end

local function RefreshESP()
    if ESP.Enabled then
        DisableESP()
        EnableESP()
    end
end

Players.PlayerRemoving:Connect(function(player)
    if ESP.Objects[player] then
        for _, obj in pairs(ESP.Objects[player]) do
            pcall(function()
                if obj and obj.Remove then obj:Remove() end
            end)
        end
        ESP.Objects[player] = nil
    end
end)

--========================
-- ANIMATION SYSTEM
--========================
local Animation = {
    Enabled = false,
    ID = "",
    Loop = true,
    Speed = 2,
    Tracks = {},
}

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
    for _, track in ipairs(Animation.Tracks) do
        pcall(function()
            track:Stop(0)
            track:Destroy()
        end)
    end
    Animation.Tracks = {}
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
    
    if not Animation.Enabled or Animation.ID == "" then return end
    
    local char = Player.Character
    if char then
        local t = playAnimOnChar(char, Animation.ID, Animation.Speed, Animation.Loop)
        if t then table.insert(Animation.Tracks, t) end
    end
    
    local live = Workspace:FindFirstChild("Live")
    if live then
        local sc = live:FindFirstChild(Player.Name)
        if sc then
            local st = playAnimOnChar(sc, Animation.ID, Animation.Speed, Animation.Loop)
            if st then table.insert(Animation.Tracks, st) end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not Animation.Enabled then return end
    if #Animation.Tracks == 0 and Animation.ID ~= "" then
        playAnimation()
    end
    
    for _, track in ipairs(Animation.Tracks) do
        pcall(function()
            track:AdjustSpeed(Animation.Speed)
        end)
    end
end)

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Animation.Enabled then
        playAnimation()
    end
end)

--========================
-- CREATE UI ELEMENTS
--========================

-- COMBAT TAB
local RagebotToggle = AimbotGroup:AddToggle('RagebotToggle', {
    Text = 'Ragebot',
    Default = false,
    Tooltip = 'Aimbot that locks onto enemies',
})

RagebotToggle:OnChanged(function(Value)
    if Value then
        EnableRagebot()
    else
        DisableRagebot()
    end
end)

RagebotToggle:AddKeyPicker('RagebotKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Ragebot',
    NoUI = false,
})

local AutoShootToggle = AimbotGroup:AddToggle('AutoShootToggle', {
    Text = 'Auto Shoot',
    Default = false,
    Tooltip = 'Automatically shoots enemies',
})

AutoShootToggle:OnChanged(function(Value)
    if Value then
        EnableAutoShoot()
    else
        DisableAutoShoot()
    end
end)

AimbotGroup:AddDivider()

local ShootDelaySlider = AimbotGroup:AddSlider('AutoShootDelay', {
    Text = 'Shoot Delay',
    Default = 0.1,
    Min = 0.0005,
    Max = 5,
    Rounding = 4,
    Suffix = 's',
})

local RapidFireToggle = TriggerGroup:AddToggle('RapidFireToggle', {
    Text = 'Rapid Fire',
    Default = false,
    Tooltip = 'Removes weapon cooldowns',
})

RapidFireToggle:OnChanged(function(Value)
    if Value then
        EnableRapidFire()
    else
        DisableRapidFire()
    end
end)

-- VISUALS TAB
local EspToggle = ESPSettingsGroup:AddToggle('EspEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Tooltip = 'Master ESP toggle',
})

EspToggle:OnChanged(function(Value)
    if Value then
        EnableESP()
    else
        DisableESP()
    end
end)

ESPSettingsGroup:AddDivider()

local EspBoxesToggle = ESPSettingsGroup:AddToggle('EspBoxes', {
    Text = 'Box ESP',
    Default = true,
})

EspBoxesToggle:OnChanged(function()
    RefreshESP()
end)

local EspBoxOutlineToggle = ESPSettingsGroup:AddToggle('EspBoxOutline', {
    Text = 'Box Outline',
    Default = true,
})

EspBoxOutlineToggle:OnChanged(function()
    RefreshESP()
end)

local EspHealthToggle = ESPSettingsGroup:AddToggle('EspHealth', {
    Text = 'Health Bar',
    Default = true,
})

EspHealthToggle:OnChanged(function()
    RefreshESP()
end)

local EspNamesToggle = ESPSettingsGroup:AddToggle('EspNames', {
    Text = 'Name ESP',
    Default = true,
})

EspNamesToggle:OnChanged(function()
    RefreshESP()
end)

local EspDistanceToggle = ESPSettingsGroup:AddToggle('EspDistance', {
    Text = 'Distance ESP',
    Default = false,
})

EspDistanceToggle:OnChanged(function()
    RefreshESP()
end)

local EspHealthNumberToggle = ESPSettingsGroup:AddToggle('EspHealthNumber', {
    Text = 'Health Number',
    Default = false,
})

EspHealthNumberToggle:OnChanged(function()
    RefreshESP()
end)

local EspTracersToggle = ESPSettingsGroup:AddToggle('EspTracers', {
    Text = 'Tracer ESP',
    Default = false,
})

EspTracersToggle:OnChanged(function()
    RefreshESP()
end)

local EspChamsToggle = ESPVisualsGroup:AddToggle('EspChams', {
    Text = 'Chams',
    Default = false,
    Tooltip = 'Makes enemies visible through walls',
})

EspChamsToggle:OnChanged(function()
    RefreshESP()
end)

-- ESP Colors
local EspBoxColor = ESPColorsGroup:AddColorPicker('EspBoxColor', {
    Title = 'Box Color',
    Default = Color3.fromRGB(0, 150, 255),
})

EspBoxColor:OnChanged(function()
    RefreshESP()
end)

local EspNameColor = ESPColorsGroup:AddColorPicker('EspNameColor', {
    Title = 'Name Color',
    Default = Color3.fromRGB(255, 255, 255),
})

EspNameColor:OnChanged(function()
    RefreshESP()
end)

local EspHealthColor = ESPColorsGroup:AddColorPicker('EspHealthColor', {
    Title = 'Health Color',
    Default = Color3.fromRGB(0, 255, 0),
})

EspHealthColor:OnChanged(function()
    RefreshESP()
end)

local EspDistanceColor = ESPColorsGroup:AddColorPicker('EspDistanceColor', {
    Title = 'Distance Color',
    Default = Color3.fromRGB(255, 255, 255),
})

EspDistanceColor:OnChanged(function()
    RefreshESP()
end)

local EspHealthNumberColor = ESPColorsGroup:AddColorPicker('EspHealthNumberColor', {
    Title = 'Health Number Color',
    Default = Color3.fromRGB(255, 255, 255),
})

EspHealthNumberColor:OnChanged(function()
    RefreshESP()
end)

local EspChamsColor = ESPColorsGroup:AddColorPicker('EspChamsColor', {
    Title = 'Chams Color',
    Default = Color3.fromRGB(0, 150, 255),
})

EspChamsColor:OnChanged(function()
    RefreshESP()
end)

local EspTracerColor = ESPColorsGroup:AddColorPicker('EspTracerColor', {
    Title = 'Tracer Color',
    Default = Color3.fromRGB(0, 150, 255),
})

EspTracerColor:OnChanged(function()
    RefreshESP()
end)

-- MOVEMENT TAB
local FlyToggle = FlyGroup:AddToggle('FlyToggle', {
    Text = 'Enable Fly',
    Default = false,
})

FlyToggle:OnChanged(function(Value)
    if Value then
        EnableFly()
    else
        DisableFly()
    end
end)

FlyToggle:AddKeyPicker('FlyKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Fly',
    NoUI = false,
})

local FlySpeedSlider = FlyGroup:AddSlider('FlySpeed', {
    Text = 'Fly Speed',
    Default = 80,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Suffix = ' studs/s',
})

local InfiniteJumpToggle = MovementModsGroup:AddToggle('InfiniteJumpToggle', {
    Text = 'Infinite Jump',
    Default = false,
})

InfiniteJumpToggle:OnChanged(function(Value)
    if Value then
        EnableInfiniteJump()
    else
        DisableInfiniteJump()
    end
end)

local NoclipToggle = MovementModsGroup:AddToggle('NoclipToggle', {
    Text = 'Noclip',
    Default = false,
})

NoclipToggle:OnChanged(function(Value)
    if Value then
        EnableNoclip()
    else
        DisableNoclip()
    end
end)

-- ANIMATION TAB
local AnimationToggle = AnimControlGroup:AddToggle('AnimationEnabled', {
    Text = 'Enable Animation',
    Default = false,
})

AnimationToggle:OnChanged(function(Value)
    Animation.Enabled = Value
    if Value then
        local presetId = animPresets[getgenv().Options.AnimationPreset and getgenv().Options.AnimationPreset.Value or "Underground Glitch"]
        if presetId then Animation.ID = presetId end
        Animation.Speed = getgenv().Options.AnimationSpeed and getgenv().Options.AnimationSpeed.Value or 2
        Animation.Loop = true
        playAnimation()
    else
        stopAllAnims()
    end
end)

local AnimationSpeed = AnimControlGroup:AddSlider('AnimationSpeed', {
    Text = 'Animation Speed',
    Default = 2,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Suffix = 'x',
})

AnimationSpeed:OnChanged(function(Value)
    Animation.Speed = Value
end)

local AnimationPreset = AnimPresetsGroup:AddDropdown('AnimationPreset', {
    Text = 'Animation Preset',
    Default = 'Underground Glitch',
    Values = {
        'Underground Glitch', 'Orbit', 'Tweaking', 'Kicking Feet',
        'Low Cortisol', 'Floss', 'Take the L', 'Upside Down',
        'Michael Myers Shake', 'Headless', 'Wall Peek L', 'Glitch Through',
        'Spin',
    },
})

AnimationPreset:OnChanged(function(Value)
    local presetId = animPresets[Value]
    if presetId then
        Animation.ID = presetId
        if Animation.Enabled then
            playAnimation()
        end
    end
end)

-- SETTINGS TAB
ConfigGroup:AddButton('Save Config', function()
    SaveManager:Save()
    Library:Notify('Configuration saved!', 3)
end)

ConfigGroup:AddButton('Load Config', function()
    local data = SaveManager:Load()
    if data then
        for idx, toggle in pairs(getgenv().Toggles) do
            if data[idx] ~= nil and type(idx) == 'string' then
                pcall(function()
                    toggle:SetValue(data[idx])
                end)
            end
        end
        
        for idx, option in pairs(getgenv().Options) do
            if data[idx] ~= nil and type(idx) == 'string' then
                pcall(function()
                    if option.Type == 'Slider' or option.Type == 'Dropdown' then
                        option:SetValue(data[idx])
                    elseif option.Type == 'ColorPicker' then
                        local col = data[idx]
                        if type(col) == 'table' and col[1] and col[2] and col[3] then
                            option:SetValueRGB(Color3.new(col[1], col[2], col[3]))
                        end
                    end
                end)
            end
        end
        
        Library:Notify('Configuration loaded!', 3)
    else
        Library:Notify('No config found!', 3)
    end
end)

InfoGroup:AddLabel('Oishi Hub V1.02', true)
InfoGroup:AddLabel('Made with Linoria UI', true)
InfoGroup:AddLabel('Press RightShift to toggle', true)

--========================
-- LOAD SAVED SETTINGS
--========================
local savedData = SaveManager:Load()
if savedData then
    task.spawn(function()
        task.wait(0.5)
        
        for idx, toggle in pairs(getgenv().Toggles) do
            if savedData[idx] ~= nil and type(idx) == 'string' then
                pcall(function()
                    toggle:SetValue(savedData[idx])
                end)
            end
        end
        
        for idx, option in pairs(getgenv().Options) do
            if savedData[idx] ~= nil and type(idx) == 'string' then
                pcall(function()
                    if option.Type == 'Slider' or option.Type == 'Dropdown' then
                        option:SetValue(savedData[idx])
                    elseif option.Type == 'ColorPicker' then
                        local col = savedData[idx]
                        if type(col) == 'table' and col[1] and col[2] and col[3] then
                            option:SetValueRGB(Color3.new(col[1], col[2], col[3]))
                        end
                    end
                end)
            end
        end
    end)
end

--========================
-- AUTO-SAVE
--========================
task.spawn(function()
    while true do
        task.wait(30)
        SaveManager:Save()
    end
end)

-- Set keybind
Library.ToggleKeybind = 'RightShift'

print('[Oishi Hub V1.02] Loaded with Linoria UI!')
