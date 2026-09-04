local repS = cloneref(game:GetService("ReplicatedStorage"))
local plrs = cloneref(game:GetService("Players"))
local runS = cloneref(game:GetService("RunService"))
local ws = cloneref(game:GetService("Workspace"))
local uis = cloneref(game:GetService("UserInputService"))
local lplr = plrs.LocalPlayer
local util = require(repS.Modules.Utility)
local enum = require(repS.Modules.EnumLibrary)
local FighterController = require(lplr.PlayerScripts.Controllers.FighterController)
local SpectateController = require(lplr.PlayerScripts.Controllers:WaitForChild("SpectateController"))

-- Bypass/Modify Item Library Cooldowns for ultra-fast shooting
spawn(function()
    wait(1)
    local ItemLibrary = require(repS.Modules.ItemLibrary)
    local function scan(tbl)
        for _, v in tbl do
            if typeof(v) == "table" then
                if v.ShootCooldown ~= nil then
                    v.ShootCooldown = 0.000000000000000001
                end
                if v.BurstCooldown ~= nil then
                    v.BurstCooldown = 0.000000000000000001
                end
                if v.AttackCooldown ~= nil then
                    v.AttackCooldown = 0.000000000000000001
                end
                if v.HeavyAttackCooldown ~= nil then
                    v.HeavyAttackCooldown = 0.000000000000000001
                end
                scan(v)
            end
        end
    end
    scan(ItemLibrary)
end)

getgenv().Config = {
    Enabled = true,
    FireRate = 0.0005,
    WeaponSlot = "Melee" -- Left in config for reference, but auto-equip is disabled
}

local slots = {
    Primary = 1,
    Secondary = 2,
    Melee = 3
}

local function getSlotNumber()
    return slots[getgenv().Config.WeaponSlot] or 3
end

-- [AUTO-EQUIP LOOPS REMOVED HERE SO IT WONT FORCE SWITCH WEAPONS]

local lastFire = 0
local deflecting = {}
local isWaitingAfterDeath = false
local waitStartTime = 0
local WAIT_DURATION = 5.5 -- 5.5 seconds wait after death/reset

plrs.PlayerRemoving:Connect(function(player)
    deflecting[player] = nil
end)

-- Death/Reset detection
local function checkDeathOrReset()
    local character = lplr.Character
    if not character then
        return true -- Character doesn't exist (dead or respawning)
    end
    
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        return true -- No humanoid found
    end
    
    if humanoid.Health <= 0 then
        return true -- Dead
    end
    
    return false -- Alive and well
end

-- Monitor for death/reset
lplr.CharacterAdded:Connect(function(character)
    -- When character respawns, start waiting
    isWaitingAfterDeath = true
    waitStartTime = tick()
    lastFire = tick() -- Reset fire timer
    print("Death/Reset detected! Waiting 5.5 seconds before teleport and auto shoot...")
end)

-- Also check for death while character exists
spawn(function()
    while true do
        wait(0.1)
        if not isWaitingAfterDeath and checkDeathOrReset() then
            isWaitingAfterDeath = true
            waitStartTime = tick()
            lastFire = tick() -- Reset fire timer
            print("Death/Reset detected! Waiting 5.5 seconds before teleport and auto shoot...")
        end
    end
end)

local function updateDeflection()
    if not FighterController or not FighterController.Objects then return end
    for _, fighterObj in FighterController.Objects do
        local player = fighterObj.Player
        if not player then continue end
        if not fighterObj.Entity or not fighterObj.Entity:IsAlive() or fighterObj:Get("IsSpectating") then
            deflecting[player] = false
            continue
        end
        local equipped = fighterObj.EquippedItem
        local isKatana = equipped and equipped.ViewModel and equipped.ViewModel.Name == "Katana"
        local isDeflecting = false
        if isKatana then
            isDeflecting = (equipped._attack_cooldown and equipped._attack_cooldown > tick()) or false
        end
        deflecting[player] = isDeflecting
    end
end

local function isEnemy(player)
    if player == lplr then return false end
    local duel = SpectateController.CurrentDuelSubject
    local localDueler = duel and duel:GetDueler(lplr)
    local localTeam = localDueler and localDueler:Get("TeamID") or nil
    if localTeam and duel and duel.Duelers then
        for _, dueler in duel.Duelers do
            if dueler.Player == player then
                local team = dueler:Get("TeamID")
                return team ~= localTeam
            end
        end
    end
    local pTeam = player:GetAttribute("TeamID")
    local lTeam = lplr:GetAttribute("TeamID")
    if pTeam and lTeam then
        return pTeam ~= lTeam
    end
    return true
