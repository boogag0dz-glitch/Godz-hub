-- ============================================================
-- 🌸 Cherry Blossom Hub | Booga Booga Reborn
-- ============================================================

-- Load WindUI
local WindUI
local ok, err = pcall(function()
    WindUI = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    ))()
end)
if not ok or not WindUI then
    warn("[CherryHub] WindUI failed: " .. tostring(err))
    return
end
print("[CherryHub] WindUI loaded!")

-- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

-- Packets (Booga Booga Reborn's own network module)
local Packets = require(ReplicatedStorage.Modules.Packets)

-- Theme
local Blossom = {
    Pink   = Color3.fromRGB(255, 183, 197),
    Soft   = Color3.fromRGB(247, 198, 208),
    Light  = Color3.fromRGB(255, 209, 220),
    Green  = Color3.fromRGB(134, 239, 172),
    Blue   = Color3.fromRGB(147, 197, 253),
    Yellow = Color3.fromRGB(253, 224, 132),
    Red    = Color3.fromRGB(252, 165, 165),
    Purple = Color3.fromRGB(196, 181, 253),
}

-- ============================================================
-- STATE
-- ============================================================
local State = {
    -- Auto Heal
    AutoHealOn    = false,
    HealPercent   = 99,
    CpsSpeed      = 500,
    SelectedFruit = "Bloodfruit",

    -- Autofarm
    AutofarmOn    = false,
    AutoCollectOn = false,

    -- Raycast Pathfinding
    PathOn        = false,
    PathTarget    = nil,
    PathInterval  = 0.3,
    PathStopDist  = 4,

    -- Speed
    SpeedLock     = false,
    Speed         = 16,
    Jump          = 50,

    -- ESP
    ESPOn         = false,
    MobESPOn      = false,
    TagsOn        = false,
    ChamsOn       = false,
    ESPFill       = Color3.fromRGB(255, 150, 170),
    ESPOutline    = Color3.fromRGB(255, 255, 255),
    ESPCache      = {},
}

-- All healable fruits in the game
local FRUIT_LIST = {
    "Bloodfruit",
    "Fruitcake",
    "Cooked Meat",
    "Cooked Fish",
    "Berry",
    "Cloudberry",
    "Frostfruit",
    "Blossom",
    "Mango",
    "Watermelon",
    "Orange",
    "Lemon",
    "Apple",
    "Strawberry",
    "Bluefruit",
    "Yellowfruit",
    "Pinefruit",
}

-- ============================================================
-- HELPERS
-- ============================================================
local function getChar()  return LocalPlayer.Character end
local function getHum()   local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot()  local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function notify(title, msg, dur)
    pcall(function()
        WindUI:Notify({ Title = title, Content = msg, Duration = dur or 3 })
    end)
end

local function applySpeed()
    local h = getHum()
    if h then h.WalkSpeed = State.Speed h.JumpPower = State.Jump end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if State.SpeedLock then applySpeed() end
end)

-- ============================================================
-- AUTO HEAL CORE (Packets-based, your code)
-- ============================================================
local healHumanoid  = nil
local cachedFruit   = nil
local lastUseTime   = 0

local function setupCharacter(char)
    healHumanoid = char:WaitForChild("Humanoid")
    cachedFruit  = nil -- reset cache on respawn
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

task.spawn(function()
    while task.wait() do
        if not State.AutoHealOn then continue end
        if not healHumanoid or healHumanoid.Health <= 0 then continue end

        local hp = (healHumanoid.Health / healHumanoid.MaxHealth) * 100
        if hp > State.HealPercent then continue end

        local now = os.clock()
        if now - lastUseTime < (1 / State.CpsSpeed) then continue end

        -- Find MainGui inventory
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        if not mainGui then continue end

        local inventory = mainGui:FindFirstChild("RightPanel")
            and mainGui.RightPanel:FindFirstChild("Inventory")
            and mainGui.RightPanel.Inventory:FindFirstChild("List")
        if not inventory then continue end

        -- Re-cache if lost
        if not cachedFruit or not cachedFruit.Parent then
            cachedFruit = nil
            for _, item in ipairs(inventory:GetChildren()) do
                if item:IsA("ImageLabel") and item.Name == State.SelectedFruit then
                    cachedFruit = item
                    break
                end
            end
        end

        if cachedFruit then
            local success = pcall(function()
                Packets.UseBagItem.send(cachedFruit.LayoutOrder)
            end)
            if success then
                lastUseTime = os.clock()
            else
                cachedFruit = nil -- reset cache if send failed
            end
        end
    end
end)

