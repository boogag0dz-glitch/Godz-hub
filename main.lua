-- ============================================================
-- 🌸 Cherry Blossom Hub | Booga Booga Reborn
-- ============================================================

local WindUI
local ok, err = pcall(function()
    WindUI = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    ))()
end)
if not ok or not WindUI then warn("[CherryHub] WindUI failed: " .. tostring(err)) return end
print("[CherryHub] WindUI loaded!")

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local LocalPlayer       = Players.LocalPlayer
local Packets           = require(ReplicatedStorage.Modules.Packets)

-- ============================================================
-- DEBUG: print all Packets keys so we know exact names
-- ============================================================
task.spawn(function()
    task.wait(2)
    print("[CherryHub] Available Packets:")
    for k, _ in pairs(Packets) do
        print("  ->", k)
    end
end)

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

-- ============================================================
-- KEYBINDS
-- ============================================================
local Keybinds = {
    ToggleUI  = Enum.KeyCode.RightShift,
    Autofarm  = Enum.KeyCode.F1,
    AutoHeal  = Enum.KeyCode.F2,
    Pathfind  = Enum.KeyCode.F3,
    AutoChest = Enum.KeyCode.F4,
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
    AutoHealOn        = false,
    HealPercent       = 99,
    CpsSpeed          = 500,
    SelectedFruit     = "Bloodfruit",
    AutofarmOn        = false,
    AutoCollectOn     = false,
    PathOn            = false,
    PathTarget        = nil,
    PathInterval      = 0.3,
    PathStopDist      = 4,
    SpeedLock         = false,
    Speed             = 16,
    Jump              = 50,
    ESPOn             = false,
    MobESPOn          = false,
    TagsOn            = false,
    ChamsOn           = false,
    ESPFill           = Color3.fromRGB(255, 150, 170),
    ESPOutline        = Color3.fromRGB(255, 255, 255),
    ESPCache          = {},
    -- Auto Chest
    AutoChestOn       = false,
    ChestType         = "Chest",        -- "Chest" or "Reinforced Chest"
    ChestRange        = 40,
    ChestFallSpeed    = -10,
    ChestCooldowns    = {},
    ChestCooldownTime = 3,
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
-- AUTO CHEST TRAP CORE
-- ============================================================
--[[
    TRAJECTORY PREDICTION:
    Uses projectile motion physics to predict exactly where
    the player will land.

    Physics equations:
        X(t) = X0 + Vx * t
        Z(t) = Z0 + Vz * t
        Y(t) = Y0 + Vy * t - 0.5 * g * t^2

    We solve for t when Y(t) = groundY (the floor height):
        groundY = Y0 + Vy*t - 0.5*g*t^2
        0 = -0.5*g*t^2 + Vy*t + (Y0 - groundY)
        quadratic: a=-0.5g, b=Vy, c=Y0-groundY

    Then plug t back into X and Z to get landing coordinates.
    We find groundY by raycasting straight down from the player.
--]]

local GRAVITY = workspace.Gravity  -- usually 196.2 in Roblox

local chestRayParams = RaycastParams.new()
chestRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function getGroundY(root)
    local exclude = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then table.insert(exclude, p.Character) end
    end
    chestRayParams.FilterDescendantsInstances = exclude
    local result = workspace:Raycast(
        root.Position,
        Vector3.new(0, -500, 0),
        chestRayParams
    )
    if result then return result.Position.Y end
    return nil
end

local function predictLanding(root)
    local pos = root.Position
    local vel = root.AssemblyLinearVelocity

    local x0, y0, z0 = pos.X, pos.Y, pos.Z
    local vx, vy, vz = vel.X, vel.Y, vel.Z

    local groundY = getGroundY(root)
    if not groundY then return nil end

    -- Solve quadratic for time of landing
    -- 0 = -0.5*g*t^2 + vy*t + (y0 - groundY)
    local a = -0.5 * GRAVITY
    local b = vy
    local c = y0 - groundY

    local discriminant = b * b - 4 * a * c
    if discriminant < 0 then return nil end  -- no real solution

    local sqrtD = math.sqrt(discriminant)
    local t1 = (-b + sqrtD) / (2 * a)
    local t2 = (-b - sqrtD) / (2 * a)

    -- We want the positive time (future landing)
    local t = nil
    if t1 > 0 and t2 > 0 then
        t = math.min(t1, t2)
    elseif t1 > 0 then
        t = t1
    elseif t2 > 0 then
        t = t2
    end

    if not t then return nil end

    -- Predicted landing position
    local landX = x0 + vx * t
    local landZ = z0 + vz * t
    local landY = groundY  -- they land exactly on the ground

    return Vector3.new(landX, landY, landZ), t
end

local function placeChest(position)
    -- Try every likely packet name Booga Booga uses
    -- The debug print above will show exact names in console
    local chestName = State.ChestType

    local tried = {}

    -- Attempt 1: PlaceItem with name
    local ok1 = pcall(function()
        Packets.PlaceItem.send({
            Name     = chestName,
            Position = position,
        })
    end)
    table.insert(tried, "PlaceItem(Name=" .. chestName .. "): " .. tostring(ok1))

    -- Attempt 2: PlaceItem with ItemName
    local ok2 = pcall(function()
        Packets.PlaceItem.send({
            ItemName = chestName,
            Position = position,
        })
    end)
    table.insert(tried, "PlaceItem(ItemName): " .. tostring(ok2))

    -- Attempt 3: PlaceObject
    local ok3 = pcall(function()
        Packets.PlaceObject.send({
            Name     = chestName,
            Position = position,
        })
    end)
    table.insert(tried, "PlaceObject: " .. tostring(ok3))

    -- Attempt 4: BuildItem
    local ok4 = pcall(function()
        Packets.BuildItem.send({
            Name     = chestName,
            Position = position,
        })
    end)
    table.insert(tried, "BuildItem: " .. tostring(ok4))

    -- Attempt 5: SpawnItem
    local ok5 = pcall(function()
        Packets.SpawnItem.send({
            Name     = chestName,
            Position = position,
        })
    end)
    table.insert(tried, "SpawnItem: " .. tostring(ok5))

    -- Attempt 6: UseItem (some games place via use)
    local ok6 = pcall(function()
        Packets.UseItem.send({
            Name     = chestName,
            Position = position,
            CFrame   = CFrame.new(position),
        })
    end)
    table.insert(tried, "UseItem: " .. tostring(ok6))

    -- Log what worked for debugging
    print("[CherryHub] Chest placement attempts:")
    for _, v in ipairs(tried) do print("  " .. v) end
end

local function autoChestLoop()
    while State.AutoChestOn do
        local myRoot = getRoot()
        if myRoot then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum  = p.Character:FindFirstChildOfClass("Humanoid")
                    if root and hum then
                        local dist = (myRoot.Position - root.Position).Magnitude
                        if dist <= State.ChestRange then
                            local vel       = root.AssemblyLinearVelocity
                            local isFalling = hum.FloorMaterial == Enum.Material.Air
                                and vel.Y <= State.ChestFallSpeed

                            local now       = tick()
                            local lastTime  = State.ChestCooldowns[p.Name] or 0
                            local offCooldown = (now - lastTime) >= State.ChestCooldownTime

                            if isFalling and offCooldown then
                                -- Predict landing position using trajectory math
                                local landPos, timeToLand = predictLanding(root)

                                if landPos and timeToLand then
                                    print(string.format(
                                        "[CherryHub] Predicting chest for %s | land=(%.1f, %.1f, %.1f) in %.2fs",
                                        p.Name, landPos.X, landPos.Y, landPos.Z, timeToLand
                                    ))

                                    -- Place the chest at predicted landing spot
                                    placeChest(landPos)
                                    State.ChestCooldowns[p.Name] = now

                                    notify("📦 Auto Chest",
                                        string.format("Trapping %s! Landing in %.1fs", p.Name, timeToLand))
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.05)
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

