-- ============================================================
-- 🌸 CHERRY BLOSSOM HUB | Booga Booga Reborn
-- ============================================================

local Players            = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService         = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- Load WindUI
-- ============================================================
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

-- ============================================================
-- Load Godz Hub backend (optional)
-- ============================================================
local GodzHub = nil
pcall(function()
    GodzHub = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/boogag0dz-glitch/Godz-hub/main/main.lua"
    ))()
end)

-- ============================================================
-- Theme Colors
-- ============================================================
local Blossom = {
    Primary   = Color3.fromRGB(255, 183, 197),
    Secondary = Color3.fromRGB(247, 198, 208),
    Accent    = Color3.fromRGB(255, 209, 220),
    Green     = Color3.fromRGB(134, 239, 172),
    Blue      = Color3.fromRGB(147, 197, 253),
    Yellow    = Color3.fromRGB(253, 224, 132),
    Red       = Color3.fromRGB(252, 165, 165),
    Purple    = Color3.fromRGB(196, 181, 253),
}

-- ============================================================
-- Global State
-- ============================================================
_G.CB = {
    AutofarmEnabled    = false,
    AutoCollectEnabled = false,
    PathfindEnabled    = false,
    PathfindTarget     = nil,
    PathfindInterval   = 1,
    SpeedLockEnabled   = false,
    LockedSpeed        = 16,
    LockedJump         = 50,
    ESPEnabled         = false,
    MobESPEnabled      = false,
    NameTagsEnabled    = false,
    ChamsEnabled       = false,
    ESPFillColor       = Color3.fromRGB(255, 150, 170),
    ESPOutlineColor    = Color3.fromRGB(255, 255, 255),
    ESPHighlights      = {},
}

-- ============================================================
-- Helpers
-- ============================================================
local function notify(title, content, duration)
    WindUI:Notify({ Title = title, Content = content, Duration = duration or 3 })
end

local function getChar()  return LocalPlayer.Character end
local function getHum()   local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot()  local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function applySpeed(speed, jump)
    local hum = getHum()
    if hum then
        if speed then hum.WalkSpeed = speed end
        if jump  then hum.JumpPower = jump  end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if _G.CB.SpeedLockEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = _G.CB.LockedSpeed
            hum.JumpPower = _G.CB.LockedJump
        end
    end
end)

-- ============================================================
-- AUTOFARM CORE
-- ============================================================
local function autofarmLoop()
    while _G.CB.AutofarmEnabled do
        local root = getRoot()
        local hum  = getHum()
        if root and hum then
            local nearest, nearestDist, nearestPrompt = nil, math.huge, nil
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local part = obj.Parent
                    if part and part:IsA("BasePart") then
                        local dist = (root.Position - part.Position).Magnitude
                        if dist < nearestDist then
                            nearest       = part
                            nearestDist   = dist
                            nearestPrompt = obj
                        end
                    end
                end
            end
            if nearestPrompt then
                local maxDist = nearestPrompt.MaxActivationDistance or 10
                if nearestDist > maxDist then
                    hum:MoveTo(nearest.Position)
                    local moved, conn = false, nil
                    conn = hum.MoveToFinished:Connect(function()
                        moved = true
                        conn:Disconnect()
                    end)
                    local t = tick()
                    while not moved and tick() - t < 5 do task.wait(0.1) end
                    if conn then pcall(function() conn:Disconnect() end) end
                end
                pcall(function() fireproximityprompt(nearestPrompt) end)
            end
        end
        task.wait(0.6)
    end
end

