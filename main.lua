-- ============================================================
-- 🌸 Cherry Blossom Hub | Booga Booga Reborn
-- ============================================================

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local LocalPlayer       = Players.LocalPlayer
local Packets           = require(ReplicatedStorage.Modules.Packets)

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

local FRUIT_LIST = {
    "Bloodfruit","Fruitcake","Cooked Meat","Cooked Fish",
    "Berry","Cloudberry","Frostfruit","Blossom",
    "Mango","Watermelon","Orange","Lemon",
    "Apple","Strawberry","Bluefruit","Yellowfruit","Pinefruit",
}

local WALL_LIST = {
    "Wood Wall","Iron Wall","Stone Wall","Ice Wall",
    "Adurite Wall","Crystal Wall","Magnetite Wall",
    "Emerald Wall","Carrot Crystal Wall",
}

-- ============================================================
-- KEYBINDS
-- ============================================================
local Keybinds = {
    ToggleUI   = Enum.KeyCode.RightShift,
    Autofarm   = Enum.KeyCode.F1,
    AutoHeal   = Enum.KeyCode.F2,
    Pathfind   = Enum.KeyCode.F3,
    AutoPinch  = Enum.KeyCode.F4,
    KillAura   = Enum.KeyCode.F5,
}
local function keyName(kc) return kc and kc.Name or "None" end
local function toKeyCode(str)
    local s, kc = pcall(function() return Enum.KeyCode[str] end)
    return (s and kc) or nil
end

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
    -- Pathfinding
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
    -- Auto Pinch
    AutoPinchOn   = false,
    PinchTarget   = nil,
    PinchWall     = "Wood Wall",
    PinchGap      = 2.5,
    PinchInterval = 0.3,
    -- Kill Aura
    KillAuraOn    = false,
    KillAuraRange = 15,
    KillAuraCooldown = 0.1,
    KillAuraTargets = 1,
    -- Resource Aura
    ResourceAuraOn = false,
    ResourceRange  = 20,
    ResourceCooldown = 0.1,
    ResourceTargets = 5,
}

-- ============================================================
-- HELPERS
-- ============================================================
local function getChar()  return LocalPlayer.Character end
local function getHum()   local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot()  local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function notify(title, msg, dur)
    pcall(function() WindUI:Notify({ Title = title, Content = msg, Duration = dur or 3 }) end)
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
-- BYTENET SWING ENCODE (from Herkle Hub)
-- Used for Kill Aura and Resource Aura
-- ============================================================
local function decode(str)
    local b1, b2, b3 = string.byte(str, -4, -2)
    return b1 + b2 * 256 + b3 * 65536
end

local function swingencode(ids)
    if typeof(ids) ~= "table" then ids = {ids} end
    local count = #ids
    local out = {string.char(0x00, 0x11, count, 0x00)}
    for i = 1, count do
        local num = ids[i]
        out[#out+1] = string.char(num%256, math.floor(num/256)%256, math.floor(num/65536)%256, 0x00)
    end
    return table.concat(out)
end

local function runSwing(ids)
    local packet = swingencode(ids)
    ReplicatedStorage:WaitForChild("ByteNetReliable"):FireServer(buffer.fromstring(packet))
end

-- ============================================================
-- UI TOGGLE
-- ============================================================
local UIEnabled = true
local HubGui    = nil

local knownGameGuis = {
    MainGui=true, RegionUI=true, SecondaryGui=true, SpawnGui=true,
    Toast=true, TradeUI=true, ClanUI=true, Topbar=true,
    vignette=true, Calendar=true, CrateUI=true, RobloxGui=true,
}
local existingGuis = {}
for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
    existingGuis[gui] = true
end
LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if HubGui then return end
    if child:IsA("ScreenGui") and not existingGuis[child] and not knownGameGuis[child.Name] then
        HubGui = child
    end
end)
local function toggleUI()
    if HubGui and HubGui.Parent then
        UIEnabled = not UIEnabled
        HubGui.Enabled = UIEnabled
    end
end

