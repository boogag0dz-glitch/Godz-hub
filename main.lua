-- SETTINGS
local Settings = {
    AutoHeal = false,
    HealAt = 50,
    AutoHit = false,
    HitboxSize = 1,
    GoldFarm = false,
    AutoCollect = false,
    SelectedPlant = "Bloodfruit"
}
Settings.SelectedPlant = "Bloodfruit"
Settings.AutoCollect = false
makeButton("Auto Heal: OFF", function(btn)
    Settings.AutoHeal = not Settings.AutoHeal
    btn.Text = "Auto Heal: " .. (Settings.AutoHeal and "ON" or "OFF")
end)
makeButton("Auto Collect: OFF", function(btn)
    Settings.AutoCollect = not Settings.AutoCollect
    btn.Text = "Auto Collect: " .. (Settings.AutoCollect and "ON" or "OFF")
end)
-- UI SECTION
-- (your buttons + sliders here)
--// UI LIB (simple custom)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GodzHub"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.1, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.Padding = UDim.new(0,5)

-- Minimize Button
local MinBtn = Instance.new("TextButton", Frame)
MinBtn.Size = UDim2.new(1,0,0,30)
MinBtn.Text = "Minimize"

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, v in pairs(Frame:GetChildren()) do
        if v:IsA("TextButton") and v ~= MinBtn then
            v.Visible = not minimized
        end
    end
end)
--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Functions
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHum(char)
    return char:FindFirstChildOfClass("Humanoid")
end

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
end

local function getTool(char)
    return char:FindFirstChildOfClass("Tool")
end

--// MAIN LOOP
task.spawn(function()
    while task.wait(0.15) do
        local char = getChar()
        local hum = getHum(char)
        local root = getRoot(char)

        if char and hum and root then

            -- 🟢 AUTO HEAL (Bloodfruit)
            if Settings.AutoHeal and hum.Health <= Settings.HealAt then
                local fruit = LocalPlayer.Backpack:FindFirstChild("Bloodfruit") 
                    or char:FindFirstChild("Bloodfruit")

                if fruit and fruit:IsA("Tool") then
                    hum:EquipTool(fruit)
                    fruit:Activate()
                end
            end

            -- 🔴 SMART AUTO HIT (only when near something)
            if Settings.AutoHit then
                local tool = getTool(char)
                if tool then
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Model") and v ~= char then
                            local hrp = v:FindFirstChild("HumanoidRootPart")
                            local vh = v:FindFirstChildOfClass("Humanoid")

                            if hrp and vh and vh.Health > 0 then
                                local dist = (hrp.Position - root.Position).Magnitude
                                if dist < 15 then
                                    tool:Activate()
                                    break
                                end
                            end
                        end
                    end
                end
            end

            -- 🔵 HITBOX EXPANDER
            if Settings.HitboxSize > 1 then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and v ~= char then
                        local hrp = v:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                            hrp.Transparency = 0.5
                            hrp.CanCollide = false
                        end
                    end
                end
            end

        end
    end
end)
makeButton("Auto Collect: OFF", function(btn)
    Settings.AutoCollect = not Settings.AutoCollect
    btn.Text = "Auto Collect: " .. (Settings.AutoCollect and "ON" or "OFF")
end)
--// SETTINGS
local Settings = {
    AutoHeal = false,
    HealAt = 50,

    AutoHit = false,

    HitboxSize = 1,

    GoldFarm = false
}