-- ============================================================
-- AUTOFARM CORE
-- ============================================================
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
local RAY_DIST=20 local PROBE_ANGLE=45 local STEP_HEIGHT=3.5 local PROBE_COUNT=7
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
-- ESP CORE
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
    local h=State.ESPCache[p.Name]
    if h and h.Parent then h:Destroy() end
    State.ESPCache[p.Name]=nil
end
local function clearAllESP()
    for _,h in pairs(State.ESPCache) do if h and h.Parent then h:Destroy() end end
    State.ESPCache={}
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
                    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    h.Adornee=obj h.Parent=obj
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
        upd()
        hum:GetPropertyChangedSignal("Health"):Connect(upd)
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

-- ============================================================
-- WINDOW
-- ============================================================
local Window = WindUI:CreateWindow({
    Title="🌸 Cherry Blossom Hub", Folder="BlossomHub", Icon="sparkles",
    NewElements=true, HideSearchBar=false,
    OpenButton={ Title="🌸 Open Hub", Draggable=true, Scale=0.55,
        Color=ColorSequence.new(Blossom.Pink,Blossom.Soft,Blossom.Light) },
    Topbar={ Height=44, ButtonsType="Mac" },
})
Window:Tag({ Title="Booga Booga Reborn", Color=Blossom.Pink, Border=true })
print("[CherryHub] Window created!")