end

local function getClosestTarget()
    local char = lplr.Character
    if not char then return nil, nil, nil end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil, nil, nil end
    local closestPlayer = nil
    local closestRoot = nil
    local closestHead = nil
    local closestDist = 500
    for _, player in plrs:GetPlayers() do
        if not isEnemy(player) then continue end
        local pChar = player.Character
        if not pChar then continue end
        local pRoot = pChar:FindFirstChild("HumanoidRootPart")
        local pHead = pChar:FindFirstChild("Head")
        local pHum = pChar:FindFirstChildWhichIsA("Humanoid")
        if not (pRoot and pHead and pHum and pHum.Health > 0) then continue end
        local dist = (myRoot.Position - pRoot.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestPlayer = player
            closestRoot = pRoot
            closestHead = pHead
        end
    end
    return closestPlayer, closestRoot, closestHead
end

local function hasKnifeViewModel(targetPlayer)
    if not targetPlayer then return false end
    local viewModels = ws:FindFirstChild("ViewModels")
    if not viewModels then return false end
    local targetName = targetPlayer.Name
    for _, model in viewModels:GetChildren() do
        if model:IsA("Model") 
           and string.find(model.Name, targetName, 1, true) 
           and string.find(model.Name, "Knife", 1, true) then
            return true
        end
    end
    return false
end

runS.Heartbeat:Connect(function()
    -- Check if we're in waiting period
    if isWaitingAfterDeath then
        if tick() - waitStartTime >= WAIT_DURATION then
            isWaitingAfterDeath = false
            lastFire = tick() -- Reset fire timer when wait is over
            print("Wait period over, resuming teleport and auto shoot...")
        else
            return -- Skip ALL processing (both teleport AND shooting) during wait period
        end
    end
    
    updateDeflection()
    local targetPlayer, targetRoot, targetHead = getClosestTarget()
    local desyncCF = nil
    
    if targetRoot and targetHead then
        local desyncPos
        if hasKnifeViewModel(targetPlayer) then
            desyncPos = (targetRoot.CFrame * CFrame.new(0, 6, 0)).Position
        else
            -- Changed to 2.8 studs above and 1 stud behind the enemy's RootPart
            desyncPos = (targetRoot.CFrame * CFrame.new(0, 2.8, 1)).Position
        end
        desyncCF = CFrame.lookAt(desyncPos, targetHead.Position)
    end

    if desyncCF and lplr.Character then
        local myRoot = lplr.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local oldCF = myRoot.CFrame
            local oldVel = myRoot.Velocity
            local oldRotVel = myRoot.RotVelocity
            myRoot.CFrame = desyncCF
            runS:BindToRenderStep("__restore", 101, function()
                if myRoot then
                    myRoot.CFrame = oldCF
                    myRoot.Velocity = oldVel
                    myRoot.RotVelocity = oldRotVel
                end
                runS:UnbindFromRenderStep("__restore")
            end)
        end
    end

    if not getgenv().Config.Enabled then return end
    if not targetPlayer or not targetHead or not targetRoot then return end
    if deflecting[targetPlayer] then return end
    if not lplr.Character or not lplr.Character:FindFirstChild("HumanoidRootPart") then return end
    if not FighterController or not FighterController.LocalFighter then return end
    local item = FighterController.LocalFighter.EquippedItem
    if not item then return end
    if tick() - lastFire < getgenv().Config.FireRate then return end
    lastFire = tick()
    local originPos = desyncCF and desyncCF.Position or targetRoot.Position
    local targetPos = targetHead.Position
    local aimCF = CFrame.lookAt(originPos, targetPos)
    local targetCF = targetHead.CFrame
    local randomOffset = Vector3.new(
        (math.random() - 0.5) * 0.1,
        (math.random() - 0.5) * 0.1,
        (math.random() - 0.5) * 0.1
    )
    local aimedPos = targetPos + randomOffset
    local objSpaceHeadOffset = targetHead.CFrame:ToObjectSpace(CFrame.new(aimedPos))
    local cameradata = {}
    cameradata[utf8.char(1)] = {
        [utf8.char(0)] = util:EncodeCFrame(aimCF),
        [utf8.char(1)] = util:EncodeCFrame(targetCF),
        [utf8.char(2)] = targetHead,
        [utf8.char(3)] = util:EncodeCFrame(objSpaceHeadOffset)
    }
    repS.Remotes.Replication.Fighter.UseItem:FireServer(
        item:Get("ObjectID"),
        enum:ToEnum("StartShooting"),
        cameradata,
        nil
    )
end)
