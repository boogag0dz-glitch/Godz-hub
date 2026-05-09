local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local cps = 50
local clicking = false
local clickMode = "toggle"
local guiVisible = true
local clickCount = 0

-- safer click support
local function doClick()
    if mouse1click then
        mouse1click()
    elseif mouse1press and mouse1release then
        mouse1press()
        task.wait()
        mouse1release()
    else
        warn("Your executor doesn't support mouse click functions.")
    end
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

local titleBarFix = Instance.new("Frame")
titleBarFix.Size = UDim2.new(1, 0, 0, 10)
titleBarFix.Position = UDim2.new(0, 0, 1, -10)
titleBarFix.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
titleBarFix.BorderSizePixel = 0
titleBarFix.Parent = titleBar

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
content.Name = "Content"
content.Size = UDim2.new(1, -24, 1, -44)
content.Position = UDim2.new(0, 12, 0, 38)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.Parent = content

local function makePanel(h, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, h)
    f.BackgroundColor3 = Color3.fromRGB(19, 19, 31)
    f.BorderColor3 = Color3.fromRGB(51, 51, 51)
    f.BorderSizePixel = 1
    f.LayoutOrder = order
    f.Parent = content
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    return f
end

local function makeLabel(parent, text, size, color, x, y, w, h)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.TextSize = size or 11
    l.TextColor3 = color or Color3.fromRGB(136, 136, 136)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Position = UDim2.new(0, x or 10, 0, y or 8)
    l.Size = UDim2.new(0, w or 200, 0, h or 14)
    l.Parent = parent
    return l
end

local cpsPanel = makePanel(75, 1)
makeLabel(cpsPanel, "CLICK RATE (CPS)", 10, Color3.fromRGB(136,136,136), 10, 6)

local cpsValLabel = makeLabel(cpsPanel, "50", 14, Color3.fromRGB(255,255,255), 10, 22, 40, 18)

local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(1, -68, 0, 8)
sliderTrack.Position = UDim2.new(0, 54, 0, 27)
sliderTrack.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = cpsPanel
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(68, 170, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(1, 0, 0, 20)
sliderBtn.Position = UDim2.new(0, 0, 0.5, -10)
sliderBtn.BackgroundTransparency = 1
sliderBtn.Text = ""
sliderBtn.Parent = sliderTrack

local infoLbl = makeLabel(cpsPanel, "Interval: 20ms", 10, Color3.fromRGB(68,170,255), 10, 52, 280, 14)

local sliderDragging = false
sliderBtn.MouseButton1Down:Connect(function() sliderDragging = true end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if sliderDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local tx = sliderTrack.AbsolutePosition.X
        local tw = sliderTrack.AbsoluteSize.X
        local pct = math.clamp((i.Position.X - tx) / tw, 0, 1)
        cps = math.max(1, math.floor(pct * 100))
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        cpsValLabel.Text = tostring(cps)
        infoLbl.Text = "Interval: " .. math.floor(1000 / cps) .. "ms"
    end
end)

local statusPanel = makePanel(40, 2)
local statusLbl = makeLabel(statusPanel, "● INACTIVE", 13, Color3.fromRGB(200,80,80), 10, 12, 160, 16)
local countLbl = makeLabel(statusPanel, "Clicks: 0", 11, Color3.fromRGB(100,100,120), 190, 13, 100, 14)

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

print("AutoClicker loaded successfully!")
