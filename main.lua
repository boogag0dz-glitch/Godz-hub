local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
repeat task.wait() until Rayfield

local E = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local S = {H = false, HP = 95, CPS = 15, A = false}

local Window = Rayfield:CreateWindow({
    Name = "Godz Hub | Reborn Fixed",
    LoadingTitle = "Auto-Heal Optimized",
    LoadingSubtitle = "By Boogag0dz"
})

local MainTab = Window:CreateTab("Main & Survival")

--------------------------------------------------
-- 🩸 THE PERFECT AUTO HEAL
--------------------------------------------------
task.spawn(function()
    while true do
        local p = game.Players.LocalPlayer
        local c = p.Character
        
        if S.H and c and c:FindFirstChild("Humanoid") then
            -- Check if HP is below the threshold
            if c.Humanoid.Health < S.HP then
                -- Check for Bloodfruit in the Backpack or Character
                local fruit = p.Backpack:FindFirstChild("Bloodfruit") or c:FindFirstChild("Bloodfruit")
                
                if fruit then
                    -- Rapid-fire consume for instant health recovery
                    E.Consume:FireServer("Bloodfruit")
                end
            end
        end
        -- High-speed loop (15 times per second)
        task.wait(1/S.CPS)
    end
end)

--------------------------------------------------
-- ⚔️ RESOURCE AURA (Fixed for God Tools)
--------------------------------------------------
task.spawn(function()
    while task.wait(0.1) do
        local c = game.Players.LocalPlayer.Character
        if not c then continue end
        
        local tool = c:FindFirstChildOfClass("Tool")
        if S.A and tool then
            -- Scans for the closest resource with a Health bar
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:FindFirstChild("Health") and (c.HumanoidRootPart.Position - obj.Position).Magnitude < 15 then
                    E.Swing:FireServer(tool, obj)
                    break
                end
            end
        end
    end
end)

--------------------------------------------------
-- 🎛️ UI CONTROLS
--------------------------------------------------
MainTab:CreateSection("Survival")
MainTab:CreateToggle({
    Name = "Auto Heal (Bloodfruit)", 
    CurrentValue = false, 
    Callback = function(v) S.H = v end
})

MainTab:CreateSlider({
    Name = "Heal Threshold (%)", 
    Range = {10, 99}, 
    CurrentValue = 95, 
    Callback = function(v) S.HP = v end
})

MainTab:CreateSection("Farming")
MainTab:CreateToggle({
    Name = "Resource Aura", 
    CurrentValue = false, 
    Callback = function(v) S.A = v end
})
