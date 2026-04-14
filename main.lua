--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Godz Hub",
    LoadingTitle = "Godz Hub",
    LoadingSubtitle = "Booga Booga Reborn",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GodzHub",
        FileName = "Config"
    }
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

--------------------------------------------------
-- ❤️ FIXED AUTO HEAL (Checks Inventory)
--------------------------------------------------
local function DoHeal()
    local char = p.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Settings.AutoHeal and hum and hum.Health < Settings.HealHP then
        -- Looks for Bloodfruit in Backpack or Character
        local fruit = p.Backpack:FindFirstChild("Bloodfruit") or char:FindFirstChild("Bloodfruit")
        
        if fruit and fruit:IsA("Tool") then
            hum:EquipTool(fruit)
            fruit:Activate()
        end
    end
end

--------------------------------------------------
-- ⚔️ FIXED AUTO FARM
--------------------------------------------------
local function DoFarm()
    local char = p.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    
    if Settings.AutoFarm and tool then
        tool:Activate()
    end
end

--------------------------------------------------
-- 🔁 MAIN LOOP
--------------------------------------------------
task.spawn(function()
    while task.wait(0.3) do
        pcall(DoHeal)
        pcall(DoFarm)
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

Rayfield:LoadConfiguration()
