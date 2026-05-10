-- ============================================================
-- 🌸 Cherry Blossom Hub | Booga Booga Reborn
-- ============================================================

-- Step 1: Load WindUI with error handling
local WindUI
local ok, err = pcall(function()
    WindUI = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    ))()
end)

if not ok or not WindUI then
    warn("[CherryHub] WindUI failed to load: " .. tostring(err))
    return
end

print("[CherryHub] WindUI loaded successfully!")

-- Step 2: Services
local Players            = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer        = Players.LocalPlayer

-- Step 3: Theme
local Blossom = {
    Pink   = Color3.fromRGB(255, 183, 197),
    Soft   = Color3.fromRGB(247, 198, 208),
    Light  = Color3.fromRGB(255, 209, 220),
    Green  = Color3.fromRGB(134, 239, 172),
    Blue   = Color3.fromRGB(147, 197, 253),
    Yellow = Color3.fromRGB(253, 224, 132),
    Red    = Color3.fromRGB(252, 165, 165),
}

-- Step 4: State
local State = {
    AutofarmOn    = false,
    AutoCollectOn = false,
    PathfindOn    = false,
    PathTarget    = nil,
    PathInterval  = 1,
    SpeedLock     = false,
    Speed         = 16,
    Jump          = 50,
    ESPOn         = false,
    MobESPOn      = false,
    TagsOn        = false,
    ChamsOn       = false,
    ESPFill       = Color3.fromRGB(255, 150, 170),
    ESPOutline    = Color3.fromRGB(255, 255, 255),
    ESPCache      = {},
}

-- Step 5: Utility
local function getChar()  return LocalPlayer.Character end
local function getHum()   local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot()  local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function notify(title, msg)
    pcall(function()
        WindUI:Notify({ Title = title, Content = msg, Duration = 3 })
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
-- AUTOFARM
-- ============================================================
local function runAutofarm()
    while State.AutofarmOn do
        local root = getRoot()
        local hum  = getHum()
        if root and hum then
            local bestPart, bestDist, bestPrompt = nil, math.huge, nil
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local part = obj.Parent
                    if part and part:IsA("BasePart") then
                        local d = (root.Position - part.Position).Magnitude
                        if d < bestDist then
                            bestPart   = part
                            bestDist   = d
                            bestPrompt = obj
                        end
                    end
                end
            end
            if bestPrompt then
                local maxD = bestPrompt.MaxActivationDistance or 10
                if bestDist > maxD then
                    hum:MoveTo(bestPart.Position)
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
-- AUTO COLLECT
-- ============================================================
local function runAutoCollect()
    while State.AutoCollectOn do
        local root = getRoot()
        if root then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    if n:find("drop") or n:find("item") or n:find("pickup") or n:find("loot") then
                        if (root.Position - obj.Position).Magnitude < 30 then
                            root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
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
-- PATHFINDING
-- ============================================================
local function runPathfind()
    while State.PathfindOn do
        local target = State.PathTarget and Players:FindFirstChild(State.PathTarget)
        local myRoot = getRoot()
        local hum    = getHum()
        if target and target.Character and myRoot and hum then
            local tr = target.Character:FindFirstChild("HumanoidRootPart")
            if tr and (myRoot.Position - tr.Position).Magnitude > 5 then
                local path = PathfindingService:CreatePath({
                    AgentHeight   = 5,
                    AgentRadius   = 2,
                    AgentCanJump  = true,
                    AgentCanClimb = true,
                })
                local ok2 = pcall(function() path:ComputeAsync(myRoot.Position, tr.Position) end)
                if ok2 and path.Status == Enum.PathStatus.Success then
                    for _, wp in ipairs(path:GetWaypoints()) do
                        if not State.PathfindOn then break end
                        hum:MoveTo(wp.Position)
                        if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                        local done, c = false, nil
                        c = hum.MoveToFinished:Connect(function() done = true c:Disconnect() end)
                        local t0 = tick()
                        while not done and tick()-t0 < 2 do task.wait(0.1) end
                        pcall(function() c:Disconnect() end)
                    end
                end
            end
        end
        task.wait(State.PathInterval)
    end
end

-- ============================================================
-- ESP
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

local function runESP()
    while State.ESPOn do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if p.Character then
                    addESP(p)
                    local h = State.ESPCache[p.Name]
                    if h and h.Parent then
                        h.FillColor = State.ESPFill
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

-- ============================================================
-- MOB ESP
-- ============================================================
local function runMobESP()
    while State.MobESPOn do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not obj:FindFirstChildOfClass("Highlight") then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character == obj then isPlayer = true break end
                end
                if not isPlayer then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255, 200, 100)
                    h.OutlineColor = Color3.fromRGB(255, 230, 150)
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
-- NAME TAGS
-- ============================================================
local function addNameTag(p)
    if p == LocalPlayer then return end
    local char = p.Character if not char then return end
    local head = char:FindFirstChild("Head")
    if not head or head:FindFirstChild("CB_Tag") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "CB_Tag" bb.Size = UDim2.new(0, 130, 0, 44)
    bb.StudsOffset = Vector3.new(0, 3.5, 0) bb.AlwaysOnTop = true bb.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0.72, 0)
    frame.BackgroundColor3 = Blossom.Pink
    frame.BackgroundTransparency = 0.25 frame.BorderSizePixel = 0 frame.Parent = bb
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 1, 0) label.Position = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1 label.Text = p.Name
    label.TextColor3 = Color3.fromRGB(80, 30, 40) label.Font = Enum.Font.GothamBold
    label.TextScaled = true label.Parent = frame

    local hbBg = Instance.new("Frame")
    hbBg.Size = UDim2.new(1, 0, 0.22, 0) hbBg.Position = UDim2.new(0, 0, 0.78, 0)
    hbBg.BackgroundColor3 = Color3.fromRGB(180, 80, 100) hbBg.BorderSizePixel = 0 hbBg.Parent = bb
    Instance.new("UICorner", hbBg).CornerRadius = UDim.new(0, 4)

    local hbFill = Instance.new("Frame")
    hbFill.Size = UDim2.new(1, 0, 1, 0) hbFill.BackgroundColor3 = Blossom.Green
    hbFill.BorderSizePixel = 0 hbFill.Parent = hbBg
    Instance.new("UICorner", hbFill).CornerRadius = UDim.new(0, 4)

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local function upd()
            local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            hbFill.Size = UDim2.new(pct, 0, 1, 0)
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
            if head then local t = head:FindFirstChild("CB_Tag") if t then t:Destroy() end end
        end
    end
