local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Settings
local cps = 50
local clicking = false
local clickMode = "toggle" -- "toggle" or "hold"
local clickButton = "Left" -- "Left", "Right", "Middle"
local unlimited = false
local randomCps = false
local clickLimit = 0
local clickCount = 0
local guiVisible = true

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoClickerGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 420)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
mainFrame.BorderColor3 = Color3.fromRGB(68, 68, 68)
mainFrame.BorderSizePixel = 1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
titleBar.BorderColor3 = Color3.fromRGB(68, 68, 68)
titleBar.BorderSizePixel = 1
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ AutoClicker"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 18, 0, 18)
closeBtn.Position = UDim2.new(1, -26, 0.5, -9)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
closeBtn.Text = ""
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(1, 0)
closeBtnCorner.Parent = closeBtn

-- Content Frame
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -44)
content.Position = UDim2.new(0, 12, 0, 38)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 8)
contentLayout.Parent = content

-- Helper: create a section panel
local function makePanel(parent, height, order)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1, 0, 0, height)
    panel.BackgroundColor3 = Color3.fromRGB(19, 19, 31)
    panel.BorderColor3 = Color3.fromRGB(51, 51, 51)
    panel.BorderSizePixel = 1
    panel.LayoutOrder = order
    panel.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = panel

    return panel
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

-- === CPS PANEL ===
local cpsPanel = makePanel(content, 80, 1)
makeLabel(cpsPanel, "CLICK RATE (CPS)", 10, Color3.fromRGB(136,136,136), 10, 8)

local cpsValueLabel = makeLabel(cpsPanel, tostring(cps), 14, Color3.fromRGB(255,255,255), 10, 26, 50, 18)
cpsValueLabel.Font = Enum.Font.GothamBold
cpsValueLabel.TextSize = 14

local cpsSlider = Instance.new("TextButton")
cpsSlider.Size = UDim2.new(1, -80, 0, 10)
cpsSlider.Position = UDim2.new(0, 60, 0, 32)
cpsSlider.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
cpsSlider.Text = ""
cpsSlider.BorderSizePixel = 0
cpsSlider.Parent = cpsPanel

local cpsSliderCorner = Instance.new("UICorner")
cpsSliderCorner.CornerRadius = UDim.new(1, 0)
cpsSliderCorner.Parent = cpsSlider

local cpsFill = Instance.new("Frame")
cpsFill.Size = UDim2.new(cps/100, 0, 1, 0)
cpsFill.BackgroundColor3 = Color3.fromRGB(68, 170, 255)
cpsFill.BorderSizePixel = 0
cpsFill.Parent = cpsSlider

local cpsFillCorner = Instance.new("UICorner")
cpsFillCorner.CornerRadius = UDim.new(1, 0)
cpsFillCorner.Parent = cpsFill

local infoLabel = makeLabel(cpsPanel, "Click / Wait: " .. math.floor(500/cps) .. "ms / " .. math.floor(500/cps) .. "ms", 10, Color3.fromRGB(68,170,255), 10, 55, 280, 14)

-- Slider drag
local dragging = false
cpsSlider.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local sliderPos = cpsSlider.AbsolutePosition.X
        local sliderWidth = cpsSlider.AbsoluteSize.X
        local relX = math.clamp(input.Position.X - sliderPos, 0, sliderWidth)
        cps = math.max(1, math.floor((relX / sliderWidth) * 100))
        cpsFill.Size = UDim2.new(cps/100, 0, 1, 0)
        cpsValueLabel.Text = tostring(cps)
        infoLabel.Text = "Click / Wait: " .. math.floor(500/cps) .. "ms / " .. math.floor(500/cps) .. "ms"
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- === ACTIVATION MODE PANEL ===
local modePanel = makePanel(content, 52, 2)
makeLabel(modePanel, "ACTIVATION MODE", 10, Color3.fromRGB(136,136,136), 10, 8)

local holdBtn = Instance.new("TextButton")
holdBtn.Size = UDim2.new(0, 70, 0, 22)
holdBtn.Position = UDim2.new(0, 10, 0, 24)
holdBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
holdBtn.TextColor3 = Color3.fromRGB(136, 136, 136)
holdBtn.Text = "Hold"
holdBtn.TextSize = 12
holdBtn.Font = Enum.Font.Gotham
holdBtn.BorderSizePixel = 1
holdBtn.BorderColor3 = Color3.fromRGB(85, 85, 85)
holdBtn.Parent = modePanel
Instance.new("UICorner", holdBtn).CornerRadius = UDim.new(0,3)

local toggleBtn2 = Instance.new("TextButton")
toggleBtn2.Size = UDim2.new(0, 70, 0, 22)
toggleBtn2.Position = UDim2.new(0, 88, 0, 24)
toggleBtn2.BackgroundColor3 = Color3.fromRGB(19, 50, 80)
toggleBtn2.TextColor3 = Color3.fromRGB(68, 170, 255)
toggleBtn2.Text = "Toggle"
toggleBtn2.TextSize = 12
toggleBtn2.Font = Enum.Font.GothamBold
toggleBtn2.BorderSizePixel = 1
toggleBtn2.BorderColor3 = Color3.fromRGB(68, 170, 255)
toggleBtn2.Parent = modePanel
Instance.new("UICorner", toggleBtn2).CornerRadius = UDim.new(0,3)

