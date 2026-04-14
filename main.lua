local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Variables \\
local AimEnabled = false
local AimPart = "Head"
local HitChance = 100
local WallCheck = true
local FOVRadius = 150

local ESPEnabled = false
local TeamCheck = true

-- // FOV Circle Setup \\
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = FOVRadius
FOVCircle.Filled = false
FOVCircle.Visible = true
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- // UI Window \\
local Window = Rayfield:CreateWindow({
   Name = "Counter Blox Hub",
   LoadingTitle = "Initializing...",
   ConfigurationSaving = { Enabled = true, FolderName = "CB_Final" }
})

-- // Tabs \\
local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visuals")

-- // Combat UI \\
CombatTab:CreateToggle({
   Name = "Master Aimbot",
   CurrentValue = false,
   Callback = function(Value) AimEnabled = Value end,
})

CombatTab:CreateDropdown({
   Name = "Target Priority",
   Options = {"Head", "LowerTorso"},
   CurrentOption = {"Head"},
   Callback = function(Option) AimPart = Option[1] end,
})

CombatTab:CreateSlider({
   Name = "Hit Chance",
   Range = {0, 100},
   Increment = 1,
   CurrentValue = 100,
   Callback = function(Value) HitChance = Value end,
})

CombatTab:CreateSlider({
   Name = "FOV Radius",
   Range = {50, 800},
   Increment = 5,
   CurrentValue = 150,
   Callback = function(Value) 
      FOVRadius = Value
      FOVCircle.Radius = Value 
   end,
})

CombatTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Callback = function(Value) WallCheck = Value end,
})

-- // Visuals UI \\
VisualTab:CreateToggle({
   Name = "Highlight ESP",
   CurrentValue = false,
   Callback = function(Value) ESPEnabled = Value end,
})

VisualTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = true,
   Callback = function(Value) TeamCheck = Value end,
})

--- // Logic Functions \\ ---

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Check if player is behind a wall
local function IsVisible(targetPart)
    if not WallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local rayResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
    return rayResult and rayResult.Instance:IsDescendantOf(targetPart.Parent)
end

-- Find best target
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(AimPart) then
            if not TeamCheck or v.Team ~= LocalPlayer.Team then
                local part = v.Character[AimPart]
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                
                if onScreen and IsVisible(part) then
                    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    
                    if distance < FOVRadius and distance < shortestDistance then
                        target = part
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return target
end

-- Handle ESP Updates
local function ManageESP()
    for _, player in pairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local highlight = char:FindFirstChild("TargetESP")
            
            if ESPEnabled then
                if (not TeamCheck or player.Team ~= LocalPlayer.Team) and player ~= LocalPlayer then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "TargetESP"
                        highlight.Parent = char
                    end
                    highlight.FillColor = (player.Team.Name == "Terrorists") and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 50, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                elseif highlight then
                    highlight:Destroy()
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

--- // Main Loop \\ ---
game:GetService("RunService").RenderStepped:Connect(function()
    -- Update FOV Circle Position
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = AimEnabled -- Only show circle if aim is on

    -- Run Aimbot
    if AimEnabled then
        local target = GetClosestPlayer()
        if target and math.random(1, 100) <= HitChance then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
    
    -- Update ESP
    ManageESP()
end)

Rayfield:Notify({
   Title = "Success",
   Content = "Combined Systems Operational",
   Duration = 5
})