-- ============================================================
-- KEYBIND LISTENER
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode
    if key == Keybinds.ToggleUI   then pcall(function() Window:Toggle() end) end
    if key == Keybinds.Autofarm   then
        State.AutofarmOn = not State.AutofarmOn
        if State.AutofarmOn then task.spawn(autofarmLoop) end
        notify("🌾 Autofarm ["..keyName(Keybinds.Autofarm).."]", State.AutofarmOn and "Started!" or "Stopped.")
    end
    if key == Keybinds.AutoHeal   then
        State.AutoHealOn = not State.AutoHealOn
        cachedFruit = nil
        notify("🍎 Auto Heal ["..keyName(Keybinds.AutoHeal).."]", State.AutoHealOn and "Active! Using: "..State.SelectedFruit or "Stopped.")
    end
    if key == Keybinds.Pathfind   then
        State.PathOn = not State.PathOn
        if State.PathOn then
            if not State.PathTarget then State.PathOn=false notify("🏃 Pathfinding","Select a target first!") return end
            task.spawn(raycastPathfindLoop)
            notify("🏃 Pathfinding","Following: "..State.PathTarget)
        else notify("🏃 Pathfinding","Stopped.") end
    end
    if key == Keybinds.AutoChest  then
        State.AutoChestOn = not State.AutoChestOn
        if State.AutoChestOn then State.ChestCooldowns={} task.spawn(autoChestLoop) end
        notify("📦 Auto Chest ["..keyName(Keybinds.AutoChest).."]", State.AutoChestOn and "Active!" or "Stopped.")
    end
end)

-- ============================================================
-- SECTIONS
-- ============================================================
local S_Main = Window:Section({ Title="🌸 Main"     })
local S_Farm = Window:Section({ Title="🌾 Farming"  })
local S_PvP  = Window:Section({ Title="⚔️ PvP"      })
local S_Move = Window:Section({ Title="🏃 Movement" })
local S_Vis  = Window:Section({ Title="👁️ Visuals"  })
local S_Set  = Window:Section({ Title="⚙️ Settings" })

-- HOME
local HomeTab = S_Main:Tab({ Title="Home", Icon="home", IconColor=Blossom.Pink })
HomeTab:Paragraph({ Title="🌸 Welcome!", Desc="Cherry Blossom Hub for Booga Booga Reborn.\nHotkeys work even when UI is closed." })
HomeTab:Space()
HomeTab:Paragraph({ Title="Default Hotkeys", Desc="RightShift — Toggle UI\nF1 — Autofarm\nF2 — Auto Heal\nF3 — Pathfinding\nF4 — Auto Chest\n\nChange all in ⚙️ Settings." })
HomeTab:Space()
HomeTab:Button({ Title="Welcome Notification", Icon="sparkles", Justify="Center",
    Callback=function() notify("🌸 Cherry Blossom Hub","Ready!",4) end })

-- AUTOFARM
local FarmTab = S_Farm:Tab({ Title="Autofarm", Icon="leaf", IconColor=Blossom.Green })
FarmTab:Toggle({ Title="Enable Autofarm", Value=false,
    Callback=function(v) State.AutofarmOn=v if v then task.spawn(autofarmLoop) end notify("🌾 Autofarm",v and"Started!"or"Stopped.") end })
FarmTab:Space()
FarmTab:Toggle({ Title="Auto Collect Drops", Value=false,
    Callback=function(v) State.AutoCollectOn=v if v then task.spawn(autoCollectLoop) end notify("🌾 Collect",v and"On!"or"Off.") end })
