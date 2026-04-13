-- GODZ HUB (Delta/Xeno FIXED)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("GODZ HUB", "DarkTheme")

local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Automation")

local Player = game.Players.LocalPlayer

local AutoHeal = false
local HealAt = 75
local AutoFarm = false

Section:NewSlider("Heal HP", "When to eat fruit", 99, 50, function(v)
    HealAt = v
end)

Section:NewToggle("Auto Heal", "Eats Bloodfruit", function(v)
    AutoHeal = v
end)

Section:NewToggle("Auto Farm", "Auto hit tool", function(v)
    AutoFarm = v
end)

task.spawn(function()
    while task.wait(0.3) do
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Tool = Character and Character:FindFirstChildOfClass("Tool")

        if AutoHeal and Humanoid and Humanoid.Health < HealAt then
            local Fruit = Player.Backpack:FindFirstChild("Bloodfruit") or (Character and Character:FindFirstChild("Bloodfruit"))
            if Fruit and Fruit:IsA("Tool") then
                Humanoid:EquipTool(Fruit)
                Fruit:Activate()
            end
        end

        if AutoFarm and Tool then
            Tool:Activate()
        end
    end
end)
