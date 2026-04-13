--// LOAD RAYFIELD SAFE
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("Rayfield failed")
    return
end

--// WINDOW
local Window = Rayfield:CreateWindow({
   Name = "Godz Hub V2",
   LoadingTitle = "Godz Hub",
   LoadingSubtitle = "Loaded",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GodzHub",
      FileName = "Config"
   }
})

--// TABS
local Combat = Window:CreateTab("Combat")
local Farm = Window:CreateTab("Farm")
local Visual = Window:CreateTab("Visual")

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

--// SAFE REMOTES
local Events = RS:FindFirstChild("Events")
if not Events then warn("No Events found") return end

local Swing = Events:FindFirstChild("SwingTool")
local Interact = Events:FindFirstChild("InteractStructure")
local UseItem = Events:FindFirstChild("UseBagItem")
local Pickup = Events:FindFirstChild("Pickup")

--// SETTINGS
local Settings = {
    AutoHit = false,
    GoldFarm = false,
    PlantFarm = false,
    AutoHeal = false,
    ESP = false
}

--// CHAR
local function Char() return LocalPlayer.Character end
local function Root() return Char() and Char():FindFirstChild("HumanoidRootPart") end
local function Hum() return Char() and Char():FindFirstChildOfClass("Humanoid") end

--------------------------------------------------
-- ⚔️ AUTO HIT (REMOTE BASED)
--------------------------------------------------
local function AutoHit()
    if not Swing then return end

    local root = Root()
    if not root then return end

    for _,v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            local hum = v.Character:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                if (root.Position - hrp.Position).Magnitude < 12 then
                    Swing:FireServer(v.Character)
                end
            end
        end
    end
end

--------------------------------------------------
-- ⛏️ GOLD FARM (BASIC WORKING)
--------------------------------------------------
local function GoldFarm()
    if not Swing then return end

    local root = Root()
    if not root then return end

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("gold") then

            if (root.Position - v.Position).Magnitude < 20 then
                Swing:FireServer(v)
            end
        end
    end
end

--------------------------------------------------
-- 🌱 PLANT FARM (INTERACT BASE)
--------------------------------------------------
local function PlantFarm()
    if not Interact then return end

    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("plantbox") then

            pcall(function()
                Interact:FireServer(v, "Harvest")
            end)

            task.wait(0.05)

            pcall(function()
                Interact:FireServer(v, "Plant", "Bloodfruit")
            end)
        end
    end
end

--------------------------------------------------
-- 🍎 AUTO HEAL
--------------------------------------------------
local function AutoHeal()
    if not UseItem then return end

    local hum = Hum()
    if hum and hum.Health < 50 then
        UseItem:FireServer("Bloodfruit")
    end
end

--------------------------------------------------
-- 👁️ ESP (WORKING)
--------------------------------------------------
local ESPs = {}

local function UpdateESP(state)
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then

            if state then
                if not ESPs[plr] then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255,0,0)
                    hl.Parent = plr.Character
                    ESPs[plr] = hl
                end
            else
                if ESPs[plr] then
                    ESPs[plr]:Destroy()
                    ESPs[plr] = nil
                end
            end

        end
    end
end

--------------------------------------------------
-- UI BINDS
--------------------------------------------------

Combat:CreateToggle({
    Name = "Auto Hit",
    Callback = function(v) Settings.AutoHit = v end
})

Combat:CreateToggle({
    Name = "Auto Heal",
    Callback = function(v) Settings.AutoHeal = v end
})

Farm:CreateToggle({
    Name = "Gold Farm",
    Callback = function(v) Settings.GoldFarm = v end
})

Farm:CreateToggle({
    Name = "Plant Farm",
    Callback = function(v) Settings.PlantFarm = v end
})

Visual:CreateToggle({
    Name = "ESP",
    Callback = function(v)
        Settings.ESP = v
        UpdateESP(v)
    end
})

--------------------------------------------------
-- MAIN LOOP (SAFE)
--------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        
        if Settings.AutoHit then AutoHit() end
        if Settings.GoldFarm then GoldFarm() end
        if Settings.PlantFarm then PlantFarm() end
        if Settings.AutoHeal then AutoHeal() end

    end
end)

print("FULL SCRIPT LOADED")