FarmTab:Space()
FarmTab:Button({ Title="Manual Farm", Icon="zap", Justify="Center",
    Callback=function()
        local root=getRoot() if not root then return end
        local best,bestDist,bestPrompt=nil,math.huge,nil
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local part=obj.Parent
                if part and part:IsA("BasePart") then
                    local d=(root.Position-part.Position).Magnitude
                    if d<bestDist then best=part bestDist=d bestPrompt=obj end
                end
            end
        end
        if bestPrompt then pcall(function() fireproximityprompt(bestPrompt) end) notify("🌾 Farm","Fired "..math.floor(bestDist).." studs away.")
        else notify("🌾 Farm","No prompt found.") end
    end })

-- AUTO HEAL
local HealTab = S_Farm:Tab({ Title="Auto Heal", Icon="heart", IconColor=Blossom.Red })
HealTab:Dropdown({ Title="Heal Fruit", Values=FRUIT_LIST, Value=1,
    Callback=function(v) State.SelectedFruit=v cachedFruit=nil notify("🍎","Fruit: "..v) end })
HealTab:Space()
HealTab:Slider({ Title="Heal When HP Below (%)", Step=1, Value={Min=1,Max=99,Default=99},
    Callback=function(v) State.HealPercent=v end })
HealTab:Space()
HealTab:Slider({ Title="Heal Speed (CPS)", Step=50, Value={Min=50,Max=1000,Default=500},
    Callback=function(v) State.CpsSpeed=v end })
HealTab:Space()
HealTab:Toggle({ Title="Enable Auto Heal", Value=false,
    Callback=function(v) State.AutoHealOn=v cachedFruit=nil notify("🍎",v and"Active! Using: "..State.SelectedFruit or"Stopped.") end })
HealTab:Space()
HealTab:Button({ Title="Heal Now", Icon="heart", Justify="Center", Color=Blossom.Red,
    Callback=function()
        if not healHumanoid then return end
        local mainGui=LocalPlayer.PlayerGui:FindFirstChild("MainGui") if not mainGui then return end
        local inventory=mainGui:FindFirstChild("RightPanel") and mainGui.RightPanel:FindFirstChild("Inventory") and mainGui.RightPanel.Inventory:FindFirstChild("List")
        if not inventory then return end
        local found=nil
        for _,item in ipairs(inventory:GetChildren()) do
            if item:IsA("ImageLabel") and item.Name==State.SelectedFruit then found=item break end
        end
        if found then pcall(function() Packets.UseBagItem.send(found.LayoutOrder) end) notify("🍎","Used: "..State.SelectedFruit)
        else notify("🍎",State.SelectedFruit.." not in inventory!") end
    end })

-- ============================================================
-- AUTO CHEST TAB
-- ============================================================
local ChestTab = S_PvP:Tab({ Title="Auto Chest", Icon="box", IconColor=Blossom.Yellow })

ChestTab:Paragraph({
    Title = "📦 Auto Chest Trap",
    Desc  = "Uses real projectile physics to predict exactly where a falling player will land (X, Y, Z), then places a chest there before they touch the ground.\n\nHotkey: F4",
})
ChestTab:Space()

-- Chest type selector
ChestTab:Dropdown({
    Title = "Chest Type",
    Desc  = "Which chest to place under them.",
    Values = { "Chest", "Reinforced Chest" },
    Value  = 1,
    Callback = function(v)
        State.ChestType = v
        notify("📦 Chest Type", "Using: " .. v)
    end,
})
ChestTab:Space()

ChestTab:Toggle({
    Title = "Enable Auto Chest",
    Desc  = "Predicts landing position and places chosen chest under falling players.",
    Value = false,
    Callback = function(v)
        State.AutoChestOn = v
        if v then State.ChestCooldowns={} task.spawn(autoChestLoop) end
        notify("📦 Auto Chest", v and "Active! Using: "..State.ChestType or "Stopped.")
    end,
})
ChestTab:Space()

ChestTab:Slider({
    Title = "Detection Range (studs)",
    Desc  = "How far away to watch for falling players.",
    Step=5, Value={Min=10,Max=100,Default=40},
    Callback=function(v) State.ChestRange=v end,
})
ChestTab:Space()

ChestTab:Slider({
    Title = "Fall Speed Trigger",
    Desc  = "How fast they must be falling (Y velocity). Default -10.\nMore negative = only triggers on very fast falls.",
    Step=1, Value={Min=-50,Max=-1,Default=-10},
    Callback=function(v) State.ChestFallSpeed=v end,
})
ChestTab:Space()

