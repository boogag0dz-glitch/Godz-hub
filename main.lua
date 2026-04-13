-- GODZ HUB (Delta/Xeno Compatible)

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/source.lua"))()

local Window = Fluent:CreateWindow({
    Title = "GODZ HUB",
    SubTitle = "Booga Booga Reborn",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" })
}

local Settings = {
    AutoHeal = false,
    HealAt = 75,
    AutoFarm = false
}

local Player = game.Players.LocalPlayer

Tabs.Main:AddSlider("HealSlider", {
    Title = "Heal HP",
    Description = "When to eat fruit",
    Default = 75,
    Min = 50,
    Max = 99,
    Rounding = 0,
    Callback = function(Value)
        Settings.HealAt = Value
    end
})

Tabs.Main:AddToggle("AutoHealToggle", {
    Title = "Auto Heal",
    Default = false,
    Callback = function(Value)
        Settings.AutoHeal = Value
    end
})

Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "Auto Hit / Farm",
    Default = false,
    Callback = function(Value)
        Settings.AutoFarm = Value
    end
})

task.spawn(function()
    while task.wait(0.3) do
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Tool = Character and Character:FindFirstChildOfClass("Tool")

        -- Auto Heal
        if Settings.AutoHeal and Humanoid and Humanoid.Health < Settings.HealAt then
            local Fruit = Player.Backpack:FindFirstChild("Bloodfruit") or (Character and Character:FindFirstChild("Bloodfruit"))
            if Fruit and Fruit:IsA("Tool") then
                Humanoid:EquipTool(Fruit)
                Fruit:Activate()
            end
        end

        -- Auto Farm
        if Settings.AutoFarm and Tool then
            Tool:Activate()
        end
    end
end)
