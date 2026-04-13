--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// SETTINGS
local Settings = {
    AutoHeal = false,
    AutoHit = false,
    GoldFarm = false,
    AutoFarmPlants = false,
    ESP = false,

    HealAt = 50,
    HealDelay = 300,
    HealFruit = "Bloodfruit",

    SelectedPlant = "Bloodfruit",
    PlantSpeed = 0.07,

    HitboxSize = 3
}

--// CONFIG
local file = "godzhub_config.json"

local function Save()
    if writefile then
        writefile(file, HttpService:JSONEncode(Settings))
    end
end

local function Load()
    if readfile and isfile and isfile(file) then
        local data = HttpService:JSONDecode(readfile(file))
        for k,v in pairs(data) do
            Settings[k]=v
        end
    end
end

Load()

--// CHARACTER
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function getHum()
    return getChar():FindFirstChildOfClass("Humanoid")
end
local function getRoot()
    return getChar():FindFirstChild("HumanoidRootPart")
end

--// UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,380,0,450)
main.Position = UDim2.new(0.35,0,0.25,0)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.Active = true
Instance.new("UICorner", main)

-- drag
local dragging, startPos, dragStart
main.InputBegan:Connect(function(i)
    if i.UserInputType.Name:find("Mouse") or i.UserInputType.Name:find("Touch") then
        dragging=true
        dragStart=i.Position
        startPos=main.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging then
        local delta=i.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end)

UIS.InputEnded:Connect(function() dragging=false end)

-- toggle
UIS.InputBegan:Connect(function(i,g)
    if not g and i.KeyCode==Enum.KeyCode.M then
        main.Visible=not main.Visible
    end
end)

-- tabs
local tabs=Instance.new("Frame",main)
tabs.Size=UDim2.new(1,0,0,40)
tabs.Position=UDim2.new(0,0,0,40)

local layout=Instance.new("UIListLayout",tabs)
layout.FillDirection=Enum.FillDirection.Horizontal

local pages={}
local function page(name)
    local p=Instance.new("Frame",main)
    p.Size=UDim2.new(1,-10,1,-90)
    p.Position=UDim2.new(0,5,0,80)
    p.Visible=false
    Instance.new("UIListLayout",p).Padding=UDim.new(0,6)
    pages[name]=p

    local b=Instance.new("TextButton",tabs)
    b.Size=UDim2.new(0,120,1,0)
    b.Text=name

    b.MouseButton1Click:Connect(function()
        for _,v in pairs(pages) do v.Visible=false end
        p.Visible=true
    end)

    return p
end

local Combat=page("Combat")
local Farm=page("Farming")
local Visual=page("Visuals")
pages["Combat"].Visible=true

-- UI helpers
local function Toggle(parent,name,key)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,0,0,35)
    b.Text=name..": "..(Settings[key] and "ON" or "OFF")
    b.MouseButton1Click:Connect(function()
        Settings[key]=not Settings[key]
        b.Text=name..": "..(Settings[key] and "ON" or "OFF")
        Save()
    end)
end

local function Slider(parent,name,min,max,key)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,50)

    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,0,0,20)
    l.Text=name..": "..Settings[key]
    l.BackgroundTransparency=1

    local bar=Instance.new("Frame",f)
    bar.Size=UDim2.new(1,0,0,10)
    bar.Position=UDim2.new(0,0,0,30)

    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new((Settings[key]-min)/(max-min),0,1,0)

    local dragging=false

    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
    end)

    UIS.InputEnded:Connect(function() dragging=false end)

    UIS.InputChanged:Connect(function(i)
        if dragging then
            local percent=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local val=math.floor(min+(max-min)*percent)
            Settings[key]=val
            fill.Size=UDim2.new(percent,0,1,0)
            l.Text=name..": "..val
            Save()
        end
    end)
end

-- dropdowns
local Fruits={"Bloodfruit","Jelly","Lemon","Pumpkin","Blossom","Frostfruit","Carrot"}
local function FruitDropdown(parent)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,0,0,35)
    b.Text="Heal Fruit: "..Settings.HealFruit

    b.MouseButton1Click:Connect(function()
        local i=table.find(Fruits,Settings.HealFruit) or 1
        i=i+1 if i>#Fruits then i=1 end
        Settings.HealFruit=Fruits[i]
        b.Text="Heal Fruit: "..Settings.HealFruit
        Save()
    end)