ChestTab:Slider({
    Title = "Cooldown Per Player (s)",
    Desc  = "Seconds before the same player can be chested again.",
    Step=0.5, Value={Min=0.5,Max=10,Default=3},
    Callback=function(v) State.ChestCooldownTime=v end,
})
ChestTab:Space()

ChestTab:Button({
    Title="Reset Cooldowns", Icon="refresh-cw", Justify="Center",
    Callback=function() State.ChestCooldowns={} notify("📦","Cooldowns reset.") end,
})
ChestTab:Space()

ChestTab:Paragraph({
    Title = "How Prediction Works",
    Desc  = "Solves the projectile equation:\nY(t) = Y₀ + Vy·t − ½·g·t²\nFinds t when Y = ground level (via raycast)\nThen: LandX = X₀ + Vx·t\n      LandZ = Z₀ + Vz·t\nPlaces chest at (LandX, groundY, LandZ).\n\nCheck executor console for placement debug info.",
})

-- PATHFINDING
local PathTab = S_Move:Tab({ Title="Pathfinding", Icon="navigation", IconColor=Blossom.Blue })
PathTab:Paragraph({ Title="Raycast Pathfinding", Desc="7 angle probes, jumps obstacles, backs up if stuck." })
PathTab:Space()
local function getPlayerList()
    local t={} for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(t,p.Name) end end return t
end
local PathDrop=PathTab:Dropdown({ Title="Target Player", AllowNone=true, Values=getPlayerList(), Callback=function(v) State.PathTarget=v end })
PathTab:Space()
PathTab:Button({ Title="Refresh", Icon="refresh-cw", Justify="Center", Callback=function() PathDrop:Refresh(getPlayerList()) end })
PathTab:Space()
PathTab:Slider({ Title="Tick Rate (s)", Step=0.05, Value={Min=0.05,Max=1,Default=0.3}, Callback=function(v) State.PathInterval=v end })
PathTab:Space()
PathTab:Slider({ Title="Stop Distance (studs)", Step=1, Value={Min=2,Max=20,Default=4}, Callback=function(v) State.PathStopDist=v end })
PathTab:Space()
PathTab:Toggle({ Title="Enable Pathfinding", Value=false,
    Callback=function(v)
        State.PathOn=v
        if v then
            if not State.PathTarget then State.PathOn=false notify("Pathfinding","Select a target first!") return end
            task.spawn(raycastPathfindLoop) notify("🏃","Following: "..State.PathTarget)
        else notify("🏃","Stopped.") end
    end })
PathTab:Space()
PathTab:Button({ Title="Teleport to Target", Icon="zap", Justify="Center", Color=Blossom.Blue,
    Callback=function()
        local t=State.PathTarget and Players:FindFirstChild(State.PathTarget) if not t then return end
        local tr=t.Character and t.Character:FindFirstChild("HumanoidRootPart") local mr=getRoot()
        if tr and mr then mr.CFrame=tr.CFrame*CFrame.new(0,0,-3) notify("🌸","Teleported to "..t.Name.."!") end
    end })

-- SPEED
local SpeedTab=S_Move:Tab({ Title="Speed", Icon="wind", IconColor=Blossom.Yellow })
SpeedTab:Slider({ Title="Walk Speed", Desc="Max: 21", Step=1, Value={Min=1,Max=21,Default=16},
    Callback=function(v) State.Speed=v local h=getHum() if h then h.WalkSpeed=v end end })
SpeedTab:Space()
SpeedTab:Slider({ Title="Jump Power", Step=1, Value={Min=1,Max=200,Default=50},
    Callback=function(v) State.Jump=v local h=getHum() if h then h.JumpPower=v end end })
SpeedTab:Space()
SpeedTab:Toggle({ Title="Speed Lock", Value=false, Callback=function(v) State.SpeedLock=v end })
SpeedTab:Space()
local PG=SpeedTab:Group({})
PG:Button({ Title="Default", Justify="Center", Icon="", Callback=function() State.Speed=16 State.Jump=50 applySpeed() end })
PG:Space()
PG:Button({ Title="Max (21)", Color=Blossom.Green, Justify="Center", Icon="", Callback=function() State.Speed=21 local h=getHum() if h then h.WalkSpeed=21 end end })
PG:Space()
PG:Button({ Title="High Jump", Color=Blossom.Blue, Justify="Center", Icon="", Callback=function() State.Jump=120 local h=getHum() if h then h.JumpPower=120 end end })