-- ============================================================
-- KILL AURA CORE
-- ============================================================
task.spawn(function()
    while true do
        if not State.KillAuraOn then task.wait(0.1) continue end
        local root = getRoot()
        if root then
            local targets = {}
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local pFolder = workspace.Players:FindFirstChild(player.Name)
                    if pFolder then
                        local rootPart = pFolder:FindFirstChild("HumanoidRootPart")
                        local entityID = pFolder:GetAttribute("EntityID")
                        if rootPart and entityID then
                            local dist = (rootPart.Position - root.Position).Magnitude
                            if dist <= State.KillAuraRange then
                                table.insert(targets, { eid = entityID, dist = dist })
                            end
                        end
                    end
                end
            end
            if #targets > 0 then
                table.sort(targets, function(a, b) return a.dist < b.dist end)
                local selected = {}
                for i = 1, math.min(State.KillAuraTargets, #targets) do
                    table.insert(selected, targets[i].eid)
                end
                pcall(function() runSwing(selected) end)
            end
        end
        task.wait(State.KillAuraCooldown)
    end
end)

-- ============================================================
-- RESOURCE AURA CORE
-- ============================================================
task.spawn(function()
    while true do
        if not State.ResourceAuraOn then task.wait(0.1) continue end
        local root = getRoot()
        if root then
            local targets = {}
            -- Check workspace.Resources
            local resourceFolder = workspace:FindFirstChild("Resources")
            if resourceFolder then
                for _, res in pairs(resourceFolder:GetChildren()) do
                    if res:IsA("Model") and res:GetAttribute("EntityID") then
                        local eid = res:GetAttribute("EntityID")
                        local ppart = res.PrimaryPart or res:FindFirstChildWhichIsA("BasePart")
                        if ppart then
                            local dist = (ppart.Position - root.Position).Magnitude
                            if dist <= State.ResourceRange then
                                table.insert(targets, { eid = eid, dist = dist })
                            end
                        end
                    end
                end
            end
            -- Also check for Gold Nodes
            for _, r in pairs(workspace:GetChildren()) do
                if r:IsA("Model") and r.Name == "Gold Node" and r:GetAttribute("EntityID") then
                    local ppart = r.PrimaryPart or r:FindFirstChildWhichIsA("BasePart")
                    if ppart then
                        local dist = (ppart.Position - root.Position).Magnitude
                        if dist <= State.ResourceRange then
                            table.insert(targets, { eid = r:GetAttribute("EntityID"), dist = dist })
                        end
                    end
                end
            end
            if #targets > 0 then
                table.sort(targets, function(a, b) return a.dist < b.dist end)
                local selected = {}
                for i = 1, math.min(State.ResourceTargets, #targets) do
                    table.insert(selected, targets[i].eid)
                end
                pcall(function() runSwing(selected) end)
            end
        end
        task.wait(State.ResourceCooldown)
    end
end)

-- ============================================================
-- AUTO PINCH CORE — correct PlaceStructure format
-- ============================================================
local function autoPinchLoop()
    while State.AutoPinchOn do
        local target = State.PinchTarget and Players:FindFirstChild(State.PinchTarget)
        if target and target.Character then
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local pos    = targetRoot.Position
                local look   = targetRoot.CFrame.LookVector
                local frontPos = pos + look * State.PinchGap
                local backPos  = pos - look * State.PinchGap
                local yAngle   = math.deg(math.atan2(look.X, look.Z))

                task.spawn(function()
                    pcall(function()
                        Packets.PlaceStructure.send({
                            buildingName = State.PinchWall,
                            yrot         = yAngle,
                            vec          = frontPos,
                            isMobile     = false,
                        })
                    end)
                end)
                task.wait(0.05)
                task.spawn(function()
                    pcall(function()
                        Packets.PlaceStructure.send({
                            buildingName = State.PinchWall,
                            yrot         = yAngle,
                            vec          = backPos,
                            isMobile     = false,
                        })
                    end)
                end)
            end
        end
        task.wait(State.PinchInterval)
    end
end

-- ============================================================
-- AUTO HEAL CORE
-- ============================================================
local healHumanoid = nil
local cachedFruit  = nil
local lastUseTime  = 0

local function setupCharacter(char)
    healHumanoid = char:WaitForChild("Humanoid")
    cachedFruit  = nil
end
if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

task.spawn(function()
    while task.wait() do
        if not State.AutoHealOn then continue end
        if not healHumanoid or healHumanoid.Health <= 0 then continue end
        local hp = (healHumanoid.Health / healHumanoid.MaxHealth) * 100
        if hp > State.HealPercent then continue end
        local now = os.clock()
        if now - lastUseTime < (1 / State.CpsSpeed) then continue end
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGui")
        if not mainGui then continue end
        local inventory = mainGui:FindFirstChild("RightPanel")
            and mainGui.RightPanel:FindFirstChild("Inventory")
            and mainGui.RightPanel.Inventory:FindFirstChild("List")
        if not inventory then continue end
        if not cachedFruit or not cachedFruit.Parent then
            cachedFruit = nil
            for _, item in ipairs(inventory:GetChildren()) do
                if item:IsA("ImageLabel") and item.Name == State.SelectedFruit then
                    cachedFruit = item break
                end
            end
        end
        if cachedFruit then
            local success = pcall(function() Packets.UseBagItem.send(cachedFruit.LayoutOrder) end)
            if success then lastUseTime = os.clock() else cachedFruit = nil end
        end
    end
end)

--
-- AUTOFARM CORE
-- 
local function autofarmLoop()
    while State.AutofarmOn do
        local root = getRoot() local hum = getHum()
        if root and hum then
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
                if bestDist > (bestPrompt.MaxActivationDistance or 10) then
                    hum:MoveTo(best.Position)
                    local done, c = false, nil
                    c = hum.MoveToFinished:Connect(function() done=true c:Disconnect() end)
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

local function autoCollectLoop()
    while State.AutoCollectOn do
        local root = getRoot()
        if root then
            local itemFolder = workspace:FindFirstChild("Items")
            if itemFolder then
                for _, item in ipairs(itemFolder:GetChildren()) do
                    if (item:IsA("BasePart") or item:IsA("MeshPart")) then
                        local entityID = item:GetAttribute("EntityID")
                        if entityID and (item.Position - root.Position).Magnitude < 30 then
                            pcall(function() Packets.Pickup.send(entityID) end)
                        end
                    end
                end
            end
        end
        task.wait(0.4)
    end
end

--
-- RAYCAST PATHFIND or Sum
--
local RAY_DIST=20 local PROBE_ANGLE=45 local STEP_HEIGHT=3.5 local PROBE_COUNT=7
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local function buildExclude()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(list, p.Character) end end
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
    return Vector3.new(vec.X*math.cos(r)+vec.Z*math.sin(r), vec.Y, -vec.X*math.sin(r)+vec.Z*math.cos(r))
end
local function flatDir(from, to)
    local d = Vector3.new(to.X-from.X, 0, to.Z-from.Z)
    return d.Magnitude > 0.01 and d.Unit or Vector3.new(0,0,1)
end
local function steer(rootPos, targetPos)
    local toTarget = flatDir(rootPos, targetPos)
    local origin   = rootPos + Vector3.new(0,1,0)
    local directDist, hitInst, hitPos = probeRay(origin, toTarget)
    if directDist >= RAY_DIST-1 then return toTarget, false, false end
    if hitInst and hitPos then
        local obstH = hitPos.Y - (rootPos.Y-2.5)
        if obstH > 0 and obstH <= STEP_HEIGHT then return toTarget, true, false end
    end
    local bestDir, bestDist = nil, 0
    for i = 1, PROBE_COUNT do
        local angle = (i/PROBE_COUNT)*PROBE_ANGLE
        local ld = probeRay(origin, rotateY(toTarget, -angle))
        local rd = probeRay(origin, rotateY(toTarget,  angle))
        if ld > bestDist then bestDist=ld bestDir=rotateY(toTarget,-angle) end
        if rd > bestDist then bestDist=rd bestDir=rotateY(toTarget, angle) end
    end
    local upDist = probeRay(origin, (toTarget+Vector3.new(0,0.5,0)).Unit)
    if upDist > bestDist then return toTarget, true, false end
    if bestDir then return bestDir, false, false end
    return -toTarget, false, true
end
local function raycastPathfindLoop()
    while State.PathOn do
        local target = State.PathTarget and Players:FindFirstChild(State.PathTarget)
        local root = getRoot() local hum = getHum()
        if target and target.Character and root and hum then
            local tr = target.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local dist = (root.Position - tr.Position).Magnitude
                if dist > State.PathStopDist then
                    local dir, doJump, stuck = steer(root.Position, tr.Position)
                    local walkTo = root.Position + dir * 8
                    walkTo = Vector3.new(walkTo.X, tr.Position.Y, walkTo.Z)
                    hum:MoveTo(walkTo)
                    if doJump and hum.FloorMaterial ~= Enum.Material.Air then hum.Jump = true end
                    if stuck then task.wait(0.2) hum.Jump = true end
                else hum:MoveTo(root.Position) end
            end
        end
        task.wait(State.PathInterval)
    end
    local h=getHum() local r=getRoot()
    if h and r then h:MoveTo(r.Position) end
end

-- ============================================================
-- ESP
-- ============================================================
local function addESP(p)
    if p==LocalPlayer or not p.Character then return end
    if State.ESPCache[p.Name] and State.ESPCache[p.Name].Parent then return end
    local h=Instance.new("Highlight")
    h.FillColor=State.ESPFill h.OutlineColor=State.ESPOutline
    h.FillTransparency=0.45 h.OutlineTransparency=0
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee=p.Character h.Parent=p.Character
    State.ESPCache[p.Name]=h
end
local function clearESP(p)
    local h=State.ESPCache[p.Name] if h and h.Parent then h:Destroy() end State.ESPCache[p.Name]=nil
end
local function clearAllESP()
    for _,h in pairs(State.ESPCache) do if h and h.Parent then h:Destroy() end end State.ESPCache={}
end
local function espLoop()
    while State.ESPOn do
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer then
                if p.Character then
                    addESP(p)
                    local h=State.ESPCache[p.Name]
                    if h and h.Parent then h.FillColor=State.ESPFill h.OutlineColor=State.ESPOutline end
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
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not obj:FindFirstChildOfClass("Highlight") then
                local isPlayer=false
                for _,p in ipairs(Players:GetPlayers()) do if p.Character==obj then isPlayer=true break end end
                if not isPlayer then
                    local h=Instance.new("Highlight")
                    h.FillColor=Color3.fromRGB(255,200,100) h.OutlineColor=Color3.fromRGB(255,230,150)
                    h.FillTransparency=0.4 h.OutlineTransparency=0
                    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop h.Adornee=obj h.Parent=obj
                end
            end
        end
        task.wait(3)
    end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then local h=obj:FindFirstChildOfClass("Highlight") if h then h:Destroy() end end
    end
end
local function addNameTag(p)
    if p==LocalPlayer then return end
    local char=p.Character if not char then return end
    local head=char:FindFirstChild("Head")
    if not head or head:FindFirstChild("CB_Tag") then return end
    local bb=Instance.new("BillboardGui")
    bb.Name="CB_Tag" bb.Size=UDim2.new(0,130,0,44)
    bb.StudsOffset=Vector3.new(0,3.5,0) bb.AlwaysOnTop=true bb.Parent=head
    local frame=Instance.new("Frame")
    frame.Size=UDim2.new(1,0,0.72,0) frame.BackgroundColor3=Blossom.Pink
    frame.BackgroundTransparency=0.25 frame.BorderSizePixel=0 frame.Parent=bb
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,7)
    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(1,-8,1,0) label.Position=UDim2.new(0,4,0,0)
    label.BackgroundTransparency=1 label.Text=p.Name
    label.TextColor3=Color3.fromRGB(80,30,40) label.Font=Enum.Font.GothamBold
    label.TextScaled=true label.Parent=frame
    local hbBg=Instance.new("Frame")
    hbBg.Size=UDim2.new(1,0,0.22,0) hbBg.Position=UDim2.new(0,0,0.78,0)
    hbBg.BackgroundColor3=Color3.fromRGB(180,80,100) hbBg.BorderSizePixel=0 hbBg.Parent=bb
    Instance.new("UICorner",hbBg).CornerRadius=UDim.new(0,4)
    local hbFill=Instance.new("Frame")
    hbFill.Size=UDim2.new(1,0,1,0) hbFill.BackgroundColor3=Blossom.Green
    hbFill.BorderSizePixel=0 hbFill.Parent=hbBg
    Instance.new("UICorner",hbFill).CornerRadius=UDim.new(0,4)
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then
        local function upd()
            local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
            hbFill.Size=UDim2.new(pct,0,1,0)
            hbFill.BackgroundColor3=pct>0.5 and Blossom.Green or Blossom.Red
        end
        upd() hum:GetPropertyChangedSignal("Health"):Connect(upd)
    end
end
local function clearAllTags()
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local head=p.Character:FindFirstChild("Head")
            if head then local t=head:FindFirstChild("CB_Tag") if t then t:Destroy() end end
        end
    end
end
local function nameTagLoop()
    while State.TagsOn do
        for _,p in ipairs(Players:GetPlayers()) do if p.Character then addNameTag(p) end end
        task.wait(2)
    end
    clearAllTags()
end

-- 
-- WINDOW Ui
-- 
local Window = WindUI:CreateWindow({
    Title  = "🌸 Cherry Blossom Hub",
    Folder = "BlossomUI",
    Icon   = "sparkles",
    NewElements   = true,
    HideSearchBar = false,
    OpenButton = {
        Title     = "🌸 Open Hub",
        Draggable = true,
        Scale     = 0.55,
        Color     = ColorSequence.new(Blossom.Pink, Blossom.Soft, Blossom.Light),
    },
    Topbar = {
        Height          = 44,
        ButtonsType     = "Mac",
        BackgroundColor = Blossom.Pink,
    },
})

-- 
-- KEYBIND Something
-- 
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if key == Keybinds.ToggleUI then toggleUI() end
    if key == Keybinds.Autofarm then
        State.AutofarmOn = not State.AutofarmOn
        if State.AutofarmOn then task.spawn(autofarmLoop) end
        notify("Autofarm ["..keyName(Keybinds.Autofarm).."]", State.AutofarmOn and "Started!" or "Stopped.")
    end
    if key == Keybinds.AutoHeal then
        State.AutoHealOn = not State.AutoHealOn
        cachedFruit = nil
        notify("Auto Heal ["..keyName(Keybinds.AutoHeal).."]", State.AutoHealOn and "Active!" or "Stopped.")
    end
    if key == Keybinds.Pathfind then
        State.PathOn = not State.PathOn
        if State.PathOn then
            if not State.PathTarget then State.PathOn=false notify("Pathfinding","Select a target first!") return end
            task.spawn(raycastPathfindLoop)
            notify("Pathfinding","Following: "..State.PathTarget)
        else notify("Pathfinding","Stopped.") end
    end
    if key == Keybinds.AutoPinch then
        State.AutoPinchOn = not State.AutoPinchOn
        if State.AutoPinchOn then
            if not State.PinchTarget then State.AutoPinchOn=false notify("Auto Pinch","Select a target first!") return end
            task.spawn(autoPinchLoop)
            notify("Auto Pinch","Pinching: "..State.PinchTarget)
        else notify("Auto Pinch","Stopped.") end
    end
    if key == Keybinds.KillAura then
        State.KillAuraOn = not State.KillAuraOn
        notify("Kill Aura ["..keyName(Keybinds.KillAura).."]", State.KillAuraOn and "Active!" or "Stopped.")
    end
end)