-- ============================================================
-- AUTO COLLECT CORE
-- ============================================================
local function autoCollectLoop()
    while _G.CB.AutoCollectEnabled do
        local root = getRoot()
        if root then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    if n:find("drop") or n:find("item") or n:find("pickup") or n:find("loot") then
                        local dist = (root.Position - obj.Position).Magnitude
                        if dist < 30 then
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
-- PATHFINDING CORE
-- ============================================================
local function pathfindLoop()
    while _G.CB.PathfindEnabled do
        local target = _G.CB.PathfindTarget and Players:FindFirstChild(_G.CB.PathfindTarget)
        local myRoot = getRoot()
        local hum    = getHum()

        if target and target.Character and myRoot and hum then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and (myRoot.Position - targetRoot.Position).Magnitude > 5 then
                local path = PathfindingService:CreatePath({
                    AgentHeight    = 5,
                    AgentRadius    = 2,
                    AgentCanJump   = true,
                    AgentCanClimb  = true,
                    WaypointSpacing = 4,
                })
                local ok = pcall(function()
                    path:ComputeAsync(myRoot.Position, targetRoot.Position)
                end)
                if ok and path.Status == Enum.PathStatus.Success then
                    for _, wp in ipairs(path:GetWaypoints()) do
                        if not _G.CB.PathfindEnabled then break end
                        if not (target.Character and target.Character:FindFirstChild("HumanoidRootPart")) then break end
                        hum:MoveTo(wp.Position)
                        if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
                        local moved, conn = false, nil
                        conn = hum.MoveToFinished:Connect(function()
                            moved = true
                            conn:Disconnect()
                        end)
                        local t0 = tick()
                        while not moved and tick() - t0 < 2 do task.wait(0.1) end
                        if conn then pcall(function() conn:Disconnect() end) end
                    end
                end
            end
        end
        task.wait(_G.CB.PathfindInterval)
    end
end

-- ============================================================
-- ESP CORE
-- ============================================================
local function clearHighlightFor(p)
    local h = _G.CB.ESPHighlights[p.Name]
    if h and h.Parent then h:Destroy() end
    _G.CB.ESPHighlights[p.Name] = nil
end

local function addHighlight(p)
    if p == LocalPlayer then return end
    local char = p.Character
    if not char then return end
    if _G.CB.ESPHighlights[p.Name] and _G.CB.ESPHighlights[p.Name].Parent then return end
    local h = Instance.new("Highlight")
    h.FillColor           = _G.CB.ESPFillColor
    h.OutlineColor        = _G.CB.ESPOutlineColor
    h.FillTransparency    = 0.45
    h.OutlineTransparency = 0
    h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee             = char
    h.Parent              = char
    _G.CB.ESPHighlights[p.Name] = h
end

local function removeAllESP()
    for _, h in pairs(_G.CB.ESPHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    _G.CB.ESPHighlights = {}
end

local function espLoop()
    while _G.CB.ESPEnabled do
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if p.Character then
                    addHighlight(p)
                    local h = _G.CB.ESPHighlights[p.Name]
                    if h and h.Parent then
                        h.FillColor    = _G.CB.ESPFillColor
                        h.OutlineColor = _G.CB.ESPOutlineColor
                    end
                else
                    clearHighlightFor(p)
                end
            end
        end
        task.wait(1.5)
    end
    removeAllESP()
end

Players.PlayerRemoving:Connect(clearHighlightFor)

-- ============================================================
-- MOB ESP CORE
-- ============================================================
local function mobEspLoop()
    while _G.CB.MobESPEnabled do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not obj:FindFirstChildOfClass("Highlight") then
                local isPlayer = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character == obj then isPlayer = true break end
                end
                if not isPlayer then
                    local h = Instance.new("Highlight")
                    h.FillColor           = Color3.fromRGB(255, 200, 100)
                    h.OutlineColor        = Color3.fromRGB(255, 230, 150)
                    h.FillTransparency    = 0.4
                    h.OutlineTransparency = 0
                    h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee             = obj
                    h.Parent              = obj
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
    local char = p.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head or head:FindFirstChild("CB_NameTag") then return end

    local bb = Instance.new("BillboardGui")
    bb.Name        = "CB_NameTag"
    bb.Size        = UDim2.new(0, 130, 0, 44)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent      = head

    local frame = Instance.new("Frame")
    frame.Size                   = UDim2.new(1, 0, 0.72, 0)
    frame.BackgroundColor3       = Color3.fromRGB(255, 183, 197)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel        = 0
    frame.Parent                 = bb
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size                   = UDim2.new(1, -8, 1, 0)
    label.Position               = UDim2.new(0, 4, 0, 0)
    label.BackgroundTransparency = 1
    label.Text                   = p.Name
    label.TextColor3             = Color3.fromRGB(80, 30, 40)
    label.TextStrokeTransparency = 0.6
    label.Font                   = Enum.Font.GothamBold
    label.TextScaled             = true
    label.Parent                 = frame

    local hbBg = Instance.new("Frame")
    hbBg.Size                   = UDim2.new(1, 0, 0.22, 0)
    hbBg.Position               = UDim2.new(0, 0, 0.78, 0)
    hbBg.BackgroundColor3       = Color3.fromRGB(180, 80, 100)
    hbBg.BackgroundTransparency = 0
    hbBg.BorderSizePixel        = 0
    hbBg.Parent                 = bb
    Instance.new("UICorner", hbBg).CornerRadius = UDim.new(0, 4)

    local hbFill = Instance.new("Frame")
    hbFill.Size                   = UDim2.new(1, 0, 1, 0)
    hbFill.BackgroundColor3       = Color3.fromRGB(134, 239, 172)
    hbFill.BackgroundTransparency = 0
    hbFill.BorderSizePixel        = 0
    hbFill.Parent                 = hbBg
    Instance.new("UICorner", hbFill).CornerRadius = UDim.new(0, 4)

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local function updateBar()
            local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            hbFill.Size = UDim2.new(pct, 0, 1, 0)
            hbFill.BackgroundColor3 = pct > 0.5
                and Color3.fromRGB(134, 239, 172)
                or  Color3.fromRGB(252, 165, 165)
        end
        updateBar()
        hum:GetPropertyChangedSignal("Health"):Connect(updateBar)
    end
end

local function removeAllNameTags()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local t = head:FindFirstChild("CB_NameTag")
                if t then t:Destroy() end
            end
        end
    end
end

local function nameTagLoop()
    while _G.CB.NameTagsEnabled do
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then addNameTag(p) end
        end
        task.wait(2)
    end
    removeAllNameTags()
end

-- ============================================================
-- CREATE WINDOW
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
        Color     = ColorSequence.new(
            Blossom.Primary,
            Blossom.Secondary,
            Blossom.Accent
        ),
    },
    Topbar = {
        Height          = 44,
        ButtonsType     = "Mac",
        BackgroundColor = Blossom.Primary,
    },
})