holdBtn.MouseButton1Click:Connect(function()
    clickMode = "hold"
    holdBtn.BackgroundColor3 = Color3.fromRGB(19, 50, 80)
    holdBtn.TextColor3 = Color3.fromRGB(68, 170, 255)
    holdBtn.BorderColor3 = Color3.fromRGB(68, 170, 255)
    holdBtn.Font = Enum.Font.GothamBold
    toggleBtn2.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
    toggleBtn2.TextColor3 = Color3.fromRGB(136, 136, 136)
    toggleBtn2.BorderColor3 = Color3.fromRGB(85, 85, 85)
    toggleBtn2.Font = Enum.Font.Gotham
end)

toggleBtn2.MouseButton1Click:Connect(function()
    clickMode = "toggle"
    toggleBtn2.BackgroundColor3 = Color3.fromRGB(19, 50, 80)
    toggleBtn2.TextColor3 = Color3.fromRGB(68, 170, 255)
    toggleBtn2.BorderColor3 = Color3.fromRGB(68, 170, 255)
    toggleBtn2.Font = Enum.Font.GothamBold
    holdBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 61)
    holdBtn.TextColor3 = Color3.fromRGB(136, 136, 136)
    holdBtn.BorderColor3 = Color3.fromRGB(85, 85, 85)
    holdBtn.Font = Enum.Font.Gotham
end)

-- === STATUS PANEL ===
local statusPanel = makePanel(content, 44, 3)
local statusLabel = makeLabel(statusPanel, "● INACTIVE", 13, Color3.fromRGB(200, 80, 80), 10, 14, 200, 16)
statusLabel.Font = Enum.Font.GothamBold

local clickCountLabel = makeLabel(statusPanel, "Clicks: 0", 11, Color3.fromRGB(100, 100, 120), 200, 16, 100, 14)

-- === START/STOP BUTTON ===
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(1, 0, 0, 36)
startBtn.BackgroundColor3 = Color3.fromRGB(26, 71, 42)
startBtn.TextColor3 = Color3.fromRGB(40, 200, 64)
startBtn.Text = "▶  START CLICKING"
startBtn.TextSize = 13
startBtn.Font = Enum.Font.GothamBold
startBtn.BorderColor3 = Color3.fromRGB(40, 200, 64)
startBtn.BorderSizePixel = 1
startBtn.LayoutOrder = 4
startBtn.Parent = content
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,4)

local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, 0, 0, 16)
hintLabel.BackgroundTransparency = 1
hintLabel.Text = "Press ` to toggle clicking  •  Press K to show/hide"
hintLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
hintLabel.TextSize = 10
hintLabel.Font = Enum.Font.Gotham
hintLabel.TextXAlignment = Enum.TextXAlignment.Center
hintLabel.LayoutOrder = 5
hintLabel.Parent = content

-- === CLICK LOGIC ===
local function setClicking(state)
    clicking = state
    if clicking then
        statusLabel.Text = "● ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(40, 200, 64)
        startBtn.Text = "⏹  STOP CLICKING"
        startBtn.BackgroundColor3 = Color3.fromRGB(74, 18, 32)
        startBtn.TextColor3 = Color3.fromRGB(226, 75, 74)
        startBtn.BorderColor3 = Color3.fromRGB(226, 75, 74)
    else
        statusLabel.Text = "● INACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        startBtn.Text = "▶  START CLICKING"
        startBtn.BackgroundColor3 = Color3.fromRGB(26, 71, 42)
        startBtn.TextColor3 = Color3.fromRGB(40, 200, 64)
        startBtn.BorderColor3 = Color3.fromRGB(40, 200, 64)
    end
end

local function autoclick()
    while clicking do
        local interval = 1 / cps
        mouse1press()
        task.wait(0.01)
        mouse1release()
        if not unlimited then
            clickCount += 1
            clickCountLabel.Text = "Clicks: " .. clickCount
            if clickLimit > 0 and clickCount >= clickLimit then
                setClicking(false)
                break
            end
        end
        task.wait(math.max(0.001, interval - 0.01))
    end
end

startBtn.MouseButton1Click:Connect(function()
    if clickMode == "toggle" then
        setClicking(not clicking)
        if clicking then task.spawn(autoclick) end
    end
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    -- K = toggle UI
    if input.KeyCode == Enum.KeyCode.K then
        guiVisible = not guiVisible
        mainFrame.Visible = guiVisible
    end

    -- ` = toggle/hold clicking
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

closeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    mainFrame.Visible = false
end)

print("✅ AutoClicker loaded! Press K to show/hide GUI | Press ` to toggle clicking")