-- ============================================================
-- AUTOFARM CORE
-- ============================================================
local function autofarmLoop()
    while State.AutofarmOn do
        local root = getRoot()
        local hum  = getHum()
        if root and hum then
            local best, bestDist, bestPrompt = nil, math.huge, nil
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local part = obj.Parent
                    if part and part:IsA("BasePart") then
                        local d = (root.Position - part.Position).Magnitude
                        if d < bestDist then
                            best = part bestDist = d bestPrompt = obj
                        end
                    end
                end
            end
            if bestPrompt then
                local maxD = bestPrompt.MaxActivationDistance or 10
                if bestDist > maxD then
                    hum:MoveTo(best.Position)
                    local done, c = false, nil
                    c = hum.MoveToFinished:Connect(function() done = true c:Disconnect() end)
                    local t = tick()
                    while not done and tick()-t < 5 do task.wait(0.1) end
                    pcall(function() c:Disconnect() end)
                end
                pcall(function() fireproximityprompt(bestPrompt) end)
            end
        end
        task.wait(0.6)
    end
end

-- ============================================================
-- AUTO COLLECT CORE
-- ============================================================
local function autoCollectLoop()
    while State.AutoCollectOn do
        local root = getRoot()
        if root then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    if n:find("drop") or n:find("item") or n:find("pickup") or n:find("loot") then
                        if (root.Position - obj.Position).Magnitude < 30 then
                            root.CFrame = CFrame.new(obj.Position + Vector3.new(0,3,0))
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
        task.wait(0.4)
    end
end

-- ============================================================
-- RAYCAST PATHFINDING CORE
-- ============================================================
local RAY_DIST    = 20
local PROBE_ANGLE = 45
local STEP_HEIGHT = 3.5
local PROBE_COUNT = 7

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function buildExclude()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(list, p.Character) end
    end
    return list
end

local function probeRay(origin, dir)
    rayParams.FilterDescendantsInstances = buildExclude()
    local result = workspace:Raycast(origin, dir * RAY_DIST, rayParams)
    if result then return result.Distance, result.Instance, result.Position end
    return RAY_DIST, nil, origin + dir * RAY_DIST
end

local function rotateY(vec, deg)
    local r = math.rad(deg)
    return Vector3.new(
        vec.X * math.cos(r) + vec.Z * math.sin(r),
        vec.Y,
        -vec.X * math.sin(r) + vec.Z * math.cos(r)
    )
end

local function flatDir(from, to)
    local d = Vector3.new(to.X - from.X, 0, to.Z - from.Z)
    return d.Magnitude > 0.01 and d.Unit or Vector3.new(0,0,1)
end

local function steer(rootPos, targetPos)
    local toTarget = flatDir(rootPos, targetPos)
    local origin   = rootPos + Vector3.new(0, 1, 0)

    -- Try direct
    local directDist, hitInst, hitPos = probeRay(origin, toTarget)
    if directDist >= RAY_DIST - 1 then
        return toTarget, false, false
    end

    -- Check jump
    if hitInst and hitPos then
        local obstH = hitPos.Y - (rootPos.Y - 2.5)
        if obstH > 0 and obstH <= STEP_HEIGHT then
            return toTarget, true, false
        end
    end

    -- Probe angles
    local bestDir, bestDist = nil, 0
    for i = 1, PROBE_COUNT do
        local angle = (i / PROBE_COUNT) * PROBE_ANGLE
        local ld = probeRay(origin, rotateY(toTarget, -angle))
        local rd = probeRay(origin, rotateY(toTarget,  angle))
        if ld > bestDist then bestDist = ld bestDir = rotateY(toTarget, -angle) end
        if rd > bestDist then bestDist = rd bestDir = rotateY(toTarget,  angle) end
    end

    -- Probe up (slopes)
    local upDist = probeRay(origin, (toTarget + Vector3.new(0, 0.5, 0)).Unit)
    if upDist > bestDist then
        return toTarget, true, false
    end

    if bestDir then return bestDir, false, false end
    return -toTarget, false, true
end