-- 
-- SECTIONS
--
local S_Main   = Window:Section({ Title = "Main"     })
local S_Farm   = Window:Section({ Title = "Farming"  })
local S_Combat = Window:Section({ Title = "Combat"   })
local S_Move   = Window:Section({ Title = "Movement" })
local S_Vis    = Window:Section({ Title = "Visuals"  })
local S_Set    = Window:Section({ Title = "Settings" })

local function getPlayerList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.Name) end
    end
    return t
end

-- 
-- HOME TAB
--
local HomeTab = S_Main:Tab({ Title = "Home", Icon = "home", IconColor = Blossom.Pink })
HomeTab:Paragraph({
    Title = "Welcome to Cherry Blossom Hub",
    Desc  = "Full featured hub for Booga Booga Reborn.\nHotkeys work even when UI is closed.",
})
HomeTab:Paragraph({
    Title = "Default Hotkeys",
    Desc  = "RightShift — Toggle UI\nF1 — Autofarm\nF2 — Auto Heal\nF3 — Pathfinding\nF4 — Auto Pinch\nF5 — Kill Aura",
})
HomeTab:Button({
    Title = "Show Notification", Icon = "sparkles", Justify = "Center",
    Callback = function() notify("Cherry Blossom Hub","Ready!",4) end,
})

