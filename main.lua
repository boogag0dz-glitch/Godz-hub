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
local MainTab = Window:CreateTab("Automation", 4483362458)

--// SETTINGS
local Settings = {
    AutoHeal = false,
    HealHP = 80,
    AutoHit = false
}

local p = game.Players.LocalPlayer
local VU = game:GetService("VirtualUser")

--------------------------------------------------
-- ❤️ REBORN AUTO HEAL (Direct Remote)
--------------------------------------------------
local function DoHeal()
    local char = p.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Settings.AutoHeal and hum and hum.Health < Settings.HealHP then
        -- This uses the direct game event to eat without opening inventory
        local event = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
        if event and event:FindFirstChild("UseItem") then
            event.UseItem:FireServer("Bloodfruit")
        end
    end
end

--------------------------------------------------
-- ⚔️ REBORN AUTO HIT (Simulated Tap)
--------------------------------------------------
local function DoHit()
    if Settings.AutoHit then
        -- This forces a screen tap even if you aren't clicking
        VU:CaptureController()
        VU:ClickButton1(Vector2.new(0,0))
    end
end

--------------------------------------------------
-- 🔁 LOOP
--------------------------------------------------
task.spawn(function()
    while task.wait(0.1) do -- Faster loop for Reborn combat
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
    Name = "Heal at HP",
    Range = {10, 99},
    Increment = 1,
    CurrentValue = 80,
    Callback = function(v) Settings.HealHP = v end
})

MainTab:CreateToggle({
    Name = "Auto Hit/Farm",
    CurrentValue = false,
    Callback = function(v) Settings.AutoHit = v end
})
