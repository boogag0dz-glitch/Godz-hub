--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// SETTINGS
local Settings = {
    AutoHeal = false,
    AutoHit = false,
    GoldFarm = false,
    ESP = false
}

--// UI (WIND STYLE)

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GodzHub"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 380)
Main.Position = UDim2.new(0.4,0,0.3,0)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

-- Title
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "Godz Hub"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- Container
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1,-10,1,-50)
Container.Position = UDim2.new(0,5,0,45)
Container.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0,6)

-- Button
local function Toggle(name, key)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1,0,0,35)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = name .. ": " .. (Settings[key] and "ON" or "OFF")
    end)
end

Toggle("Auto Heal","AutoHeal")
Toggle("Auto Hit","AutoHit")
Toggle("Gold Farm","GoldFarm")
Toggle("ESP","ESP")

-- KEYBIND (M)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        Main.Visible = not Main.Visible
    end
end)

--// FUNCTIONS
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
    local char = getChar()
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    return getChar():FindFirstChildOfClass("Humanoid")
end

--// AUTO HEAL (FIXED)
task.spawn(function()
    while task.wait(0.2) do
        if Settings.AutoHeal then
            local hum = getHum()

            if hum and hum.Health < hum.MaxHealth then
                local fruit = LocalPlayer.Backpack:FindFirstChild("Bloodfruit")

                if fruit then
                    hum:EquipTool(fruit)
                    fruit:Activate()
                end
            end
        end
    end
end)

--// AUTO PATH (TO GOLD)
local function getNearestGold()
    local closest, dist = nil, math.huge
    local root = getRoot()

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("gold") then
            local part = v:FindFirstChildWhichIsA("BasePart")

            if part then
                local d = (part.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = part
                end
            end
        end
    end

    return closest
end

-- AUTO FARM
task.spawn(function()
    while task.wait(0.3) do
        if Settings.GoldFarm then
            local root = getRoot()
            local gold = getNearestGold()

            if root and gold then
                root.CFrame = gold.CFrame + Vector3.new(0,3,0)
            end
        end
    end
end)

--// ESP (PLAYERS + GOLD)

local ESPObjects = {}

local function createESP(obj, color)
    local box = Drawing.new("Square")
    box.Color = color
    box.Thickness = 2
    box.Filled = false
    ESPObjects[obj] = box
end

RunService.RenderStepped:Connect(function()
    for obj, box in pairs(ESPObjects) do
        if obj and obj.Parent then
            local pos, vis = Camera:WorldToViewportPoint(obj.Position)

            if vis then
                box.Size = Vector2.new(50,50)
                box.Position = Vector2.new(pos.X-25, pos.Y-25)
                box.Visible = Settings.ESP
            else
                box.Visible = false
            end
        else
            box:Remove()
            ESPObjects[obj] = nil
        end
    end
end)

-- CREATE ESP
task.spawn(function()
    while task.wait(2) do
        if Settings.ESP then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    if root and not ESPObjects[root] then
                        createESP(root, Color3.fromRGB(255,0,0))
                    end
                end
            end

            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name:lower():find("gold") then
                    local part = v:FindFirstChildWhichIsA("BasePart")
                    if part and not ESPObjects[part] then
                        createESP(part, Color3.fromRGB(255,255,0))
                    end
                end
            end
        end
    end
end)