-- 
-- AUTOFARM TAB
-- 
local FarmTab = S_Farm:Tab({ Title = "Autofarm", Icon = "leaf", IconColor = Blossom.Green })
FarmTab:Paragraph({ Title = "Autofarm Info", Desc = "Fires the nearest ProximityPrompt. Auto Collect uses EntityID pickup from workspace.Items." })
FarmTab:Toggle({
    Title = "Enable Autofarm", Value = false,
    Callback = function(v) State.AutofarmOn=v if v then task.spawn(autofarmLoop) end notify("Autofarm",v and"Started!"or"Stopped.") end,
})
FarmTab:Toggle({
    Title = "Auto Collect Drops", Desc = "Picks up nearby items using Packets.Pickup.", Value = false,
    Callback = function(v) State.AutoCollectOn=v if v then task.spawn(autoCollectLoop) end notify("Auto Collect",v and"On!"or"Off.") end,
})
FarmTab:Button({
    Title = "Manual Farm", Icon = "zap", Justify = "Center",
    Callback = function()
        local root = getRoot() if not root then return end
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
            notify("Manual Farm","Fired "..math.floor(bestDist).." studs away.")
        else notify("Manual Farm","No prompt found.") end
    end,
})

-- Resource Aura
FarmTab:Paragraph({ Title = "Resource Aura", Desc = "Swings at nearby resources using ByteNet EntityID swing packets." })
FarmTab:Toggle({
    Title = "Enable Resource Aura", Value = false,
    Callback = function(v) State.ResourceAuraOn=v notify("Resource Aura",v and"Active!"or"Stopped.") end,
})
FarmTab:Slider({
    Title = "Resource Range (studs)", Step = 1, Value = { Min = 1, Max = 50, Default = 20 },
    Callback = function(v) State.ResourceRange = v end,
})
FarmTab:Slider({
    Title = "Swing Cooldown (s)", Step = 0.01, Value = { Min = 0.01, Max = 1, Default = 0.1 },
    Callback = function(v) State.ResourceCooldown = v end,
})
FarmTab:Slider({
    Title = "Max Targets", Step = 1, Value = { Min = 1, Max = 10, Default = 5 },
    Callback = function(v) State.ResourceTargets = v end,
})