-- ESP
local EspTab=S_Vis:Tab({ Title="ESP", Icon="eye", IconColor=Blossom.Pink })
EspTab:Toggle({ Title="Player ESP", Value=false, Callback=function(v) State.ESPOn=v if v then task.spawn(espLoop) else clearAllESP() end end })
EspTab:Space()
EspTab:Colorpicker({ Title="Fill Color", Default=State.ESPFill, Callback=function(c) State.ESPFill=c for _,h in pairs(State.ESPCache) do if h and h.Parent then h.FillColor=c end end end })
EspTab:Space()
EspTab:Colorpicker({ Title="Outline Color", Default=State.ESPOutline, Callback=function(c) State.ESPOutline=c for _,h in pairs(State.ESPCache) do if h and h.Parent then h.OutlineColor=c end end end })
EspTab:Space()
EspTab:Toggle({ Title="Mob ESP", Value=false, Callback=function(v) State.MobESPOn=v if v then task.spawn(mobEspLoop) end end })
EspTab:Space()
EspTab:Toggle({ Title="Name Tags", Value=false, Callback=function(v) State.TagsOn=v if v then task.spawn(nameTagLoop) else clearAllTags() end end })
EspTab:Space()
EspTab:Toggle({ Title="Chams", Value=false,
    Callback=function(v)
        State.ChamsOn=v
        task.spawn(function()
            while State.ChamsOn do
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LocalPlayer and p.Character then
                        for _,part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then part.LocalTransparencyModifier=0.4 end
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
    end })
EspTab:Space()
EspTab:Button({ Title="Clear All Visuals", Icon="trash", Color=Blossom.Red, Justify="Center",
    Callback=function()
        State.ESPOn=false State.MobESPOn=false State.TagsOn=false State.ChamsOn=false
        clearAllESP() clearAllTags()
        for _,obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Highlight") then pcall(function() obj:Destroy() end) end end
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") then part.LocalTransparencyModifier=0 end end end end
    end })

-- SETTINGS
local SetTab=S_Set:Tab({ Title="Settings", Icon="settings", IconColor=Blossom.Soft })
SetTab:Section({ Title="⌨️ Keybinds" })
SetTab:Paragraph({ Title="How to change", Desc="Click box → press any key. Works when UI is closed." })
SetTab:Space()
SetTab:Keybind({ Title="Toggle UI", Desc="Default: RightShift", Value="RightShift",
    Callback=function(v) local kc=toKeyCode(v) if kc then Keybinds.ToggleUI=kc notify("⌨️","Toggle UI → "..v) end end })
SetTab:Space()
SetTab:Keybind({ Title="Autofarm", Desc="Default: F1", Value="F1",
    Callback=function(v) local kc=toKeyCode(v) if kc then Keybinds.Autofarm=kc notify("⌨️","Autofarm → "..v) end end })
SetTab:Space()
SetTab:Keybind({ Title="Auto Heal", Desc="Default: F2", Value="F2",
    Callback=function(v) local kc=toKeyCode(v) if kc then Keybinds.AutoHeal=kc notify("⌨️","Auto Heal → "..v) end end })
SetTab:Space()
SetTab:Keybind({ Title="Pathfinding", Desc="Default: F3", Value="F3",
    Callback=function(v) local kc=toKeyCode(v) if kc then Keybinds.Pathfind=kc notify("⌨️","Pathfinding → "..v) end end })
SetTab:Space()
SetTab:Keybind({ Title="Auto Chest", Desc="Default: F4", Value="F4",
    Callback=function(v) local kc=toKeyCode(v) if kc then Keybinds.AutoChest=kc notify("⌨️","Auto Chest → "..v) end end })
SetTab:Space()
SetTab:Section({ Title="🌸 About" })
SetTab:Button({ Title="Credits", Icon="heart", Justify="Center",
    Callback=function() notify("🌸 Credits","Cherry Blossom Hub\nUI: WindUI\nHeal: Packets.UseBagItem\nPathfinding: Custom Raycast\nChest: Trajectory Prediction",5) end })
SetTab:Space()
SetTab:Button({ Title="Close UI", Icon="x", Color=Blossom.Red, Justify="Center",
    Callback=function() Window:Destroy() end })

print("[CherryHub] All tabs loaded! Ready.")