local function raycastPathfindLoop()
    while State.PathOn do
        local target = State.PathTarget and Players:FindFirstChild(State.PathTarget)
        local root   = getRoot()
        local hum    = getHum()

        if target and target.Character and root and hum then
            local tr = target.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local dist = (root.Position - tr.Position).Magnitude
                if dist > State.PathStopDist then
                    local dir, doJump, stuck = steer(root.Position, tr.Position)
                    local walkTo = root.Position + dir * 8
                    walkTo = Vector3.new(walkTo.X, tr.Position.Y, walkTo.Z)
                    hum:MoveTo(walkTo)
                    if doJump and hum.FloorMaterial ~= Enum.Material.Air then
                        hum.Jump = true
                    end
                    if stuck then
                        task.wait(0.2)
                        hum.Jump = true
                    end
                else
                    hum:MoveTo(root.Position)
                end
            end
        end
        task.wait(State.PathInterval)
    end
    local h = getHum() local r = getRoot()
    if h and r then h:MoveTo(r.Position) end
end

-- ============================================================
-- ESP CORE
-- ============================================================
local function addESP(p)
    if p == LocalPlayer or not p.Character then return end
    if State.ESPCache[p.Name] and State.ESPCache[p.Name].Parent then return end
    local h = Instance.new("Highlight")
    h.FillColor = State.ESPFill h.OutlineColor = State.ESPOutline
    h.FillTransparency = 0.45 h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = p.Character h.Parent = p.Character
    State.ESPCache[p.Name] = h
end

local function clearESP(p)
    local h = State.ESPCache[p.Name]
    if h and h.Parent then h:Destroy() end
    State.ESPCache[p.Name] = nil
end

local function clearAllESP()
    for _, h in pairs(State.ESPCache) do
        if h and h.Parent then h:Destroy() end
    end
    State.ESPCache = {}
end

local function espLoop()
    while State.ESPOn do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if p.Character then
                    addESP(p)
                    local h = State.ESPCache[p.Name]
                    if h and h.Parent then
                        h.FillColor    = State.ESPFill
                        h.OutlineColor = State.ESPOutline
                    end
                else clearESP(p) end
            end
        end
        task.wait(1.5)
    end
    clearAllESP()
end

Players.PlayerRemoving:Connect(clearESP)

local function mobEspLoop()
    while State.MobESPOn do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid")
                and not obj:FindFirstChildOfClass("Highlight") then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character == obj then isPlayer = true break end
                end
                if not isPlayer then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255,200,100)
                    h.OutlineColor = Color3.fromRGB(255,230,150)
                    h.FillTransparency = 0.4 h.OutlineTransparency = 0
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee = obj h.Parent = obj
                end
            end
        end
        task.wait(3)
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local h = obj:FindFirstChildOfClass("Highlight")
            if h then h:Destroy() end
        end
    end
end

-- ============================================================
-- NAME TAGS CORE
-- ============================================================
local function addNameTag(p)
    if p == LocalPlayer then return end
    local char = p.Character if not char then return end
    local head = char:FindFirstChild("Head")
    if not head or head:FindFirstChild("CB_Tag") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "CB_Tag" bb.Size = UDim2.new(0,130,0,44)
    bb.StudsOffset = Vector3.new(0,3.5,0) bb.AlwaysOnTop = true bb.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0.72,0)
    frame.BackgroundColor3 = Blossom.Pink
    frame.BackgroundTransparency = 0.25 frame.BorderSizePixel = 0 frame.Parent = bb
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-8,1,0) label.Position = UDim2.new(0,4,0,0)
    label.BackgroundTransparency = 1 label.Text = p.Name
    label.TextColor3 = Color3.fromRGB(80,30,40) label.Font = Enum.Font.GothamBold
    label.TextScaled = true label.Parent = frame

    local hbBg = Instance.new("Frame")
    hbBg.Size = UDim2.new(1,0,0.22,0) hbBg.Position = UDim2.new(0,0,0.78,0)
    hbBg.BackgroundColor3 = Color3.fromRGB(180,80,100)
    hbBg.BorderSizePixel = 0 hbBg.Parent = bb
    Instance.new("UICorner", hbBg).CornerRadius = UDim.new(0,4)

    local hbFill = Instance.new("Frame")
    hbFill.Size = UDim2.new(1,0,1,0) hbFill.BackgroundColor3 = Blossom.Green
    hbFill.BorderSizePixel = 0 hbFill.Parent = hbBg
    Instance.new("UICorner", hbFill).CornerRadius = UDim.new(0,4)

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local function upd()
            local pct = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)
            hbFill.Size = UDim2.new(pct,0,1,0)
            hbFill.BackgroundColor3 = pct > 0.5 and Blossom.Green or Blossom.Red
        end
        upd()
        hum:GetPropertyChangedSignal("Health"):Connect(upd)
    end