Window:Tag({
    Title  = "Booga Booga Reborn",
    Color  = Blossom.Primary,
    Border = true,
})

-- ============================================================
-- SECTIONS
-- ============================================================
local MainSection     = Window:Section({ Title = "🌸 Main"      })
local FarmSection     = Window:Section({ Title = "🌾 Farming"   })
local MovementSection = Window:Section({ Title = "🏃 Movement"  })
local VisualSection   = Window:Section({ Title = "👁️ Visuals"    })
local SettingsSection = Window:Section({ Title = "⚙️ Settings"  })

-- ============================================================
-- TAB: HOME
-- ============================================================
local HomeTab = MainSection:Tab({
    Title     = "Home",
    Icon      = "home",
    IconColor = Blossom.Primary,
})

HomeTab:Paragraph({
    Title = "🌸 Welcome to Cherry Blossom Hub",
    Desc  = "A clean and beautiful script hub for Booga Booga Reborn. Use the tabs on the left to navigate between features.",
})

HomeTab:Space()

HomeTab:Paragraph({
    Title = "Feature List",
    Desc  = "• Autofarm — auto fires nearby resource prompts\n• Auto Collect — teleports to nearby drops\n• Pathfinding — walks/follows a chosen player\n• Teleport — instant warp to any player\n• Speed & Jump — tune your movement\n• Player ESP — highlights through walls\n• Mob ESP — highlights NPCs\n• Name Tags — health bars above players\n• Chams — enemy transparency",
})

HomeTab:Space()

HomeTab:Button({
    Title    = "🌸 Show Welcome Notification",
    Justify  = "Center",
    Icon     = "sparkles",
    Callback = function()
        notify("🌸 Cherry Blossom Hub", "Welcome! All features are ready to use.", 4)
    end,
})

-- ============================================================
-- TAB: AUTOFARM
-- ============================================================
local AutofarmTab = FarmSection:Tab({
    Title     = "Autofarm",
    Icon      = "leaf",
    IconColor = Blossom.Green,
})

AutofarmTab:Paragraph({
    Title = "How Autofarm Works",
    Desc  = "Scans workspace every 0.6s for the nearest ProximityPrompt. Walks to it if out of range, then fires it automatically.",
})

AutofarmTab:Space()

