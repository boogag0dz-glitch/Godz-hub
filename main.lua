--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Settings = {
    AutoHeal = false,
    HealAt = 50,
    HealDelay = 0.1,
    HealItem = "Bloodfruit",

    AutoHit = false,
    PvP = false,

    GoldFarm = false,
    PlantFarm = false,
    PlantSpeed = 0.07,

    ESP = false
}

-- CHAR FUNCS
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getRoot() return getChar():FindFirstChild("HumanoidRootPart") end
local function getTool() return getChar():FindFirstChildOfClass("Tool") end

-- WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Godz Hub",
    LoadingTitle = "Godz Hub",
    LoadingSubtitle = "Booga Booga Reborn",
    ConfigurationSaving = {Enabled = true, FolderName = "GodzHub", FileName = "Config"},
    KeySystem = false
})

-- TABS
local Combat = Window:CreateTab("Combat")
local Farm = Window:CreateTab("Farm")
local Visual = Window:CreateTab("Visual")

--------------------------------------------------
-- COMBAT
--------------------------------------------------

Combat:CreateToggle({
    Name = "Auto Heal",
    CurrentValue = false,
    Callback = function(v) Settings.AutoHeal = v end
})

Combat:CreateSlider({
    Name = "Heal HP",
    Range = {1,99},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) Settings.HealAt = v end
})

Combat:CreateSlider({
    Name = "Heal Delay (ms)",
    Range = {1,1000},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(v) Settings.HealDelay = v/1000 end
})

Combat:CreateDropdown({
    Name = "Heal Item",
    Options = {"Bloodfruit","Jelly","Lemon"},
    CurrentOption = "Bloodfruit",
    Callback = function(v) Settings.HealItem = v end
})

Combat:CreateToggle({
    Name = "Auto Hit",
    CurrentValue = false,
    Callback = function(v) Settings.AutoHit = v end
})

Combat:CreateToggle({
    Name = "PvP AI",
    CurrentValue = false,
    Callback = function(v) Settings.PvP = v end
})

--------------------------------------------------
-- FARM
--------------------------------------------------

Farm:CreateToggle({
    Name = "Gold Farm (ICE FIX)",
    CurrentValue = false,
    Callback = function(v) Settings.GoldFarm = v end
})

Farm:CreateToggle({
    Name = "Plant Farm (5x5)",
    CurrentValue = false,
    Callback = function(v) Settings.PlantFarm = v end
})

Farm:CreateSlider({
    Name = "Plant Speed",
    Range = {5,50},
    Increment = 1,
    CurrentValue = 7,
    Callback = function(v) Settings.PlantSpeed = v/100 end
})

--------------------------------------------------
-- VISUAL
--------------------------------------------------

Visual:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(v) Settings.ESP = v end
})

--------------------------------------------------
-- SYSTEMS
--------------------------------------------------

-- AUTO HEAL
task.spawn(function()
    while task.wait(0.1) do
        if not Settings.AutoHeal then continue end
        local hum = getHum()
        if hum and hum.Health <= Settings.HealAt then
            local item = LocalPlayer.Backpack:FindFirstChild(Settings.HealItem)
            if item then
                hum:EquipTool(item)
                item:Activate()
                task.wait(Settings.HealDelay)
            end
        end
    end
end)

-- AUTO HIT (REAL FIX)
task.spawn(function()
    while task.wait(0.15) do
        if not Settings.AutoHit then continue end

        local root = getRoot()
        local tool = getTool()
        if not root or not tool then continue end

        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    if (root.Position - hrp.Position).Magnitude < 12 then
                        if tool.Parent ~= getChar() then
                            getHum():EquipTool(tool)
                        end
                        tool:Activate()
                    end
                end
            end
        end
    end
end)

-- GOLD FARM (WALK, NO TP)
task.spawn(function()
    while task.wait(0.6) do
        if not Settings.GoldFarm then continue end

        local root = getRoot()
        local hum = getHum()
        if not root or not hum then continue end

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("ice") or v.Name:lower():find("gold")) then

                hum:MoveTo(v.Position)
                hum.MoveToFinished:Wait()

                local pick = LocalPlayer.Backpack:FindFirstChild("God Pick")
                if pick then
                    hum:EquipTool(pick)
                    for i=1,15 do
                        pick:Activate()
                        task.wait(0.25)
                    end
                end
            end
        end
    end
end)

-- PLANT FARM (REAL FIX)
task.spawn(function()
    while task.wait(Settings.PlantSpeed) do
        if not Settings.PlantFarm then continue end

        local root = getRoot()
        local hum = getHum()
        if not root or not hum then continue end

        local hoe = LocalPlayer.Backpack:FindFirstChild("God Hoe")
        if not hoe then continue end

        hum:EquipTool(hoe)

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("plant") then
                local part = v:FindFirstChildWhichIsA("BasePart")

                if part and (root.Position - part.Position).Magnitude < 60 then
                    hum:MoveTo(part.Position)
                    hum.MoveToFinished:Wait()

                    root.CFrame = CFrame.new(root.Position, part.Position)

                    task.wait(0.08)
                    hoe:Activate()
                end
            end
        end
    end
end)

-- ESP
task.spawn(function()
    while task.wait(1) do
        if not Settings.ESP then continue end

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.Name:lower():find("gold") then
                    v.Color = Color3.fromRGB(255,215,0)
                elseif v.Name:lower():find("plant") then
                    v.Color = Color3.fromRGB(0,255,0)
                end
            end
        end
    end
end)
