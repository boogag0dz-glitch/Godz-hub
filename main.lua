--// 1. WAIT FOR RAYFIELD TO BE READY
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
repeat task.wait() until Rayfield

--// 2. CONNECT TO THE EXACT 2026 REMOTES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local ConsumeRemote = Events:WaitForChild("Consume")   -- Found in your screenshot!
local SwingRemote = Events:WaitForChild("SwingTool") -- Found in your screenshot!

--// 3. SET UP THE WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Godz Hub 2026",
    LoadingTitle = "Reborn Mobile",
    LoadingSubtitle = "By Boogag0dz",
    ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Automation", 4483362458)
local Settings = { AutoHeal = false, HealHP = 85, AutoHit = false }

--------------------------------------------------
-- ❤️ DYNAMIC AUTO HEAL (Using 'Consume')
--------------------------------------------------
local function DoHeal()
    local p = game.Players.LocalPlayer
    local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    
    if Settings.AutoHeal and hum and hum.Health < Settings.HealHP then
        -- We fire the 'Consume' remote you found in ReplicatedStorage
        ConsumeRemote:FireServer("Bloodfruit") 
    end
end

--------------------------------------------------
-- ⚔️ DYNAMIC AUTO HIT (Using 'SwingTool')
--------------------------------------------------
local function DoHit()
    if Settings.AutoHit then
        local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            -- We fire 'SwingTool' which you found in your events list
            SwingRemote:FireServer(tool)
        end
    end
end

--------------------------------------------------
-- 🔁 MAIN LOOP
--------------------------------------------------
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoHeal then pcall(DoHeal) end
        if Settings.AutoHit then pcall(DoHit) end
    end
end)

--------------------------------------------------
-- 🎛️ UI CONTROLS
--------------------------------------------------
MainTab:CreateToggle({
    Name = "Auto Heal (Bloodfruit)",
    CurrentValue = false,
    Callback = function(v) Settings.AutoHeal = v end
})

MainTab:CreateSlider({
    Name = "Heal Threshold",
    Range = {10, 95},
    Increment = 1,
    CurrentValue = 85,
    Callback = function(v) Settings.HealHP = v end
})

MainTab:CreateToggle({
    Name = "Auto Hit/Farm",
    CurrentValue = false,
    Callback = function(v) Settings.AutoHit = v end
})