end

local function runNameTags()
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
    Topbar = {
        Height      = 44,
        ButtonsType = "Mac",
    },
})

Window:Tag({ Title = "Booga Booga Reborn", Color = Blossom.Pink, Border = true })

print("[CherryHub] Window created!")

-- ============================================================
-- SECTIONS
-- ============================================================
local S_Main  = Window:Section({ Title = "🌸 Main"     })
local S_Farm  = Window:Section({ Title = "🌾 Farming"  })
local S_Move  = Window:Section({ Title = "🏃 Movement" })
local S_Vis   = Window:Section({ Title = "👁️ Visuals"  })
local S_Set   = Window:Section({ Title = "⚙️ Settings" })

-- ============================================================
-- HOME TAB
-- ============================================================
local HomeTab = S_Main:Tab({ Title = "Home", Icon = "home", IconColor = Blossom.Pink })

HomeTab:Paragraph({
    Title = "🌸 Welcome!",
    Desc  = "Cherry Blossom Hub for Booga Booga Reborn.\nUse the tabs to access all features.",
})
HomeTab:Space()
HomeTab:Paragraph({
    Title = "Features",
    Desc  = "🌾 Autofarm + Auto Collect\n🏃 Pathfinding + Teleport\n💨 Speed & Jump control\n👁️ Player ESP, Mob ESP, Name Tags, Chams",
})
HomeTab:Space()
HomeTab:Button({
    Title = "Show Welcome Notification",
    Icon = "sparkles", Justify = "Center",
    Callback = function()
        notify("🌸 Cherry Blossom Hub", "Welcome! All features are ready.")
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
        if v then task.spawn(runAutofarm) end
        notify("🌾 Autofarm", v and "Started!" or "Stopped.")
    end,
})
FarmTab:Space()
FarmTab:Toggle({
    Title = "Auto Collect Drops", Desc = "Teleports to nearby drops within 30 studs.",
    Value = false,
    Callback = function(v)
        State.AutoCollectOn = v
        if v then task.spawn(runAutoCollect) end
        notify("🌾 Auto Collect", v and "Collecting drops!" or "Stopped.")
    end,
})
FarmTab:Space()
FarmTab:Button({
    Title = "Manual Farm (One Cycle)", Icon = "zap", Justify = "Center",
    Callback = function()
        local root = getRoot()
        if not root then notify("Error", "No character!") return end
        local bestPart, bestDist, bestPrompt = nil, math.huge, nil
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local part = obj.Parent
                if part and part:IsA("BasePart") then
                    local d = (root.Position - part.Position).Magnitude
                    if d < bestDist then bestPart = part bestDist = d bestPrompt = obj end
                end
            end
        end
        if bestPrompt then
            pcall(function() fireproximityprompt(bestPrompt) end)
            notify("🌾 Manual Farm", "Fired prompt " .. math.floor(bestDist) .. " studs away.")
        else
            notify("🌾 Manual Farm", "No prompt found nearby.")
        end
    end,
})

