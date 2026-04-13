--// LOAD UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Godz Hub Legit",
    LoadingTitle = "Godz Hub",
    LoadingSubtitle = "Safe Mode",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GodzHub",
        FileName = "Legit"
    }
})

--// TABS
local Combat = Window:CreateTab("Combat")
local Farm = Window:CreateTab("Farm")
local PlayerTab = Window:CreateTab("Player")

--// SERVICES
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

--// SETTINGS
local Settings = {
    AutoHit = false,
    AutoHeal = false,
    AutoFarm = false
}

--// CHAR
local function Char() return LocalPlayer.Character end
local function Root() return Char() and Char():FindFirstChild("HumanoidRootPart") end
local function Hum() return Char() and Char():FindFirstChildOfClass("Humanoid") end

--// TOOL
local function GetTool()
    return Char() and Char():FindFirstChildOfClass("Tool")
end

--------------------------------------------------
-- ⚔️ AUTO HIT (LEGIT)
--------------------------------------------------
local function AutoHit()
    local tool = GetTool()
    local root = Root()

    if not tool or not root then return end

    for _,v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            local hum = v.Character:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local dist = (root.Position - hrp.Position).Magnitude

                if dist < 10 then
                    tool:Activate() -- legit swing
                    task.wait(0.3) -- human delay
                end
            end
        end
    end
end

--------------------------------------------------
-- 🍎 AUTO HEAL (LEGIT)
--------------------------------------------------
local function AutoHeal()
    local hum = Hum()
    if not hum then return end

    if hum.Health < 50 then
        for _,item in pairs(LocalPlayer.Backpack:GetChildren()) do
            if item.Name:lower():find("fruit") then
                hum:EquipTool(item)
                item:Activate()
                task.wait(1)
            end
        end
    end
end

--------------------------------------------------
-- 🧭 WALK TO POSITION (NO TP)
--------------------------------------------------
local function WalkTo(pos)
    local char = Char()
    local hum = Hum()

    if not char or not hum then return end

    local path = PathfindingService:CreatePath()
    path:ComputeAsync(char.PrimaryPart.Position, pos)

    local waypoints = path:GetWaypoints()

    for _,waypoint in pairs(waypoints) do
        hum:MoveTo(waypoint.Position)
        hum.MoveToFinished:Wait()
    end
end

--------------------------------------------------
-- ⛏️ AUTO FARM (WALK + HIT)
--------------------------------------------------
local function AutoFarm()
    local root = Root()
    local tool = GetTool()

    if not root or not tool then return end

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("gold") then

            local dist = (root.Position - v.Position).Magnitude

            if dist > 15 then
                WalkTo(v.Position)
            end

            if (root.Position - v.Position).Magnitude < 12 then
                tool:Activate()
                task.wait(0.4)
            end
        end
    end
end

--------------------------------------------------
-- UI
--------------------------------------------------

Combat:CreateToggle({
    Name = "Auto Hit (Legit)",
    Callback = function(v) Settings.AutoHit = v end
})

Combat:CreateToggle({
    Name = "Auto Heal",
    Callback = function(v) Settings.AutoHeal = v end
})

Farm:CreateToggle({
    Name = "Auto Farm Gold (Walk)",
    Callback = function(v) Settings.AutoFarm = v end
})

--------------------------------------------------
-- LOOP
--------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        
        if Settings.AutoHit then
            pcall(AutoHit)
        end
        
        if Settings.AutoHeal then
            pcall(AutoHeal)
        end
        
        if Settings.AutoFarm then
            pcall(AutoFarm)
        end

    end
end)

print("LEGIT SYSTEM LOADED")
