local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
repeat task.wait() until Rayfield

local S = {H = false, HP = 95, CPS = 15, A = false}
local RS = game:GetService("ReplicatedStorage")

--// 🕸️ BYTENET PACKET HOOK
local Net = nil
for _, v in pairs(RS:GetDescendants()) do
    if v:IsA("ModuleScript") and (v.Name == "Net" or v.Name == "ByteNet") then
        Net = require(v)
        break
    end
end

if not Net then
    warn("Net module not found! Some features may not work.")
end

local Window = Rayfield:CreateWindow({
    Name = "Godz Hub | ByteNet Reborn",
    LoadingTitle = "Syncing Network Pings...",
    LoadingSubtitle = "By Boogag0dz"
})

local MainTab = Window:CreateTab("Main")

-- Create a label for ping display
local PingLabel = MainTab:CreateLabel("Ping: Loading...")

-- Function to measure ping
local function measurePing()
    local RS = game:GetService("ReplicatedStorage")
    local event = RS:FindFirstChild("PingEvent") -- Replace with your actual RemoteEvent name
    if event and event:IsA("RemoteEvent") then
        local startTime = tick()
        local responded = false
        -- Listen for the response
        local connection
        connection = event.OnClientEvent:Connect(function()
            local ping = (tick() - startTime) * 1000 -- in milliseconds
            PingLabel:Set("Ping: " .. math.floor(ping) .. " ms")
            responded = true
            connection:Disconnect()
        end)
        -- Send ping request
        event:FireServer()
        -- Timeout if no response
        task.wait(1)
        if not responded then
            PingLabel:Set("Ping: Timeout")
            connection:Disconnect()
        end
    else
        PingLabel:Set("Ping: RemoteEvent not found")
    end
end

-- Add button to check ping
MainTab:CreateButton({
    Name = "Check Ping",
    Callback = function()
        measurePing()
    end
})

-- Your existing toggles
MainTab:CreateToggle({Name = "ByteNet Auto Heal", Callback = function(v) S.H = v end})
MainTab:CreateToggle({Name = "ByteNet Resource Aura", Callback = function(v) S.A = v end})

-- Your existing scripts for auto heal and resource aura...
task.spawn(function()
    while true do
        local p = game.Players.LocalPlayer
        if S.H and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character.Humanoid.Health < S.HP then
                pcall(function()
                    if Net and Net.Packets then
                        Net.Packets.Consume:Send("Bloodfruit")
                    elseif RS:FindFirstChild("Events") and RS.Events:FindFirstChild("Consume") then
                        RS.Events.Consume:FireServer("Bloodfruit")
                    end
                end)
            end
        end
        task.wait(1 / S.CPS)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        local c = game.Players.LocalPlayer.Character
        if S.A and c and c:FindFirstChildOfClass("Tool") then
            local tool = c:FindFirstChildOfClass("Tool")
            if c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Health") then
                        if obj:GetPrimaryPartCFrame() and (hrp.Position - obj:GetPrimaryPartCFrame().Position).Magnitude < 15 then
                            pcall(function()
                                if Net and Net.Packets then
                                    Net.Packets.Swing:Send(tool, obj)
                                elseif RS:FindFirstChild("Events") and RS.Events:FindFirstChild("Swing") then
                                    RS.Events.Swing:FireServer(tool, obj)
                                end
                            end)
                            break
                        end
                    end
                end
            end
        end
    end
end)
