local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
repeat task.wait() until Rayfield

--// 🕸️ BYTENET BYPASS LOGIC
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ByteNet = nil

-- This scans for the game's hidden "Net" module
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("ModuleScript") and (v.Name:find("Net") or v.Name:find("Byte")) then
        ByteNet = require(v)
        break
    end
end

local S = {H = false, HP = 95, CPS = 15, A = false}
local Window = Rayfield:CreateWindow({
    Name = "Godz Hub | ByteNet Reborn",
    LoadingTitle = "Syncing Packets...",
    LoadingSubtitle = "By Boogag0dz"
})

local MainTab = Window:CreateTab("Main & Survival")

--------------------------------------------------
-- 🩸 BYTENET AUTO HEAL
--------------------------------------------------
task.spawn(function()
    while true do
        local p = game.Players.LocalPlayer
        if S.H and p.Character and p.Character.Humanoid.Health < S.HP then
            -- We send the 'Consume' ping through the network buffer
            pcall(function()
                -- Trying the two most common ByteNet paths for Reborn
                if ByteNet and ByteNet.Packets then
                    ByteNet.Packets.Consume:Send("Bloodfruit")
                else
                    -- Fallback if ByteNet is obfuscated
                    ReplicatedStorage.Events.Consume:FireServer("Bloodfruit")
                end
            end)
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
                            if ByteNet and ByteNet.Packets then
                                ByteNet.Packets.Swing:Send(tool, obj)
                            else
                                ReplicatedStorage.Events.Swing:FireServer(tool, obj)
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
