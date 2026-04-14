local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
repeat task.wait() until Rayfield

local S = {H = false, HP = 95, CPS = 15, A = false}
local RS = game:GetService("ReplicatedStorage")

--// 🕸️ BYTENET PACKET HOOK
-- This finds the actual ping-sender the game uses
local Net = nil
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("ModuleScript") and (v.Name == "Net" or v.Name == "ByteNet") then
        Net = require(v)
        break
    end
end

local Window = Rayfield:CreateWindow({
    Name = "Godz Hub | ByteNet Reborn",
    LoadingTitle = "Syncing Network Pings...",
    LoadingSubtitle = "By Boogag0dz"
})

local MainTab = Window:CreateTab("Main")

--------------------------------------------------
-- 🩸 BYTENET AUTO HEAL (Fix for 3497.mp4)
--------------------------------------------------
task.spawn(function()
    while true do
        local p = game.Players.LocalPlayer
        if S.H and p.Character and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health < S.HP then
                pcall(function()
                    -- Instead of FireServer, we send a packet through the Net module
                    if Net and Net.Packets then
                        Net.Packets.Consume:Send("Bloodfruit")
                    else
                        -- Fallback for standard events if Net isn't found
                        RS.Events.Consume:FireServer("Bloodfruit")
                    end
                end)
            end
        end
        task.wait(1/S.CPS)
    end
end)

--------------------------------------------------
-- ⚔️ BYTENET RESOURCE AURA
--------------------------------------------------
task.spawn(function()
    while task.wait(0.1) do
        local c = game.Players.LocalPlayer.Character
        if S.A and c and c:FindFirstChildOfClass("Tool") then
            local tool = c:FindFirstChildOfClass("Tool")
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Health") then
                    if (c.HumanoidRootPart.Position - obj:GetModelCFrame().Position).Magnitude < 15 then
                        pcall(function()
                            if Net and Net.Packets then
                                Net.Packets.Swing:Send(tool, obj)
                            else
                                RS.Events.Swing:FireServer(tool, obj)
                            end
                        end)
                        break
                    end
                end
            end
        end
    end
end)

MainTab:CreateToggle({Name = "ByteNet Auto Heal", Callback = function(v) S.H = v end})
MainTab:CreateToggle({Name = "ByteNet Resource Aura", Callback = function(v) S.A = v end})