-- Helper to make buttons
local function makeButton(text, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = text

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Helper for sliders
local function makeSlider(name, min, max, default, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = name .. ": " .. default

    local value = default

    btn.MouseButton1Click:Connect(function()
        value = value + 1
        if value > max then value = min end
        btn.Text = name .. ": " .. value
        callback(value)
    end)
end

--// BUTTONS

makeButton("Auto Heal: OFF", function(btn)
    Settings.AutoHeal = not Settings.AutoHeal
    btn.Text = "Auto Heal: " .. (Settings.AutoHeal and "ON" or "OFF")
end)

makeSlider("Heal At", 0, 99, 50, function(v)
    Settings.HealAt = v
end)

makeButton("Auto Hit: OFF", function(btn)
    Settings.AutoHit = not Settings.AutoHit
    btn.Text = "Auto Hit: " .. (Settings.AutoHit and "ON" or "OFF")
end)

makeSlider("Hitbox Size", 1, 16, 1, function(v)
    Settings.HitboxSize = v
end)

makeButton("Gold Farm: OFF", function(btn)
    Settings.GoldFarm = not Settings.GoldFarm
    btn.Text = "Gold Farm: " .. (Settings.GoldFarm and "ON" or "OFF")
end)
local Plants = {
    "Bloodfruit",
    "Jelly",
    "Lemon",
    "Pumpkin",
    "Blossom",
    "Frostfruit",
    "Carrot"
}

local currentIndex = 1

makeButton("Plant: Bloodfruit", function(btn)
    currentIndex = currentIndex + 1
    if currentIndex > #Plants then
        currentIndex = 1
    end

    Settings.SelectedPlant = Plants[currentIndex]
    btn.Text = "Plant: " .. Settings.SelectedPlant
end)
-- COMBAT SECTION
-- (autoheal + autohit + hitbox here)

-- FARM SECTION
-- (gold farm + plant farm here)
-- ❄️ GOLD FARM (ICE BIOME)

local TweenService = game:GetService("TweenService")

local function tweenTo(pos)
    local char = getChar()
    local root = getRoot(char)

    if root then
        local tween = TweenService:Create(
            root,
            TweenInfo.new(2, Enum.EasingStyle.Linear),
            {CFrame = pos}
        )
        tween:Play()
        tween.Completed:Wait()
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if Settings.GoldFarm then

            local char = getChar()
            local tool = getTool(char)

            if char and tool then

                -- find ice gold nodes
                local nodes = {}

                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name:lower():find("gold") then
                        table.insert(nodes, v)
                    end
                end

                -- sort closest first
                table.sort(nodes, function(a, b)
                    return (a.Position - char.HumanoidRootPart.Position).Magnitude <
                           (b.Position - char.HumanoidRootPart.Position).Magnitude
                end)

                -- go through nodes
                for i, node in ipairs(nodes) do
                    if not Settings.GoldFarm then break end

                    tweenTo(node.CFrame + Vector3.new(0, 3, 0))

                    -- hit node
                    for i = 1, 15 do
                        if not Settings.GoldFarm then break end
                        tool:Activate()
                        task.wait(0.1)
                    end
                end

            end
        end
    end
end)
-- VISUAL SECTION
-- (indicators here)
-- 🧭 ROTATING PLAYER INDICATORS

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Indicators"

local indicators = {}

local function createIndicator(plr)
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 50, 0, 50)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▲"
    arrow.TextScaled = true
    arrow.Font = Enum.Font.SourceSansBold
    arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.Parent = ScreenGui

    indicators[plr] = arrow
end

local function removeIndicator(plr)
    if indicators[plr] then
        indicators[plr]:Destroy()
        indicators[plr] = nil
    end
end

-- track players
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        createIndicator(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        createIndicator(plr)
    end
end)

Players.PlayerRemoving:Connect(removeIndicator)

-- update loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not root then return end

    for plr, arrow in pairs(indicators) do
        local pchar = plr.Character
        local proot = pchar and pchar:FindFirstChild("HumanoidRootPart")

        if pchar and proot then
            local pos, onScreen = Camera:WorldToViewportPoint(proot.Position)

            -- team color
            if plr.Team == LocalPlayer.Team then
                arrow.TextColor3 = Color3.fromRGB(0,255,0)
            else
                arrow.TextColor3 = Color3.fromRGB(255,0,0)
            end

            if onScreen then
                arrow.Visible = false
            else
                arrow.Visible = true

                -- screen center
                local center = Camera.ViewportSize / 2

                -- direction from center to target
                local dir = (Vector2.new(pos.X, pos.Y) - center).Unit

                -- place arrow on edge of screen
                local edgeX = center.X + dir.X * (center.X - 30)
                local edgeY = center.Y + dir.Y * (center.Y - 30)

                arrow.Position = UDim2.new(0, edgeX, 0, edgeY)

                -- 🔥 ROTATION
                local angle = math.deg(math.atan2(dir.Y, dir.X)) + 90
                arrow.Rotation = angle
            end
        else
            arrow.Visible = false
        end
    end
end)