AutofarmTab:Toggle({
    Title = "Enable Autofarm",
    Desc  = "Automatically collects the nearest resource in the world.",
    Value = false,
    Callback = function(state)
        _G.CB.AutofarmEnabled = state
        if state then task.spawn(autofarmLoop) end
        notify("🌾 Autofarm", state and "Autofarm started!" or "Autofarm stopped.")
    end,
})

AutofarmTab:Space()

AutofarmTab:Toggle({
    Title = "Auto Collect Drops",
    Desc  = "Teleports to nearby dropped items (named drop/item/pickup/loot) within 30 studs.",
    Value = false,
    Callback = function(state)
        _G.CB.AutoCollectEnabled = state
        if state then task.spawn(autoCollectLoop) end
        notify("🌾 Auto Collect", state and "Now collecting drops!" or "Stopped collecting drops.")
    end,
})

AutofarmTab:Space()

AutofarmTab:Button({
    Title    = "Manual Farm (One Cycle)",
    Desc     = "Fires the nearest prompt once right now, ignoring the toggle.",
    Icon     = "zap",
    Justify  = "Center",
    Callback = function()
        local root = getRoot()
        if not root then notify("Error", "No character found.") return end
        local nearest, nearestDist, nearestPrompt = nil, math.huge, nil
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local part = obj.Parent
                if part and part:IsA("BasePart") then
                    local dist = (root.Position - part.Position).Magnitude
                    if dist < nearestDist then
                        nearest = part nearest = part nearestDist = dist nearestPrompt = obj
                    end
                end
            end
        end
        if nearestPrompt then
            pcall(function() fireproximityprompt(nearestPrompt) end)
            notify("🌾 Manual Farm", "Triggered prompt " .. math.floor(nearestDist) .. " studs away.")
        else
            notify("🌾 Manual Farm", "No ProximityPrompt found nearby.")
        end
    end,
})

-- ============================================================
-- TAB: PATHFINDING
-- ============================================================
local PathTab = MovementSection:Tab({
    Title     = "Pathfinding",
    Icon      = "navigation",
    IconColor = Blossom.Blue,
})

PathTab:Paragraph({
    Title = "How to Use",
    Desc  = "Select a player → adjust interval → enable. Your character walks to them using Roblox PathfindingService, automatically jumping over obstacles. Use Teleport for an instant warp.",
})

PathTab:Space()

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

local PathDropdown = PathTab:Dropdown({
    Title     = "Target Player",
    Desc      = "The player your character will walk toward.",
    Values    = getPlayerNames(),
    AllowNone = true,
    Callback  = function(value)
        _G.CB.PathfindTarget = value
    end,
})

PathTab:Space()

PathTab:Button({
    Title    = "Refresh Player List",
    Icon     = "refresh-cw",
    Justify  = "Center",
    Callback = function()
        PathDropdown:Refresh(getPlayerNames())
        notify("🏃 Pathfinding", "Player list refreshed.")
    end,
})

PathTab:Space()

PathTab:Slider({
    Title = "Recalculation Interval (s)",
    Desc  = "How often the path is recomputed. Lower = more responsive.",
    Step  = 0.5,
    Value = { Min = 0.5, Max = 6, Default = 1 },
    Callback = function(value)
        _G.CB.PathfindInterval = value
    end,
})

PathTab:Space()

PathTab:Toggle({
    Title = "Enable Pathfinding",
    Desc  = "Continuously walks toward the selected player.",
    Value = false,
    Callback = function(state)
        _G.CB.PathfindEnabled = state
        if state then
            if not _G.CB.PathfindTarget then
                _G.CB.PathfindEnabled = false
                notify("🏃 Pathfinding", "Please select a target player first!")
                return
            end
            task.spawn(pathfindLoop)
            notify("🏃 Pathfinding", "Now following: " .. _G.CB.PathfindTarget)
        else
            local hum = getHum()
            local root = getRoot()
            if hum and root then hum:MoveTo(root.Position) end
            notify("🏃 Pathfinding", "Pathfinding stopped.")
        end
    end,
})

PathTab:Space()

