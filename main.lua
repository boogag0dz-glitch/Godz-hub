--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Godz Hub",
    LoadingTitle = "Godz Hub",
    LoadingSubtitle = "Auto Systems",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "GodzHub",
        FileName = "Config"
    }
})

--// TABS
local Combat = Window:CreateTab("Combat", 4483362458)
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
    AutoHitMode = "Players",

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
-- ❤️ AUTO HEAL
--------------------------------------------------
local function AutoHeal()
    local hum = getHum()
    if not hum then return end
    if hum.Health >= Settings.HealHP then return end

    local gui = LocalPlayer:WaitForChild("PlayerGui")

    for _,v in pairs(gui:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ImageButton") then
            
            local txt = v.Text and string.lower(v.Text) or ""
            local name = string.lower(v.Name)

            if txt:find("blood") or name:find("blood") then
                pcall(function()
                    v:Activate()
                end)
                return
            end
        end
    end
end

--------------------------------------------------
-- ⚔️ AUTO HIT (NEW SYSTEM)
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

            -- 🧍 PLAYERS
            if Settings.AutoHitMode == "Players" or Settings.AutoHitMode == "Both" then
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - root.Position).Magnitude

                    if dist <= 10 then
                        root.CFrame = CFrame.lookAt(root.Position, hrp.Position)
                        tool:Activate()
                        return
                    end
                end
            end

            -- 🌳 RESOURCES
            if Settings.AutoHitMode == "Resources" or Settings.AutoHitMode == "Both" then
                if v.Name:lower():find("tree")
                or v.Name:lower():find("rock")
                or v.Name:lower():find("gold")
                or v.Name:lower():find("ice") then

                    local part = v:FindFirstChildWhichIsA("BasePart")

                    if part then
                        local dist = (part.Position - root.Position).Magnitude

                        if dist <= 10 then
                            root.CFrame = CFrame.lookAt(root.Position, part.Position)
                            tool:Activate()
                            return
                        end
                    end
                end
            end
        end
    end
end

--------------------------------------------------
-- 👁️ ESP
--------------------------------------------------
local ESPObjects = {}

local function CreateESP(plr)
    if plr == LocalPlayer then return end

    local highlight = Instance.new("Highlight")
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
-- 🔁 LOOP
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
-- 🎛️ UI
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

Combat:CreateDropdown({
    Name = "Auto Hit Mode",
    Options = {"Players", "Resources", "Both"},
    CurrentOption = "Players",
    Callback = function(option)
        Settings.AutoHitMode = option
    end
})

Visuals:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.ESP = v
    end
})

Rayfield:LoadConfiguration()