end

local function PlantDropdown(parent)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,0,0,35)
    b.Text="Plant: "..Settings.SelectedPlant

    b.MouseButton1Click:Connect(function()
        local i=table.find(Fruits,Settings.SelectedPlant) or 1
        i=i+1 if i>#Fruits then i=1 end
        Settings.SelectedPlant=Fruits[i]
        b.Text="Plant: "..Settings.SelectedPlant
        Save()
    end)
end

-- UI build
Toggle(Combat,"Auto Heal","AutoHeal")
Slider(Combat,"Heal HP",1,99,"HealAt")
Slider(Combat,"Heal Speed (ms)",100,1000,"HealDelay")
FruitDropdown(Combat)

Toggle(Combat,"Auto Hit","AutoHit")

Toggle(Farm,"Gold Farm","GoldFarm")
Toggle(Farm,"Plant Farm","AutoFarmPlants")
PlantDropdown(Farm)
Slider(Farm,"Plant Speed",1,10,"PlantSpeed")

Toggle(Visual,"ESP","ESP")

--// AUTO HEAL
task.spawn(function()
    local last=0
    while true do
        task.wait(0.1)
        if not Settings.AutoHeal then continue end

        local hum=getHum()
        if hum and hum.Health<=Settings.HealAt then
            if tick()-last < (Settings.HealDelay/1000) then continue end

            local fruit=LocalPlayer.Backpack:FindFirstChild(Settings.HealFruit)
                or getChar():FindFirstChild(Settings.HealFruit)

            if fruit then
                hum:EquipTool(fruit)
                task.wait(0.1)
                fruit:Activate()
                last=tick()
            end
        end
    end
end)

--// AUTO HIT
task.spawn(function()
    local last=0
    while task.wait(0.1) do
        if Settings.AutoHit then
            local root=getRoot()
            local hum=getHum()
            local tool=LocalPlayer.Backpack:FindFirstChild("God Rock") or LocalPlayer.Backpack:FindFirstChild("Emerald Blade")

            if root and hum and tool then
                hum:EquipTool(tool)

                for _,p in pairs(Players:GetPlayers()) do
                    if p~=LocalPlayer and p.Character then
                        local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position-root.Position).Magnitude<8 then
                            if tick()-last>0.3 then
                                tool:Activate()
                                last=tick()
                            end
                        end
                    end
                end
            end
        end
    end
end)

--// GOLD FARM (WALK)
local function walkTo(pos)
    local hum=getHum()
    local root=getRoot()
    if not hum or not root then return end

    local path=PathfindingService:CreatePath()
    path:ComputeAsync(root.Position,pos)

    for _,wp in ipairs(path:GetWaypoints()) do
        hum:MoveTo(wp.Position)
        hum.MoveToFinished:Wait()
    end
end

task.spawn(function()
    while task.wait(2) do
        if Settings.GoldFarm then
            local root=getRoot()
            local closest=nil
            local dist=math.huge

            for _,v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():find("gold") then
                    local d=(root.Position-v.Position).Magnitude
                    if d<dist then dist=d closest=v end
                end
            end

            if closest then
                walkTo(closest.Position)

                local tool=LocalPlayer.Backpack:FindFirstChild("God Pick")
                if tool then
                    getHum():EquipTool(tool)
                    for i=1,10 do
                        tool:Activate()
                        task.wait(0.3)
                    end
                end
            end
        end
    end
end)

--// PLANT FARM
task.spawn(function()
    while task.wait(Settings.PlantSpeed) do
        if Settings.AutoFarmPlants then
            local tool=LocalPlayer.Backpack:FindFirstChild("God Hoe") or LocalPlayer.Backpack:FindFirstChild("Pink Diamond Hoe")
            if tool then
                getHum():EquipTool(tool)

                for _,v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name:lower():find("plant") then
                        if (v.Position-getRoot().Position).Magnitude<20 then
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end
end)