PathTab:Button({
    Title    = "Teleport to Target",
    Desc     = "Instantly warps you directly behind the selected player.",
    Icon     = "zap",
    Justify  = "Center",
    Color    = Blossom.Blue,
    Callback = function()
        local target = _G.CB.PathfindTarget and Players:FindFirstChild(_G.CB.PathfindTarget)
        if not target then notify("Teleport", "No target selected.") return end
        local tr = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local mr = getRoot()
        if tr and mr then
            mr.CFrame = tr.CFrame * CFrame.new(0, 0, -3)
            notify("🌸 Teleport", "Teleported to " .. target.Name .. "!")
        else
            notify("Teleport", "Target or character not loaded.")
        end
    end,
})

-- ============================================================
-- TAB: SPEED
-- ============================================================
local SpeedTab = MovementSection:Tab({
    Title     = "Speed",
    Icon      = "wind",
    IconColor = Blossom.Yellow,
})

SpeedTab:Paragraph({
    Title = "Speed Info",
    Desc  = "Default WalkSpeed is 16, capped at 21 to keep movement natural. Enable Speed Lock to keep settings after respawning.",
})

SpeedTab:Space()

SpeedTab:Slider({
    Title = "Walk Speed",
    Desc  = "Adjust your character's walk speed. (Default: 16)",
    Step  = 1,
    Value = { Min = 1, Max = 21, Default = 16 },
    Callback = function(value)
        _G.CB.LockedSpeed = value
        applySpeed(value, nil)
    end,
})

SpeedTab:Space()

SpeedTab:Slider({
    Title = "Jump Power",
    Desc  = "Adjust your character's jump height. (Default: 50)",
    Step  = 1,
    Value = { Min = 1, Max = 200, Default = 50 },
    Callback = function(value)
        _G.CB.LockedJump = value
        applySpeed(nil, value)
    end,
})

SpeedTab:Space()

SpeedTab:Toggle({
    Title = "Speed Lock (Keep on Respawn)",
    Desc  = "Re-applies your speed and jump settings after every respawn.",
    Value = false,
    Callback = function(state)
        _G.CB.SpeedLockEnabled = state
        notify("🏃 Speed Lock", state and "Speed will persist on respawn." or "Speed lock disabled.")
    end,
})

SpeedTab:Space()

local PresetGroup = SpeedTab:Group({})

PresetGroup:Button({
    Title    = "Default",
    Justify  = "Center",
    Icon     = "",
    Callback = function()
        _G.CB.LockedSpeed = 16
        _G.CB.LockedJump  = 50
        applySpeed(16, 50)
        notify("Speed", "Reset to default (16 / 50).")
    end,
})

PresetGroup:Space()

PresetGroup:Button({
    Title    = "Max (21)",
    Color    = Blossom.Green,
    Justify  = "Center",
    Icon     = "",
    Callback = function()
        _G.CB.LockedSpeed = 21
        applySpeed(21, nil)
        notify("Speed", "Walk speed set to 21.")
    end,
})

PresetGroup:Space()

PresetGroup:Button({
    Title    = "High Jump",
    Color    = Blossom.Blue,
    Justify  = "Center",
    Icon     = "",
    Callback = function()
        _G.CB.LockedJump = 120
        applySpeed(nil, 120)
        notify("Speed", "Jump power set to 120.")
    end,
})

SpeedTab:Space()

SpeedTab:Button({
    Title    = "Reset All Speed",
    Icon     = "refresh-cw",
    Color    = Blossom.Red,
    Justify  = "Center",
    Callback = function()
        _G.CB.LockedSpeed = 16
        _G.CB.LockedJump  = 50
        applySpeed(16, 50)
        notify("Speed", "All speed settings reset.")
    end,
})

-- ============================================================
-- TAB: ESP
-- ============================================================
local EspTab = VisualSection:Tab({
    Title     = "ESP",
    Icon      = "eye",
    IconColor = Blossom.Primary,
})

EspTab:Section({ Title = "Player ESP" })

EspTab:Toggle({
    Title = "Player Highlight ESP",
    Desc  = "Renders a colored highlight on every player, visible through walls.",
    Value = false,
    Callback = function(state)
        _G.CB.ESPEnabled = state
        if state then task.spawn(espLoop) else removeAllESP() end
        notify("👁️ ESP", state and "Player ESP enabled!" or "Player ESP disabled.")
    end,
})

EspTab:Space()