-- ============================================================
-- PATHFINDING TAB
-- ============================================================
local PathTab = S_Move:Tab({ Title = "Pathfinding", Icon = "navigation", IconColor = Blossom.Blue })

PathTab:Paragraph({
    Title = "How to Use",
    Desc  = "Pick a player → set interval → enable.\nYour character follows them using PathfindingService.",
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
    Title = "Target Player", Desc = "Who to follow.", AllowNone = true,
    Values = getPlayerList(),
    Callback = function(v) State.PathTarget = v end,
})
PathTab:Space()
PathTab:Button({
    Title = "Refresh Player List", Icon = "refresh-cw", Justify = "Center",
    Callback = function()
        PathDrop:Refresh(getPlayerList())
        notify("Pathfinding", "List refreshed.")
    end,
})
PathTab:Space()
PathTab:Slider({
    Title = "Recalculation Interval (s)",
    Desc  = "How often path is recomputed.",
    Step  = 0.5,
    Value = { Min = 0.5, Max = 6, Default = 1 },
    Callback = function(v) State.PathInterval = v end,
})
PathTab:Space()
PathTab:Toggle({
    Title = "Enable Pathfinding", Desc = "Continuously follow selected player.",
    Value = false,
    Callback = function(v)
        State.PathfindOn = v
        if v then
            if not State.PathTarget then
                State.PathfindOn = false
                notify("Pathfinding", "Select a target first!")
                return
            end
            task.spawn(runPathfind)
            notify("🏃 Pathfinding", "Following: " .. State.PathTarget)
        else
            local h = getHum() local r = getRoot()
            if h and r then h:MoveTo(r.Position) end
            notify("🏃 Pathfinding", "Stopped.")
        end
    end,
})
PathTab:Space()
PathTab:Button({
    Title = "Teleport to Target", Icon = "zap", Justify = "Center",
    Color = Blossom.Blue,
    Callback = function()
        local t = State.PathTarget and Players:FindFirstChild(State.PathTarget)
        if not t then notify("Teleport", "No target selected.") return end
        local tr = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
        local mr = getRoot()
        if tr and mr then
            mr.CFrame = tr.CFrame * CFrame.new(0, 0, -3)
            notify("🌸 Teleport", "Teleported to " .. t.Name .. "!")
        else
            notify("Teleport", "Target not loaded.")
        end
    end,
})

-- ============================================================
-- SPEED TAB
-- ============================================================
local SpeedTab = S_Move:Tab({ Title = "Speed", Icon = "wind", IconColor = Blossom.Yellow })

