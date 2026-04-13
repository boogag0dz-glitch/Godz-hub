--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// WINDOW
local Window = Rayfield:CreateWindow({
   Name = "Godz Hub V2",
   LoadingTitle = "Godz Hub",
   LoadingSubtitle = "Final Build",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GodzHub",
      FileName = "Config"
   },
   KeySystem = false
})

-- KEYBIND
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(i,g)
    if i.KeyCode == Enum.KeyCode.M then
        Rayfield:Toggle()
    end
end)

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

--// REMOTES
local Events = RS:WaitForChild("Events")
local Swing = Events:WaitForChild("SwingTool")
local Interact = Events:WaitForChild("InteractStructure")
local UseItem = Events:WaitForChild("UseBagItem")
local Consume = Events:WaitForChild("Consume")
local Pickup = Events:WaitForChild("Pickup")
local Swap = Events:WaitForChild("ToolSwapFromBag")
local Target = Events:WaitForChild("TargetAcquire")

--// SETTINGS
local Settings = {
    AutoHit = false,
    AutoHeal = false,
    HealAt = 50,
    HealItem = "Bloodfruit",
    HealSpeed = 0.1,

    GoldFarm = false,
    PlantFarm = false,
    SelectedPlant = "Bloodfruit",

    ESP = false
}

--// FUNCTIONS
local function Char()
    return LocalPlayer.Character
end

local function Root()
    return Char() and Char():FindFirstChild("HumanoidRootPart")
end

local function Hum()
    return Char() and Char():FindFirstChildOfClass("Humanoid")
end

local function Equip(tool)
    pcall(function()
        Swap:FireServer(tool)
    end)
end

--// AUTO HIT
local function AutoHit()
    local root = Root()
    if not root then return end

    Equip("Emerald Blade")

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= Char() then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                if (hrp.Position - root.Position).Magnitude < 15 then
                    Target:FireServer(v)
                    Swing:FireServer(v)
                    break
                end
            end
        end
    end
end

--// WALK
local function WalkTo(pos)
    local char = Char()
    if not char then return end

    local hum = Hum()
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(char.HumanoidRootPart.Position, pos)

    for _, wp in pairs(path:GetWaypoints()) do
        hum:MoveTo(wp.Position)
        hum.MoveToFinished:Wait()
    end
end

--// GOLD FARM
local function GoldFarm()
    Equip("God Pick")

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            
            if v.Name:lower():find("ice") or v.Name:lower():find("gold") then
                
                WalkTo(v.Position)

                for i = 1, 20 do
                    Swing:FireServer(v)
                    task.wait(0.1)
                end
            end
        end
    end
end

--// PLANT FARM
local function PlantFarm()
    Equip("God Hoe")

    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("plantbox") then
            
            pcall(function()
                Interact:FireServer(v, "Harvest")
            end)

            pcall(function()
                Interact:FireServer(v, "Plant", Settings.SelectedPlant)
            end)

            task.wait(0.07)
        end
    end
end

--// AUTO HEAL
local function AutoHeal()
    local hum = Hum()
    if not hum then return end

    if hum.Health <= Settings.HealAt then
        
        pcall(function()
            UseItem:FireServer(Settings.HealItem)
        end)

        pcall(function()
            Consume:FireServer(Settings.HealItem)
        end)
    end
end

--// AUTO COLLECT
local function AutoCollect()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("drop") then
            Pickup:FireServer(v)
        end
    end
end

--// ESP
local ESPs = {}

local function ToggleESP(state)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if state then
                local hl = Instance.new("Highlight")
                hl.Parent = plr.Character
                ESPs[plr] = hl
            else
                if ESPs[plr] then
                    ESPs[plr]:Destroy()
                end
            end
        end
    end
end

--// UI
local Combat = Window:CreateTab("Combat")
local Farm = Window:CreateTab("Farm")
local Visual = Window:CreateTab("Visual")

Combat:CreateToggle({
    Name = "Auto Hit",
    Callback = function(v) Settings.AutoHit = v end
})

Combat:CreateToggle({
    Name = "Auto Heal",
    Callback = function(v) Settings.AutoHeal = v end
})

Combat:CreateSlider({
    Name = "Heal HP",
    Range = {1,99},
    Increment = 1,
    Callback = function(v) Settings.HealAt = v end
})

Farm:CreateToggle({
    Name = "Gold Farm",
    Callback = function(v) Settings.GoldFarm = v end
})

Farm:CreateToggle({
    Name = "Plant Farm",
    Callback = function(v) Settings.PlantFarm = v end
})

Farm:CreateDropdown({
    Name = "Plant Select",
    Options = {"Bloodfruit","Jelly","Lemon","Pumpkin","Blossom","Frostfruit","Carrot"},
    Callback = function(v) Settings.SelectedPlant = v end
})

Visual:CreateToggle({
    Name = "ESP",
    Callback = function(v)
        Settings.ESP = v
        ToggleESP(v)
    end
})

--// LOOP
task.spawn(function()
    while task.wait(0.1) do
        
        if Settings.AutoHit then AutoHit() end
        if Settings.GoldFarm then GoldFarm() end
        if Settings.PlantFarm then PlantFarm() end
        if Settings.AutoHeal then AutoHeal() end

    end
end)
