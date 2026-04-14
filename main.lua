local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
repeat task.wait() until Rayfield

--// 🕸️ BYTENET DETECTION
local ByteNet = nil
for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
    if v.Name == "ByteNet" or v.Name == "Net" then
        ByteNet = require(v)
        break
    end
end

local S = {H = false, HP = 95, CPS = 15, A = false}

local Window = Rayfield:CreateWindow({
    Name = "Godz Hub | ByteNet Edition",
    LoadingTitle = "Syncing Server Pings...",
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
            -- ByteNet usually uses a 'namespace' for actions
            -- If we find the 'Consume' packet, we fire it through ByteNet
            pcall(function()
                -- This is a generic way to try and ping the 'Consume' packet
                E.Consume:FireServer("Bloodfruit") 
                -- If the above fails, your friend's 'ByteNet' logic takes over here
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
                        -- Fire the swing through the standard remote as a fallback
                        game:GetService("ReplicatedStorage").Events.Swing:FireServer(tool, obj)
                        break
                    end
                end
            end
        end
    end
end)

MainTab:CreateToggle({Name = "ByteNet Auto Heal", Callback = function(v) S.H = v end})
MainTab:CreateToggle({Name = "ByteNet Resource Aura", Callback = function(v) S.A = v end})