SpeedTab:Paragraph({
    Title = "Speed Info",
    Desc  = "Default WalkSpeed: 16 (max 21).\nDefault JumpPower: 50.\nEnable Speed Lock to keep settings on respawn.",
})
SpeedTab:Space()
SpeedTab:Slider({
    Title = "Walk Speed", Desc = "Default is 16.", Step = 1,
    Value = { Min = 1, Max = 21, Default = 16 },
    Callback = function(v)
        State.Speed = v
        local h = getHum() if h then h.WalkSpeed = v end
    end,
})
SpeedTab:Space()
SpeedTab:Slider({
    Title = "Jump Power", Desc = "Default is 50.", Step = 1,
    Value = { Min = 1, Max = 200, Default = 50 },
    Callback = function(v)
        State.Jump = v
        local h = getHum() if h then h.JumpPower = v end
    end,
})
SpeedTab:Space()
SpeedTab:Toggle({
    Title = "Speed Lock (Keep on Respawn)",
    Desc  = "Re-applies speed after every respawn.",
    Value = false,
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
        notify("Speed", "Reset to default.")
    end,
})
PGroup:Space()
PGroup:Button({
    Title = "Max (21)", Color = Blossom.Green, Justify = "Center", Icon = "",
    Callback = function()
        State.Speed = 21
        local h = getHum() if h then h.WalkSpeed = 21 end
        notify("Speed", "Walk speed set to 21.")
    end,
})
PGroup:Space()
PGroup:Button({
    Title = "High Jump", Color = Blossom.Blue, Justify = "Center", Icon = "",
    Callback = function()
        State.Jump = 120
        local h = getHum() if h then h.JumpPower = 120 end
        notify("Speed", "Jump power set to 120.")
    end,
})
SpeedTab:Space()
SpeedTab:Button({
    Title = "Reset All Speed", Icon = "refresh-cw", Color = Blossom.Red, Justify = "Center",
    Callback = function()
        State.Speed = 16 State.Jump = 50 applySpeed()
        notify("Speed", "All speed reset.")
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
        if v then task.spawn(runESP) else clearAllESP() end
        notify("👁️ ESP", v and "Player ESP on!" or "Player ESP off.")
    end,
})
EspTab:Space()
EspTab:Colorpicker({
    Title = "Fill Color", Desc = "Inside highlight color.", Default = State.ESPFill,
    Callback = function(c)
        State.ESPFill = c
        for _, h in pairs(State.ESPCache) do if h and h.Parent then h.FillColor = c end end
    end,
})
EspTab:Space()
EspTab:Colorpicker({
    Title = "Outline Color", Desc = "Border highlight color.", Default = State.ESPOutline,
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
        if v then task.spawn(runMobESP) end
        notify("👁️ Mob ESP", v and "On!" or "Off.")
    end,
})
EspTab:Space()
EspTab:Toggle({
    Title = "Player Name Tags", Desc = "Shows name + live health bar above players.",
    Value = false,
    Callback = function(v)
        State.TagsOn = v
        if v then task.spawn(runNameTags) else clearAllTags() end
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
        notify("👁️ Visuals", "All cleared.")
    end,
})

-- ============================================================
-- SETTINGS TAB
-- ============================================================
local SetTab = S_Set:Tab({ Title = "Settings", Icon = "settings", IconColor = Blossom.Soft })

SetTab:Paragraph({ Title = "UI Settings", Desc = "Customize your hub experience." })
SetTab:Space()
SetTab:Keybind({
    Title = "Toggle UI Key", Desc = "Press to open/close the hub.",
    Value = "RightAlt",
    Callback = function(v)
        pcall(function() Window:SetToggleKey(Enum.KeyCode[v]) end)
    end,
})
SetTab:Space()
SetTab:Button({
    Title = "Credits", Icon = "heart", Justify = "Center",
    Callback = function()
        notify("🌸 Credits", "Cherry Blossom Hub\nUI: WindUI by Footagesus\nHub: Godz Hub", 5)
    end,
})
SetTab:Space()
SetTab:Button({
    Title = "Close UI", Icon = "x", Color = Blossom.Red, Justify = "Center",
    Callback = function() Window:Destroy() end,
})

print("[CherryHub] All tabs loaded! Script ready.")