EspTab:Colorpicker({
    Title    = "Fill Color",
    Desc     = "Body color of the player highlights.",
    Default  = Color3.fromRGB(255, 150, 170),
    Callback = function(color)
        _G.CB.ESPFillColor = color
        for _, h in pairs(_G.CB.ESPHighlights) do
            if h and h.Parent then h.FillColor = color end
        end
    end,
})

EspTab:Space()

EspTab:Colorpicker({
    Title    = "Outline Color",
    Desc     = "Border color of the player highlights.",
    Default  = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        _G.CB.ESPOutlineColor = color
        for _, h in pairs(_G.CB.ESPHighlights) do
            if h and h.Parent then h.OutlineColor = color end
        end
    end,
})

EspTab:Space()

EspTab:Section({ Title = "Mob ESP" })

EspTab:Toggle({
    Title = "Mob Highlight ESP",
    Desc  = "Highlights all NPC and mob models with a Humanoid.",
    Value = false,
    Callback = function(state)
        _G.CB.MobESPEnabled = state
        if state then task.spawn(mobEspLoop) end
        notify("👁️ Mob ESP", state and "Mob ESP enabled!" or "Mob ESP disabled.")
    end,
})

EspTab:Space()

EspTab:Section({ Title = "Name Tags" })

EspTab:Toggle({
    Title = "Player Name Tags",
    Desc  = "Stylized name tag above every player with a live health bar.",
    Value = false,
    Callback = function(state)
        _G.CB.NameTagsEnabled = state
        if state then task.spawn(nameTagLoop) else removeAllNameTags() end
        notify("👁️ Name Tags", state and "Name tags enabled!" or "Name tags disabled.")
    end,
})

EspTab:Space()

EspTab:Section({ Title = "Chams" })

EspTab:Toggle({
    Title = "Chams (Enemy Transparency)",
    Desc  = "Makes all enemy character parts 40% transparent so you can track them through surfaces.",
    Value = false,
    Callback = function(state)
        _G.CB.ChamsEnabled = state
        task.spawn(function()
            while _G.CB.ChamsEnabled do
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
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 0
                        end
                    end
                end
            end
        end)
        notify("👁️ Chams", state and "Chams enabled!" or "Chams disabled.")
    end,
})

EspTab:Space()

EspTab:Button({
    Title    = "Remove All Visuals",
    Desc     = "Clears every ESP, name tag, and cham effect instantly.",
    Icon     = "trash",
    Color    = Blossom.Red,
    Justify  = "Center",
    Callback = function()
        _G.CB.ESPEnabled      = false
        _G.CB.MobESPEnabled   = false
        _G.CB.NameTagsEnabled = false
        _G.CB.ChamsEnabled    = false
        removeAllESP()
        removeAllNameTags()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Highlight") then pcall(function() obj:Destroy() end) end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = 0
                    end
                end
            end
        end
        notify("👁️ Visuals", "All visuals cleared.")
    end,
})

-- ============================================================
-- TAB: SETTINGS
-- ============================================================
local SettingsTab = SettingsSection:Tab({
    Title     = "Settings",
    Icon      = "settings",
    IconColor = Blossom.Secondary,
})

SettingsTab:Paragraph({
    Title = "UI Settings",
    Desc  = "Customize the Cherry Blossom Hub experience.",
})

SettingsTab:Space()

SettingsTab:Keybind({
    Title = "Toggle UI Keybind",
    Desc  = "Press this key to open/close the hub.",
    Value = "RightShift",
    Callback = function(v)
        pcall(function()
            Window:SetToggleKey(Enum.KeyCode[v])
        end)
    end,
})

SettingsTab:Space()

SettingsTab:Toggle({
    Title = "UI Notifications",
    Desc  = "Show popup notifications when features are toggled.",
    Value = true,
    Callback = function(state)
        _G.CB.NotificationsEnabled = state
    end,
})

SettingsTab:Space()

SettingsTab:Button({
    Title    = "🌸 Credits",
    Justify  = "Center",
    Icon     = "heart",
    Callback = function()
        notify("🌸 Credits", "Cherry Blossom Hub\nUI by WindUI (Footagesus)\nScripts by Godz Hub", 5)
    end,
})

SettingsTab:Space()

SettingsTab:Button({
    Title    = "Close UI",
    Icon     = "x",
    Color    = Blossom.Red,
    Justify  = "Center",
    Callback = function()
        Window:Destroy()
    end,
})