-- 
-- AUTO HEAL TAB
-- 
local HealTab = S_Combat:Tab({ Title = "Auto Heal", Icon = "heart", IconColor = Blossom.Red })
HealTab:Paragraph({ Title = "Auto Heal Info", Desc = "Uses Packets.UseBagItem. Hotkey: F2" })
HealTab:Dropdown({
    Title = "Heal Fruit", Values = FRUIT_LIST, Value = 1,
    Callback = function(v) State.SelectedFruit=v cachedFruit=nil notify("Auto Heal","Fruit: "..v) end,
})
HealTab:Slider({
    Title = "Heal When HP Below (%)", Step = 1, Value = { Min = 1, Max = 99, Default = 99 },
    Callback = function(v) State.HealPercent = v end,
})
HealTab:Slider({
    Title = "Heal Speed (CPS)", Step = 50, Value = { Min = 50, Max = 1000, Default = 500 },
    Callback = function(v) State.CpsSpeed = v end,
})
HealTab:Toggle({
    Title = "Enable Auto Heal", Value = false,
    Callback = function(v) State.AutoHealOn=v cachedFruit=nil notify("Auto Heal",v and"Active! Using: "..State.SelectedFruit or"Stopped.") end,
})
HealTab:Paragraph({ Title = "Fruit Guide", Desc = "Bloodfruit — 4 HP (best PvP)\nFruitcake — 4 HP + 35 food\nCooked Meat — 1 HP + 35 food\nBerry — 1.5 HP" })
HealTab:Button({
    Title = "Heal Now", Icon = "heart", Justify = "Center", Color = Blossom.Red,
    Callback = function()
        if not healHumanoid then return end
        local mainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGui") if not mainGui then return end
        local inventory = mainGui:FindFirstChild("RightPanel") and mainGui.RightPanel:FindFirstChild("Inventory") and mainGui.RightPanel.Inventory:FindFirstChild("List")
        if not inventory then return end
        local found = nil
        for _, item in ipairs(inventory:GetChildren()) do
            if item:IsA("ImageLabel") and item.Name == State.SelectedFruit then found=item break end
        end
        if found then pcall(function() Packets.UseBagItem.send(found.LayoutOrder) end) notify("Heal","Used: "..State.SelectedFruit)
        else notify("Heal",State.SelectedFruit.." not in inventory!") end
    end,
})

