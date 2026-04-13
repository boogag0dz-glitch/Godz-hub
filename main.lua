--// GODZ HUB FINAL

-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- CHARACTER FUNCS
local function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
local function getHum() return getChar():FindFirstChildOfClass("Humanoid") end
local function getRoot() return getChar():FindFirstChild("HumanoidRootPart") end
local function getTool()
    return getChar():FindFirstChildOfClass("Tool")
end

-- SETTINGS
local Settings = {
    AutoHeal = false,
    HealAt = 50,
    HealDelay = 0.1,
    HealItem = "Bloodfruit",

    AutoHit = false,
    PvP = false,

    GoldFarm = false,
    PlantFarm = false,

    PlantSpeed = 0.07,

    ESP = false
}

-- UI (CLEAN BASIC RAYFIELD STYLE)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "GodzHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0.3,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0,5)

-- TOGGLE KEY (M)
UIS.InputBegan:Connect(function(input,gp)
    if input.KeyCode == Enum.KeyCode.M then
        frame.Visible = not frame.Visible
    end
end)

-- UI HELPERS
local function button(text,callback)
    local b = Instance.new("TextButton",frame)
    b.Size = UDim2.new(1,0,0,30)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)

    b.MouseButton1Click:Connect(function()
        callback(b)
    end)
end

local function slider(name,min,max,default,callback)
    local val = default
    local b = Instance.new("TextButton",frame)
    b.Size = UDim2.new(1,0,0,30)
    b.Text = name..": "..val

    b.MouseButton1Click:Connect(function()
        val = val + 1
        if val > max then val = min end
        b.Text = name..": "..val
        callback(val)
    end)
end

local function dropdown(name,list,callback)
    local index = 1
    local b = Instance.new("TextButton",frame)
    b.Size = UDim2.new(1,0,0,30)
    b.Text = name..": "..list[index]

    b.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #list then index = 1 end
        b.Text = name..": "..list[index]
        callback(list[index])
    end)
end

-- UI
button("Auto Heal: OFF",function(b)
    Settings.AutoHeal = not Settings.AutoHeal
    b.Text = "Auto Heal: "..(Settings.AutoHeal and "ON" or "OFF")
end)

slider("Heal HP",1,99,50,function(v) Settings.HealAt=v end)
slider("Heal Speed",1,20,10,function(v) Settings.HealDelay=v/100 end)

dropdown("Heal Item",{"Bloodfruit","Jelly","Lemon"},function(v)
    Settings.HealItem=v
end)

button("Auto Hit",function() Settings.AutoHit = not Settings.AutoHit end)
button("PvP AI",function() Settings.PvP = not Settings.PvP end)
button("Gold Farm",function() Settings.GoldFarm = not Settings.GoldFarm end)
button("Plant Farm",function() Settings.PlantFarm = not Settings.PlantFarm end)
button("ESP",function() Settings.ESP = not Settings.ESP end)

slider("Plant Speed",5,20,7,function(v)
    Settings.PlantSpeed = v/100
end)

-- AUTO HEAL
task.spawn(function()
    while task.wait(0.1) do
        if not Settings.AutoHeal then continue end

        local hum = getHum()
        if hum and hum.Health <= Settings.HealAt then
            local item = LocalPlayer.Backpack:FindFirstChild(Settings.HealItem)
            if item then
                hum:EquipTool(item)
                item:Activate()
                task.wait(Settings.HealDelay)
            end
        end
    end
end)

-- AUTO HIT
task.spawn(function()
    while task.wait(0.12) do
        if not Settings.AutoHit then continue end

        local root = getRoot()
        local tool = getTool()
        if not root or not tool then continue end

        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    if (root.Position - hrp.Position).Magnitude < 12 then
                        tool:Activate()
                    end
                end
            end
        end
    end
end)

-- PVP AI
task.spawn(function()
    while task.wait(0.1) do
        if not Settings.PvP then continue end

        local root = getRoot()
        local hum = getHum()
        local tool = getTool()
        if not root or not hum or not tool then continue end

        local target,dist=nil,math.huge

        for _,plr in pairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then
                local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
                local h=plr.Character:FindFirstChildOfClass("Humanoid")
                if hrp and h and h.Health>0 then
                    local d=(root.Position-hrp.Position).Magnitude
                    if d<dist then dist=d target=hrp end
                end
            end
        end

        if target then
            hum:MoveTo(target.Position)
            root.CFrame=CFrame.new(root.Position,target.Position)
            if dist<10 then tool:Activate() end
        end
    end
end)

-- GOLD FARM (ICE FIX)
task.spawn(function()
    while task.wait(0.6) do
        if not Settings.GoldFarm then continue end

        local root=getRoot()
        local hum=getHum()
        if not root or not hum then continue end

        local closest,dist=nil,math.huge

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("gold") or v.Name:lower():find("ice")) then
                local d=(root.Position-v.Position).Magnitude
                if d<dist then dist=d closest=v end
            end
        end

        if closest then
            hum:MoveTo(closest.Position)
            hum.MoveToFinished:Wait()

            local pick = LocalPlayer.Backpack:FindFirstChild("God Pick")
                or LocalPlayer.Backpack:FindFirstChild("Void Pick")

            if pick then
                hum:EquipTool(pick)
                for i=1,20 do
                    pick:Activate()
                    task.wait(0.25)
                end
            end
        end
    end
end)

-- PLANT FARM (5x5 AI)
task.spawn(function()
    while task.wait(Settings.PlantSpeed) do
        if not Settings.PlantFarm then continue end

        local root=getRoot()
        local hum=getHum()
        if not root or not hum then continue end

        local hoe = LocalPlayer.Backpack:FindFirstChild("God Hoe")
        if not hoe then continue end

        hum:EquipTool(hoe)

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("plant") then
                local part=v:FindFirstChildWhichIsA("BasePart")
                if part and (root.Position-part.Position).Magnitude<60 then

                    hum:MoveTo(part.Position)
                    hum.MoveToFinished:Wait()

                    root.CFrame=CFrame.new(root.Position,part.Position)

                    hoe:Activate()
                    task.wait(Settings.PlantSpeed)
                end
            end
        end
    end
end)

-- ESP
task.spawn(function()
    while task.wait(1) do
        if not Settings.ESP then continue end

        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.Name:lower():find("gold") then
                    v.Color=Color3.fromRGB(255,215,0)
                elseif v.Name:lower():find("plant") then
                    v.Color=Color3.fromRGB(0,255,0)
                end
            end
        end
    end
end)
