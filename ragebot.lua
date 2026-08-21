getgenv().Config = {
    HitPart = "Head",
    FOVRadius = 300,
    ShowFOV = true
}

local phem1_plrs = game:GetService("Players")
local phem2_cs = game:GetService("CollectionService")
local phem5 = game:GetService("ReplicatedStorage")
local phem6 = phem1_plrs.LocalPlayer
local phem7 = require(phem5.Modules.Utility)
local phem8 = phem7.Raycast

local phem4 = Drawing.new("Circle")
phem4.Visible = getgenv().Config.ShowFOV
phem4.Radius = getgenv().Config.FOVRadius
phem4.Color = Color3.fromRGB(255, 255, 255)
phem4.Thickness = 1
phem4.Filled = false

game:GetService("RunService").RenderStepped:Connect(function()
    phem4.Position = workspace.CurrentCamera.ViewportSize / 2
    phem4.Radius = getgenv().Config.FOVRadius
    phem4.Visible = getgenv().Config.ShowFOV
end)

local function phem9()
    local phem10 = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
    local phem11 = nil
    local phem12 = getgenv().Config.FOVRadius
    for phem13, phem14 in phem2_cs:GetTagged("Entity") do
        if phem14 == phem6.Character then 
            continue 
        end
        local phem15 = phem14:FindFirstChild(getgenv().Config.HitPart, true)
        if not phem15 or not phem15:IsA("BasePart") then 
            continue 
        end
        local phem16, phem17 = workspace.CurrentCamera:WorldToViewportPoint(phem15.Position)
        if not phem17 then 
            continue 
        end
        local phem18 = (phem10 - Vector2.new(phem16.X, phem16.Y)).Magnitude
        if phem18 < phem12 then
            phem12 = phem18
            phem11 = phem15
        end
    end
    return phem11
end

phem7.Raycast = function(self, phem19, phem20, phem21, phem22, phem23, phem24)
    if type(phem21) ~= "number" or phem21 < 100 then
        return phem8(self, phem19, phem20, phem21, phem22, phem23, phem24)
    end
    local phem25 = phem9()
    if not phem25 then
        return phem8(self, phem19, phem20, phem21, phem22, phem23, phem24)
    end
    local phem26 = phem25.Position
    local phem27 = (phem26 - phem19).Unit
    local phem28 = (phem26 - phem19).Magnitude
    if phem28 > phem21 then
        phem28 = phem21
        phem26 = phem19 + (phem27 * phem21)
    end
    return {
        Position = phem26,
        Distance = phem28,
        Instance = phem25,
        Material = phem25.Material,
        Normal = -phem27
    }
end