--
-- KILL AURA TAB
-- 
local KATab = S_Combat:Tab({ Title = "Kill Aura", Icon = "sword", IconColor = Blossom.Red })
KATab:Paragraph({ Title = "Kill Aura Info", Desc = "Swings at nearby players using ByteNet EntityID swing packets.\nDefault hotkey: F5" })
KATab:Toggle({
    Title = "Enable Kill Aura", Value = false,
    Callback = function(v) State.KillAuraOn=v notify("Kill Aura",v and"Active!"or"Stopped.") end,
})
KATab:Slider({
    Title = "Range (studs)", Step = 1, Value = { Min = 1, Max = 30, Default = 15 },
    Callback = function(v) State.KillAuraRange = v end,
})
KATab:Slider({
    Title = "Attack Cooldown (s)", Step = 0.01, Value = { Min = 0.01, Max = 1, Default = 0.1 },
    Callback = function(v) State.KillAuraCooldown = v end,
})
KATab:Slider({
    Title = "Max Targets", Step = 1, Value = { Min = 1, Max = 6, Default = 1 },
    Callback = function(v) State.KillAuraTargets = v end,
})

-- \
-- AUTO PINCH TAB
-- 
local PinchTab = S_Combat:Tab({ Title = "Auto Pinch", Icon = "zap", IconColor = Blossom.Purple })
PinchTab:Paragraph({ Title = "Auto Pinch Info", Desc = "Places two walls trapping the target using correct PlaceStructure packet format.\nHotkey: F4" })
local PinchDrop = PinchTab:Dropdown({
    Title = "Target Player", Values = getPlayerList(), AllowNone = true,
    Callback = function(v) State.PinchTarget = v end,
})
PinchTab:Button({
    Title = "Refresh Player List", Icon = "refresh-cw", Justify = "Center",
    Callback = function() PinchDrop:Refresh(getPlayerList()) notify("Auto Pinch","Refreshed.") end,
})
PinchTab:Dropdown({
    Title = "Wall Type", Values = WALL_LIST, Value = 1,
    Callback = function(v) State.PinchWall=v notify("Auto Pinch","Wall: "..v) end,
})
PinchTab:Slider({
    Title = "Wall Gap (studs)", Step = 0.5, Value = { Min = 1, Max = 6, Default = 2.5 },
    Callback = function(v) State.PinchGap = v end,
})
PinchTab:Slider({
    Title = "Re-place Interval (s)", Step = 0.1, Value = { Min = 0.1, Max = 2, Default = 0.3 },
    Callback = function(v) State.PinchInterval = v end,
})
PinchTab:Toggle({
    Title = "Enable Auto Pinch", Value = false,
    Callback = function(v)
        State.AutoPinchOn = v
        if v then
            if not State.PinchTarget then State.AutoPinchOn=false notify("Auto Pinch","Select a target first!") return end
            task.spawn(autoPinchLoop)
            notify("Auto Pinch","Pinching: "..State.PinchTarget)
        else notify("Auto Pinch","Stopped.") end
    end,
})

