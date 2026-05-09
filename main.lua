local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local cps = 50
local clicking = false
local clickCount = 0

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
local gui = Instance.new("ScreenGui")
gui.Name = "AutoClickerGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 220)
frame.Position = UDim2.new(0.5, -140, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "⚡ AutoClicker"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 35)
status.BackgroundTransparency = 1
status.Text = "● INACTIVE"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.Font = Enum.Font.GothamBold
status.TextSize = 13
status.Parent = frame

local clicksLabel = Instance.new("TextLabel")
clicksLabel.Size = UDim2.new(1, 0, 0, 20)
clicksLabel.Position = UDim2.new(0, 0, 0, 55)
clicksLabel.BackgroundTransparency = 1
clicksLabel.Text = "Clicks: 0"
clicksLabel.TextColor3 = Color3.new(1,1,1)
clicksLabel.Font = Enum.Font.Gotham
clicksLabel.TextSize = 12
clicksLabel.Parent = frame

local cpsLabel = Instance.new("TextLabel")
cpsLabel.Size = UDim2.new(1, 0, 0, 20)
cpsLabel.Position = UDim2.new(0, 0, 0, 80)
cpsLabel.BackgroundTransparency = 1
cpsLabel.Text = "CPS: 50"
cpsLabel.TextColor3 = Color3.new(1,1,1)
cpsLabel.Font = Enum.Font.Gotham
cpsLabel.TextSize = 12
cpsLabel.Parent = frame

-- Slider
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0, 220, 0, 8)
sliderBg.Position = UDim2.new(0.5, -110, 0, 110)
sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
sliderBg.Parent = frame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(1, 0, 0, 20)
sliderBtn.Position = UDim2.new(0, 0, -0.5, 0)
sliderBtn.BackgroundTransparency = 1
sliderBtn.Text = ""
sliderBtn.Parent = sliderBg

local draggingSlider = false

sliderBtn.MouseButton1Down:Connect(function()
    draggingSlider = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = input.Position.X - sliderBg.AbsolutePosition.X
        local size = math.clamp(pos / sliderBg.AbsoluteSize.X, 0, 1)

        sliderFill.Size = UDim2.new(size, 0, 1, 0)
        cps = math.floor(size * 99) + 1

        cpsLabel.Text = "CPS: " .. cps
    end
end)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 220, 0, 35)
toggleBtn.Position = UDim2.new(0.5, -110, 0, 145)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 90, 50)
toggleBtn.Text = "START CLICKING"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local function updateUI()
    if clicking then
        status.Text = "● ACTIVE"
        status.TextColor3 = Color3.fromRGB(0,255,100)
        toggleBtn.Text = "STOP CLICKING"
    else
        status.Text = "● INACTIVE"
        status.TextColor3 = Color3.fromRGB(255,80,80)
        toggleBtn.Text = "START CLICKING"
    end
end

local function toggleClicking()
    clicking = not clicking
    updateUI()

    if clicking then
        task.spawn(function()
            while clicking do
                doClick()
                clickCount += 1
                clicksLabel.Text = "Clicks: " .. clickCount
                task.wait(1 / cps)
            end
        end)
    end
end

toggleBtn.MouseButton1Click:Connect(toggleClicking)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.K then
        frame.Visible = not frame.Visible
    end

    if input.KeyCode == Enum.KeyCode.BackQuote then
        toggleClicking()
    end
end)

print("✅ Loaded | K = hide/show UI | ` = toggle autoclick")