end

local function clearAllTags()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local t = head:FindFirstChild("CB_Tag")
                if t then t:Destroy() end
            end
        end
    end
end

local function nameTagLoop()
    while State.TagsOn do
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then addNameTag(p) end
        end
        task.wait(2)
    end
    clearAllTags()
end

-- ============================================================
-- WINDOW
-- ============================================================
local Window = WindUI:CreateWindow({
    Title         = "🌸 Cherry Blossom Hub",
    Folder        = "BlossomHub",
    Icon          = "sparkles",
    NewElements   = true,
    HideSearchBar = false,
    OpenButton = {
        Title     = "🌸 Open Hub",
        Draggable = true,
        Scale     = 0.55,
        Color     = ColorSequence.new(Blossom.Pink, Blossom.Soft, Blossom.Light),
    },
    Topbar = { Height = 44, ButtonsType = "Mac" },
})

Window:Tag({ Title = "Booga Booga Reborn", Color = Blossom.Pink, Border = true })
print("[CherryHub] Window created!")

local S_Main = Window:Section({ Title = "🌸 Main"     })
local S_Farm = Window:Section({ Title = "🌾 Farming"  })
local S_Move = Window:Section({ Title = "🏃 Movement" })
local S_Vis  = Window:Section({ Title = "👁️ Visuals"  })
local S_Set  = Window:Section({ Title = "⚙️ Settings" })

-- ============================================================
-- HOME TAB
-- ============================================================
local HomeTab = S_Main:Tab({ Title = "Home", Icon = "home", IconColor = Blossom.Pink })

HomeTab:Paragraph({
    Title = "🌸 Welcome!",
    Desc  = "Cherry Blossom Hub for Booga Booga Reborn.\nUse the tabs to navigate features.",
})
HomeTab:Space()
HomeTab:Paragraph({
    Title = "Features",
    Desc  = "🌾 Autofarm + Auto Collect\n🍎 Auto Heal (Packets-based, fruit selector)\n🏃 Raycast Pathfinding + Teleport\n💨 Speed & Jump\n👁️ ESP, Mob ESP, Name Tags, Chams",
})
HomeTab:Space()
HomeTab:Button({
    Title = "Show Welcome Notification", Icon = "sparkles", Justify = "Center",
    Callback = function()
        notify("🌸 Cherry Blossom Hub", "All features ready!", 4)
    end,
})

-- ============================================================
-- AUTOFARM TAB
-- ============================================================
local FarmTab = S_Farm:Tab({ Title = "Autofarm", Icon = "leaf", IconColor = Blossom.Green })

FarmTab:Paragraph({
    Title = "Autofarm Info",
    Desc  = "Finds the nearest ProximityPrompt every 0.6s, walks to it if needed, then fires it.",
})
FarmTab:Space()
FarmTab:Toggle({
    Title = "Enable Autofarm", Desc = "Auto fires nearest resource prompt.",
    Value = false,
    Callback = function(v)
        State.AutofarmOn = v
        if v then task.spawn(autofarmLoop) end
        notify("🌾 Autofarm", v and "Started!" or "Stopped.")
    end,
})
FarmTab:Space()
FarmTab:Toggle({
    Title = "Auto Collect Drops", Desc = "Teleports to nearby drops within 30 studs.",
    Value = false,
    Callback = function(v)
        State.AutoCollectOn = v
        if v then task.spawn(autoCollectLoop) end
        notify("🌾 Auto Collect", v and "Collecting!" or "Stopped.")
    end,
})
FarmTab:Space()
FarmTab:Button({
    Title = "Manual Farm (One Cycle)", Icon = "zap", Justify = "Center",
    Callback = function()
        local root = getRoot()
        if not root then notify("Error","No character!") return end
        local best, bestDist, bestPrompt = nil, math.huge, nil
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local part = obj.Parent
                if part and part:IsA("BasePart") then
                    local d = (root.Position - part.Position).Magnitude
                    if d < bestDist then best=part bestDist=d bestPrompt=obj end
                end
            end
        end
        if bestPrompt then
            pcall(function() fireproximityprompt(bestPrompt) end)
            notify("🌾 Manual Farm","Fired prompt " .. math.floor(bestDist) .. " studs away.")
        else
            notify("🌾 Manual Farm","No prompt found nearby.")
        end
    end,
})