-- 
-- PATHFINDING TAB
-- 
local PathTab = S_Move:Tab({ Title = "Pathfinding", Icon = "navigation", IconColor = Blossom.Blue })
PathTab:Paragraph({ Title = "Raycast Pathfinding", Desc = "Steers around obstacles using raycasts. Hotkey: F3" })
local PathDrop = PathTab:Dropdown({
    Title = "Target Player", Values = getPlayerList(), AllowNone = true,
    Callback = function(v) State.PathTarget = v end,
})
PathTab:Button({
    Title = "Refresh Player List", Icon = "refresh-cw", Justify = "Center",
    Callback = function() PathDrop:Refresh(getPlayerList()) notify("Pathfinding","Refreshed.") end,
})
PathTab:Slider({
    Title = "Tick Rate (s)", Step = 0.05, Value = { Min = 0.05, Max = 1, Default = 0.3 },
    Callback = function(v) State.PathInterval = v end,
})
PathTab:Slider({
    Title = "Stop Distance (studs)", Step = 1, Value = { Min = 2, Max = 20, Default = 4 },
    Callback = function(v) State.PathStopDist = v end,
})
PathTab:Toggle({
    Title = "Enable Pathfinding", Value = false,
    Callback = function(v)
        State.PathOn = v
        if v then
            if not State.PathTarget then State.PathOn=false notify("Pathfinding","Select a target first!") return end
            task.spawn(raycastPathfindLoop)
            notify("Pathfinding","Following: "..State.PathTarget)
        else notify("Pathfinding","Stopped.") end
    end,
})
PathTab:Button({
    Title = "Teleport to Target", Icon = "zap", Justify = "Center", Color = Blossom.Blue,
    Callback = function()
        local t = State.PathTarget and Players:FindFirstChild(State.PathTarget)
        if not t then notify("Teleport","No target.") return end
        local tr = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
        local mr = getRoot()
        if tr and mr then mr.CFrame = tr.CFrame * CFrame.new(0,0,-3) notify("Teleport","Teleported to "..t.Name.."!")
        else notify("Teleport","Target not loaded.") end
    end,
})

-- 
-- SPEED TAB
-- 
local SpeedTab = S_Move:Tab({ Title = "Speed", Icon = "wind", IconColor = Blossom.Yellow })
SpeedTab:Slider({
    Title = "Walk Speed", Desc = "Default: 16 / Max: 21", Step = 1,
    Value = { Min = 1, Max = 21, Default = 16 },
    Callback = function(v) State.Speed=v local h=getHum() if h then h.WalkSpeed=v end end,
})
SpeedTab:Slider({
    Title = "Jump Power", Desc = "Default: 50", Step = 1,
    Value = { Min = 1, Max = 200, Default = 50 },
    Callback = function(v) State.Jump=v local h=getHum() if h then h.JumpPower=v end end,
})
SpeedTab:Toggle({
    Title = "Speed Lock", Desc = "Re-applies speed after every respawn.", Value = false,
    Callback = function(v) State.SpeedLock=v notify("Speed Lock",v and"Active."or"Disabled.") end,
})
local PG = SpeedTab:Group({})
PG:Button({ Title="Default", Justify="Center", Icon="",
    Callback=function() State.Speed=16 State.Jump=50 applySpeed() notify("Speed","Reset.") end })
PG:Space()
PG:Button({ Title="Max (21)", Color=Blossom.Green, Justify="Center", Icon="",
    Callback=function() State.Speed=21 local h=getHum() if h then h.WalkSpeed=21 end notify("Speed","21.") end })
PG:Space()
PG:Button({ Title="High Jump", Color=Blossom.Blue, Justify="Center", Icon="",
    Callback=function() State.Jump=120 local h=getHum() if h then h.JumpPower=120 end notify("Speed","Jump 120.") end })
SpeedTab:Button({
    Title="Reset All", Icon="refresh-cw", Color=Blossom.Red, Justify="Center",
    Callback=function() State.Speed=16 State.Jump=50 applySpeed() notify("Speed","All reset.") end,
})

