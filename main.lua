--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// SETTINGS
local Settings = {
    AutoHeal = false,
    HealAt = 50,
    AutoHit = false,
    HitboxSize = 1,
    GoldFarm = false,
    AutoCollect = false,
    SelectedPlant = "Bloodfruit"
}

--// CLEAN UI (FIXED FOR YOUR SCRIPT)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GodzHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 350)
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,35)
Title.Text = "Godz Hub"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1,-10,1,-45)
Container.Position = UDim2.new(0,5,0,40)
Container.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0,6)

-- BUTTON
local function makeButton(text, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1,0,0,32)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)

    return btn
end

-- TOGGLE
local function makeToggle(name, setting)
    makeButton(name .. ": OFF", function(btn)
        Settings[setting] = not Settings[setting]

        btn.Text = name .. ": " .. (Settings[setting] and "ON" or "OFF")
        btn.BackgroundColor3 = Settings[setting]
            and Color3.fromRGB(50,120,50)
            or Color3.fromRGB(35,35,35)
    end)
end

-- SLIDER (cycle)
local function makeSlider(name, min, max, default, setting)
    local value = default
    Settings[setting] = default

    makeButton(name .. ": " .. value, function(btn)
        value += 1
        if value > max then value = min end

        Settings[setting] = value
        btn.Text = name .. ": " .. value
    end)
end

-- MINIMIZE
makeButton("Minimize", function()
    Container.Visible = not Container.Visible
end)

--// UI CONTROLS

makeToggle("Auto Heal", "AutoHeal")

makeSlider("Heal At", 0, 99, 50, "HealAt")

makeToggle("Auto Hit", "AutoHit")

makeSlider("Hitbox Size", 1, 16, 1, "HitboxSize")

makeToggle("Gold Farm", "GoldFarm")

makeToggle("Auto Collect", "AutoCollect")

-- PLANT SELECTOR
local Plants = {"Bloodfruit","Jelly","Lemon","Pumpkin","Blossom","Frostfruit","Carrot"}
local currentIndex = 1

makeButton("Plant: Bloodfruit", function(btn)
    currentIndex += 1
    if currentIndex > #Plants then currentIndex = 1 end

    Settings.SelectedPlant = Plants[currentIndex]
    btn.Text = "Plant: " .. Settings.SelectedPlant
end)
--// GOLD FARM
local function tweenTo(pos)
    local root = getRoot(getChar())
    if root then
        local t = TweenService:Create(root, TweenInfo.new(2), {CFrame = pos})
        t:Play()
        t.Completed:Wait()
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if Settings.GoldFarm then
            local char = getChar()
            local tool = getTool(char)

            if char and tool then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name:lower():find("gold") then
                        tweenTo(v.CFrame + Vector3.new(0,3,0))
                        for i=1,15 do
                            tool:Activate()
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end
end)

--// INDICATORS
local indicators = {}

local function createIndicator(plr)
    local arrow = Instance.new("TextLabel", ScreenGui)
    arrow.Size = UDim2.new(0,50,0,50)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▲"
    arrow.TextScaled = true
    arrow.AnchorPoint = Vector2.new(0.5,0.5)
    indicators[plr] = arrow
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createIndicator(p) end
end

Players.PlayerAdded:Connect(createIndicator)

RunService.RenderStepped:Connect(function()
    local root = getRoot(getChar())
    if not root then return end

    for plr, arrow in pairs(indicators) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hrp then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            arrow.TextColor3 = (plr.Team == LocalPlayer.Team) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

            if not onScreen then
                arrow.Visible = true
                local center = Camera.ViewportSize/2
                local dir = (Vector2.new(pos.X,pos.Y) - center).Unit
                arrow.Position = UDim2.new(0, center.X + dir.X*(center.X-30), 0, center.Y + dir.Y*(center.Y-30))
                arrow.Rotation = math.deg(math.atan2(dir.Y, dir.X)) + 90
            else
                arrow.Visible = false
            end
        else
            arrow.Visible = false
        end
    end
end)
