-- LOAD UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Settings = {
    AutoHeal = false,
    HealAt = 50,
    HealDelay = 0.2,
    HealItem = "Bloodfruit",

    AutoHit = false,
    HitRange = 15,

    HitboxSize = 1,

    GoldFarm = false,

    PlantFarm = false,
    SelectedPlant = "Bloodfruit",

    ESP = false
}

-- CHAR FUNCS
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHum()
    return getChar():FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    return getChar():FindFirstChild("HumanoidRootPart")
end

local function getTool()
    return getChar():FindFirstChildOfClass("Tool")
end

-- WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Godz Hub",
    LoadingTitle = "Godz Hub",
    LoadingSubtitle = "Booga Booga Reborn",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GodzHub",
        FileName = "Config"
    },
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
    Callback = function(v)
        Settings.AutoHeal = v
    end
})

Combat:CreateSlider({
    Name = "Heal HP",
    Range = {1,99},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        Settings.HealAt = v
    end
})

Combat:CreateSlider({
    Name = "Heal Delay (ms)",
    Range = {1,1000},
    Increment = 1,
    CurrentValue = 200,
    Callback = function(v)
        Settings.HealDelay = v / 1000
    end
})

Combat:CreateDropdown({
    Name = "Heal Item",
    Options = {"Bloodfruit"},
    CurrentOption = "Bloodfruit",
    Callback = function(v)
        Settings.HealItem = v
    end
})

Combat:CreateToggle({
    Name = "Auto Hit",
    CurrentValue = false,
    Callback = function(v)
        Settings.AutoHit = v
    end
})

Combat:CreateSlider({
    Name = "Hitbox Size",
    Range = {1,16},
    Increment = 1,
    CurrentValue = 1,
    Callback = function(v)
        Settings.HitboxSize = v
    end
})

--------------------------------------------------
-- FARM
--------------------------------------------------

Farm:CreateToggle({
    Name = "Gold Farm (ICE FIX)",
    CurrentValue = false,
    Callback = function(v)
        Settings.GoldFarm = v
    end
})

Farm:CreateToggle({
    Name = "Plant Farm",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlantFarm = v
    end
})

Farm:CreateDropdown({
    Name = "Plant Select",
    Options = {"Bloodfruit","Jelly","Lemon","Pumpkin","Blossom","Frostfruit","Carrot"},
    CurrentOption = "Bloodfruit",
    Callback = function(v)
        Settings.SelectedPlant = v
    end
})

--------------------------------------------------
-- VISUAL
--------------------------------------------------

Visual:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.ESP = v
    end
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
            local tool = LocalPlayer.Backpack:FindFirstChild(Settings.HealItem)
                or getChar():FindFirstChild(Settings.HealItem)

            if tool then
                hum:EquipTool(tool)
                tool:Activate()
                task.wait(Settings.HealDelay)
            end
        end
    end
end)

-- AUTO HIT (FIXED)
task.spawn(function()
    while task.wait(0.15) do
        if not Settings.AutoHit then continue end

        local root = getRoot()
        local tool = getTool()
        if not root or not tool then continue end

        for _,v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                local hum = v.Character:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    local dist = (root.Position - hrp.Position).Magnitude
                    if dist < Settings.HitRange then
                        tool:Activate()
                    end
                end
            end
        end
    end
end)

-- HITBOX
task.spawn(function()
    while task.wait(1) do
        if Settings.HitboxSize <= 1 then continue end

        for _,v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(Settings.HitboxSize,Settings.HitboxSize,Settings.HitboxSize)
                    hrp.CanCollide = false
                end
            end
        end
    end
end)

-- GOLD FARM (ICE FIX)
task.spawn(function()
    while task.wait(0.5) do
        if not Settings.GoldFarm then continue end

        local root = getRoot()
        local hum = getHum()
        if not root or not hum then continue end

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("gold") or v.Name:lower():find("ice")) then

                hum:MoveTo(v.Position)
                hum.MoveToFinished:Wait()

                local tool = LocalPlayer.Backpack:FindFirstChild("God Pick")
                    or LocalPlayer.Backpack:FindFirstChild("Void Pick")
                    or LocalPlayer.Backpack:FindFirstChild("Pink Diamond Pick")
                    or LocalPlayer.Backpack:FindFirstChild("Emerald Pick")

                if tool then
                    hum:EquipTool(tool)
                end

                for i=1,15 do
                    if not v.Parent then break end
                    tool:Activate()
                    task.wait(0.3)
                end
            end
        end
    end
end)

-- ESP
task.spawn(function()
    while task.wait(1) do
        if not Settings.ESP then continue end

        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    if p.Team == LocalPlayer.Team then
                        h.FillColor = Color3.new(0,1,0)
                    else
                        h.FillColor = Color3.new(1,0,0)
                    end
                end
            end
        end
    end
end)
