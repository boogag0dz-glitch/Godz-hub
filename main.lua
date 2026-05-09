local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local cps = 50
local clicking = false
local clickMode = "toggle"
local guiVisible = true
local clickCount = 0

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

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 6)

-- Fix corners showing at bottom of titlebar
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

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 16, 0, 16)
closeBtn.Position = UDim2.new(1, -24, 0.5, -8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
closeBtn.Text = ""
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 16, 0, 16)
minBtn.Position = UDim2.new(1, -46, 0.5, -8)
minBtn.BackgroundColor3 = Color3.fromRGB(254, 188, 46)
minBtn.Text = ""
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

-- Content
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

-- CPS Panel
local cpsPanel = makePanel(75, 1)
makeLabel(cpsPanel, "CLICK RATE (CPS)", 10, Color3.fromRGB(136,136,136), 10, 6)

local cpsValLabel = makeLabel(cpsPanel, "50", 14, Color3.fromRGB(255,255,255), 10, 22, 40, 18)
cpsValLabel.Font = Enum.Font.GothamBold

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

-- Slider drag logic
local sliderDragging = false
sliderBtn.MouseButton1Down:Connect(function() sliderDragging = true end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then sliderDragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if sliderDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local tx = sliderTrack.AbsolutePosition.X
        local tw = sliderTrack.AbsoluteSize.X
        local pct = math.clamp((i.Position.X - tx) / tw, 0, 1)
        cps = math.max(1, math.floor(pct * 100))
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        cpsValLabel.Text = tostring(cps)
        infoLbl.Text = "Interval: " .. math.floor(1000/cps) .. "ms"
    end
end)

-- Mode Panel
local modePanel = makePanel(50, 2)
makeLabel(modePanel, "ACTIVATION MODE", 10, Color3.fromRGB(136,136,136), 10, 6)

local holdBtn = Instance.new("TextButton")
holdBtn.Size = UDim2.new(0, 70, 0, 22)
holdBtn.Position = UDim2.new(0, 10, 0, 22)
holdBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
holdBtn.TextColor3 = Color3.fromRGB(136,136,136)
holdBtn.Text = "Hold"
holdBtn.TextSize = 12
holdBtn.Font = Enum.Font.Gotham
holdBtn.BorderSizePixel = 1
holdBtn.BorderColor3 = Color3.fromRGB(85,85,85)
holdBtn.Parent = modePanel
Instance.new("UICorner", holdBtn).CornerRadius = UDim.new(0, 3)

local togBtn = Instance.new("TextButton")
togBtn.Size = UDim2.new(0, 70, 0, 22)
togBtn.Position = UDim2.new(0, 88, 0, 22)
togBtn.BackgroundColor3 = Color3.fromRGB(19, 50, 80)
togBtn.TextColor3 = Color3.fromRGB(68,170,255)
togBtn.Text = "Toggle"
togBtn.TextSize = 12
togBtn.Font = Enum.Font.GothamBold
togBtn.BorderSizePixel = 1
togBtn.BorderColor3 = Color3.fromRGB(68,170,255)
togBtn.Parent = modePanel
Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0, 3)

local function setMode(mode)
    clickMode = mode
    if mode == "hold" then
        holdBtn.BackgroundColor3 = Color3.fromRGB(19,50,80)
        holdBtn.TextColor3 = Color3.fromRGB(68,170,255)
        holdBtn.BorderColor3 = Color3.fromRGB(68,170,255)
        holdBtn.Font = Enum.Font.GothamBold
        togBtn.BackgroundColor3 = Color3.fromRGB(42,42,61)
        togBtn.TextColor3 = Color3.fromRGB(136,136,136)
        togBtn.BorderColor3 = Color3.fromRGB(85,85,85)
        togBtn.Font = Enum.Font.Gotham
    else
        togBtn.BackgroundColor3 = Color3.fromRGB(19,50,80)
        togBtn.TextColor3 = Color3.fromRGB(68,170,255)
        togBtn.BorderColor3 = Color3.fromRGB(68,170,255)
        togBtn.Font = Enum.Font.GothamBold
        holdBtn.BackgroundColor3 = Color3.fromRGB(42,42,61)
        holdBtn.TextColor3 = Color3.fromRGB(136,136,136)
        holdBtn.BorderColor3 = Color3.fromRGB(85,85,85)
        holdBtn.Font = Enum.Font.Gotham
    end