-- ============================================================
-- AUTO HEAL TAB
-- ============================================================
local HealTab = S_Farm:Tab({ Title = "Auto Heal", Icon = "heart", IconColor = Blossom.Red })

HealTab:Paragraph({
    Title = "Auto Heal Info",
    Desc  = "Uses Booga Booga's own Packets.UseBagItem to heal directly from your inventory.\nSelect your fruit, set your HP threshold, and enable.",
})
HealTab:Space()

-- Fruit selector dropdown
HealTab:Dropdown({
    Title    = "Heal Fruit",
    Desc     = "Choose which fruit to use for healing.",
    Values   = FRUIT_LIST,
    Value    = 1, -- defaults to Bloodfruit
    Callback = function(value)
        State.SelectedFruit = value
        cachedFruit = nil -- reset cache when fruit changes
        notify("🍎 Auto Heal", "Fruit set to: " .. value)
    end,
})
HealTab:Space()

-- HP threshold slider
HealTab:Slider({
    Title = "Heal When HP Below (%)",
    Desc  = "Start healing when your HP % drops below this value.",
    Step  = 1,
    Value = { Min = 1, Max = 99, Default = 99 },
    Callback = function(v)
        State.HealPercent = v
    end,
})
HealTab:Space()

-- CPS speed slider
HealTab:Slider({
    Title = "Heal Speed (CPS)",
    Desc  = "How many times per second to send the heal packet. Higher = faster healing.",
    Step  = 50,
    Value = { Min = 50, Max = 1000, Default = 500 },
    Callback = function(v)
        State.CpsSpeed = v
    end,
})
HealTab:Space()

-- Enable toggle
HealTab:Toggle({
    Title = "Enable Auto Heal",
    Desc  = "Automatically heals using selected fruit via Packets.UseBagItem.",
    Value = false,
    Callback = function(v)
        State.AutoHealOn = v
        cachedFruit = nil -- reset cache on toggle
        notify("🍎 Auto Heal", v and "Auto heal active! Using: " .. State.SelectedFruit or "Auto heal stopped.")
    end,
})
HealTab:Space()

-- Status paragraph showing current settings
HealTab:Paragraph({
    Title = "Heal Priority Info",
    Desc  = "Best fruits to use:\n🩸 Bloodfruit — 4 HP (best for combat)\n🎂 Fruitcake — 4 HP + 35 food\n🍖 Cooked Meat — 1 HP + 35 food\n🐟 Cooked Fish — 1 HP + 20 food\n🫐 Berry — 1.5 HP (easy to farm)\n\nTip: Use Bloodfruit for PvP, Cooked Meat for long farm sessions.",
})
HealTab:Space()

-- Manual heal button
HealTab:Button({
    Title    = "Heal Now (Manual)",
    Desc     = "Sends one heal packet immediately using selected fruit.",
    Icon     = "heart",
    Justify  = "Center",
    Color    = Blossom.Red,
    Callback = function()
        if not healHumanoid then notify("Error","No character!") return end

        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        if not mainGui then notify("🍎 Heal","MainGui not found!") return end

        local inventory = mainGui:FindFirstChild("RightPanel")
            and mainGui.RightPanel:FindFirstChild("Inventory")
            and mainGui.RightPanel.Inventory:FindFirstChild("List")
        if not inventory then notify("🍎 Heal","Inventory not found!") return end

        local found = nil
        for _, item in ipairs(inventory:GetChildren()) do
            if item:IsA("ImageLabel") and item.Name == State.SelectedFruit then
                found = item break
            end
        end

        if found then
            local success = pcall(function()
                Packets.UseBagItem.send(found.LayoutOrder)
            end)
            notify("🍎 Heal", success and "Used: " .. State.SelectedFruit or "Failed to send packet!")
        else
            notify("🍎 Heal", State.SelectedFruit .. " not found in inventory!")
        end
    end,
})

-- ============================================================
-- PATHFINDING TAB
-- ============================================================
local PathTab = S_Move:Tab({ Title = "Pathfinding", Icon = "navigation", IconColor = Blossom.Blue })

