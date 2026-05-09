local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local cps = 50
local clicking = false
local clickMode = "toggle"
local guiVisible = true
local clickCount = 0

-- Roblox click simulation
local function doClick()
    local mousePos = UserInputService:GetMouseLocation()

    VirtualInputManager:SendMouseButtonEvent(
        mousePos.X,
        mousePos.Y,
        0,
        true,
        game,
        0
    )

    task.wait()

    VirtualInputManager:SendMouseButtonEvent(
        mousePos.X,
        mousePos.Y,
        0,
        false,
        game,
        0
    )
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoClickerGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 370)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -185)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(68, 68, 68)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 6)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ AutoClicker"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 16, 0, 16)
closeBtn.Position = UDim2.new(1, -24, 0.5, -8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
closeBtn.Text = ""
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 16, 0, 16)
minBtn.Position = UDim2.new(1, -46, 0.5, -8)
minBtn.BackgroundColor3 = Color3.fromRGB(254, 188, 46)
minBtn.Text = ""
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -44)
content.Position = UDim2.new(0, 12, 0, 38)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = content

local function makePanel(h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, h)
    f.BackgroundColor3 = Color3.fromRGB(19, 19, 31)
    f.BorderColor3 = Color3.fromRGB(51, 51, 51)
    f.Parent = content
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    return f
end

local function makeLabel(parent, text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 0, 20)
    l.Position = UDim2.new(0, 10, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1,1,1)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.Parent = parent
    return l
end

local cpsPanel = makePanel(70)
local cpsLabel = makeLabel(cpsPanel, "CPS: 50", 10)

local statusPanel = makePanel(45)
local statusLbl = makeLabel(statusPanel, "● INACTIVE", 10)
local countLbl = makeLabel(statusPanel, "Clicks: 0", 22)

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 36)
startBtn.BackgroundColor3 = Color3.fromRGB(26,71,42)
startBtn.TextColor3 = Color3.fromRGB(40,200,64)
startBtn.Text = "▶ START CLICKING"
startBtn.TextSize = 13
startBtn.Font = Enum.Font.GothamBold
startBtn.Parent = content
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 4)

local function setClicking(state)
    clicking = state

    if clicking then
        statusLbl.Text = "● ACTIVE"
        statusLbl.TextColor3 = Color3.fromRGB(40,200,64)
        startBtn.Text = "⏹ STOP CLICKING"
    else
        statusLbl.Text = "● INACTIVE"
        statusLbl.TextColor3 = Color3.fromRGB(200,80,80)
        startBtn.Text = "▶ START CLICKING"
    end
end

local function autoclick()
    while clicking do
        doClick()
        clickCount += 1
        countLbl.Text = "Clicks: " .. clickCount
        task.wait(1 / cps)
    end
end

startBtn.MouseButton1Click:Connect(function()
    setClicking(not clicking)
    if clicking then
        task.spawn(autoclick)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

minBtn.MouseButton1Click:Connect(function()
    content.Visible = not content.Visible
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.BackQuote then
        setClicking(not clicking)
        if clicking then
            task.spawn(autoclick)
        end
    end

    if input.KeyCode == Enum.KeyCode.K then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

print("✅ AutoClicker loaded! ` = toggle | K = hide/show")
