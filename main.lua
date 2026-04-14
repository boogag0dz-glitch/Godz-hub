local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
repeat task.wait() until Rayfield

local E = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local S = {H = false, HP = 95, CPS = 10, A = false, P = false, K = false, R = 15}

local Window = Rayfield:CreateWindow({
    Name = "Godz Hub | Reborn",
    LoadingTitle = "Aster Edition",
    LoadingSubtitle = "By Boogag0dz",
    ConfigurationSaving = { Enabled = false }
})

--// 🗂️ TABS (Matched to Aster Hub Layout)
local FarmTab = Window:CreateTab("Main & GoldFarm", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local AutomationTab = Window:CreateTab("Automation", 4483362458)

--------------------------------------------------
-- 🚀 CORE LOGIC (Consume, SwingTool, Pickup)
--------------------------------------------------
task.spawn(function()
    while true do
        local p = game.Players.LocalPlayer
        local c = p.Character
        if S.H and c and c:FindFirstChild("Humanoid") and c.Humanoid.Health < S.HP then
            E.Consume:FireServer("Bloodfruit") --
        end
        task.wait(1/S.CPS)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        local p = game.Players.LocalPlayer
        local c = p.Character
        if not c then continue end

        if S.P then -- Auto Pickup
            for _, v in pairs(workspace:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("Pickup") then E.Pickup:FireServer(v) end
            end
        end

        local tool = c:FindFirstChildOfClass("Tool")
        if tool and (S.A or S.K) then
            if S.K then -- Kill Aura
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v ~= p and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (c.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                        if dist < S.R then E.SwingTool:FireServer(tool, v.Character) end
                    end
                end
            else -- Resource Aura
                E.SwingTool:FireServer(tool)
            end
        end
    end
end)

--------------------------------------------------
-- 🎛️ UI SECTIONS
--------------------------------------------------
-- MAIN & GOLDFARM
FarmTab:CreateSection("Farming Aura")
FarmTab:CreateToggle({Name = "Resource Aura", Callback = function(v) S.A = v end})
FarmTab:CreateToggle({Name = "Auto Pickup Items", Callback = function(v) S.P = v end})

-- COMBAT
CombatTab:CreateSection("PVP Features")
CombatTab:CreateToggle({Name = "Kill Aura", Callback = function(v) S.K = v end})
CombatTab:CreateSlider({Name = "Aura Range", Range = {5, 30}, CurrentValue = 15, Callback = function(v) S.R = v end})

-- AUTOMATION
AutomationTab:CreateSection("Survival")
AutomationTab:CreateToggle({Name = "Auto Heal", Callback = function(v) S.H = v end})
AutomationTab:CreateSlider({Name = "Heal %", Range = {10, 99}, CurrentValue = 95, Callback = function(v) S.HP = v end})
AutomationTab:CreateSlider({Name = "Heal Speed (CPS)", Range = {1, 20}, CurrentValue = 10, Callback = function(v) S.CPS = v end})
