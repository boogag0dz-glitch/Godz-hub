--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Godz Hub",
    LoadingTitle = "Godz Hub",
    LoadingSubtitle = "Booga Booga Reborn",
    ConfigurationSaving = { Enabled = false }
})

--// TABS
local MainTab = Window:CreateTab("Main", 4483362458)

--// SETTINGS
local Settings = {
    AutoHeal = false,
    HealHP = 75,
    AutoFarm = false
}

local p = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--------------------------------------------------
-- ❤️ TRUE AUTO HEAL (Bypasses UI)
--------------------------------------------------
local function DoHeal()
    local char = p.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Settings.AutoHeal and hum and hum.Health < Settings.HealHP then
        -- This looks for the Remote that handles eating
        local Events = ReplicatedStorage:FindFirstChild("Events") or ReplicatedStorage:FindFirstChild("RemoteEvents")
        local UseItem = Events and (Events:FindFirstChild("UseItem") or Events:FindFirstChild("EatItem"))
        
        if UseItem then
            -- We tell the game to eat Bloodfruit directly
            UseItem:FireServer("Bloodfruit")
        else
            -- Backup method if Remotes are hidden: Manual activation
            local fruit = p.Backpack:FindFirstChild("Bloodfruit") or char:FindFirstChild("Bloodfruit")
            if fruit then
                hum:EquipTool(fruit)
                fruit:Activate()
            end
        end
    end
end

--------------------------------------------------
-- ⚔️ AUTO FARM
--------------------------------------------------
local function DoFarm()
    local char = p.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if Settings.AutoFarm and tool then
        tool:Activate()
    end
end

--------------------------------------------------
-- 🔁 LOOP
--------------------------------------------------
task.spawn(function()
    while task.wait(0.3) do
        if Settings.AutoHeal then pcall(DoHeal) end
        if Settings.AutoFarm then pcall(DoFarm) end
    end
end)

--------------------------------------------------
-- 🎛️ UI CONTROLS
--------------------------------------------------
MainTab:CreateToggle({
    Name = "Auto Heal",
    CurrentValue = false,
    Callback = function(v) Settings.AutoHeal = v end
})

MainTab:CreateSlider({
    Name = "Heal HP Threshold",
    Range = {10, 99},
    Increment = 1,
    CurrentValue = 75,
    Callback = function(v) Settings.HealHP = v end
})

MainTab:CreateToggle({
    Name = "Auto Farm/Hit",
    CurrentValue = false,
    Callback = function(v) Settings.AutoFarm = v end
})