PathTab:Paragraph({
    Title = "Custom Raycast Pathfinding",
    Desc  = "Steers around obstacles using raycasts — no PathfindingService needed.\n• Probes 7 angles left & right\n• Jumps obstacles under 3.5 studs\n• Backs up if completely stuck",
})
PathTab:Space()

local function getPlayerList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.Name) end
    end
    return t
end

local PathDrop = PathTab:Dropdown({
    Title = "Target Player", Desc = "Who to follow.",
    Values = getPlayerList(), AllowNone = true,
    Callback = function(v) State.PathTarget = v end,
})
PathTab:Space()
PathTab:Button({
    Title = "Refresh Player List", Icon = "refresh-cw", Justify = "Center",
    Callback = function()
        PathDrop:Refresh(getPlayerList())
        notify("Pathfinding","List refreshed.")
    end,
})
PathTab:Space()
PathTab:Slider({
    Title = "Tick Rate (s)", Desc = "How often raycast steers. Lower = smoother.",
    Step = 0.05,
    Value = { Min = 0.05, Max = 1, Default = 0.3 },
    Callback = function(v) State.PathInterval = v end,
})
PathTab:Space()
PathTab:Slider({
    Title = "Stop Distance (studs)", Desc = "Stop when within this distance of target.",
    Step = 1,
    Value = { Min = 2, Max = 20, Default = 4 },
    Callback = function(v) State.PathStopDist = v end,
})
PathTab:Space()
PathTab:Toggle({
    Title = "Enable Pathfinding", Desc = "Follow selected player with raycast steering.",
    Value = false,
    Callback = function(v)
        State.PathOn = v
        if v then
            if not State.PathTarget then
                State.PathOn = false
                notify("Pathfinding","Select a target first!")
                return
            end
            task.spawn(raycastPathfindLoop)
            notify("🏃 Pathfinding","Following: " .. State.PathTarget)
        else
            notify("🏃 Pathfinding","Stopped.")
        end
    end,
})
PathTab:Space()
PathTab:Button({
    Title = "Teleport to Target", Icon = "zap", Justify = "Center",
    Color = Blossom.Blue,
    Callback = function()
        local t = State.PathTarget and Players:FindFirstChild(State.PathTarget)
        if not t then notify("Teleport","No target selected.") return end
        local tr = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
        local mr = getRoot()
        if tr and mr then
            mr.CFrame = tr.CFrame * CFrame.new(0,0,-3)
            notify("🌸 Teleport","Teleported to " .. t.Name .. "!")
        else
            notify("Teleport","Target not loaded.")
        end
    end,
})

-- ============================================================
-- SPEED TAB
-- ============================================================
local SpeedTab = S_Move:Tab({ Title = "Speed", Icon = "wind", IconColor = Blossom.Yellow })

SpeedTab:Paragraph({
    Title = "Speed Info",
    Desc  = "Default WalkSpeed: 16 (max 21).\nDefault JumpPower: 50.",
})
SpeedTab:Space()
SpeedTab:Slider({
    Title = "Walk Speed", Desc = "Default: 16", Step = 1,
    Value = { Min = 1, Max = 21, Default = 16 },
    Callback = function(v)
        State.Speed = v
        local h = getHum() if h then h.WalkSpeed = v end
    end,
})
SpeedTab:Space()
SpeedTab:Slider({
    Title = "Jump Power", Desc = "Default: 50", Step = 1,
    Value = { Min = 1, Max = 200, Default = 50 },
    Callback = function(v)
        State.Jump = v
        local h = getHum() if h then h.JumpPower = v end
    end,
})
SpeedTab:Space()
SpeedTab:Toggle({
    Title = "Speed Lock (Keep on Respawn)", Value = false,
    Callback = function(v)
        State.SpeedLock = v
        notify("Speed Lock", v and "Active." or "Disabled.")
    end,
})
SpeedTab:Space()