end
holdBtn.MouseButton1Click:Connect(function() setMode("hold") end)
togBtn.MouseButton1Click:Connect(function() setMode("toggle") end)

-- Status Panel
local statusPanel = makePanel(40, 3)
local statusLbl = makeLabel(statusPanel, "● INACTIVE", 13, Color3.fromRGB(200,80,80), 10, 12, 160, 16)
statusLbl.Font = Enum.Font.GothamBold
local countLbl = makeLabel(statusPanel, "Clicks: 0", 11, Color3.fromRGB(100,100,120), 190, 13, 100, 14)

-- Start/Stop Button
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 36)
startBtn.BackgroundColor3 = Color3.fromRGB(26,71,42)
startBtn.TextColor3 = Color3.fromRGB(40,200,64)
startBtn.Text = "▶  START CLICKING"
startBtn.TextSize = 13
startBtn.Font = Enum.Font.GothamBold
startBtn.BorderColor3 = Color3.fromRGB(40,200,64)
startBtn.BorderSizePixel = 1
startBtn.LayoutOrder = 4
startBtn.Parent = content
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 4)

local hintLbl = Instance.new("TextLabel")
hintLbl.Size = UDim2.new(1, 0, 0, 14)
hintLbl.BackgroundTransparency = 1
hintLbl.Text = "` = toggle click  •  K = show/hide  •  drag titlebar to move"
hintLbl.TextColor3 = Color3.fromRGB(70,70,90)
hintLbl.TextSize = 9
hintLbl.Font = Enum.Font.Gotham
hintLbl.TextXAlignment = Enum.TextXAlignment.Center
hintLbl.LayoutOrder = 5
hintLbl.Parent = content

-- =====================
-- CLICKING LOGIC
-- =====================
local function setClicking(state)
    clicking = state
    if clicking then
        statusLbl.Text = "● ACTIVE"
        statusLbl.TextColor3 = Color3.fromRGB(40,200,64)
        startBtn.Text = "⏹  STOP CLICKING"
        startBtn.BackgroundColor3 = Color3.fromRGB(74,18,32)
        startBtn.TextColor3 = Color3.fromRGB(226,75,74)
        startBtn.BorderColor3 = Color3.fromRGB(226,75,74)
    else
        statusLbl.Text = "● INACTIVE"
        statusLbl.TextColor3 = Color3.fromRGB(200,80,80)
        startBtn.Text = "▶  START CLICKING"
        startBtn.BackgroundColor3 = Color3.fromRGB(26,71,42)
        startBtn.TextColor3 = Color3.fromRGB(40,200,64)
        startBtn.BorderColor3 = Color3.fromRGB(40,200,64)
    end
end

local function autoclick()
    while clicking do
        local interval = 1 / cps
        mouse1press()
        task.wait(0.01)
        mouse1release()
        clickCount += 1
        countLbl.Text = "Clicks: " .. clickCount
        task.wait(math.max(0.001, interval - 0.01))
    end
end

startBtn.MouseButton1Click:Connect(function()
    setClicking(not clicking)
    if clicking then task.spawn(autoclick) end
end)

-- =====================
-- DRAGGING (manual, works on all executors)
-- =====================
local dragging2 = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging2 = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging2 and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging2 = false
    end
end)

-- =====================
-- MINIMIZE
-- =====================
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0, 300, 0, 34) or UDim2.new(0, 300, 0, 370)
end)

-- =====================
-- CLOSE / SHOW
-- =====================
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    guiVisible = false
end)

-- =====================
-- KEYBINDS
-- =====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
    end

    if input.KeyCode == Enum.KeyCode.BackQuote then
        if clickMode == "toggle" then
            setClicking(not clicking)
            if clicking then task.spawn(autoclick) end
        elseif clickMode == "hold" then
            setClicking(true)
            task.spawn(autoclick)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.BackQuote and clickMode == "hold" then
        setClicking(false)
    end
end)

print("✅ AutoClicker loaded! ` = toggle | K = show/hide | drag titlebar to move")
