local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
repeat task.wait() until Rayfield

local E = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local S = {H = false, HP = 85, A = false}
local W = Rayfield:CreateWindow({Name = "Godz Hub 2026", LoadingTitle = "Reborn"})
local T = W:CreateTab("Automation")

task.spawn(function()
    while task.wait(0.1) do
        local c = game.Players.LocalPlayer.Character
        if S.H and c and c.Humanoid.Health < S.HP then E.Consume:FireServer("Bloodfruit") end
        if S.A and c and c:FindFirstChildOfClass("Tool") then E.SwingTool:FireServer(c:FindFirstChildOfClass("Tool")) end
    end
end)

T:CreateToggle({Name = "Auto Heal", Callback = function(v) S.H = v end})
T:CreateSlider({Name = "Heal HP", Range = {10, 95}, CurrentValue = 85, Callback = function(v) S.HP = v end})
T:CreateToggle({Name = "Auto Hit/Farm", Callback = function(v) S.A = v end})