--
-- ESP TAB
-- 
local EspTab = S_Vis:Tab({ Title = "ESP", Icon = "eye", IconColor = Blossom.Pink })
EspTab:Toggle({
    Title = "Player ESP", Desc = "Highlights players through walls.", Value = false,
    Callback = function(v) State.ESPOn=v if v then task.spawn(espLoop) else clearAllESP() end notify("ESP",v and"On!"or"Off.") end,
})
EspTab:Colorpicker({
    Title = "Fill Color", Default = State.ESPFill,
    Callback = function(c) State.ESPFill=c for _,h in pairs(State.ESPCache) do if h and h.Parent then h.FillColor=c end end end,
})
EspTab:Colorpicker({
    Title = "Outline Color", Default = State.ESPOutline,
    Callback = function(c) State.ESPOutline=c for _,h in pairs(State.ESPCache) do if h and h.Parent then h.OutlineColor=c end end end,
})
EspTab:Toggle({
    Title = "Mob ESP", Value = false,
    Callback = function(v) State.MobESPOn=v if v then task.spawn(mobEspLoop) end notify("Mob ESP",v and"On!"or"Off.") end,
})
EspTab:Toggle({
    Title = "Name Tags", Desc = "Shows name and health bar above players.", Value = false,
    Callback = function(v) State.TagsOn=v if v then task.spawn(nameTagLoop) else clearAllTags() end notify("Name Tags",v and"On!"or"Off.") end,
})
EspTab:Toggle({
    Title = "Chams", Desc = "Makes enemy parts 40% transparent.", Value = false,
    Callback = function(v)
        State.ChamsOn=v
        task.spawn(function()
            while State.ChamsOn do
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LocalPlayer and p.Character then
                        for _,part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
                                part.LocalTransparencyModifier=0.4
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LocalPlayer and p.Character then
                    for _,part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.LocalTransparencyModifier=0 end
                    end
                end
            end
        end)
        notify("Chams",v and"On!"or"Off.")
    end,
})
EspTab:Button({
    Title="Clear All Visuals", Icon="trash", Color=Blossom.Red, Justify="Center",
    Callback=function()
        State.ESPOn=false State.MobESPOn=false State.TagsOn=false State.ChamsOn=false
        clearAllESP() clearAllTags()
        for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Highlight") then pcall(function() obj:Destroy() end) end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer and p.Character then
                for _,part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.LocalTransparencyModifier=0 end
                end
            end
        end
        notify("Visuals","All cleared.")
    end,
})

-- 
-- SETTINGS TAB
-- 
local SetTab = S_Set:Tab({ Title = "Settings", Icon = "settings", IconColor = Blossom.Soft })
SetTab:Paragraph({ Title = "Keybinds", Desc = "Click a box then press any key. Works when UI is closed." })
SetTab:Keybind({
    Title = "Toggle UI", Desc = "Default: RightShift", Value = "RightShift",
    Callback = function(v) local kc=toKeyCode(v) if kc then Keybinds.ToggleUI=kc notify("Keybind","Toggle UI: "..v) end end,
})
SetTab:Keybind({
    Title = "Autofarm", Desc = "Default: F1", Value = "F1",
    Callback = function(v) local kc=toKeyCode(v) if kc then Keybinds.Autofarm=kc notify("Keybind","Autofarm: "..v) end end,
})
SetTab:Keybind({
    Title = "Auto Heal", Desc = "Default: F2", Value = "F2",
    Callback = function(v) local kc=toKeyCode(v) if kc then Keybinds.AutoHeal=kc notify("Keybind","Auto Heal: "..v) end end,
})
SetTab:Keybind({
    Title = "Pathfinding", Desc = "Default: F3", Value = "F3",
    Callback = function(v) local kc=toKeyCode(v) if kc then Keybinds.Pathfind=kc notify("Keybind","Pathfinding: "..v) end end,
})
SetTab:Keybind({
    Title = "Auto Pinch", Desc = "Default: F4", Value = "F4",
    Callback = function(v) local kc=toKeyCode(v) if kc then Keybinds.AutoPinch=kc notify("Keybind","Auto Pinch: "..v) end end,
})
SetTab:Keybind({
    Title = "Kill Aura", Desc = "Default: F5", Value = "F5",
    Callback = function(v) local kc=toKeyCode(v) if kc then Keybinds.KillAura=kc notify("Keybind","Kill Aura: "..v) end end,
})
SetTab:Button({
    Title = "Credits", Icon = "heart", Justify = "Center",
    Callback = function() notify("Credits","Cherry Blossom Hub\nUI: WindUI\nPackets research: Herkle Hub",5) end,
})
SetTab:Button({
    Title = "Close UI", Icon = "x", Color = Blossom.Red, Justify = "Center",
    Callback = function() Window:Destroy() end,
})

print("[CherryHub] All tabs loaded! Ready.")
