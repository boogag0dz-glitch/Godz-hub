local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
repeat task.wait() until Rayfield

local E = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local S = {H = false, HP = 95, CPS = 10, A = false, P = false, K = false, R = 18}

local Window = Rayfield:CreateWindow({
    Name = "Godz Hub | Reborn",
    LoadingTitle = "Official Game Support",
    LoadingSubtitle = "By Boogag0dz"
})

--// Sidebar Tabs
local FarmTab = Window:CreateTab("Main & GoldFarm")
local CombatTab = Window:CreateTab("Combat")
local AutomationTab = Window:CreateTab("Automation")

--------------------------------------------------
-- 🚀 SURVIVAL & FARMING LOGIC
--------------------------------------------------
task.spawn(function()
    while true do
        local p = game.Players.LocalPlayer
        local c = p.Character
        -- Fast Auto Heal
        if S.H and c and c:FindFirstChild("Humanoid") and c.Humanoid.Health < S.HP then
            E.Consume:FireServer("Bloodfruit") 
        end
        task.wait(1/S.CPS)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        local p = game.Players.LocalPlayer
        local c = p.Character
        if not c then continue end

        -- Auto Pickup Items
        if S.P then
            for _, v in pairs(workspace:GetChildren()) do
                if v:FindFirstChild("Handle") or v:IsA("BasePart") then
                    E.Pickup:FireServer(v)
                end
            end
        end

        -- Resource & Kill Aura
        local tool = c:FindFirstChildOfClass("Tool")
        if tool then
            if S.K then -- Kill Aura
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v ~= p and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local d = (c.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                        if d < S.R then E.Attack:FireServer(tool, v.Character) end
                    end
                end
            elseif S.A then -- Resource Aura (Bushes/Rocks)
                E.Swing:FireServer(tool)
            end
        end
    end
end)

--------------------------------------------------
-- 🎛️ UI SETTINGS
--------------------------------------------------
FarmTab:CreateToggle({Name = "Resource Aura", Callback = function(v) S.A = v end})
FarmTab:CreateToggle({Name = "Auto Pickup", Callback = function(v) S.P = v end})

CombatTab:CreateToggle({Name = "Kill Aura", Callback = function(v) S.K = v end})
CombatTab:CreateSlider({Name = "Range", Range = {5, 30}, CurrentValue = 18, Callback = function(v) S.R = v end})

AutomationTab:CreateToggle({Name = "Auto Heal", Callback = function(v) S.H = v end})
AutomationTab:CreateSlider({Name = "Heal Speed (CPS)", Range = {1, 20}, CurrentValue = 10, Callback = function(v) S.CPS = v end})