local PGroup = SpeedTab:Group({})
PGroup:Button({
    Title = "Default", Justify = "Center", Icon = "",
    Callback = function()
        State.Speed = 16 State.Jump = 50 applySpeed()
        notify("Speed","Reset to default.")
    end,
})
PGroup:Space()
PGroup:Button({
    Title = "Max (21)", Color = Blossom.Green, Justify = "Center", Icon = "",
    Callback = function()
        State.Speed = 21
        local h = getHum() if h then h.WalkSpeed = 21 end
        notify("Speed","Walk speed 21.")
    end,
})
PGroup:Space()
PGroup:Button({
    Title = "High Jump", Color = Blossom.Blue, Justify = "Center", Icon = "",
    Callback = function()
        State.Jump = 120
        local h = getHum() if h then h.JumpPower = 120 end
        notify("Speed","Jump power 120.")
    end,
})
SpeedTab:Space()
SpeedTab:Button({
    Title = "Reset All Speed", Icon = "refresh-cw", Color = Blossom.Red, Justify = "Center",
    Callback = function()
        State.Speed = 16 State.Jump = 50 applySpeed()
        notify("Speed","All reset.")
    end,
})

-- ============================================================
-- ESP TAB
-- ============================================================
local EspTab = S_Vis:Tab({ Title = "ESP", Icon = "eye", IconColor = Blossom.Pink })

EspTab:Toggle({
    Title = "Player ESP", Desc = "Highlights players through walls.",
    Value = false,
    Callback = function(v)
        State.ESPOn = v
        if v then task.spawn(espLoop) else clearAllESP() end
        notify("👁️ ESP", v and "On!" or "Off.")
    end,
})
EspTab:Space()
EspTab:Colorpicker({
    Title = "Fill Color", Default = State.ESPFill,
    Callback = function(c)
        State.ESPFill = c
        for _, h in pairs(State.ESPCache) do if h and h.Parent then h.FillColor = c end end
    end,
})
EspTab:Space()
EspTab:Colorpicker({
    Title = "Outline Color", Default = State.ESPOutline,
    Callback = function(c)
        State.ESPOutline = c
        for _, h in pairs(State.ESPCache) do if h and h.Parent then h.OutlineColor = c end end
    end,
})
EspTab:Space()
EspTab:Toggle({
    Title = "Mob ESP", Desc = "Highlights NPCs/mobs in orange.",
    Value = false,
    Callback = function(v)
        State.MobESPOn = v
        if v then task.spawn(mobEspLoop) end
        notify("👁️ Mob ESP", v and "On!" or "Off.")
    end,
})
EspTab:Space()
EspTab:Toggle({
    Title = "Player Name Tags", Desc = "Name + live health bar above players.",
    Value = false,
    Callback = function(v)
        State.TagsOn = v
        if v then task.spawn(nameTagLoop) else clearAllTags() end
        notify("👁️ Name Tags", v and "On!" or "Off.")
    end,
})
EspTab:Space()
EspTab:Toggle({
    Title = "Chams", Desc = "Makes enemy parts 40% transparent.",
    Value = false,
    Callback = function(v)
        State.ChamsOn = v
        task.spawn(function()
            while State.ChamsOn do
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        for _, part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                part.LocalTransparencyModifier = 0.4
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end
                    end
                end
            end
        end)
        notify("👁️ Chams", v and "On!" or "Off.")
    end,
})
EspTab:Space()
EspTab:Button({
    Title = "Remove All Visuals", Icon = "trash", Color = Blossom.Red, Justify = "Center",
    Callback = function()
        State.ESPOn = false State.MobESPOn = false
        State.TagsOn = false State.ChamsOn = false
        clearAllESP() clearAllTags()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Highlight") then pcall(function() obj:Destroy() end) end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end
                end
            end
        end
        notify("👁️ Visuals","All cleared.")
    end,
})

-- ============================================================
-- SETTINGS TAB
-- ============================================================
local SetTab = S_Set:Tab({ Title = "Settings", Icon = "settings", IconColor = Blossom.Soft })

SetTab:Paragraph({ Title = "UI Settings", Desc = "Customize your hub." })
SetTab:Space()
SetTab:Keybind({
    Title = "Toggle UI Key", Desc = "Open/close the hub.",
    Value = "RightShift",
    Callback = function(v)
        pcall(function() Window:SetToggleKey(Enum.KeyCode[v]) end)
    end,
})
SetTab:Space()
SetTab:Button({
    Title = "Credits", Icon = "heart", Justify = "Center",
    Callback = function()
        notify("🌸 Credits","Cherry Blossom Hub\nUI: WindUI by Footagesus\nHealing: Packets.UseBagItem", 5)
    end,
})
SetTab:Space()
SetTab:Button({
    Title = "Close UI", Icon = "x", Color = Blossom.Red, Justify = "Center",
    Callback = function() Window:Destroy() end,
})

print("[CherryHub] All tabs loaded! Ready.")
