--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Godz Hub",
    LoadingTitle = "Godz Hub Loading...",
    LoadingSubtitle = "by you",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GodzHub",
        FileName = "Config"
    }
})

--// TABS
local Combat = Window:CreateTab("Combat", 4483362458)
local Farm = Window:CreateTab("Farm", 4483362458)
local Visuals = Window:CreateTab("Visuals", 4483362458)

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// SETTINGS
local Settings = {
    AutoHeal = false,
    HealHP = 50,

    AutoHit = false,
    HitDelay = 0.2,

    ESP = false
}

--// HELPERS
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHum()
    return getChar():FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    return getChar():FindFirstChild("HumanoidRootPart")
end

local function getTool()
    return getChar():FindFirstChildOfClass("Tool")
end

--------------------------------------------------
-- 🔥 AUTO HEAL (UI CLICK METHOD)
--------------------------------------------------
local function AutoHeal()
    local hum = getHum()
    if not hum then return end
    if hum.Health >= Settings.HealHP then return end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    for _,v in pairs(playerGui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("ImageLabel") then
            
            local match = false
            if v.Text and string.lower(v.Text):find("blood") then match = true end
            if v.Name and string.lower(v.Name):find("blood") then match = true end

            if match then
                local parent = v.Parent
                if parent and (parent:IsA("ImageButton") or parent:IsA("TextButton")) then
                    for _,c in pairs(getconnections(parent.MouseButton1Click)) do
                        c:Fire()
                    end
                    task.wait(0.8)
                    return
                end
            end
        end
    end
end

--------------------------------------------------
-- ⚔️ AUTO HIT (FIXED)
--------------------------------------------------
local function AutoHit()
    local char = getChar()
    local root = getRoot()
    local tool = getTool()

    if not root or not tool then return end

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= char then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            local hum = v:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist <= 12 then
                    tool:Activate()
                    return
                end
            end
        end
    end
end

--------------------------------------------------
-- 👁️ ESP (SIMPLE)
--------------------------------------------------
local ESPObjects = {}

local function CreateESP(plr)
    if plr == LocalPlayer then return end

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0

    highlight.Parent = game.CoreGui
    ESPObjects[plr] = highlight

    game:GetService("RunService").RenderStepped:Connect(function()
        if not Settings.ESP then
            highlight.Enabled = false
            return
        end

        local char = plr.Character
        if char then
            highlight.Adornee = char
            highlight.Enabled = true

            if plr.Team == LocalPlayer.Team then
                highlight.FillColor = Color3.fromRGB(0,255,0)
            else
                highlight.FillColor = Color3.fromRGB(255,0,0)
            end
        else
            highlight.Enabled = false
        end
    end)
end

for _,p in pairs(Players:GetPlayers()) do
    CreateESP(p)
end
Players.PlayerAdded:Connect(CreateESP)

--------------------------------------------------
-- 🧠 LOOPS
--------------------------------------------------
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoHeal then
            pcall(AutoHeal)
        end

        if Settings.AutoHit then
            pcall(AutoHit)
            task.wait(Settings.HitDelay)
        end
    end
end)

--------------------------------------------------
-- 🎛️ UI (COMBAT)
--------------------------------------------------
Combat:CreateToggle({
    Name = "Auto Heal",
    CurrentValue = false,
    Callback = function(v)
        Settings.AutoHeal = v
    end
})

Combat:CreateSlider({
    Name = "Heal HP",
    Range = {1, 99},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        Settings.HealHP = v
    end
})

Combat:CreateToggle({
    Name = "Auto Hit",
    CurrentValue = false,
    Callback = function(v)
        Settings.AutoHit = v
    end
})

Combat:CreateSlider({
    Name = "Hit Delay",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = 0.2,
    Callback = function(v)
        Settings.HitDelay = v
    end
})

--------------------------------------------------
-- 🎛️ VISUALS
--------------------------------------------------
Visuals:CreateToggle({
    Name = "ESP (Green Ally / Red Enemy)",
    CurrentValue = false,
    Callback = function(v)
        Settings.ESP = v
    end
})

Rayfield:LoadConfiguration()
